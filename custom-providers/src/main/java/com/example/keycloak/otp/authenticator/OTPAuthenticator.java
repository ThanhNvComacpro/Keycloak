package com.example.keycloak.otp.authenticator;

import com.example.keycloak.otp.service.EmailOTPService;
import com.example.keycloak.otp.service.SMSOTPService;
import com.example.keycloak.otp.service.impl.EmailOTPServiceImpl;
import com.example.keycloak.otp.service.impl.SMSOTPServiceImpl;
import com.example.keycloak.otp.utils.OTPUtils;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.AuthenticationFlowError;
import org.keycloak.authentication.Authenticator;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.sessions.AuthenticationSessionModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.ws.rs.core.MultivaluedMap;
import jakarta.ws.rs.core.Response;

/**
 * Custom authenticator for OTP login with email/phone support
 */
public class OTPAuthenticator implements Authenticator {
    
    private static final Logger logger = LoggerFactory.getLogger(OTPAuthenticator.class);
    
    private static final String SEND_OTP_ACTION = "send-otp";
    private static final String VERIFY_OTP_ACTION = "verify-otp";
    
    // Session attributes
    private static final String OTP_CODE_ATTR = "otp_code";
    private static final String OTP_CONTACT_ATTR = "otp_contact";
    private static final String OTP_TYPE_ATTR = "otp_type";
    private static final String OTP_TIMESTAMP_ATTR = "otp_timestamp";
    private static final String OTP_ATTEMPTS_ATTR = "otp_attempts";
    
    // Configuration
    private static final int OTP_VALIDITY_MINUTES = 5;
    private static final int MAX_OTP_ATTEMPTS = 3;
    
    private final EmailOTPService emailService;
    private final SMSOTPService smsService;
    
    public OTPAuthenticator() {
        this.emailService = new EmailOTPServiceImpl();
        this.smsService = new SMSOTPServiceImpl();
    }
    
    @Override
    public void authenticate(AuthenticationFlowContext context) {
        // Show the initial form to collect email/phone
        Response response = createOTPForm(context, null);
        context.challenge(response);
    }
    
    @Override
    public void action(AuthenticationFlowContext context) {
        MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
        String action = formData.getFirst("action");
        
        if (SEND_OTP_ACTION.equals(action)) {
            handleSendOTP(context, formData);
        } else if (VERIFY_OTP_ACTION.equals(action)) {
            handleVerifyOTP(context, formData);
        } else {
            logger.warn("Unknown action: {}", action);
            context.failure(AuthenticationFlowError.INTERNAL_ERROR);
        }
    }
    
    private void handleSendOTP(AuthenticationFlowContext context, MultivaluedMap<String, String> formData) {
        String contact = formData.getFirst("contact");
        
        if (contact == null || contact.trim().isEmpty()) {
            Response response = createOTPForm(context, "missing_contact");
            context.challenge(response);
            return;
        }
        
        contact = contact.trim();
        String otpType;
        
        if (OTPUtils.isEmail(contact)) {
            otpType = "email";
        } else if (OTPUtils.isPhoneNumber(contact)) {
            otpType = "phone";
            contact = OTPUtils.normalizePhoneNumber(contact);
        } else {
            Response response = createOTPForm(context, "invalid_contact");
            context.challenge(response);
            return;
        }
        
        // Generate OTP
        String otp = OTPUtils.generateOTP();
        String language = getLanguage(context);
        
        boolean sent = false;
        if ("email".equals(otpType)) {
            sent = emailService.sendOTP(contact, otp, language);
        } else if ("phone".equals(otpType)) {
            sent = smsService.sendOTP(contact, otp, language);
        }
        
        if (sent) {
            // Store OTP data in session
            AuthenticationSessionModel authSession = context.getAuthenticationSession();
            authSession.setAuthNote(OTP_CODE_ATTR, otp);
            authSession.setAuthNote(OTP_CONTACT_ATTR, contact);
            authSession.setAuthNote(OTP_TYPE_ATTR, otpType);
            authSession.setAuthNote(OTP_TIMESTAMP_ATTR, String.valueOf(System.currentTimeMillis()));
            authSession.setAuthNote(OTP_ATTEMPTS_ATTR, "0");
            
            // Show verification form
            Response response = createVerificationForm(context, contact, otpType, null);
            context.challenge(response);
        } else {
            String errorKey = "email".equals(otpType) ? "email_send_failed" : "sms_send_failed";
            Response response = createOTPForm(context, errorKey);
            context.challenge(response);
        }
    }
    
    private void handleVerifyOTP(AuthenticationFlowContext context, MultivaluedMap<String, String> formData) {
        String enteredOTP = formData.getFirst("otp");
        
        if (enteredOTP == null || enteredOTP.trim().isEmpty()) {
            String contact = getStoredContact(context);
            String otpType = getStoredOTPType(context);
            Response response = createVerificationForm(context, contact, otpType, "missing_otp");
            context.challenge(response);
            return;
        }
        
        AuthenticationSessionModel authSession = context.getAuthenticationSession();
        String storedOTP = authSession.getAuthNote(OTP_CODE_ATTR);
        String contact = authSession.getAuthNote(OTP_CONTACT_ATTR);
        String otpType = authSession.getAuthNote(OTP_TYPE_ATTR);
        String timestampStr = authSession.getAuthNote(OTP_TIMESTAMP_ATTR);
        String attemptsStr = authSession.getAuthNote(OTP_ATTEMPTS_ATTR);
        
        if (storedOTP == null || contact == null || timestampStr == null) {
            logger.warn("OTP session data is missing");
            context.failure(AuthenticationFlowError.INTERNAL_ERROR);
            return;
        }
        
        // Check OTP validity (time-based)
        long timestamp = Long.parseLong(timestampStr);
        long currentTime = System.currentTimeMillis();
        long validityMs = OTP_VALIDITY_MINUTES * 60 * 1000;
        
        if (currentTime - timestamp > validityMs) {
            clearOTPSession(authSession);
            Response response = createOTPForm(context, "otp_expired");
            context.challenge(response);
            return;
        }
        
        // Check attempts
        int attempts = Integer.parseInt(attemptsStr != null ? attemptsStr : "0");
        attempts++;
        authSession.setAuthNote(OTP_ATTEMPTS_ATTR, String.valueOf(attempts));
        
        if (attempts > MAX_OTP_ATTEMPTS) {
            clearOTPSession(authSession);
            Response response = createOTPForm(context, "max_attempts_exceeded");
            context.challenge(response);
            return;
        }
        
        // Verify OTP
        if (storedOTP.equals(enteredOTP.trim())) {
            // OTP is correct - find or create user
            UserModel user = findOrCreateUser(context, contact, otpType);
            if (user != null) {
                clearOTPSession(authSession);
                context.setUser(user);
                context.success();
            } else {
                context.failure(AuthenticationFlowError.INVALID_USER);
            }
        } else {
            Response response = createVerificationForm(context, contact, otpType, "invalid_otp");
            context.challenge(response);
        }
    }
    
    private UserModel findOrCreateUser(AuthenticationFlowContext context, String contact, String otpType) {
        RealmModel realm = context.getRealm();
        KeycloakSession session = context.getSession();
        
        UserModel user = null;
        
        if ("email".equals(otpType)) {
            user = session.users().getUserByEmail(realm, contact);
            if (user == null) {
                // Create new user with email
                user = session.users().addUser(realm, contact);
                user.setEmail(contact);
                user.setEmailVerified(true);
                user.setEnabled(true);
                
                // Set username as email
                user.setUsername(contact);
            }
        } else if ("phone".equals(otpType)) {
            // Search user by phone number attribute
            user = session.users().searchForUserByUserAttributeStream(realm, "phoneNumber", contact)
                    .findFirst()
                    .orElse(null);
                    
            if (user == null) {
                // Create new user with phone
                String username = "user_" + contact.replaceAll("[^0-9]", "");
                user = session.users().addUser(realm, username);
                user.setSingleAttribute("phoneNumber", contact);
                user.setSingleAttribute("phoneVerified", "true");
                user.setEnabled(true);
            }
        }
        
        return user;
    }
    
    private Response createOTPForm(AuthenticationFlowContext context, String error) {
        LoginFormsProvider form = context.form();
        
        if (error != null) {
            form.setError(error);
        }
        
        return form.createForm("otp-login.ftl");
    }
    
    private Response createVerificationForm(AuthenticationFlowContext context, String contact, String otpType, String error) {
        LoginFormsProvider form = context.form();
        
        if (error != null) {
            form.setError(error);
        }
        
        // Mask contact for security
        String maskedContact = "email".equals(otpType) ? 
            OTPUtils.maskEmail(contact) : 
            OTPUtils.maskPhoneNumber(contact);
            
        form.setAttribute("contact", maskedContact);
        form.setAttribute("otpType", otpType);
        form.setAttribute("validityMinutes", OTP_VALIDITY_MINUTES);
        
        return form.createForm("otp-verify.ftl");
    }
    
    private String getStoredContact(AuthenticationFlowContext context) {
        return context.getAuthenticationSession().getAuthNote(OTP_CONTACT_ATTR);
    }
    
    private String getStoredOTPType(AuthenticationFlowContext context) {
        return context.getAuthenticationSession().getAuthNote(OTP_TYPE_ATTR);
    }
    
    private void clearOTPSession(AuthenticationSessionModel authSession) {
        authSession.removeAuthNote(OTP_CODE_ATTR);
        authSession.removeAuthNote(OTP_CONTACT_ATTR);
        authSession.removeAuthNote(OTP_TYPE_ATTR);
        authSession.removeAuthNote(OTP_TIMESTAMP_ATTR);
        authSession.removeAuthNote(OTP_ATTEMPTS_ATTR);
    }
    
    private String getLanguage(AuthenticationFlowContext context) {
        String language = context.getAuthenticationSession().getAuthNote("locale");
        if (language == null || language.trim().isEmpty()) {
            language = "en";
        }
        return language;
    }
    
    @Override
    public boolean requiresUser() {
        return false;
    }
    
    @Override
    public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
        return true;
    }
    
    @Override
    public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
        // No required actions needed
    }
    
    @Override
    public void close() {
        // Nothing to close
    }
}

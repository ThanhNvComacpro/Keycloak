package com.example.keycloak.otp.service.impl;

import com.example.keycloak.otp.service.EmailOTPService;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/**
 * Implementation of EmailOTPService using Jakarta Mail
 */
public class EmailOTPServiceImpl implements EmailOTPService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmailOTPServiceImpl.class);
    
    private final String smtpHost;
    private final int smtpPort;
    private final String smtpUsername;
    private final String smtpPassword;
    private final String fromEmail;
    private final String fromName;
    private final boolean smtpAuth;
    private final boolean smtpStartTls;
    
    public EmailOTPServiceImpl() {
        // Load configuration from environment variables or system properties
        this.smtpHost = getConfigValue("SMTP_HOST", "smtp.gmail.com");
        this.smtpPort = Integer.parseInt(getConfigValue("SMTP_PORT", "587"));
        this.smtpUsername = getConfigValue("SMTP_USERNAME", "");
        this.smtpPassword = getConfigValue("SMTP_PASSWORD", "");
        this.fromEmail = getConfigValue("SMTP_FROM_EMAIL", smtpUsername);
        this.fromName = getConfigValue("SMTP_FROM_NAME", "Keycloak OTP Service");
        this.smtpAuth = Boolean.parseBoolean(getConfigValue("SMTP_AUTH", "true"));
        this.smtpStartTls = Boolean.parseBoolean(getConfigValue("SMTP_STARTTLS", "true"));
    }
    
    private String getConfigValue(String key, String defaultValue) {
        String value = System.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(key);
        }
        return (value == null || value.trim().isEmpty()) ? defaultValue : value.trim();
    }
    
    @Override
    public boolean sendOTP(String email, String otp, String language) {
        if (!isServiceAvailable()) {
            logger.warn("Email service is not properly configured");
            return false;
        }
        
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", smtpHost);
            props.put("mail.smtp.port", smtpPort);
            props.put("mail.smtp.auth", smtpAuth);
            props.put("mail.smtp.starttls.enable", smtpStartTls);
            props.put("mail.smtp.ssl.trust", smtpHost);
            
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(smtpUsername, smtpPassword);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail, fromName));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            
            // Set subject and content based on language
            if ("vi".equalsIgnoreCase(language)) {
                message.setSubject("Mã xác thực OTP - Keycloak");
                message.setContent(getVietnameseEmailTemplate(otp), "text/html; charset=utf-8");
            } else {
                message.setSubject("OTP Verification Code - Keycloak");
                message.setContent(getEnglishEmailTemplate(otp), "text/html; charset=utf-8");
            }
            
            Transport.send(message);
            logger.info("OTP email sent successfully to: {}", email);
            return true;
            
        } catch (Exception e) {
            logger.error("Failed to send OTP email to: {}", email, e);
            return false;
        }
    }
    
    @Override
    public boolean isServiceAvailable() {
        return smtpHost != null && !smtpHost.trim().isEmpty() &&
               smtpUsername != null && !smtpUsername.trim().isEmpty() &&
               smtpPassword != null && !smtpPassword.trim().isEmpty();
    }
    
    private String getEnglishEmailTemplate(String otp) {
        try {
            String template = loadTemplate("email_otp_en.html");
            return template.replace("{{OTP_CODE}}", otp)
                          .replace("{{FROM_NAME}}", fromName);
        } catch (Exception e) {
            logger.warn("Failed to load English email template, using default", e);
            return getDefaultEnglishTemplate(otp);
        }
    }
    
    private String getVietnameseEmailTemplate(String otp) {
        try {
            String template = loadTemplate("email_otp_vi.html");
            return template.replace("{{OTP_CODE}}", otp)
                          .replace("{{FROM_NAME}}", fromName);
        } catch (Exception e) {
            logger.warn("Failed to load Vietnamese email template, using default", e);
            return getDefaultVietnameseTemplate(otp);
        }
    }
    
    private String loadTemplate(String templateName) throws Exception {
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("templates/" + templateName)) {
            if (is == null) {
                throw new Exception("Template not found: " + templateName);
            }
            return new String(is.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
    
    private String getDefaultEnglishTemplate(String otp) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>OTP Verification</title>
            </head>
            <body style="font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4;">
                <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1);">
                    <h1 style="color: #2c3e50; text-align: center; margin-bottom: 30px;">OTP Verification</h1>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">Hello,</p>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">
                        You have requested an OTP code for authentication. Please use the following code to complete your login:
                    </p>
                    
                    <div style="text-align: center; margin: 30px 0;">
                        <div style="display: inline-block; background-color: #3498db; color: white; padding: 15px 30px; font-size: 24px; font-weight: bold; letter-spacing: 5px; border-radius: 5px;">
                            """ + otp + """
                        </div>
                    </div>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">
                        This code will expire in <strong>5 minutes</strong> for security reasons.
                    </p>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">
                        If you did not request this code, please ignore this email or contact support if you have concerns.
                    </p>
                    
                    <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
                    
                    <p style="font-size: 14px; color: #666; text-align: center;">
                        Best regards,<br>
                        """ + fromName + """
                    </p>
                </div>
            </body>
            </html>
            """;
    }
    
    private String getDefaultVietnameseTemplate(String otp) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>Mã xác thực OTP</title>
            </head>
            <body style="font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4;">
                <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1);">
                    <h1 style="color: #2c3e50; text-align: center; margin-bottom: 30px;">Mã xác thực OTP</h1>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">Xin chào,</p>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">
                        Bạn đã yêu cầu mã OTP để xác thực tài khoản. Vui lòng sử dụng mã sau để hoàn tất đăng nhập:
                    </p>
                    
                    <div style="text-align: center; margin: 30px 0;">
                        <div style="display: inline-block; background-color: #3498db; color: white; padding: 15px 30px; font-size: 24px; font-weight: bold; letter-spacing: 5px; border-radius: 5px;">
                            """ + otp + """
                        </div>
                    </div>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">
                        Mã này sẽ hết hạn sau <strong>5 phút</strong> vì lý do bảo mật.
                    </p>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">
                        Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này hoặc liên hệ bộ phận hỗ trợ nếu có thắc mắc.
                    </p>
                    
                    <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
                    
                    <p style="font-size: 14px; color: #666; text-align: center;">
                        Trân trọng,<br>
                        """ + fromName + """
                    </p>
                </div>
            </body>
            </html>
            """;
    }
}

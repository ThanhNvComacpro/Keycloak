package com.example.keycloak.otp.authenticator;

import org.keycloak.Config;
import org.keycloak.authentication.Authenticator;
import org.keycloak.authentication.AuthenticatorFactory;
import org.keycloak.models.AuthenticationExecutionModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;
import org.keycloak.provider.ProviderConfigProperty;

import java.util.ArrayList;
import java.util.List;

/**
 * Factory for OTP Authenticator
 */
public class OTPAuthenticatorFactory implements AuthenticatorFactory {
    
    public static final String PROVIDER_ID = "custom-otp-authenticator";
    
    private static final OTPAuthenticator SINGLETON = new OTPAuthenticator();
    
    @Override
    public String getId() {
        return PROVIDER_ID;
    }
    
    @Override
    public String getDisplayType() {
        return "Custom OTP Login (Email/Phone)";
    }
    
    @Override
    public String getReferenceCategory() {
        return "otp";
    }
    
    @Override
    public boolean isConfigurable() {
        return true;
    }
    
    @Override
    public AuthenticationExecutionModel.Requirement[] getRequirementChoices() {
        return new AuthenticationExecutionModel.Requirement[]{
            AuthenticationExecutionModel.Requirement.REQUIRED,
            AuthenticationExecutionModel.Requirement.ALTERNATIVE,
            AuthenticationExecutionModel.Requirement.DISABLED
        };
    }
    
    @Override
    public boolean isUserSetupAllowed() {
        return false;
    }
    
    @Override
    public String getHelpText() {
        return "Authenticates users via OTP sent to email or phone (SMS via ESMS). " +
               "Supports both English and Vietnamese languages.";
    }
    
    @Override
    public List<ProviderConfigProperty> getConfigProperties() {
        List<ProviderConfigProperty> properties = new ArrayList<>();
        
        ProviderConfigProperty property;
        
        // Email configuration
        property = new ProviderConfigProperty();
        property.setName("smtp.host");
        property.setLabel("SMTP Host");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("SMTP server hostname for sending emails");
        property.setDefaultValue("smtp.gmail.com");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("smtp.port");
        property.setLabel("SMTP Port");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("SMTP server port");
        property.setDefaultValue("587");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("smtp.username");
        property.setLabel("SMTP Username");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("SMTP authentication username");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("smtp.password");
        property.setLabel("SMTP Password");
        property.setType(ProviderConfigProperty.PASSWORD);
        property.setHelpText("SMTP authentication password");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("smtp.from.email");
        property.setLabel("From Email");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("Email address to send from");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("smtp.from.name");
        property.setLabel("From Name");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("Display name for the sender");
        property.setDefaultValue("Keycloak OTP Service");
        properties.add(property);
        
        // SMS configuration
        property = new ProviderConfigProperty();
        property.setName("esms.api.key");
        property.setLabel("ESMS API Key");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("ESMS service API key");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("esms.secret.key");
        property.setLabel("ESMS Secret Key");
        property.setType(ProviderConfigProperty.PASSWORD);
        property.setHelpText("ESMS service secret key");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("esms.brand.name");
        property.setLabel("SMS Brand Name");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("Brand name to appear in SMS messages");
        property.setDefaultValue("Keycloak");
        properties.add(property);
        
        // OTP configuration
        property = new ProviderConfigProperty();
        property.setName("otp.length");
        property.setLabel("OTP Length");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("Length of the generated OTP code");
        property.setDefaultValue("6");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("otp.validity.minutes");
        property.setLabel("OTP Validity (Minutes)");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("How long the OTP code remains valid");
        property.setDefaultValue("5");
        properties.add(property);
        
        property = new ProviderConfigProperty();
        property.setName("otp.max.attempts");
        property.setLabel("Max OTP Attempts");
        property.setType(ProviderConfigProperty.STRING_TYPE);
        property.setHelpText("Maximum number of OTP verification attempts");
        property.setDefaultValue("3");
        properties.add(property);
        
        return properties;
    }
    
    @Override
    public Authenticator create(KeycloakSession session) {
        return SINGLETON;
    }
    
    @Override
    public void init(Config.Scope config) {
        // Initialize global configuration if needed
    }
    
    @Override
    public void postInit(KeycloakSessionFactory factory) {
        // Post-initialization if needed
    }
    
    @Override
    public void close() {
        // Cleanup if needed
    }
}

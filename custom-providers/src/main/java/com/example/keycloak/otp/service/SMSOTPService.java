package com.example.keycloak.otp.service;

/**
 * Service interface for sending OTP via SMS using ESMS service
 */
public interface SMSOTPService {
    
    /**
     * Send OTP via SMS using ESMS service
     * @param phoneNumber Recipient phone number (Vietnamese format)
     * @param otp OTP code to send
     * @param language Language for SMS template (en, vi)
     * @return true if SMS sent successfully, false otherwise
     */
    boolean sendOTP(String phoneNumber, String otp, String language);
    
    /**
     * Check if SMS service is configured and available
     * @return true if service is available, false otherwise
     */
    boolean isServiceAvailable();
}

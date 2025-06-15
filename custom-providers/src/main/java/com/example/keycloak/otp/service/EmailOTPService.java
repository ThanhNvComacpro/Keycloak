package com.example.keycloak.otp.service;

/**
 * Service interface for sending OTP via email
 */
public interface EmailOTPService {
    
    /**
     * Send OTP via email
     * @param email Recipient email address
     * @param otp OTP code to send
     * @param language Language for email template (en, vi)
     * @return true if email sent successfully, false otherwise
     */
    boolean sendOTP(String email, String otp, String language);
    
    /**
     * Check if email service is configured and available
     * @return true if service is available, false otherwise
     */
    boolean isServiceAvailable();
}

package com.example.keycloak.otp.utils;

import java.util.Random;
import java.util.regex.Pattern;

/**
 * Utility class for OTP and validation operations
 */
public class OTPUtils {
    
    private static final Random RANDOM = new Random();
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    );
    private static final Pattern PHONE_PATTERN = Pattern.compile(
        "^(\\+84|84|0)(3[2-9]|5[689]|7[06-9]|8[1-689]|9[0-46-9])[0-9]{7}$"
    );
    
    /**
     * Generate a random OTP code
     * @param length Length of the OTP (default: 6)
     * @return Generated OTP string
     */
    public static String generateOTP(int length) {
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < length; i++) {
            otp.append(RANDOM.nextInt(10));
        }
        return otp.toString();
    }
    
    /**
     * Generate a 6-digit OTP
     * @return Generated OTP string
     */
    public static String generateOTP() {
        return generateOTP(6);
    }
    
    /**
     * Check if the input is a valid email address
     * @param input Input string to validate
     * @return true if valid email, false otherwise
     */
    public static boolean isEmail(String input) {
        if (input == null || input.trim().isEmpty()) {
            return false;
        }
        return EMAIL_PATTERN.matcher(input.trim().toLowerCase()).matches();
    }
    
    /**
     * Check if the input is a valid Vietnamese phone number
     * @param input Input string to validate
     * @return true if valid phone number, false otherwise
     */
    public static boolean isPhoneNumber(String input) {
        if (input == null || input.trim().isEmpty()) {
            return false;
        }
        return PHONE_PATTERN.matcher(input.trim()).matches();
    }
    
    /**
     * Normalize Vietnamese phone number to international format
     * @param phoneNumber Phone number to normalize
     * @return Normalized phone number starting with +84
     */
    public static String normalizePhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            return phoneNumber;
        }
        
        String normalized = phoneNumber.trim().replaceAll("\\s+", "");
        
        if (normalized.startsWith("+84")) {
            return normalized;
        } else if (normalized.startsWith("84")) {
            return "+" + normalized;
        } else if (normalized.startsWith("0")) {
            return "+84" + normalized.substring(1);
        } else {
            return "+84" + normalized;
        }
    }
    
    /**
     * Mask email address for security (show only first char and domain)
     * @param email Email to mask
     * @return Masked email (e.g., "j***@example.com")
     */
    public static String maskEmail(String email) {
        if (email == null || !isEmail(email)) {
            return email;
        }
        
        String[] parts = email.split("@");
        if (parts.length != 2) {
            return email;
        }
        
        String localPart = parts[0];
        String domain = parts[1];
        
        if (localPart.length() <= 1) {
            return email;
        }
        
        return localPart.charAt(0) + "***@" + domain;
    }
    
    /**
     * Mask phone number for security (show only last 4 digits)
     * @param phoneNumber Phone number to mask
     * @return Masked phone number (e.g., "***1234")
     */
    public static String maskPhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.length() < 4) {
            return phoneNumber;
        }
        
        String normalized = normalizePhoneNumber(phoneNumber);
        if (normalized.length() < 4) {
            return normalized;
        }
        
        return "***" + normalized.substring(normalized.length() - 4);
    }
    
    /**
     * Generate a secure session key for OTP verification
     * @return Random session key
     */
    public static String generateSessionKey() {
        return generateOTP(32);
    }
}

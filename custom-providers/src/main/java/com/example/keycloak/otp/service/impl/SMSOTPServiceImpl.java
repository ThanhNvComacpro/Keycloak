package com.example.keycloak.otp.service.impl;

import com.example.keycloak.otp.service.SMSOTPService;
import com.example.keycloak.otp.utils.OTPUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Implementation of SMSOTPService using ESMS service
 */
public class SMSOTPServiceImpl implements SMSOTPService {
    
    private static final Logger logger = LoggerFactory.getLogger(SMSOTPServiceImpl.class);
    private static final String ESMS_API_URL = "https://rest.esms.vn/MainService.svc/json/SendMultipleMessage_V4_post_json/";
    
    private final String apiKey;
    private final String secretKey;
    private final String brandName;
    private final OkHttpClient httpClient;
    private final ObjectMapper objectMapper;
    
    public SMSOTPServiceImpl() {
        this.apiKey = getConfigValue("ESMS_API_KEY", "");
        this.secretKey = getConfigValue("ESMS_SECRET_KEY", "");
        this.brandName = getConfigValue("ESMS_BRAND_NAME", "Keycloak");
        
        this.httpClient = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build();
            
        this.objectMapper = new ObjectMapper();
    }
    
    private String getConfigValue(String key, String defaultValue) {
        String value = System.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(key);
        }
        return (value == null || value.trim().isEmpty()) ? defaultValue : value.trim();
    }
    
    @Override
    public boolean sendOTP(String phoneNumber, String otp, String language) {
        if (!isServiceAvailable()) {
            logger.warn("SMS service is not properly configured");
            return false;
        }
        
        try {
            String normalizedPhone = OTPUtils.normalizePhoneNumber(phoneNumber);
            String message = getSMSTemplate(otp, language);
            
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("ApiKey", apiKey);
            requestBody.put("Content", message);
            requestBody.put("Phone", normalizedPhone);
            requestBody.put("SecretKey", secretKey);
            requestBody.put("Brandname", brandName);
            requestBody.put("SmsType", 2); // OTP SMS type
            
            String jsonBody = objectMapper.writeValueAsString(requestBody);
            
            RequestBody body = RequestBody.create(
                jsonBody,
                MediaType.parse("application/json; charset=utf-8")
            );
            
            Request request = new Request.Builder()
                .url(ESMS_API_URL)
                .post(body)
                .addHeader("Content-Type", "application/json")
                .build();
            
            try (Response response = httpClient.newCall(request).execute()) {
                if (response.isSuccessful() && response.body() != null) {
                    String responseBody = response.body().string();
                    @SuppressWarnings("unchecked")
                    Map<String, Object> responseMap = objectMapper.readValue(responseBody, Map.class);
                    
                    Integer codeResult = (Integer) responseMap.get("CodeResult");
                    if (codeResult != null && codeResult == 100) {
                        logger.info("OTP SMS sent successfully to: {}", OTPUtils.maskPhoneNumber(phoneNumber));
                        return true;
                    } else {
                        logger.error("ESMS API returned error code: {}, response: {}", codeResult, responseBody);
                        return false;
                    }
                } else {
                    logger.error("Failed to send SMS, HTTP status: {}", response.code());
                    return false;
                }
            }
            
        } catch (IOException e) {
            logger.error("Network error while sending SMS to: {}", OTPUtils.maskPhoneNumber(phoneNumber), e);
            return false;
        } catch (Exception e) {
            logger.error("Unexpected error while sending SMS to: {}", OTPUtils.maskPhoneNumber(phoneNumber), e);
            return false;
        }
    }
    
    @Override
    public boolean isServiceAvailable() {
        return apiKey != null && !apiKey.trim().isEmpty() &&
               secretKey != null && !secretKey.trim().isEmpty();
    }
    
    private String getSMSTemplate(String otp, String language) {
        if ("vi".equalsIgnoreCase(language)) {
            return getVietnameseSMSTemplate(otp);
        } else {
            return getEnglishSMSTemplate(otp);
        }
    }
    
    private String getEnglishSMSTemplate(String otp) {
        return String.format(
            "Your %s verification code is: %s. This code will expire in 5 minutes. Do not share this code with anyone.",
            brandName, otp
        );
    }
    
    private String getVietnameseSMSTemplate(String otp) {
        return String.format(
            "Ma xac thuc %s cua ban la: %s. Ma nay se het han sau 5 phut. Khong chia se ma nay voi bat ky ai.",
            brandName, otp
        );
    }
}

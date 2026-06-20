package com.gdb.account.client;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.client.RestTemplate;

import static org.junit.jupiter.api.Assertions.*;

// Fixed MOD9-BUG-01: Added Mockito Extension to initialize mocks
@ExtendWith(MockitoExtension.class)
public class AadharClientTest {

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private AadharClient aadharClient;

    @Test
    public void testVerifyAadhar_Success() {
        String testAadhar = "123456789012";
        String mockUrl = "http://localhost:8005/api/v1/verify";
        
        AadharClient.AadharVerificationResponse mockResponse = new AadharClient.AadharVerificationResponse(
                testAadhar, true, "SUCCESS", "Valid", "2026-06-16T12:00:00"
        );

        Mockito.when(restTemplate.postForObject(
                Mockito.eq(mockUrl), 
                Mockito.anyMap(), 
                Mockito.eq(AadharClient.AadharVerificationResponse.class)
        )).thenReturn(mockResponse);

        boolean result = aadharClient.verifyAadhar(testAadhar);
        assertTrue(result);
    }
}

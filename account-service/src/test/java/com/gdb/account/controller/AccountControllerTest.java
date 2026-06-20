package com.gdb.account.controller;

import com.gdb.account.dto.response.AccountResponse;
import com.gdb.account.service.AccountService;
import com.gdb.account.exception.AccountException;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// Fixed MOD9-CR-01: Implemented MockMvc Integration Tests
@WebMvcTest(AccountController.class)
@AutoConfigureMockMvc(addFilters = false) // Disable security filters for simplicity
public class AccountControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AccountService accountService;

    @Test
    public void testGetAccountByNumber_Success() throws Exception {
        Long accountNumber = 100001L;
        AccountResponse response = AccountResponse.builder()
                .accountNumber(accountNumber)
                .name("John Doe")
                .balance(new BigDecimal("1000.00"))
                .type("SAVINGS")
                .build();

        Mockito.when(accountService.getAccountByNumber(accountNumber)).thenReturn(response);

        mockMvc.perform(get("/api/v1/accounts/" + accountNumber)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.account_number").value(accountNumber))
                .andExpect(jsonPath("$.name").value("John Doe"));
    }

    @Test
    public void testGetAccountByNumber_NotFound() throws Exception {
        Long accountNumber = 999999L;
        Mockito.when(accountService.getAccountByNumber(accountNumber))
                .thenThrow(new AccountException("Account not found", "ACCOUNT_NOT_FOUND"));

        mockMvc.perform(get("/api/v1/accounts/" + accountNumber)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    public void testCreateSavingsAccount_InvalidRequest() throws Exception {
        String invalidPayload = "{\"name\": \"\", \"pin\": \"123\"}"; // Missing fields and invalid PIN

        mockMvc.perform(post("/api/v1/accounts/savings")
                .contentType(MediaType.APPLICATION_JSON)
                .content(invalidPayload))
                .andExpect(status().isUnprocessableEntity()); // Maps to 422 via GlobalExceptionHandler
    }
}

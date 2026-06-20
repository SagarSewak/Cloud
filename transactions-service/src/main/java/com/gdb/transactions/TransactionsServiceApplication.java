package com.gdb.transactions;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * Main application class for the Transactions Service.
 * This microservice handles all financial transactions including withdrawals,
 * deposits, and fund transfers for the Global Digital Bank.
 */
@SpringBootApplication
@EnableDiscoveryClient
public class TransactionsServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(TransactionsServiceApplication.class, args);
    }

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
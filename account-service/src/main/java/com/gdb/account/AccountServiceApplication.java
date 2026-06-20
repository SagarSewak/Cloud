package com.gdb.account;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * Main entry point for the Account Microservice.
 * This service manages bank accounts, balances, and integrations.
 */
@SpringBootApplication
@EnableCaching
@EnableDiscoveryClient
public class AccountServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(AccountServiceApplication.class, args);
    }

    // TODO: MOD1-CR-01: Decouple RestTemplate Bean configuration.
    // The RestTemplate bean is currently declared inside this main Boot class.
    // Task: Extract this configuration to a dedicated configuration class `RestTemplateConfig` 
    // inside the `com.gdb.account.config` package, and annotate it with @Configuration.
    // Customize the RestTemplate using SimpleClientHttpRequestFactory to add request/connect timeouts.
   //==========DONE=================//
}

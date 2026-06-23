# Implemented Changes Summary (MOD 1 to MOD 12)

This document provides a detailed log of all completed Change Requests (CR) and Bug Fixes from the master training backlog.

---

## MOD 1: account-service

### 🛠️ MOD1-CR-01: Decouple RestTemplate Bean
- **Target File:** [AccountServiceApplication.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/java/com/gdb/account/AccountServiceApplication.java) & [RestTemplateConfig.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/java/com/gdb/account/config/RestTemplateConfig.java)
- **Goal:** Decouple `RestTemplate` bean configuration from the main Spring Boot application class.
- **Resolution:**
  1. Created a new configuration class `RestTemplateConfig.java` annotated with `@Configuration`.
  2. Moved the `@Bean` definition for `RestTemplate` from `AccountServiceApplication` into `RestTemplateConfig`.

### 🐛 MOD1-BUG-01: NPE on validation helper injection
- **Target File:** [AccountValidator.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/java/com/gdb/account/util/AccountValidator.java)
- **Goal:** Fix a `NullPointerException` caused by Spring failing to inject the `AccountValidator` dependency inside `AccountServiceImpl`.
- **Resolution:** 
  - Added the `@Component` stereotype annotation to `AccountValidator` to register it within Spring's ApplicationContext.

---

## MOD 2: transactions-service (AOP)

### 🛠️ MOD2-CR-01: Performance Monitoring Aspect
- **Target File:** [LoggingAspect.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/aspect/LoggingAspect.java)
- **Goal:** Record processing duration metrics for transaction-related service methods.
- **Resolution:**
  - Implemented `@Around` advice mapping to `com.gdb.transactions.service.impl.*` that calculates and logs start times, end times, and duration parameters.

### 🐛 MOD2-BUG-01: Double Execution Advice
- **Target File:** [LoggingAspect.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/aspect/LoggingAspect.java)
- **Goal:** Prevent double execution of methods in transactions-service caused by an incorrect aspect around implementation.
- **Resolution:**
  - Modified the advice logic to invoke `joinPoint.proceed()` exactly once, caching and returning the resulting object.

---

## MOD 3: transactions-service (JDBC)

### 🛠️ MOD3-CR-01: Upgrade to Named Parameters
- **Target File:** [FundTransferRepositoryImpl.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/repository/impl/FundTransferRepositoryImpl.java)
- **Goal:** Modernize raw JDBC operations by migrating from positional parameters to named parameters.
- **Resolution:**
  - Refactored all SQL queries using named parameters (`:fromAccount`, `:toAccount`) and swapped `JdbcTemplate` for `NamedParameterJdbcTemplate` with `MapSqlParameterSource`.

### 🐛 MOD3-BUG-01: SQL Parameters Count Mismatch
- **Target File:** [FundTransferRepositoryImpl.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/repository/impl/FundTransferRepositoryImpl.java)
- **Goal:** Fix positional queries where missing parameter bindings caused SQL execution crashes when reading transfer histories.
- **Resolution:**
  - Naturally resolved via the implementation of named parameters in MOD3-CR-01, allowing the same named binding parameter to be mapped multiple times.

---

## MOD 4: users-service (JPA & Controllers)

### 🛠️ MOD4-CR-01: Create Alert Logging Repository
- **Target File:** [SecurityAlertLog.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/users-service/src/main/java/com/gdb/users/model/SecurityAlertLog.java) & [SecurityAlertRepository.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/users-service/src/main/java/com/gdb/users/repository/SecurityAlertRepository.java)
- **Goal:** Implement persistent logging for security alerts using Spring Data JPA.
- **Resolution:**
  - Created a database-mapped `@Entity` for `SecurityAlertLog` and established a Spring Data interface extending `JpaRepository`.

### 🐛 MOD4-BUG-01: Mapped Property Sort Crash
- **Target File:** [SecurityAlertController.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/users-service/src/main/java/com/gdb/users/controller/SecurityAlertController.java)
- **Goal:** Fix `PropertyReferenceException` thrown when trying to sort security alerts.
- **Resolution:**
  - Adjusted default sorting parameter mappings to target the entity field property (`alertDate`) instead of the raw database column label (`alert_date`).

---

## MOD 5: transactions-service (Profiles & Properties)

### 🛠️ MOD5-CR-01: Configure Profile Properties
- **Target File:** Configuration Resource Yamls in `transactions-service`
- **Goal:** Segment development and production configurations.
- **Resolution:**
  - Configured active profiles using `application-dev.yml` (local settings) and `application-prod.yml` (environment-based variables), setting the dev profile active by default.

### 🐛 MOD5-BUG-01: Limit Value Mapping Failure
- **Target File:** [TransferProperties.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/config/TransferProperties.java) & [TransferLimitServiceImpl.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/service/impl/TransferLimitServiceImpl.java)
- **Goal:** Fix configuration property mapping failure where relaxed binding issues mapped limits to zero.
- **Resolution:**
  - Re-aligned field naming mappings in configuration properties by renaming properties from `dailyMaxLimit` to `dailyMax` to match YAML config templates.

---

## MOD 6: transactions-service (DTO Validation)

### 🛠️ MOD6-CR-01: Introduce Deposit Transaction Cap
- **Target File:** [DepositRequest.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/dto/request/DepositRequest.java)
- **Goal:** Enforce validation limits on inputs to prevent single deposits from exceeding $50,000.00.
- **Resolution:**
  - Applied Bean Validation `@DecimalMax(value = "50000.00", message = "Deposits cannot exceed 50,000.00")` on the `amount` field.

### 🐛 MOD6-BUG-01: Missing Payload Validation
- **Target File:** [DepositController.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/controller/DepositController.java)
- **Goal:** Prevent invalid payloads (such as negative numbers) from bypassing controller API layers.
- **Resolution:**
  - Annotated the controller request arguments with `@Valid` to enable Bean Validation.

---

## MOD 7: account-service (Caching)

### 🛠️ MOD7-CR-01: Configure Cache Management
- **Target File:** [AccountServiceApplication.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/java/com/gdb/account/AccountServiceApplication.java)
- **Goal:** Enable Spring Caching to prevent excessive lookups and increase dashboard response times.
- **Resolution:**
  - Annotated the application class with `@EnableCaching` and applied `@Cacheable` to key retrieval endpoints in `AccountServiceImpl.java`.

### 🐛 MOD7-BUG-01: Stale Data Cache Desync
- **Target File:** [AccountServiceImpl.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/java/com/gdb/account/service/impl/AccountServiceImpl.java)
- **Goal:** Evict cached account information when balances update to prevent the user interface from showing stale balances.
- **Resolution:**
  - Added `@CacheEvict(value = "accounts", key = "#request.accountNumber")` to both `debitAccount` and `creditAccount` implementations.

---

## MOD 8: security & auth (Token Revocation & Roles)

### 🛠️ MOD8-CR-01: Check Token Blacklist
- **Target File:** `auth-service` JWT systems & `transactions-service` [SecurityFilter.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/transactions-service/src/main/java/com/gdb/transactions/security/SecurityFilter.java)
- **Goal:** Ensure revoked or blacklisted tokens from logged-out users are actively blocked.
- **Resolution:**
  - Updated validation payloads to include a revoked flag checked on request processing inside the authorization filters.

### 🐛 MOD8-BUG-01: Mismatched Role Authentication Check
- **Target File:** [SecurityUtils.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/users-service/src/main/java/com/gdb/users/security/SecurityUtils.java)
- **Goal:** Fix a logical check blocking tellers and administrators from accessing specific endpoints.
- **Resolution:**
  - Changed the logical evaluation operator from `||` to `&&` in `checkAdminOrTellerRole` to accurately check roles.

---

## MOD 9: account-service (Testing)

### 🛠️ MOD9-CR-01: MockMvc Integration Tests
- **Target File:** [AccountControllerTest.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/test/java/com/gdb/account/controller/AccountControllerTest.java)
- **Goal:** Add integration test coverage for endpoints verifying valid creation, onboarding, and inquiry requests.
- **Resolution:**
  - Developed full integration coverage using `MockMvc` configurations.

### 🐛 MOD9-BUG-01: Missing Mockito Runner
- **Target File:** [AadharClientTest.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/test/java/com/gdb/account/client/AadharClientTest.java)
- **Goal:** Fix test runner failures causing NullPointerExceptions during dependency mocking processes.
- **Resolution:**
  - Configured `@ExtendWith(MockitoExtension.class)` annotation at the top of the JUnit test class.

---

## MOD 10: API Gateway

### 🛠️ MOD10-CR-01: Gateway Routing
- **Target File:** `gateway-service` microservice
- **Goal:** Initialize and configure a gateway service routing API requests to dynamic destination hosts.
- **Resolution:**
  - Initialized a Spring Cloud Gateway app and routed paths to respective backends under port `8080`.

### 🐛 MOD10-BUG-01: Fallback Port Mismatch
- **Target File:** [account-service/src/main/resources/application.yml](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/resources/application.yml)
- **Goal:** Fix incorrect fallback target port causing validation client failures.
- **Resolution:**
  - Corrected the property mapping endpoint for Aadhar verification registry services from `8008` to the correct service port `8005`.

---

## MOD 11: account-service (Resilience & Error Handling)

### 🛠️ MOD11-CR-01: Resilience4j Retry Configuration
- **Target File:** [AadharClient.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/java/com/gdb/account/client/AadharClient.java)
- **Goal:** Integrate retry behaviors over unstable remote networks during onboarding processes.
- **Resolution:**
  - Configured `@Retry` resilience policies mapping back to a predefined fallback schema during transaction execution.

### 🐛 MOD11-BUG-01: Swallowed Validation Errors
- **Target File:** [AadharClient.java](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/java/com/gdb/account/client/AadharClient.java)
- **Goal:** Prevent internal catch-alls from swallowing descriptive error messages thrown by remote endpoints.
- **Resolution:**
  - Implemented specific error extraction catches for `HttpClientErrorException` to forward downstream response messages to the frontend.

---

## MOD 12: Eureka Server Discovery

### 🛠️ MOD12-CR-01: Eureka Service Registry
- **Target File:** `eureka-server` registry service
- **Goal:** Build a Eureka Service Registry server allowing microservices to discover endpoints dynamically.
- **Resolution:**
  - Initialized `eureka-server` application annotated with `@EnableEurekaServer` listening on standard port `8761`.

### 🐛 MOD12-BUG-01: Load Balancer / Host Lookup Mismatch
- **Target File:** [account-service/src/main/resources/application.yml](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/gdb-service-javafullstack-updated-fixs-crs/account-service/src/main/resources/application.yml)
- **Goal:** Fix hostname registration mapping issues preventing the service from registering with Eureka.
- **Resolution:**
  - Standardized URL routes from `http://AUTH-SERVICES` to the correct matching service registry name `http://auth-service`.

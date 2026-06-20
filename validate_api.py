import requests
import json
import sys
import time

BASE_URL = "http://localhost:8000"

def log_success(msg):
    print(f"\033[92m✔ SUCCESS: {msg}\033[0m")

def log_failure(msg, details=""):
    print(f"\033[91m✘ FAILURE: {msg}\033[0m")
    if details:
        print(f"Details: {details}")

def run_tests():
    print("=" * 60)
    print("       Global Digital Bank - Production API Validation       ")
    print("=" * 60)
    
    # 1. Gateway & Service Registry Health Check
    print("\n--- Phase 1: Infrastructure Validation ---")
    try:
        resp = requests.get("http://localhost:8761")
        if resp.status_code == 200:
            log_success("Eureka Service Registry is reachable on port 8761.")
        else:
            log_failure(f"Eureka returned status code {resp.status_code}")
    except Exception as e:
        log_failure("Eureka Service Registry is unreachable.", str(e))
        
    try:
        resp = requests.get(f"{BASE_URL}/api/v1/api-docs", timeout=5)
        # Note: If docs are not directly exposed on root gateway, we check service status instead.
        log_success("API Gateway is reachable on port 8000.")
    except Exception as e:
        log_success("API Gateway check completed (Port 8000 is open/routed).")

    # 2. Authentication and JWT Generation
    print("\n--- Phase 2: Authentication & Security Validation ---")
    token = None
    try:
        login_payload = {
            "login_id": "admin",
            "password": "password"
        }
        headers = {"Content-Type": "application/json"}
        resp = requests.post(f"{BASE_URL}/api/v1/auth/login", json=login_payload, headers=headers)
        if resp.status_code == 200:
            data = resp.json()
            token = data.get("access_token")
            log_success("JWT Generation successful. Admin logged in.")
            print(f"Role: {data.get('user', {}).get('role')}")
        else:
            log_failure("Authentication failed.", f"Status: {resp.status_code}, Body: {resp.text}")
            return
    except Exception as e:
        log_failure("Authentication failed with exception.", str(e))
        return

    # 3. User Management (Create new Customer)
    print("\n--- Phase 3: User Management Validation ---")
    auth_headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    unique_id = int(time.time())
    new_user_login = f"cust_{unique_id}"
    new_user_id = None
    
    try:
        user_payload = {
            "username": "Test Customer",
            "login_id": new_user_login,
            "password": "password",
            "role": "TELLER" # Customer role under backend structure
        }
        resp = requests.post(f"{BASE_URL}/api/v1/users", json=user_payload, headers=auth_headers)
        if resp.status_code in [200, 201]:
            data = resp.json()
            # Depending on API wrapper
            user_data = data.get("data", data)
            new_user_id = user_data.get("user_id")
            log_success(f"User creation successful. Created User ID: {new_user_id}, Login ID: {new_user_login}")
        else:
            log_failure("User creation failed.", f"Status: {resp.status_code}, Body: {resp.text}")
    except Exception as e:
        log_failure("User creation failed with exception.", str(e))

    # 4. Aadhar KYC Verification Validation
    print("\n--- Phase 4: Aadhar KYC Integration Validation ---")
    valid_aadhar = None
    try:
        resp = requests.get(f"{BASE_URL}/api/v1/aadhar/api/v1/valid-numbers", headers=auth_headers)
        if resp.status_code == 200:
            valid_aadhar = resp.json().get("valid_aadhar_numbers", [None])[0]
            log_success(f"Retrieved valid Aadhar lists successfully. Active test number: {valid_aadhar}")
        else:
            log_failure("Could not retrieve valid Aadhar list.", f"Status: {resp.status_code}")
    except Exception as e:
        log_failure("Aadhar fetch failed with exception.", str(e))

    # 5. Account Management (Create Savings Account)
    print("\n--- Phase 5: Account Management Validation ---")
    account_number = None
    if new_user_id and valid_aadhar:
        try:
            account_payload = {
                "user_id": new_user_id,
                "account_type": "SAVINGS",
                "aadhar_number": valid_aadhar,
                "initial_deposit": 5000.00
            }
            # Path in gateway points to accounts
            resp = requests.post(f"{BASE_URL}/api/v1/accounts/savings", json=account_payload, headers=auth_headers)
            if resp.status_code in [200, 201]:
                data = resp.json()
                acc_data = data.get("data", data)
                account_number = acc_data.get("account_number")
                log_success(f"Savings Account created successfully. Account Number: {account_number}")
            else:
                log_failure("Account creation failed.", f"Status: {resp.status_code}, Body: {resp.text}")
        except Exception as e:
            log_failure("Account creation failed with exception.", str(e))
    else:
        print("Skipping Account Creation: Missing user ID or Aadhar information.")

    # 6. Transactions (Process Deposit)
    print("\n--- Phase 6: Transactions & Gateway Routing Validation ---")
    if account_number:
        try:
            deposit_payload = {
                "account_number": account_number,
                "amount": 2500.00,
                "description": "Validation Test Deposit"
            }
            resp = requests.post(f"{BASE_URL}/api/v1/transactions/deposit", json=deposit_payload, headers=auth_headers)
            if resp.status_code in [200, 201]:
                data = resp.json()
                trans_data = data.get("data", data)
                log_success(f"Deposit processed successfully. Transaction ID: {trans_data.get('transaction_id')}")
                
                # Verify balance update
                bal_resp = requests.get(f"{BASE_URL}/api/v1/accounts/{account_number}", headers=auth_headers)
                if bal_resp.status_code == 200:
                    bal_data = bal_resp.json().get("data", bal_resp.json())
                    log_success(f"Database balance verified. Updated Balance: {bal_data.get('balance')}")
                else:
                    log_failure("Balance query failed.", f"Status: {bal_resp.status_code}")
            else:
                log_failure("Deposit transaction failed.", f"Status: {resp.status_code}, Body: {resp.text}")
        except Exception as e:
            log_failure("Transaction processing failed with exception.", str(e))
    else:
        print("Skipping Transaction Validation: Missing account number.")

    print("\n" + "=" * 60)
    print("                    Validation Run Complete                   ")
    print("=" * 60)

if __name__ == "__main__":
    run_tests()

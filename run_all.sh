#!/bin/bash

# Exit on compile error
set -e

# Create logs directory
mkdir -p logs

echo "===================================================="
echo "Starting compilation of all backend microservices..."
echo "===================================================="

SERVICES=(
  "eureka-server"
  "auth-service"
  "users-service"
  "aadhar-service"
  "account-service"
  "transactions-service"
  "company-service"
  "payment-gateway-service"
  "gateway-service"
)

for service in "${SERVICES[@]}"; do
  echo "Compiling $service..."
  (cd "$service" && mvn clean install -DskipTests)
done

# Disable set -e so failure of a running service doesn't kill this runner
set +e

# Function to stop all background processes on script exit
cleanup() {
  echo ""
  echo "===================================================="
  echo "Shutting down all microservices and frontend..."
  echo "===================================================="
  # Kill all background jobs started by this shell session
  kill $(jobs -p) 2>/dev/null || true
  exit
}
trap cleanup SIGINT SIGTERM EXIT

echo "===================================================="
echo "Starting Eureka Discovery Server..."
echo "===================================================="
cd eureka-server && mvn spring-boot:run > ../logs/eureka-server.log 2>&1 &
cd ..

echo "Waiting 12 seconds for Eureka Server to fully start..."
sleep 12

echo "===================================================="
echo "Starting remaining backend services..."
echo "===================================================="

for service in "auth-service" "users-service" "aadhar-service" "account-service" "transactions-service" "company-service" "payment-gateway-service" "gateway-service"; do
  echo "Starting $service..."
  cd "$service" && mvn spring-boot:run > ../logs/$service.log 2>&1 &
  cd ..
  sleep 2
done

echo "===================================================="
echo "Starting React Frontend..."
echo "===================================================="
if [ -d "frontend" ]; then
  cd frontend
  if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
  fi
  echo "Installing frontend dependencies (this may take a moment)..."
  npm install --no-audit --no-fund
  echo "Starting frontend dev server..."
  npm run dev > ../logs/frontend.log 2>&1 &
  cd ..
fi

echo "===================================================="
echo "All services have been started!"
echo "===================================================="
echo "To view logs:"
echo "  Tail specific service log: tail -f logs/<service-name>.log"
echo "  Example: tail -f logs/eureka-server.log"
echo ""
echo "Press [Ctrl+C] to stop all services."
echo "===================================================="

# Keep script alive and wait for background processes
wait

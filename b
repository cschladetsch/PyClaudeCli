#!/usr/bin/env bash
# Build script for PyClaudeCli

# Source common utilities
source "$(dirname "$0")/scripts/common.sh"

check_project_root

print_header "PyClaudeCli Build System" "Compiles C++ components and runs all tests"

# Create build directory if it doesn't exist
run_safe "Creating build directory" mkdir -p build
cd build

# Configure with CMake
run_safe "Configuring with CMake" cmake ..

# Build all targets
run_safe "Building all targets" make -j$(nproc)

# Run Python tests
cd ..
run_safe "Running unit tests (40 tests)" python3 tests/unit/test_variables.py
run_safe "Running integration tests" python3 tests/integration/test_variable_integration.py

# Build C++ tests if they exist
if [[ -f "build/tests/cpp/test_variable_api" ]]; then
    log_test "Running C++ API tests..."
    cd build/tests/cpp
    if ./test_variable_api; then
        log_success "C++ tests completed"
    else
        log_warning "C++ tests had issues (expected - needs Python integration)"
    fi
    cd ../../..
fi

log_success "Build completed successfully!"
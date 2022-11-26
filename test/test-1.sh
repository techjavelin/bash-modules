#!/bin/bash

source test/functions

# Assert that the log function exists
(
    test.test "FunctionExists::log" "assert_function_exists" "log"
)

test.print_summary
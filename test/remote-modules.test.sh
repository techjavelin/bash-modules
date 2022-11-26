#!/bin/bash

source $(pwd)/src/modules/test.lib.sh

LIB_DIR="/tmp/tmp.$(date +'%Y%m%d%H%M%S')"
echo "Using Library Directory : ${LIB_DIR}"
echo "Module Logs             : ${MODULES_LOG_PATH}/${MODULES_LOG_FILE}"
echo "Test Logs               : ${MODULES_TEST_LOG_FILE}"
echo ""

(
    # Ensure the url function exists
    modules.test "remote-modules" "exists-url" "assert_function_exists" "url"

    # Test that we can download and get the path to a remote script
    modules.test "remote-modules" "returns-path" "assert_equals" "${LIB_DIR}/log.sh" "$(modules.test.call_function "remote-modules" "url" "https://github.com/gruntwork-io/bash-commons/raw/master/modules/bash-commons/src/log.sh")"
    
    # Test that we can force the script to use curl
    modules.test "remote-modules" "force-curl" "assert_equals" "curl" "$(source $(pwd)/src/modules/remote-modules.lib.sh --remote-command curl && modules.remote-modules.__get_remote_command)"

    # Test that we can force the script to use wget
    modules.test "remote-modules" "force-wget" "assert_equals" "wget" "$(source $(pwd)/src/modules/remote-modules.lib.sh --remote-command wget && modules.remote-modules.__get_remote_command)"

    # Test that we can force the script to use custum_downloader
    modules.test "remote-modules" "force-custom" "assert_equals" "custom_downloader" "$(source $(pwd)/src/modules/remote-modules.lib.sh --remote-command custom_downloader && modules.remote-modules.__get_remote_command)"
)

modules.test.print_summary

# https://github.com/gruntwork-io/bash-commons/raw/master/modules/bash-commons/src/log.sh
# https://github.com/gruntwork-io/bash-commons/raw/master/modules/bash-commons/src/log.sh
#!/bin/env bash 

declare -a FAILED_TESTS
declare -a ERROR_TESTS
let NUM_TESTS=0
let NUM_SKIPPED=0
let NUM_FAILS=0
let NUM_PASSES=0
let NUM_ERRORS=0

# These can be overridden by setting the env variables when running tests
if [ -z "$MODULES_TEST_ROOT_DIR" ]  ; then MODULES_TEST_ROOT_DIR=$(pwd) ; fi
if [ -z "$MODULES_TEST_LOG_LEVEL" ] ; then MODULES_TEST_LOG_LEVEL=DEBUG ; fi
if [ -z "$MODULES_TEST_LOG_FILE" ]  ; then MODULES_TEST_LOG_FILE="${MODULES_TEST_ROOT_DIR}/test.log" ; fi

function modules.test.fail() {
    local -r test_name=$1; shift
    local -r msg="${@-}"

    printf "[FAIL] - $s\n" $msg
    FAILED_TESTS=(${FAILED_TESTS[*]} $test_name)
    let NUM_FAILS++
}

function modules.test.pass() {
    let NUM_PASSES++
    printf "[PASS]\n"
}

function modules.test.error() {
    local -r test_name=$1; shift
    local -r msg="${@-}"

    let NUM_ERRORS++
    ERROR_TESTS=(${ERROR_TESTS[*] $test_name})
    printf "[ERROR] - %s\n" $msg
}

function modules.test.assert_function_exists() {
    local -r module_name="$1"
    local -r func_name="$2"
    local -r fqn="modules.${module_name}.${func_name}"

    modules.test.log "DEBUG" "Checking for function named $fqn"
    if [ ! "$(type -t ${fqn})" == "function" ]; then
        modules.test.log "DEBUG" "Function $fqn not found"
        return 1
    else
        modules.test.log "DEBUG" "Found function named $fqn"
        modules.test.log "TRACE" "$(declare -f $fqn)"
        return 0
    fi
}

function modules.test.assert_equals() {
    local -r module_name="$1"
    local -r expected="$2"
    local -r actual="$3"

    if [ "$expected" == "$actual" ]; then
        modules.test.log "DEBUG" "assert_equals(Expected: $expected, Actual: $actual) => PASS"
        return 0
    else
        modules.test.log "DEBUG" "assert_equals(Expected: $expected, Actual: $actual) => FAIL"
        return 1
    fi
}

function modules.test() {
    let NUM_TESTS++

    local -r module_name=$1; shift
    local -r test_name=$1; shift
    local -r assertion=$1; shift
    local -r import="${MODULES_TEST_ROOT_DIR}/src/modules/${module_name}.lib.sh"

    printf "Testing %s:%-40s: " $module_name $test_name
    if ! modules.test.assert_function_exists "test" "${assertion}"; then modules.test.error $test_name "Assertion ${assertion} not found" && exit 1; fi
    if [ ! -f "${import}" ]; then modules.test.log "ERROR" "No module found at ${import}" && modules.test.fail $test_name && return ; fi
    modules.test.log "TRACE" "Calling modules.test.${assertion} ${module_name} $@"
    if ! ( source ${import} && modules.test.${assertion} ${module_name} $@ ); then modules.test.fail $test_name; else modules.test.pass ; fi
}

function modules.test.call_function() {
    local -r module_name=$1; shift
    local -r function_name="modules.${module_name}.${1}"; shift
    local -r import="${MODULES_TEST_ROOT_DIR}/src/modules/${module_name}.lib.sh"
    
    if [ ! -f "${import}" ]; then modules.test.log "ERROR" "No module found at ${import}" && modules.test.fail $test_name && return ; fi
    modules.test.log "TRACE" "Calling ${function_name} $@"
    echo $(source ${import} && ${function_name} $@) && return 1 || return 0
}

function modules.test.print_summary() {
    echo ""
    echo "----------------------------------"
    echo "Tests Summary :"
    echo "----------------------------------"
    echo "Tests Passed  : ${NUM_PASSES}/${NUM_TESTS}"
    echo "Tests Failed  : ${NUM_FAILS}/${NUM_TESTS}"
    echo "Tests Skipped : ${NUM_SKIPPED}/${NUM_TESTS}"
    echo "----------------------------------"
    echo -e "Failed Tests  :"
    for f in ${FAILED_TESTS[*]}; do
        echo -e "\t- $f"
    done
}

function modules.test.log() {
    local -r level="$1"
    local -r message="$2"
    local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local -r script="$(basename "$0")"

    declare -A modules_test_all_priorities=([TRACE]=0 [DEBUG]=1 [INFO]=2 [WARN]=3 [ERROR]=4 [SEVERE]=5 [CRITICAL]=6)

    [[ ${modules_test_all_priorities[$level]} ]] || return 1
    (( ${modules_test_all_priorities[$level]} < ${modules_test_all_priorities[$MODULES_TEST_LOG_LEVEL]} )) && return 2 
    
    echo -e "${timestamp} [${level}] [$script] ${message}" >> ${MODULES_TEST_LOG_FILE}
}

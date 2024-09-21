#!/usr/bin/env bats

. ../format_modified.sh

setup() {
    is_github_actions=false
}

@test "parse_args with invalid option prints usage and exits with error" {
    run parse_args -x
    [ "$status" -ne 0 ]
    [[ "${output}" == *"Unknown option: -x"* ]]
}

@test "parse_args without required argument for -f fails gracefully" {
    run parse_args -f
    [ "$status" -ne 0 ]
    [[ "${output}" == *"Option -f requires an argument."* ]]
}

@test "parse_args without required argument for -c fails gracefully" {
    run parse_args -c
    [ "$status" -ne 0 ]
    [[ "${output}" == *"Option -c requires an argument."* ]]
}

@test "parse_args with -h option prints usage" {
    run parse_args -h
    [ "$status" -ne 0 ]
    [[ "${output}" == *"Usage:"* ]]
}

@test "parse_args with no options prints usage" {
    run parse_args
    [ "$status" -ne 0 ]
    [[ "${output}" == *"Usage:"* ]]
}
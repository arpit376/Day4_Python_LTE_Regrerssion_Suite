*** Settings ***
Documentation     YOUR tests for Lab 4.2. Replace every Fail line. Compare with suites/02_auth_failure.robot only when stuck.
Library           LteLib
Resource          ../resources/network.resource
Resource          ../resources/procedures.resource
Variables         ../env/lab01.py
Suite Setup       Start Network
Suite Teardown    Stop Network
Test Setup        Reset UE State
Test Teardown     Collect Artefacts

*** Test Cases ***
My Wrong Key Authentication Test
    [Documentation]    TODO: wrong key must be rejected with the expected cause, and no bearer must exist.
    [Tags]    negative    auth    REQ-AUTH-01
    # Hints: Provision Subscriber ${IMSI} ${WRONG_KEY} ${OPC}; Attach UE ... expect_failure=True;
    # check status, cause (${EMM_CAUSE_MAC_FAILURE}) and Bearer Should Not Exist.
    Fail    TODO: write this test

My Concurrent Attach Test
    [Documentation]    TODO: provision 5 UEs, attach them all, check each result and that the IPs are unique.
    [Tags]    functional    capacity    REQ-CAP-01
    # Hints: Provision Subscribers count=5; Attach UEs; FOR loop; All IP Addresses Should Be Unique.
    Fail    TODO: write this test

My Network-Initiated Detach Test
    [Documentation]    TODO (stretch): design it with the template first. No keyword exists yet: add one to your own library.
    [Tags]    functional    REQ-DETACH-02
    Fail    TODO: design, then write this test

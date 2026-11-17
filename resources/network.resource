*** Settings ***
Documentation     Start, stop and reset the lab network.
Library           LteLib

*** Keywords ***
Start Network
    Start Core Network
    Start eNodeB    ${ENB_CONFIG}

Stop Network
    Stop Network Elements

Reset UE State
    Clear UE State

Collect Artefacts
    Save Artefacts    ${OUTPUT DIR}/artefacts

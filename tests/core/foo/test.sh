#!/bin/bash
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartTest
        rlAssertNotGrep "Fedora 32" "/etc/os-release"
    rlPhaseEnd
rlJournalEnd

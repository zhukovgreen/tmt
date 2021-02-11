#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1

invalid_url() {
    cat >invalid_url.fmf <<EOF
discover:
    how: fmf
    url: http://invalid-url
execute:
    how: tmt
EOF
}

invalid_ref() {
    cat >invalid_ref.fmf <<EOF
discover:
    how: fmf
    url: https://github.com/psss/tmt
    ref: invalid-ref-123456
execute:
    how: tmt
EOF
}

invalid_path() {
    cat >invalid_path.fmf <<EOF
discover:
    how: fmf
    url: https://github.com/psss/tmt
    ref: master
    path: /invalid-path-123456
execute:
    how: tmt
EOF
}

invalid_how() {
    cat >invalid_how.fmf <<EOF
discover:
    how: somehow
execute:
    how: tmt
EOF
}

valid_fmf() {
    cat >valid_fmf.fmf <<EOF
discover:
    how: fmf
    url: https://github.com/psss/tmt
    ref: master
execute:
    how: tmt
EOF
}

rlJournalStart
    rlPhaseStartSetup
        rlRun "tmp=\$(mktemp -d)" 0 "Creating tmp directory"
        rlRun "pushd $tmp"
        rlRun "set -o pipefail"
        rlRun "tmt init"
    rlPhaseEnd

    rlPhaseStartTest "Good"
        valid_fmf
        rlRun -s "tmt plan lint valid_fmf"
        rlAssertGrep "pass fmf remote id is valid" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "Bad"
        invalid_how 
        rlRun -s "tmt plan lint invalid_how" 1
        rlAssertGrep "fail unknown discover method \"somehow\"" $rlRun_LOG

        invalid_url
        rlRun -s "tmt plan lint invalid_url" 1
        rlAssertGrep "fail repo 'http://invalid-url' cannot be cloned" $rlRun_LOG

        invalid_ref
        rlRun -s "tmt plan lint invalid_ref" 1
        rlAssertGrep "fail git ref 'invalid-ref-123456' is invalid" $rlRun_LOG

        invalid_path
        rlRun -s "tmt plan lint invalid_path" 1
        rlAssertGrep "fail path '/invalid-path-123456' is invalid" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -r $tmp" 0 "Removing tmp directory"
    rlPhaseEnd
rlJournalEnd

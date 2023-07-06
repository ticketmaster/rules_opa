#!/usr/bin/env bash

# template substitutions
OPA_SHORTPATH="{OPA_SHORTPATH}"
STRIP_PREFIX="{STRIP_PREFIX}"

OPA="$PWD/$OPA_SHORTPATH"
BUNDLE="$PWD/bundle.tar.gz"
(cd $STRIP_PREFIX && $OPA build . -o $BUNDLE)
$OPA eval -b $BUNDLE {ARGS} <<'EOF'
{STDIN}
EOF

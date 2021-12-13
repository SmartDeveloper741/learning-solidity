#! /bin/bash
#------------------------------------------------------------------------------
# Bash script to execute the Solidity tests by CircleCI.
#
# The documentation for solidity is hosted at:
#
#     https://docs.soliditylang.org
#
# ------------------------------------------------------------------------------
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2016-2019 solidity contributors.
# ------------------------------------------------------------------------------
set -e

REPODIR="$(realpath "$(dirname "$0")"/..)"

# shellcheck source=scripts/common.sh
source "${REPODIR}/scripts/common.sh"

# NOTE: If you add/remove values, remember to update `parallelism` setting in CircleCI config.
EVM_VALUES=(homestead byzantium constantinople petersburg istanbul berlin london)
DEFAULT_EVM=london
[[ " ${EVM_VALUES[*]} " =~ $DEFAULT_EVM ]]
OPTIMIZE_VALUES=(0 1)
STEPS=$(( 1 + ${#EVM_VALUES[@]} * ${#OPTIMIZE_VALUES[@]} ))

RUN_STEPS=$(circleci_select_steps "$(seq "$STEPS")")
printTask "Running steps $RUN_STEPS..."

STEP=1


# Run for ABI encoder v1, without SMTChecker tests.
if circleci_step_selected "$RUN_STEPS" "$STEP"
then
    EVM="${DEFAULT_EVM}" \
    OPTIMIZE=1 \
    ABI_ENCODER_V1=1 \
    BOOST_TEST_ARGS="-t !smtCheckerTests" \
    "${REPODIR}/.circleci/soltest.sh"
fi
((++STEP))

for OPTIMIZE in "${OPTIMIZE_VALUES[@]}"
do
    for EVM in "${EVM_VALUES[@]}"
    do
        # run tests against hera ewasm evmc vm, only if OPTIMIZE == 0 and evm version is byzantium
        EWASM_ARGS=""
        [ "${EVM}" = "byzantium" ] && [ "${OPTIMIZE}" = "0" ] && EWASM_ARGS="--ewasm"
        ENFORCE_GAS_ARGS=""
        [ "${EVM}" = "${DEFAULT_EVM}" ] && ENFORCE_GAS_ARGS="--enforce-gas-cost"
        # Run SMTChecker tests only when OPTIMIZE == 0
        DISABLE_SMTCHECKER=""
        [ "${OPTIMIZE}" != "0" ] && DISABLE_SMTCHECKER="-t !smtCheckerTests"

        if circleci_step_selected "$RUN_STEPS" "$STEP"
        then
            EVM="$EVM" \
            OPTIMIZE="$OPTIMIZE" \
            SOLTEST_FLAGS="$SOLTEST_FLAGS $ENFORCE_GAS_ARGS $EWASM_ARGS" \
            BOOST_TEST_ARGS="-t !@nooptions $DISABLE_SMTCHECKER" \
            "${REPODIR}/.circleci/soltest.sh"
        fi
        ((++STEP))
    done
done

((STEP == STEPS + 1)) || assertFail "Step counter not properly adjusted!"

#!/usr/bin/env bash
#
# Copyright (2023) The Delta Lake Project Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ---------------------------------------------------------------
# Docker integration tests for the Delta Lake quickstart image.
#
# Usage:
#   ./tests/test_docker.sh [IMAGE_NAME]
#
# IMAGE_NAME defaults to "delta_quickstart" if not provided.
# ---------------------------------------------------------------

set -euo pipefail

IMAGE="${1:-delta_quickstart}"
PASS=0
FAIL=0

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# ---------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------

run_test() {
  local description="$1"
  local cmd="$2"
  local user="${3:-NBuser}"

  printf "  %-60s" "${description}"
  if docker run --rm \
      --user "${user}" \
      --entrypoint bash \
      "${IMAGE}" -c "${cmd}" \
      >/dev/null 2>&1; then
    echo -e "${GREEN}PASS${RESET}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${RESET}"
    FAIL=$((FAIL + 1))
  fi
}

# Like run_test but also captures and prints stdout/stderr on failure for easier debugging.
run_test_verbose() {
  local description="$1"
  local cmd="$2"
  local user="${3:-NBuser}"
  local output

  printf "  %-60s" "${description}"
  if output=$(docker run --rm \
      --user "${user}" \
      --entrypoint bash \
      "${IMAGE}" -c "${cmd}" 2>&1); then
    echo -e "${GREEN}PASS${RESET}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${RESET}"
    echo -e "${YELLOW}    Output: ${output}${RESET}"
    FAIL=$((FAIL + 1))
  fi
}

section() {
  echo ""
  echo -e "${YELLOW}== $1 ==${RESET}"
}

# ---------------------------------------------------------------
# Pre-flight: verify the image exists
# ---------------------------------------------------------------

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  echo -e "${RED}ERROR: Image '${IMAGE}' not found. Build it first:${RESET}"
  echo "  docker build -t ${IMAGE} -f Dockerfile ."
  exit 1
fi

echo ""
echo "Running tests against image: ${IMAGE}"

# ---------------------------------------------------------------
# 1. System tools
# ---------------------------------------------------------------

section "System Tools"
run_test "vim is installed"  "vim --version"
run_test "curl is installed" "curl --version"
run_test "tree is installed" "tree --version"

# ---------------------------------------------------------------
# 2. Python runtime
# ---------------------------------------------------------------

section "Python Runtime"
run_test "python3 is available"         "python3 --version"
run_test "pip is available"             "pip --version"

# ---------------------------------------------------------------
# 3. Python package imports
# ---------------------------------------------------------------

section "Python Package Imports"
run_test "delta-spark imports cleanly"  "python3 -c 'import delta'"
run_test "deltalake imports cleanly"    "python3 -c 'import deltalake'"
run_test "polars imports cleanly"       "python3 -c 'import polars'"
run_test "pyarrow imports cleanly"      "python3 -c 'import pyarrow'"
run_test "pyspark imports cleanly"      "python3 -c 'import pyspark'"
run_test "jupyterlab imports cleanly"   "python3 -c 'import jupyterlab'"

# ---------------------------------------------------------------
# 4. Python package versions
# ---------------------------------------------------------------

section "Python Package Versions"
run_test "delta-spark version matches Dockerfile ARG" \
  "python3 -c \"
import delta
expected = '4.1.0'
actual = delta.__version__
assert actual == expected, f'Expected {expected}, got {actual}'
\""

run_test "deltalake version matches Dockerfile ARG" \
  "python3 -c \"
import deltalake
expected = '1.4.2'
actual = deltalake.__version__
assert actual == expected, f'Expected {expected}, got {actual}'
\""

run_test "polars version matches Dockerfile ARG" \
  "python3 -c \"
import polars
expected = '1.38.1'
actual = polars.__version__
assert actual == expected, f'Expected {expected}, got {actual}'
\""

run_test "pyarrow version matches Dockerfile ARG" \
  "python3 -c \"
import pyarrow
expected = '23.0.1'
actual = pyarrow.__version__
assert actual == expected, f'Expected {expected}, got {actual}'
\""

# ---------------------------------------------------------------
# 5. Spark
# ---------------------------------------------------------------

section "Apache Spark"
run_test "spark-submit is on PATH"  "spark-submit --version"
run_test "pyspark is on PATH"       "pyspark --version"

# ---------------------------------------------------------------
# 6. startup.sh artifact resolution
# ---------------------------------------------------------------

section "startup.sh artifact resolution"
run_test_verbose "startup.sh selects Spark 4.1 Delta artifact" \
  "set -euo pipefail
mkdir -p /tmp/mock-spark/bin
printf '%s\n' '#!/usr/bin/env bash' 'echo \"Spark version 4.1.1\" >&2' > /tmp/mock-spark/bin/spark-submit
printf '%s\n' '#!/usr/bin/env bash' 'echo \"\$*\"' > /tmp/mock-spark/bin/pyspark
chmod +x /tmp/mock-spark/bin/spark-submit /tmp/mock-spark/bin/pyspark
startup_output=\$(SPARK_HOME=/tmp/mock-spark DELTA_SPARK_VERSION=4.1.0 bash startup.sh 2>&1)
echo \"\$startup_output\"
[[ \"\$startup_output\" == *\"--packages io.delta:delta-spark_4.1_2.13:4.1.0\"* ]]"

run_test_verbose "startup.sh selects Spark 4.0 Delta artifact" \
  "set -euo pipefail
mkdir -p /tmp/mock-spark/bin
printf '%s\n' '#!/usr/bin/env bash' 'echo \"Spark version 4.0.3\" >&2' > /tmp/mock-spark/bin/spark-submit
printf '%s\n' '#!/usr/bin/env bash' 'echo \"\$*\"' > /tmp/mock-spark/bin/pyspark
chmod +x /tmp/mock-spark/bin/spark-submit /tmp/mock-spark/bin/pyspark
startup_output=\$(SPARK_HOME=/tmp/mock-spark DELTA_SPARK_VERSION=4.1.0 bash startup.sh 2>&1)
echo \"\$startup_output\"
[[ \"\$startup_output\" == *\"--packages io.delta:delta-spark_4.0_2.13:4.1.0\"* ]]"

# ---------------------------------------------------------------
# 7. Rust toolchain
# ---------------------------------------------------------------

section "Rust Toolchain"
run_test "rustc is available"       'source "$HOME/.cargo/env" && rustc --version'
run_test "cargo is available"       'source "$HOME/.cargo/env" && cargo --version'

# ---------------------------------------------------------------
# 8. Functional: delta-rs (Python) write/read via Polars
# ---------------------------------------------------------------

section "Functional: delta-rs + Polars"
run_test_verbose "write and read a Delta table with Polars" \
  "python3 -c \"
import polars as pl
table_path = '/tmp/test_polars_delta'

df = pl.DataFrame({'name': ['alice', 'bob'], 'age': [30, 25]})
df.write_delta(table_path)

result = pl.read_delta(table_path)
assert result.shape == (2, 2), f'Unexpected shape: {result.shape}'
assert sorted(result['name'].to_list()) == ['alice', 'bob']
print('Polars Delta write/read OK')
\""

run_test_verbose "append to a Delta table with Polars" \
  "python3 -c \"
import polars as pl
table_path = '/tmp/test_polars_delta_append'

df1 = pl.DataFrame({'name': ['alice'], 'age': [30]})
df1.write_delta(table_path)

df2 = pl.DataFrame({'name': ['bob'], 'age': [25]})
df2.write_delta(table_path, mode='append')

result = pl.read_delta(table_path)
assert result.shape == (2, 2), f'Unexpected shape after append: {result.shape}'
print('Polars Delta append OK')
\""

# ---------------------------------------------------------------
# 9. Functional: deltalake Python API
# ---------------------------------------------------------------

section "Functional: deltalake Python API"
run_test_verbose "DeltaTable reads file list and history" \
  "python3 -c \"
import polars as pl
from deltalake import DeltaTable

table_path = '/tmp/test_deltalake_api'

pl.DataFrame({'id': [1, 2, 3], 'value': ['a', 'b', 'c']}).write_delta(table_path)

dt = DeltaTable(table_path)
assert len(dt.file_uris()) > 0, 'Expected at least one file URI'
assert len(dt.history()) > 0, 'Expected non-empty history'
print('DeltaTable API OK')
\""

# ---------------------------------------------------------------
# Summary
# ---------------------------------------------------------------

TOTAL=$((PASS + FAIL))
echo ""
echo "-------------------------------------------------------"
printf "Results: ${GREEN}%d passed${RESET}, ${RED}%d failed${RESET} (${TOTAL} total)\n" "${PASS}" "${FAIL}"
echo "-------------------------------------------------------"
echo ""

if [ "${FAIL}" -gt 0 ]; then
  exit 1
fi

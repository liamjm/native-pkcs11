#!/bin/bash
# shellcheck source-path=SCRIPTDIR
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eux

# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
cd "$(dirname -- "$(readlink -f -- "$0")")"

NATIVE_PKCS11_TMPDIR=$(mktemp -d -p "${RUNNER_TEMP:-}") || return 1
export NATIVE_PKCS11_TMPDIR


. ../create_selfsigned.sh

cargo build -p native-pkcs11

#readonly LIBNATIVE_PATH="/usr/lib/x86_64-linux-gnu/libcredentialkit_pkcs11.so.0"
readonly LIBNATIVE_PATH="/usr/lib/x86_64-linux-gnu/libnative_pkcs11_credkit.so"
#readonly LIBNATIVE_PATH="/tmp/libnative_pkcs11_credkit.so"
#readonly LIBNATIVE_PATH="$PWD/../../target/debug/libnative_pkcs11.so"

echo "Testing libnative from $LIBNATIVE_PATH"

CLIENT_ROOT_CERT="/tmp/gecc_root.pem"



readonly PKCS11_CONFIG=$NATIVE_PKCS11_TMPDIR/pkcs11.cfg
cat <<EOF >"$PKCS11_CONFIG"
name = native-pkcs11
library = "$LIBNATIVE_PATH"
EOF

# readonly SERVER_KEY_P8=""
# readonly SERVER_CERT=""
# readonly SERVER_ROOT_CERT=""
# readonly CLIENT_ROOT_CERT=""

java \
  -Djava.security.debug=sunpkcs11,pkcs11keystore \
  -Djavax.net.debug=ssl:handshake \
  SunPKCS11ProviderTest.java "$PKCS11_CONFIG" \
  "$SERVER_KEY_P8" "$SERVER_CERT" "$SERVER_ROOT_CERT" "$CLIENT_ROOT_CERT"

echo "SUCCESS" >/dev/stderr

# NATIVE_PKCS11_LOG_STDERR=1 RUST_LOG=debug /usr/bin/java -jar -Djava.security.debug=sunpkcs11,pkcs11keystore -Djavax.net.debug=all  burpsuite_community_v2025.1.2.jar

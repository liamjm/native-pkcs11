#!/bin/bash
# Copyright 2022 Google LLC
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

set -e

# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
cd $(dirname -- "$( readlink -f -- "$0"; )")

cargo build --target aarch64-apple-darwin --target x86_64-apple-darwin -p native-pkcs11

lipo target/aarch64-apple-darwin/debug/libnative_pkcs11.dylib target/x86_64-apple-darwin/debug/libnative_pkcs11.dylib -create -output target/libnative_pkcs11.dylib

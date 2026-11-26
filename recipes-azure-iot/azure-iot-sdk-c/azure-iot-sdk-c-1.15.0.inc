# gitsm would fetch the submodules recursively: c-build-tools is nested in every
# submodule, which makes the checkout larger than 2 GB. The build needs only the
# first-level submodules, pinned to the commits of the main repo.
SRC_URI = " \
    git://github.com/Azure/azure-iot-sdk-c.git;protocol=https;nobranch=1;tag=LTS_10_2026 \
    git://github.com/Azure/azure-c-shared-utility.git;protocol=https;nobranch=1;name=c-utility;destsuffix=${BP}/c-utility \
    git://github.com/Azure/azure-umqtt-c.git;protocol=https;nobranch=1;name=umqtt;destsuffix=${BP}/umqtt \
    git://github.com/Azure/azure-uamqp-c.git;protocol=https;nobranch=1;name=uamqp;destsuffix=${BP}/uamqp \
    git://github.com/kgabis/parson.git;protocol=https;nobranch=1;name=parson;destsuffix=${BP}/deps/parson \
    git://github.com/Azure/azure-uhttp-c.git;protocol=https;nobranch=1;name=uhttp;destsuffix=${BP}/deps/uhttp \
    git://github.com/Azure/c-logging.git;protocol=https;nobranch=1;name=c-logging;destsuffix=${BP}/deps/c-logging \
    git://github.com/Azure/macro-utils-c.git;protocol=https;nobranch=1;name=macro-utils-c;destsuffix=${BP}/deps/azure-macro-utils-c \
    git://github.com/Azure/umock-c.git;protocol=https;nobranch=1;name=umock-c;destsuffix=${BP}/deps/umock-c \
    git://github.com/Azure/c-build-tools.git;protocol=https;nobranch=1;name=c-build-tools;destsuffix=${BP}/deps/c-build-tools \
    git://github.com/Azure/azure-utpm-c.git;protocol=https;nobranch=1;name=utpm;destsuffix=${BP}/provisioning_client/deps/utpm \
"
SRCREV = "97cb2a98767a101d7bfeb51436bd838727d7eef1"
SRCREV_c-utility = "c25e600c3fa42176323da919a1bd17dc2cc05d95"
SRCREV_umqtt = "7bd43b9792ad39036ec25b5763277ba01f04bb19"
SRCREV_uamqp = "49b6cf5d51b5fccd8d3961d1d4a1c5cfcf39e9a5"
SRCREV_parson = "ec53fb6528b45811df9db0db22cab96a94a96a11"
SRCREV_uhttp = "a26f2948556bd1f817fd1eac7c02f2554bfe2244"
SRCREV_c-logging = "504e7d4765adc718957cb32cf7699d9e9272c727"
SRCREV_macro-utils-c = "045636acd64c0edf67c1b07fcfc0901d0ecfbd64"
SRCREV_umock-c = "e54b586e00f26f36f8f96e389738b8c798ad6fb7"
SRCREV_c-build-tools = "b26bcf4a6a8eda025b1dce0a6bbfe02e2f7bb4e5"
SRCREV_utpm = "2b92a93b24b6052ba4eb06d000aa118f765b6a83"
SRCREV_FORMAT = "default"

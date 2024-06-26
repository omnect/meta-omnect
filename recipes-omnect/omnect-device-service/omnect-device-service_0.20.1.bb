# Auto-Generated by cargo-bitbake 0.3.16
#
inherit cargo

# If this is git based prefer versioned ones if they exist
# DEFAULT_PREFERENCE = "-1"

# how to get omnect-device-service could be as easy as but default to a git checkout:
# SRC_URI += "crate://crates.io/omnect-device-service/0.20.1"
SRC_URI += "git://github.com/omnect/omnect-device-service.git;protocol=https;nobranch=1;branch=main"
SRCREV = "6a53de2d03e63d1868f89aa0fdec2b55f5b350c0"
S = "${WORKDIR}/git"
CARGO_SRC_DIR = ""


# please note if you have entries that do not begin with crate://
# you must change them to how that package can be fetched
SRC_URI += " \
    crate://crates.io/actix-codec/0.5.2 \
    crate://crates.io/actix-http/3.7.0 \
    crate://crates.io/actix-macros/0.2.4 \
    crate://crates.io/actix-router/0.5.3 \
    crate://crates.io/actix-rt/2.10.0 \
    crate://crates.io/actix-server/2.4.0 \
    crate://crates.io/actix-service/2.0.2 \
    crate://crates.io/actix-utils/3.0.1 \
    crate://crates.io/actix-web-codegen/4.3.0 \
    crate://crates.io/actix-web/4.7.0 \
    crate://crates.io/addr2line/0.22.0 \
    crate://crates.io/adler/1.0.2 \
    crate://crates.io/ahash/0.8.11 \
    crate://crates.io/aho-corasick/1.1.3 \
    crate://crates.io/alloc-no-stdlib/2.0.4 \
    crate://crates.io/alloc-stdlib/0.2.2 \
    crate://crates.io/android-tzdata/0.1.1 \
    crate://crates.io/android_system_properties/0.1.5 \
    crate://crates.io/anyhow/1.0.86 \
    crate://crates.io/async-broadcast/0.5.1 \
    crate://crates.io/async-channel/2.3.1 \
    crate://crates.io/async-executor/1.12.0 \
    crate://crates.io/async-fs/1.6.0 \
    crate://crates.io/async-io/1.13.0 \
    crate://crates.io/async-io/2.3.3 \
    crate://crates.io/async-lock/2.8.0 \
    crate://crates.io/async-lock/3.4.0 \
    crate://crates.io/async-process/1.8.1 \
    crate://crates.io/async-recursion/1.1.1 \
    crate://crates.io/async-signal/0.2.8 \
    crate://crates.io/async-task/4.7.1 \
    crate://crates.io/async-trait/0.1.80 \
    crate://crates.io/atomic-waker/1.1.2 \
    crate://crates.io/atty/0.2.14 \
    crate://crates.io/autocfg/1.3.0 \
    crate://crates.io/backtrace/0.3.73 \
    crate://crates.io/base64/0.13.1 \
    crate://crates.io/base64/0.21.7 \
    crate://crates.io/base64/0.22.1 \
    crate://crates.io/bindgen/0.63.0 \
    crate://crates.io/bindgen/0.69.4 \
    crate://crates.io/bitflags/1.3.2 \
    crate://crates.io/bitflags/2.5.0 \
    crate://crates.io/block-buffer/0.10.4 \
    crate://crates.io/blocking/1.6.1 \
    crate://crates.io/brotli-decompressor/4.0.1 \
    crate://crates.io/brotli/6.0.0 \
    crate://crates.io/bumpalo/3.16.0 \
    crate://crates.io/byteorder/1.5.0 \
    crate://crates.io/bytes/1.6.0 \
    crate://crates.io/bytestring/1.3.1 \
    crate://crates.io/cc/1.0.99 \
    crate://crates.io/cexpr/0.6.0 \
    crate://crates.io/cfg-if/1.0.0 \
    crate://crates.io/cfg_aliases/0.1.1 \
    crate://crates.io/chrono/0.4.38 \
    crate://crates.io/clang-sys/1.8.1 \
    crate://crates.io/concurrent-queue/2.5.0 \
    crate://crates.io/convert_case/0.4.0 \
    crate://crates.io/cookie/0.16.2 \
    crate://crates.io/core-foundation-sys/0.8.6 \
    crate://crates.io/core-foundation/0.9.4 \
    crate://crates.io/cp_r/0.5.1 \
    crate://crates.io/cpufeatures/0.2.12 \
    crate://crates.io/crc32fast/1.4.2 \
    crate://crates.io/crossbeam-channel/0.5.13 \
    crate://crates.io/crossbeam-utils/0.8.20 \
    crate://crates.io/crypto-common/0.1.6 \
    crate://crates.io/darling/0.20.9 \
    crate://crates.io/darling_core/0.20.9 \
    crate://crates.io/darling_macro/0.20.9 \
    crate://crates.io/derivative/2.2.0 \
    crate://crates.io/derive_more/0.99.17 \
    crate://crates.io/difflib/0.4.0 \
    crate://crates.io/digest/0.10.7 \
    crate://crates.io/displaydoc/0.2.4 \
    crate://crates.io/dotenvy/0.15.7 \
    crate://crates.io/downcast/0.11.0 \
    crate://crates.io/either/1.12.0 \
    crate://crates.io/encoding_rs/0.8.34 \
    crate://crates.io/enum_dispatch/0.3.13 \
    crate://crates.io/enumflags2/0.7.10 \
    crate://crates.io/enumflags2_derive/0.7.10 \
    crate://crates.io/env_logger/0.10.2 \
    crate://crates.io/env_logger/0.8.4 \
    crate://crates.io/equivalent/1.0.1 \
    crate://crates.io/errno/0.3.9 \
    crate://crates.io/event-listener-strategy/0.5.2 \
    crate://crates.io/event-listener/2.5.3 \
    crate://crates.io/event-listener/3.1.0 \
    crate://crates.io/event-listener/5.3.1 \
    crate://crates.io/fastrand/1.9.0 \
    crate://crates.io/fastrand/2.1.0 \
    crate://crates.io/filetime/0.2.23 \
    crate://crates.io/flate2/1.0.30 \
    crate://crates.io/float-cmp/0.9.0 \
    crate://crates.io/fnv/1.0.7 \
    crate://crates.io/foreign-types-shared/0.1.1 \
    crate://crates.io/foreign-types/0.3.2 \
    crate://crates.io/form_urlencoded/1.2.1 \
    crate://crates.io/fragile/2.0.0 \
    crate://crates.io/freedesktop_entry_parser/1.3.0 \
    crate://crates.io/fsevent-sys/4.1.0 \
    crate://crates.io/futures-channel/0.3.30 \
    crate://crates.io/futures-core/0.3.30 \
    crate://crates.io/futures-executor/0.3.30 \
    crate://crates.io/futures-io/0.3.30 \
    crate://crates.io/futures-lite/1.13.0 \
    crate://crates.io/futures-lite/2.3.0 \
    crate://crates.io/futures-macro/0.3.30 \
    crate://crates.io/futures-sink/0.3.30 \
    crate://crates.io/futures-task/0.3.30 \
    crate://crates.io/futures-util/0.3.30 \
    crate://crates.io/futures/0.3.30 \
    crate://crates.io/generic-array/0.14.7 \
    crate://crates.io/getrandom/0.2.15 \
    crate://crates.io/gimli/0.29.0 \
    crate://crates.io/glob/0.3.1 \
    crate://crates.io/h2/0.3.26 \
    crate://crates.io/h2/0.4.5 \
    crate://crates.io/hashbrown/0.12.3 \
    crate://crates.io/hashbrown/0.14.5 \
    crate://crates.io/headers-core/0.2.0 \
    crate://crates.io/headers/0.3.9 \
    crate://crates.io/heck/0.4.1 \
    crate://crates.io/hermit-abi/0.1.19 \
    crate://crates.io/hermit-abi/0.3.9 \
    crate://crates.io/hex/0.4.3 \
    crate://crates.io/home/0.5.9 \
    crate://crates.io/http-body-util/0.1.2 \
    crate://crates.io/http-body/0.4.6 \
    crate://crates.io/http-body/1.0.0 \
    crate://crates.io/http/0.2.12 \
    crate://crates.io/http/1.1.0 \
    crate://crates.io/httparse/1.9.3 \
    crate://crates.io/httpdate/1.0.3 \
    crate://crates.io/humantime/2.1.0 \
    crate://crates.io/hyper-openssl/0.9.2 \
    crate://crates.io/hyper-proxy/0.9.1 \
    crate://crates.io/hyper-timeout/0.4.1 \
    crate://crates.io/hyper-tls/0.6.0 \
    crate://crates.io/hyper-util/0.1.5 \
    crate://crates.io/hyper/0.14.29 \
    crate://crates.io/hyper/1.3.1 \
    crate://crates.io/iana-time-zone-haiku/0.1.2 \
    crate://crates.io/iana-time-zone/0.1.60 \
    crate://crates.io/icu_collections/1.5.0 \
    crate://crates.io/icu_locid/1.5.0 \
    crate://crates.io/icu_locid_transform/1.5.0 \
    crate://crates.io/icu_locid_transform_data/1.5.0 \
    crate://crates.io/icu_normalizer/1.5.0 \
    crate://crates.io/icu_normalizer_data/1.5.0 \
    crate://crates.io/icu_properties/1.5.0 \
    crate://crates.io/icu_properties_data/1.5.0 \
    crate://crates.io/icu_provider/1.5.0 \
    crate://crates.io/icu_provider_macros/1.5.0 \
    crate://crates.io/ident_case/1.0.1 \
    crate://crates.io/idna/1.0.0 \
    crate://crates.io/indexmap/1.9.3 \
    crate://crates.io/indexmap/2.2.6 \
    crate://crates.io/inotify-sys/0.1.5 \
    crate://crates.io/inotify/0.9.6 \
    crate://crates.io/instant/0.1.13 \
    crate://crates.io/io-lifetimes/1.0.11 \
    crate://crates.io/ipnet/2.9.0 \
    crate://crates.io/is-terminal/0.4.12 \
    crate://crates.io/itertools/0.10.5 \
    crate://crates.io/itertools/0.12.1 \
    crate://crates.io/itoa/1.0.11 \
    crate://crates.io/jobserver/0.1.31 \
    crate://crates.io/js-sys/0.3.69 \
    crate://crates.io/kqueue-sys/1.0.4 \
    crate://crates.io/kqueue/1.0.8 \
    crate://crates.io/language-tags/0.3.2 \
    crate://crates.io/lazy_static/1.4.0 \
    crate://crates.io/lazycell/1.3.0 \
    crate://crates.io/libc/0.2.155 \
    crate://crates.io/libloading/0.8.3 \
    crate://crates.io/linked-hash-map/0.5.6 \
    crate://crates.io/linked_hash_set/0.1.4 \
    crate://crates.io/linux-raw-sys/0.3.8 \
    crate://crates.io/linux-raw-sys/0.4.14 \
    crate://crates.io/litemap/0.7.3 \
    crate://crates.io/local-channel/0.1.5 \
    crate://crates.io/local-waker/0.1.4 \
    crate://crates.io/lock_api/0.4.12 \
    crate://crates.io/log-panics/2.1.0 \
    crate://crates.io/log/0.4.21 \
    crate://crates.io/memchr/2.7.2 \
    crate://crates.io/memoffset/0.7.1 \
    crate://crates.io/memoffset/0.9.1 \
    crate://crates.io/mime/0.3.17 \
    crate://crates.io/minimal-lexical/0.2.1 \
    crate://crates.io/miniz_oxide/0.7.3 \
    crate://crates.io/mio/0.8.11 \
    crate://crates.io/mockall/0.11.4 \
    crate://crates.io/mockall_derive/0.11.4 \
    crate://crates.io/native-tls/0.2.12 \
    crate://crates.io/network-interface/0.1.6 \
    crate://crates.io/nix/0.26.4 \
    crate://crates.io/nix/0.28.0 \
    crate://crates.io/nom/7.1.3 \
    crate://crates.io/normalize-line-endings/0.3.0 \
    crate://crates.io/notify-debouncer-mini/0.3.0 \
    crate://crates.io/notify/6.1.1 \
    crate://crates.io/num-bigint/0.4.5 \
    crate://crates.io/num-complex/0.4.6 \
    crate://crates.io/num-derive/0.4.2 \
    crate://crates.io/num-integer/0.1.46 \
    crate://crates.io/num-iter/0.1.45 \
    crate://crates.io/num-rational/0.4.2 \
    crate://crates.io/num-traits/0.2.19 \
    crate://crates.io/num/0.4.3 \
    crate://crates.io/num_cpus/1.16.0 \
    crate://crates.io/object/0.36.0 \
    crate://crates.io/once_cell/1.19.0 \
    crate://crates.io/openssl-macros/0.1.1 \
    crate://crates.io/openssl-probe/0.1.5 \
    crate://crates.io/openssl-sys/0.9.102 \
    crate://crates.io/openssl/0.10.64 \
    crate://crates.io/ordered-stream/0.2.0 \
    crate://crates.io/parking/2.2.0 \
    crate://crates.io/parking_lot/0.12.3 \
    crate://crates.io/parking_lot_core/0.9.10 \
    crate://crates.io/paste/1.0.15 \
    crate://crates.io/peeking_take_while/0.1.2 \
    crate://crates.io/percent-encoding/2.3.1 \
    crate://crates.io/pin-project-internal/1.1.5 \
    crate://crates.io/pin-project-lite/0.2.14 \
    crate://crates.io/pin-project/1.1.5 \
    crate://crates.io/pin-utils/0.1.0 \
    crate://crates.io/piper/0.2.3 \
    crate://crates.io/pkg-config/0.3.30 \
    crate://crates.io/polling/2.8.0 \
    crate://crates.io/polling/3.7.1 \
    crate://crates.io/ppv-lite86/0.2.17 \
    crate://crates.io/predicates-core/1.0.6 \
    crate://crates.io/predicates-tree/1.0.9 \
    crate://crates.io/predicates/2.1.5 \
    crate://crates.io/prettyplease/0.2.20 \
    crate://crates.io/proc-macro-crate/1.3.1 \
    crate://crates.io/proc-macro2/1.0.85 \
    crate://crates.io/quote/1.0.36 \
    crate://crates.io/rand/0.8.5 \
    crate://crates.io/rand_chacha/0.3.1 \
    crate://crates.io/rand_core/0.6.4 \
    crate://crates.io/redox_syscall/0.4.1 \
    crate://crates.io/redox_syscall/0.5.1 \
    crate://crates.io/regex-automata/0.4.7 \
    crate://crates.io/regex-lite/0.1.6 \
    crate://crates.io/regex-syntax/0.8.4 \
    crate://crates.io/regex/1.10.5 \
    crate://crates.io/reqwest/0.12.4 \
    crate://crates.io/rustc-demangle/0.1.24 \
    crate://crates.io/rustc-hash/1.1.0 \
    crate://crates.io/rustc_version/0.4.0 \
    crate://crates.io/rustix/0.37.27 \
    crate://crates.io/rustix/0.38.34 \
    crate://crates.io/rustls-pemfile/2.1.2 \
    crate://crates.io/rustls-pki-types/1.7.0 \
    crate://crates.io/rustversion/1.0.17 \
    crate://crates.io/ryu/1.0.18 \
    crate://crates.io/same-file/1.0.6 \
    crate://crates.io/schannel/0.1.23 \
    crate://crates.io/scopeguard/1.2.0 \
    crate://crates.io/sd-notify/0.4.1 \
    crate://crates.io/security-framework-sys/2.11.0 \
    crate://crates.io/security-framework/2.11.0 \
    crate://crates.io/semver/1.0.23 \
    crate://crates.io/serde/1.0.203 \
    crate://crates.io/serde_derive/1.0.203 \
    crate://crates.io/serde_json/1.0.117 \
    crate://crates.io/serde_repr/0.1.19 \
    crate://crates.io/serde_urlencoded/0.7.1 \
    crate://crates.io/serde_with/2.3.3 \
    crate://crates.io/serde_with_macros/2.3.3 \
    crate://crates.io/sha1/0.10.6 \
    crate://crates.io/shlex/1.3.0 \
    crate://crates.io/signal-hook-registry/1.4.2 \
    crate://crates.io/signal-hook-tokio/0.3.1 \
    crate://crates.io/signal-hook/0.3.17 \
    crate://crates.io/slab/0.4.9 \
    crate://crates.io/smallvec/1.13.2 \
    crate://crates.io/socket2/0.4.10 \
    crate://crates.io/socket2/0.5.7 \
    crate://crates.io/stable_deref_trait/1.2.0 \
    crate://crates.io/static_assertions/1.1.0 \
    crate://crates.io/stdext/0.3.3 \
    crate://crates.io/strsim/0.11.1 \
    crate://crates.io/strum/0.24.1 \
    crate://crates.io/strum_macros/0.24.3 \
    crate://crates.io/syn/1.0.109 \
    crate://crates.io/syn/2.0.66 \
    crate://crates.io/sync_wrapper/0.1.2 \
    crate://crates.io/synstructure/0.13.1 \
    crate://crates.io/system-configuration-sys/0.5.0 \
    crate://crates.io/system-configuration/0.5.1 \
    crate://crates.io/systemd-zbus/0.1.1 \
    crate://crates.io/tempfile/3.10.1 \
    crate://crates.io/termcolor/1.4.1 \
    crate://crates.io/termtree/0.4.1 \
    crate://crates.io/thiserror-impl/1.0.61 \
    crate://crates.io/thiserror/1.0.61 \
    crate://crates.io/time-core/0.1.1 \
    crate://crates.io/time-macros/0.2.10 \
    crate://crates.io/time/0.3.23 \
    crate://crates.io/tinystr/0.7.6 \
    crate://crates.io/tokio-io-timeout/1.2.0 \
    crate://crates.io/tokio-macros/2.3.0 \
    crate://crates.io/tokio-native-tls/0.3.1 \
    crate://crates.io/tokio-openssl/0.6.4 \
    crate://crates.io/tokio-util/0.7.11 \
    crate://crates.io/tokio/1.38.0 \
    crate://crates.io/toml_datetime/0.6.6 \
    crate://crates.io/toml_edit/0.19.15 \
    crate://crates.io/tower-layer/0.3.2 \
    crate://crates.io/tower-service/0.3.2 \
    crate://crates.io/tower/0.4.13 \
    crate://crates.io/tracing-attributes/0.1.27 \
    crate://crates.io/tracing-core/0.1.32 \
    crate://crates.io/tracing/0.1.40 \
    crate://crates.io/try-lock/0.2.5 \
    crate://crates.io/typenum/1.17.0 \
    crate://crates.io/uds_windows/1.1.0 \
    crate://crates.io/unicode-ident/1.0.12 \
    crate://crates.io/url/2.5.1 \
    crate://crates.io/utf16_iter/1.0.5 \
    crate://crates.io/utf8_iter/1.0.4 \
    crate://crates.io/uuid/1.8.0 \
    crate://crates.io/vcpkg/0.2.15 \
    crate://crates.io/version_check/0.9.4 \
    crate://crates.io/waker-fn/1.2.0 \
    crate://crates.io/walkdir/2.5.0 \
    crate://crates.io/want/0.3.1 \
    crate://crates.io/wasi/0.11.0+wasi-snapshot-preview1 \
    crate://crates.io/wasm-bindgen-backend/0.2.92 \
    crate://crates.io/wasm-bindgen-futures/0.4.42 \
    crate://crates.io/wasm-bindgen-macro-support/0.2.92 \
    crate://crates.io/wasm-bindgen-macro/0.2.92 \
    crate://crates.io/wasm-bindgen-shared/0.2.92 \
    crate://crates.io/wasm-bindgen/0.2.92 \
    crate://crates.io/web-sys/0.3.69 \
    crate://crates.io/which/4.4.2 \
    crate://crates.io/winapi-i686-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi-util/0.1.8 \
    crate://crates.io/winapi-x86_64-pc-windows-gnu/0.4.0 \
    crate://crates.io/winapi/0.3.9 \
    crate://crates.io/windows-core/0.52.0 \
    crate://crates.io/windows-sys/0.48.0 \
    crate://crates.io/windows-sys/0.52.0 \
    crate://crates.io/windows-targets/0.48.5 \
    crate://crates.io/windows-targets/0.52.5 \
    crate://crates.io/windows_aarch64_gnullvm/0.48.5 \
    crate://crates.io/windows_aarch64_gnullvm/0.52.5 \
    crate://crates.io/windows_aarch64_msvc/0.48.5 \
    crate://crates.io/windows_aarch64_msvc/0.52.5 \
    crate://crates.io/windows_i686_gnu/0.48.5 \
    crate://crates.io/windows_i686_gnu/0.52.5 \
    crate://crates.io/windows_i686_gnullvm/0.52.5 \
    crate://crates.io/windows_i686_msvc/0.48.5 \
    crate://crates.io/windows_i686_msvc/0.52.5 \
    crate://crates.io/windows_x86_64_gnu/0.48.5 \
    crate://crates.io/windows_x86_64_gnu/0.52.5 \
    crate://crates.io/windows_x86_64_gnullvm/0.48.5 \
    crate://crates.io/windows_x86_64_gnullvm/0.52.5 \
    crate://crates.io/windows_x86_64_msvc/0.48.5 \
    crate://crates.io/windows_x86_64_msvc/0.52.5 \
    crate://crates.io/winnow/0.5.40 \
    crate://crates.io/winreg/0.52.0 \
    crate://crates.io/write16/1.0.0 \
    crate://crates.io/writeable/0.5.5 \
    crate://crates.io/xdg-home/1.2.0 \
    crate://crates.io/yoke-derive/0.7.4 \
    crate://crates.io/yoke/0.7.4 \
    crate://crates.io/zbus/3.14.1 \
    crate://crates.io/zbus_macros/3.14.1 \
    crate://crates.io/zbus_names/2.6.1 \
    crate://crates.io/zerocopy-derive/0.7.34 \
    crate://crates.io/zerocopy/0.7.34 \
    crate://crates.io/zerofrom-derive/0.1.4 \
    crate://crates.io/zerofrom/0.1.4 \
    crate://crates.io/zerovec-derive/0.10.2 \
    crate://crates.io/zerovec/0.10.2 \
    crate://crates.io/zstd-safe/7.1.0 \
    crate://crates.io/zstd-sys/2.0.10+zstd.1.5.6 \
    crate://crates.io/zstd/0.13.1 \
    crate://crates.io/zvariant/3.15.2 \
    crate://crates.io/zvariant_derive/3.15.2 \
    crate://crates.io/zvariant_utils/1.0.1 \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-cert-client-async;destsuffix=aziot-cert-client-async \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-cert-common-http;destsuffix=aziot-cert-common-http \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-cert-common;destsuffix=aziot-cert-common \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-certd-config;destsuffix=aziot-certd-config \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-identity-client-async;destsuffix=aziot-identity-client-async \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-identity-common-http;destsuffix=aziot-identity-common-http \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-identity-common;destsuffix=aziot-identity-common \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-identityd-config;destsuffix=aziot-identityd-config \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-key-client-async;destsuffix=aziot-key-client-async \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-key-common-http;destsuffix=aziot-key-common-http \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-key-common;destsuffix=aziot-key-common \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=aziot-keyd-config;destsuffix=aziot-keyd-config \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=cert-renewal;destsuffix=cert-renewal \
    git://github.com/Azure/iot-identity-service.git;protocol=https;nobranch=1;name=http-common;destsuffix=http-common \
    git://github.com/omnect/azure-iot-sdk-sys.git;protocol=https;nobranch=1;name=azure-iot-sdk-sys;destsuffix=azure-iot-sdk-sys \
    git://github.com/omnect/azure-iot-sdk.git;protocol=https;nobranch=1;name=azure-iot-sdk;destsuffix=azure-iot-sdk \
    git://github.com/omnect/eis-utils.git;protocol=https;nobranch=1;name=eis-utils;destsuffix=eis-utils \
    git://github.com/omnect/modemmanager-sys.git;protocol=https;nobranch=1;name=modemmanager-sys;destsuffix=modemmanager-sys \
    git://github.com/omnect/modemmanager.git;protocol=https;nobranch=1;name=modemmanager;destsuffix=modemmanager \
"

SRCREV_FORMAT .= "_aziot-cert-client-async"
SRCREV_aziot-cert-client-async = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-cert-client-async"
SRCREV_FORMAT .= "_aziot-cert-common"
SRCREV_aziot-cert-common = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-cert-common"
SRCREV_FORMAT .= "_aziot-cert-common-http"
SRCREV_aziot-cert-common-http = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-cert-common-http"
SRCREV_FORMAT .= "_aziot-certd-config"
SRCREV_aziot-certd-config = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-certd-config"
SRCREV_FORMAT .= "_aziot-identity-client-async"
SRCREV_aziot-identity-client-async = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-client-async"
SRCREV_FORMAT .= "_aziot-identity-common"
SRCREV_aziot-identity-common = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-common"
SRCREV_FORMAT .= "_aziot-identity-common-http"
SRCREV_aziot-identity-common-http = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identity-common-http"
SRCREV_FORMAT .= "_aziot-identityd-config"
SRCREV_aziot-identityd-config = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-identityd-config"
SRCREV_FORMAT .= "_aziot-key-client-async"
SRCREV_aziot-key-client-async = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-client-async"
SRCREV_FORMAT .= "_aziot-key-common"
SRCREV_aziot-key-common = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-common"
SRCREV_FORMAT .= "_aziot-key-common-http"
SRCREV_aziot-key-common-http = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-key-common-http"
SRCREV_FORMAT .= "_aziot-keyd-config"
SRCREV_aziot-keyd-config = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/aziot-keyd-config"
SRCREV_FORMAT .= "_azure-iot-sdk"
SRCREV_azure-iot-sdk = "0.13.0"
EXTRA_OECARGO_PATHS += "${WORKDIR}/azure-iot-sdk"
SRCREV_FORMAT .= "_azure-iot-sdk-sys"
SRCREV_azure-iot-sdk-sys = "0.6.0"
EXTRA_OECARGO_PATHS += "${WORKDIR}/azure-iot-sdk-sys"
SRCREV_FORMAT .= "_cert-renewal"
SRCREV_cert-renewal = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/cert-renewal"
SRCREV_FORMAT .= "_eis-utils"
SRCREV_eis-utils = "0.3.2"
EXTRA_OECARGO_PATHS += "${WORKDIR}/eis-utils"
SRCREV_FORMAT .= "_http-common"
SRCREV_http-common = "1.4.7"
EXTRA_OECARGO_PATHS += "${WORKDIR}/http-common"
SRCREV_FORMAT .= "_modemmanager"
SRCREV_modemmanager = "0.3.0"
EXTRA_OECARGO_PATHS += "${WORKDIR}/modemmanager"
SRCREV_FORMAT .= "_modemmanager-sys"
SRCREV_modemmanager-sys = "0.1.0"
EXTRA_OECARGO_PATHS += "${WORKDIR}/modemmanager-sys"

# FIXME: update generateme with the real MD5 of the license file
LIC_FILES_CHKSUM = " \
    file://MIT OR Apache-2.0;md5=generateme \
"

SUMMARY = "This service allows remote features like: user fw update consent, factory reset, network adapter status and reboot."
HOMEPAGE = "https://www.omnect.io/home"
LICENSE = "MIT OR Apache-2.0"

# includes this file if it exists but does not fail
# this is useful for anything you may want to override from
# what cargo-bitbake generates.
include omnect-device-service-${PV}.inc
include omnect-device-service.inc

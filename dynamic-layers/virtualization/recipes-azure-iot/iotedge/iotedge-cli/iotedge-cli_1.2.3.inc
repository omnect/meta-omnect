export VERSION = "1.2.3"

# ignore all instances of #[warn], #[deny], and #[forbid] lint directives
# otherwise edgelet-docker will fail caused by #[deny(rust_2018_idioms)]
RUSTFLAGS += "--cap-lints allow"

# kas patches

Patches applied by kas to the upstream layers it fetches. A kas repo entry gets exactly one
patch, always `p001`.

Most layers need a single patch (`<layer>_layerdir.patch`, which exports `LAYERDIR_<layer>` so
meta-omnect can reference the layer's files), and `p001` points at it directly.

`ext/_openembedded-core` currently needs more than one, so its `p001` points at the generated
`oe.patch` instead. Glob order is the apply order and the shell collates globs by locale, so
regenerate and verify under a fixed collation:

    export LC_ALL=C
    cat kas/patches/oe_*.patch > kas/patches/oe.patch
    cmp <(cat kas/patches/oe_*.patch) kas/patches/oe.patch

The `oe_*.patch` files are the maintainable sources and are edited individually; `oe.patch` is a
generated artifact that is tracked so kas can consume it. A source is dropped once upstream
makes it unnecessary - `oe_rust-1.97.1.patch`, for example, retires when oe-core ships
rust >= 1.97.1, while `oe_layerdir.patch` is permanent.

`.github/workflows/kas-patch-checker.yml` runs the same `cmp` on every pull request, so a
forgotten regeneration fails CI instead of silently building a stale concatenation.

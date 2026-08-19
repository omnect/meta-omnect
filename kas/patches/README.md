# kas patches

Patches applied by kas to the upstream layers it fetches. A kas repo entry gets exactly one
patch, always `p001`.

Most layers need a single patch (`<layer>_layerdir.patch`, which exports `LAYERDIR_<layer>` so
meta-omnect can reference the layer's files), and `p001` points at it directly.

`ext/_openembedded-core` currently needs more than one, so its `p001` points at the generated
`oe.patch` instead:

    cat kas/patches/oe_*.patch > kas/patches/oe.patch

The `oe_*.patch` files are the maintainable sources and are edited individually; `oe.patch` is a
generated artifact that is tracked so kas can consume it. There is no script — after editing any
`oe_*.patch`, regenerate by hand and verify with:

    cmp <(cat kas/patches/oe_*.patch) kas/patches/oe.patch

Current sources, in glob (= apply) order:

| file | retires when |
|---|---|
| `oe_layerdir.patch` | never |
| `oe_rust-1.97.1.patch` | oe-core ships rust >= 1.97.1 |

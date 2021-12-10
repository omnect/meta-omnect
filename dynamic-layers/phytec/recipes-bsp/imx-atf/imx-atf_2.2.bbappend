FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = "\
    file://0001-plat-imx8mm-use-uart3-as-console.patch \
    file://0002-plat-imx8mn-use-uart3-as-console.patch \
"

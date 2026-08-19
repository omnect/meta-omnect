# nspr-dev is the only recipe in the image build that requires target perl, and we
# never install dev packages. Dropping the dependency keeps the perl recipe out of
# the build and out of the SBOM, where it otherwise shows up as a shipped
# component although no perl file is in the image.
RDEPENDS:${PN}-dev:remove = "perl"

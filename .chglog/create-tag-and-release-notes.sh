#/bin/bash

set -e

# get current yocto-version
yocto_release=$(yq '.env.OE_VERSION' kas/distro/oe.yaml)

# set prod subscription
az account set --subscription "b94a1716-806f-4b00-b17c-8924be76e728"

# get number of existing releases based on current yocto-version
release_incr=$(az storage blob list --account-name omnectsharedprodst --container-name release-notes --prefix release-notes-"${yocto_release}"v  --num-results "*" --query "length(@)")

tag="${yocto_release}"v$(($release_incr + 1))

echo new tag is: $tag

# create signed tag
git tag -s "$tag" -m ""

# create release-notes
docker run -v "$PWD":/workdir quay.io/git-chglog/git-chglog --output release-notes-"$tag".md  "$tag"
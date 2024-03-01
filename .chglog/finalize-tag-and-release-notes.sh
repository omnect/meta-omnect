#/bin/bash

set -e

[[ ! "$#" -eq 1 ]] && echo unexpected number of parameters. tag expected. && exit 1

release_notes=release-notes-$1.md

[[ ! -f "${release_notes}" ]] && echo file does not exist "${release_notes}" && exit 1

# upload release-notes to blobstorage
az storage blob upload --account-name omnectsharedprodst --container-name release-notes --file $(readlink -f "${release_notes}")

# set link release-notes link as tag message
git tag $1 -f -a -s -m "https://omnectsharedprodst.blob.core.windows.net/release-notes/release-notes-4.0.16v1.md"

# push tag
git push upstream $1
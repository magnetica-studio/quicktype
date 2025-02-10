#!/usr/bin/env bash

set -e

./script/patch-npm-version.ts

VERSION=$(jq -r '.version' package.json )
npm version $VERSION --workspaces --force

# Publish core
pushd packages/quicktype-core
npm publish --access public
popd

# Publish typescript input
pushd packages/quicktype-typescript-input
jq --arg version $VERSION \
    '.dependencies."@novonotes/quicktype-core" = $version' \
    package.json > package.1.json
mv package.1.json package.json
npm publish --access public
popd

# Publish graphql input
pushd packages/quicktype-graphql-input
jq --arg version $VERSION \
    '.dependencies."@novonotes/quicktype-core" = $version' \
    package.json > package.1.json
mv package.1.json package.json
npm publish --access public
popd

# pubish quicktype
jq --arg version $VERSION \
    '.dependencies."@novonotes/quicktype-core" = $version | .dependencies."@novonotes/quicktype-graphql-input" = $version | .dependencies."@novonotes/quicktype-typescript-input" = $version' \
    package.json > package.1.json
mv package.1.json package.json
npm publish --access public


# Publish vscode extension
# pushd packages/quicktype-vscode
# npm run pub
# popd
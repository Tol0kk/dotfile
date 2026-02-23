#!/bin/bash
set -e

# Parse the JSON input from Terraform (optional, if you want to pass arguments)
eval "$(jq -r '@sh "FLAKE_ATTR=\(.flake_attr)"')"

echo "🔨  Starting NixOS Build for ${FLAKE_ATTR}..." >&2
echo "    (This may take a while)..." >&2

OUT_PATH=$(nix build "${FLAKE_ATTR}" --print-out-paths --no-link)

if [ -d "$OUT_PATH" ]; then
    # Find the first .qcow2 file inside the directory
    IMAGE_FILE=$(find "$OUT_PATH" -name "*.qcow2" -type f | head -n 1)

    if [ -z "$IMAGE_FILE" ]; then
        echo "❌  Error: Build successful, but no .qcow2 file found in ${OUT_PATH}" >&2
        exit 1
    fi
else
    # The output is already a file
    IMAGE_FILE="$OUT_PATH"
fi

echo "✅  Build complete: ${OUT_PATH}" >&2

# Output JSON for Terraform
jq -n --arg path "$IMAGE_FILE" '{"image_path":$path}'

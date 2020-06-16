#!/usr/bin/env sh
# Generate manifest.tmpl
set -euf

docker_image=$1
shift

cat <<EOF >./manifest.tmpl
image: phasecorex/${docker_image}:{{#if build.tag}}{{trimPrefix "v" build.tag}}{{else}}latest{{/if}}
{{#if build.tags}}
tags:
{{#each build.tags}}
  - {{this}}
{{/each}}
{{/if}}
manifests:
EOF

for arch in "$@"; do
    case ${arch} in
    amd64)
        tag_arch="amd64"
        os="linux"
        variant=""
        ;;
    arm32v5)
        tag_arch="arm"
        os="linux"
        variant="v5"
        ;;
    arm32v6)
        tag_arch="arm"
        os="linux"
        variant="v6"
        ;;
    arm32v7)
        tag_arch="arm"
        os="linux"
        variant="v7"
        ;;
    arm64v8)
        tag_arch="arm64"
        os="linux"
        variant="v8"
        ;;
    *)
        echo ERROR: Unknown tag arch.
        exit 1
        ;;
    esac
    cat <<EOF >>./manifest.tmpl
  -
    image: phasecorex/${docker_image}:{{#if build.tag}}{{trimPrefix "v" build.tag}}-{{/if}}${arch}
    platform:
      architecture: ${tag_arch}
      os: ${os}
EOF

    if [ -n "${variant}" ]; then
        cat <<EOF >>./manifest.tmpl
      variant: ${variant}
EOF
    fi
done

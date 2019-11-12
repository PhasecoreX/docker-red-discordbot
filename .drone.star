def main(ctx):
    image_name = "phasecorex/red-discordbot"
    base_image_name = "phasecorex/user-python:3.7-slim"
    all_image_tags_arches = [
        {
            "tags": ["noaudio"],
            "arches": ["arm64v8", "arm32v7", "arm32v5", "amd64"],
            "dockerfile": "Dockerfile.noaudio",
        },
        {
            "tags": ["audio", "latest"],
            "arches": ["arm64v8", "arm32v7", "arm32v5", "amd64"],
        },
        {
            "tags": ["full"],
            "arches": ["arm64v8", "arm32v7", "arm32v5", "amd64"],
            "dockerfile": "Dockerfile.full",
        },
    ]
    other_options = {"build_args_from_env": ["DRONE_COMMIT_SHA"]}

    return generate(image_name, base_image_name, all_image_tags_arches, other_options)


def generate(image_name, base_image_name, all_image_tags_arches, other_options):
    depends_on_manifests = []
    for image_tags_arches in all_image_tags_arches:
        depends_on_manifests.append(
            _get_pipeline_manifest_name(image_name, image_tags_arches["tags"])
        )

    result = (
        gather_all_pipeline_build(
            image_name, base_image_name, all_image_tags_arches, other_options
        )
        + gather_all_pipeline_manifest(image_name, all_image_tags_arches)
        + [pipeline_notify(depends_on_manifests)]
    )
    if (
        "downstream_builds" in other_options
        and other_options["downstream_builds"] != None
    ):
        result.append(
            pipeline_downstream_build(
                depends_on_manifests, other_options["downstream_builds"]
            )
        )
    return result


def gather_all_pipeline_build(
    image_name, base_image_name, all_image_tags_arches, other_options
):
    # One for each architecture
    result = []
    all_arches = {}
    for image_tags_arches in all_image_tags_arches:
        for image_arch in image_tags_arches["arches"]:
            base_image = base_image_name
            if base_image.startswith("library/"):
                if ":" in base_image_name:
                    base_image = "{image_arch}/{image_name}".format(
                        image_arch=image_arch, image_name=base_image_name[8:]
                    )
                else:
                    base_tag = (
                        image_tags_arches["base_tag"]
                        if "base_tag" in image_tags_arches
                        else _correct_image_tag(image_tags_arches["tags"])
                    )
                    base_image = "{image_arch}/{image_name}:{tag}".format(
                        image_arch=image_arch,
                        image_name=base_image_name[8:],
                        tag=base_tag,
                    )
            else:
                base_image += "-" + image_arch
            arch_dict_value = {
                "base_image": base_image,
                "dockerfile": (
                    image_tags_arches["dockerfile"]
                    if "dockerfile" in image_tags_arches
                    else "Dockerfile"
                ),
                "tags": image_tags_arches["tags"],
            }
            if image_arch in all_arches:
                all_arches[image_arch].append(arch_dict_value)
            else:
                all_arches[image_arch] = [arch_dict_value]
    for image_arch, arch_infos in all_arches.items():
        # [{"base_image": "amd64/ubuntu:18.04", "dockerfile": "Dockerfile.debian", "tags": ["18.04", "bionic", "latest"]},...]
        # pipeline_build(image_name, "amd64", ^^^)
        result.append(pipeline_build(image_name, image_arch, arch_infos, other_options))
    return result


def gather_all_pipeline_manifest(image_name, all_image_tags_arches):
    # One for each tag set
    result = []
    for image_tags_arches in all_image_tags_arches:
        # pipeline_manifest(image_name, ["18.04", "bionic", "latest"], ["amd64", "arm32v7", "arm64v8"])
        result.append(
            pipeline_manifest(
                image_name, image_tags_arches["tags"], image_tags_arches["arches"]
            )
        )
    return result


def pipeline_build(image_name, image_arch, arch_infos, other_options):
    steps = []
    if "pre_build_commands" in other_options:
        steps.append(
            get_build_prepare_step(
                image_name,
                image_arch,
                other_options["pre_build_commands"]["image"],
                other_options["pre_build_commands"]["commands"],
            )
        )
    for arch_info in arch_infos:
        steps.append(get_build_step(image_name, image_arch, arch_info, other_options))
    return {
        "kind": "pipeline",
        "name": _get_pipeline_build_name(image_name, image_arch),
        "trigger": _get_trigger(),
        "platform": {
            "os": "linux",
            "arch": _get_drone_arch(image_arch)[0],
            # "variant": _get_drone_arch(image_arch)[1],
        },
        "steps": steps,
    }


def pipeline_manifest(image_name, image_tags, image_arches):
    image_tag = _correct_image_tag(image_tags)
    return {
        "kind": "pipeline",
        "name": _get_pipeline_manifest_name(image_name, image_tags),
        "trigger": _get_trigger(),
        "depends_on": [
            "build-" + _get_image_name_without_repo(image_name) + "-" + s
            for s in image_arches
        ],
        "steps": [get_manifest_generate_step(image_name, image_tag, image_arches)]
        + [get_manifest_step(image_name, image_tag) for image_tag in image_tags],
    }


def pipeline_notify(depends_on):
    return {
        "kind": "pipeline",
        "name": "notify",
        "trigger": _get_trigger(any_status=True),
        "clone": {"disable": True},
        "depends_on": depends_on,
        "steps": [
            {
                "name": "send-discord-notification",
                "image": "appleboy/drone-discord",
                "allow_failure": True,
                "settings": {
                    "webhook_id": {"from_secret": "discord_webhook_id"},
                    "webhook_token": {"from_secret": "discord_webhook_token"},
                    "message": "{{#success build.status}}**{{repo.name}}**: Build #{{build.number}} on {{build.branch}} branch succeeded!{{else}}**{{repo.name}}**: Build #{{build.number}} on {{build.branch}} branch failed. Fix me please. {{build.link}}{{/success}}",
                },
            }
        ],
    }


def pipeline_downstream_build(depends_on, downstream_images):
    return {
        "kind": "pipeline",
        "name": "downstream-build",
        "trigger": _get_trigger(),
        "clone": {"disable": True},
        "depends_on": depends_on,
        "steps": [
            {
                "name": "trigger",
                "image": "plugins/downstream",
                "settings": {
                    "server": "https://cloud.drone.io",
                    "token": {"from_secret": "drone_token"},
                    "fork": True,
                    "last_successful": True,
                    "repositories": downstream_images,
                },
            }
        ],
    }


def get_build_prepare_step(image_name, image_arch, image, commands):
    return {
        "name": "prepare-build-{image_name}-{image_arch}".format(
            image_name=_get_image_name_without_repo(image_name), image_arch=image_arch
        ),
        "image": image,
        "commands": commands,
    }


def get_build_step(image_name, image_arch, arch_info, other_options):
    image_tags = arch_info["tags"]
    image_tag = _correct_image_tag(image_tags)
    dockerfile = arch_info["dockerfile"]
    base_image = arch_info["base_image"]
    build_args_from_env = (
        other_options["build_args_from_env"]
        if "build_args_from_env" in other_options
        else []
    )
    return {
        "name": "build-{image_name}-{image_tag}-{image_arch}".format(
            image_name=_get_image_name_without_repo(image_name),
            image_tag=image_tag,
            image_arch=image_arch,
        ),
        "image": "plugins/docker",
        "settings": {
            "username": {"from_secret": "docker_username"},
            "password": {"from_secret": "docker_password"},
            "create_repository": True,
            "cache_from": "{image_name}:{image_tag}-{arch}".format(
                image_name=image_name, image_tag=image_tag, arch=image_arch
            ),
            "repo": "{image_name}".format(image_name=image_name),
            "tags": [s + "-" + image_arch for s in image_tags],
            "context": "docker-user-image",
            "dockerfile": "{dockerfile}".format(
                dockerfile=dockerfile + (".qemu" if image_arch != "amd64" else "")
            ),
            "build_args": [
                "QEMU_ARCH={qemu_arch}".format(qemu_arch=_get_qemu_arch(image_arch)),
                "BASE_IMG={base_image}".format(base_image=base_image),
                "ARCH={arch}".format(arch=image_arch),
            ],
            "build_args_from_env": build_args_from_env,
        },
    }


def get_manifest_generate_step(image_name, image_tag, image_arches):
    image_arches_string = " ".join(image_arches)
    return {
        "name": "prepare-manifest-{image_name}-{image_tag}".format(
            image_name=_get_image_name_without_repo(image_name), image_tag=image_tag
        ),
        "image": "docker:git",
        "commands": [
            "./generate_manifest.sh {image_name} {image_arches_string}".format(
                image_name=_get_image_name_without_repo(image_name),
                image_arches_string=image_arches_string,
            ),
            'echo "Generated docker manifest template:"',
            "cat manifest.tmpl",
        ],
    }


def get_manifest_step(image_name, image_tag):
    return {
        "name": "manifest-{image_name}-{image_tag}".format(
            image_name=_get_image_name_without_repo(image_name), image_tag=image_tag
        ),
        "image": "plugins/manifest",
        "environment": {"DRONE_TAG": "{image_tag}".format(image_tag=image_tag)},
        "settings": {
            "username": {"from_secret": "docker_username"},
            "password": {"from_secret": "docker_password"},
            "spec": "manifest.tmpl",
        },
    }


def _get_image_name_without_repo(image_name):
    return image_name.split("/")[1]


def _get_drone_arch(image_arch):
    if image_arch == "amd64":
        return "amd64", ""
    if image_arch.startswith("arm32"):
        return "arm", image_arch[5:]
    if image_arch.startswith("arm64"):
        return "arm64", "v8"
    return "ERROR_GET_DRONE_ARCH_" + image_arch


def _get_qemu_arch(image_arch):
    if image_arch == "amd64":
        return "x86_64"
    if image_arch.startswith("arm32"):
        return "arm"
    if image_arch.startswith("arm64"):
        return "aarch64"
    return "ERROR_GET_QEMU_ARCH_" + image_arch


def _get_trigger(any_status=False):
    result = {"branch": ["master"], "event": ["push"]}
    if any_status:
        result["status"] = ["success", "failure"]
    return result


def _correct_image_tag(image_tags):
    image_tag = image_tags[0]
    if image_tag == "latest" and len(image_tags) > 1:
        image_tag = image_tags[1]
    return image_tag


def _get_pipeline_build_name(image_name, image_arch):
    return "build-{image_name}-{image_arch}".format(
        image_name=_get_image_name_without_repo(image_name), image_arch=image_arch
    )


def _get_pipeline_manifest_name(image_name, image_tags):
    return "manifest-{image_name}-{image_tag}".format(
        image_name=_get_image_name_without_repo(image_name),
        image_tag=_correct_image_tag(image_tags),
    )

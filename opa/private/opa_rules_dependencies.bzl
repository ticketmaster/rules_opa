load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

DEFAULT_VERSION = "1.1.0"

_OPA_SHA256 = {
    "1.1.0": {
        "opa_darwin_amd64": "444e976b5f0a0035d5fa5c8ecfdd213e0bdd2d7da140a1bfc87b4f995cfee464",
        "opa_darwin_arm64_static": "f9112728505d5c00a9f9256e54457176f0d467ddc82db6295fe00552080b403f",
        "opa_linux_amd64": "5dfbb79c80232dd226822264f1695fd862976c23c7da197ab86af89c393dcac2",
        "opa_linux_amd64_static": "8246c73b39f74d02cf98dc1df71227bdc4eb0ccc639ab1e9897854b4383da4e1",
        "opa_linux_arm64_static": "bdcf9a561a8c48bb6376977e6ba8f1b77adb6433f51bb1b3d440922f78856bb4",
        "opa_windows_amd64": "4a85ef10c51245e8e507c57e50c7bdbd9533f9f76dd9bbb01305aa37e0390258",
        "opa_capabilities_json": "db207cb45b0a2efaac5643cdff6610fa20a875e8472a026d3819fbb0bb9da2f9",
        "opa_builtin_metadata_json": "a53dbf0dedcc6f286550a6d4d656367791b10dc9fdb4ffd4a74649c731b56883",
    },
    "0.65.0": {
        "opa_darwin_amd64": "565435206e43a92564093ea85e4001a4a56956476f333367db792a7d693b63c0",
        "opa_darwin_arm64_static": "3d8f7e940aa7cf13a532bd095ec5f2d61f7920588675771bfb5da63c3b60cd36",
        "opa_linux_amd64": "5cda006dd8fc42622e5cc61866c2086936c55a808ac87a2db94bf3751eb5ff3d",
        "opa_linux_amd64_static": "cd6b0b2d762571a746f0261890b155e6dd71cca90dad6b42b6fcf6dd7f619f08",
        "opa_linux_arm64_static": "dba53c4f4a003f5b866e316129a144423900f78093645307ab0c4d20329ccd40",
        "opa_windows_amd64": "6d0c8276487aabb10620d00d4e91d2f76c07a567edc68298ca23d1bc72b93369",
        "opa_capabilities_json": "fdcc65f878bb42838ea1a63a7904cbf67361f0f536a99a61dff11be33357fe8c",
        "opa_builtin_metadata_json": "47cff9a1f192a3d82c143bef3bc1774f0e7e6cf54a5f6a48371a48631b912424",
    },
    "0.63.0": {
        "opa_darwin_amd64": "236b2644541021aa7f0995fb0a0792bfb427e9a2d5417626f7c17d875f433ca6",
        "opa_darwin_arm64_static": "5c707597ce6e65e74f3a01fafee0f98e6276f0f66dd3d459ebc52997adac2b0e",
        "opa_linux_amd64": "20ab8e7ea816f9abd89d850656ff4ea08e5b7f2929720d6f5f20770d79800117",
        "opa_linux_amd64_static": "af1a9d13611974ff18c529dea3592512dd46f80a4fba95969cebccd2b0ddca64",
        "opa_linux_arm64_static": "0162d324e6578279072fda4a3eb69cd935a73512289135bef0c3bfe7aa1aaa2f",
        "opa_windows_amd64": "eb49d9bf98ca21be55c71bf033ed4b058aa1ffdec9b182cb66ae42c007e43074",
        "opa_capabilities_json": "4e43bd196f78e2210097e2e3bbce25512ef7783c48922be9e2ac0af8ad2fa7c8",
        "opa_builtin_metadata_json": "3c3bee9988c8d1d7784969a68eadd365fa9e56dd4cefe5b083de9e96f0ab431e",
    },
    "0.60.0": {
        "opa_darwin_amd64": "1b96cb23a63700b75f670e6bca1e3f8e9e7930c29b095753a9f978ce88828fa0",
        "opa_darwin_arm64_static": "27c1209fda3a5b8d7ec158b3696246ce7d1bf3f0f08f3698a23bf7dada5a618b",
        "opa_linux_amd64": "71514c6c70e744713656a302131e3172988c4898b43cb503f273086d47ccc299",
        "opa_linux_amd64_static": "7d7cb45d9e6390646e603456503ca1232180604accc646de823e4d2c363dbeb0",
        "opa_linux_arm64_static": "dd2ba13e42faa16f4a7933f80f44ee518bb96a023ea6dfb8193916a8ba134555",
        "opa_windows_amd64": "8e20b4fcd6b8094be186d8c9ec5596477fb7cb689b340d285865cb716c3c8ea7",
        "opa_capabilities_json": "c8e827c4186a3f30de7fefa3c2c9d72c8856ee10fd2890b8c41f5e351b6bfaa2",
        "opa_builtin_metadata_json": "2cd517a6de5b2278b43e120b31b663a9337212a53874ddfdc432651628bc3736",
    },
    "0.59.0": {
        "opa_darwin_amd64": "3edddc7dded91a7b2fe7fbe3d862778dccc28eff6ee515c41b38d65474d5e9f4",
        "opa_darwin_arm64_static": "890d23badb79ba0594e360c721ea3ff6d2da0a5461e2864a0fcb80438544635e",
        "opa_linux_amd64": "aadd956093b680485ceca4ee1e8ccd31f129e002972ca57b97fe375086ffbfc5",
        "opa_linux_amd64_static": "5f615343a1cae1deb2f2f514b2f4b46456495fe1c828b17e779eb583aced0cc3",
        "opa_linux_arm64_static": "ca9de0976739dc3dc07e1e7e16079f0fa4df8fc2706abe852219406abc63c3e3",
        "opa_windows_amd64": "0167f2bd69b72993ccdca222d0bc5d9278ffb194f9c87fddc1b55ecc9edf17df",
        "opa_capabilities_json": "c8e827c4186a3f30de7fefa3c2c9d72c8856ee10fd2890b8c41f5e351b6bfaa2",
        "opa_builtin_metadata_json": "641ee050578b4c1d49e5ab6cef435416e8f4e0b0a3d6ba785e11f3024594a26a",
    },
    "0.57.1": {
        "opa_darwin_amd64": "54a2d229638baddb0ac6f7c283295e547e6f491ab2ddcaf714fa182427e8421d",
        "opa_darwin_arm64_static": "367adba9c1380297c87a83019965a28bb0f33fe7c0854ff6beedb4aa563e4b4f",
        "opa_linux_amd64": "5212d513dad9bd90bc67743d7812e5ec7019b2a994f30c0d8dbb2b2c6772f094",
        "opa_linux_amd64_static": "59e8c6ef9ae2f95b76aa79344eb81ca6f3950a0fd7a23534c4d7065f42fda99f",
        "opa_linux_arm64_static": "6d581ef6f9a066c0d2a36f3cb7ee605ec8195e49631121d1707248549758806b",
        "opa_windows_amd64": "9a6d3ef2279760efbcead6a7095393e04adaa1be3c7458eb62a2b79d93df4bc3",
        "opa_capabilities_json": "3a99b25a99f484b9de2037ef459af50cfa3c2da01219d38ddb049ad0c2384411",
        "opa_builtin_metadata_json": "5e9aeb1048a49e9fc04c694be53a4eead8a1b5f4acff71d14b1610d84fb347b4",
    },
    "0.54.0": {
        "opa_darwin_amd64": "a33e829306cd2210ed743da7f4f957588ea350a184bb6ecbb7cbfd77ae7ca401",
        "opa_darwin_arm64_static": "74500746e5faf0deb60863f1a3d1e3eed96006ff8183940f1c13f1a47969059d",
        "opa_linux_amd64_static": "633829141f8d6706ac24e0b84393d7730a975a17cc4a15790bf7fad959a28ec3",
        "opa_linux_arm64_static": "883e22c082508e2f95ba25333559ba8a5c38c9c5ef667314e132c9d8451450d8",
        "opa_windows_amd64": "25284b69e1dd7feaa17446e49b1085b61dca0b496dc868304153eb64b422c7eb",
        "opa_capabilities_json": "2f91fc361a5799b21e0b92d767cf756ca4754912ce84c5b16234a9bf83a38480",
        "opa_builtin_metadata_json": "792a6f3763782b2860eb35edf2c69fbbcfa26f07f9c48287301c47179c73e95d",
    },
}

_SUPPORTED_PLATFORMS = [
    "opa_darwin_amd64",
    "opa_darwin_arm64_static",
    "opa_linux_amd64_static",
    "opa_linux_arm64_static",
    "opa_windows_amd64",
]

def opa_rules_dependencies(
        version = DEFAULT_VERSION):
    """Install the opa dependencies

    Args:
        version: version of the opa release to use

    Returns:
        List of direct dependencies
    """

    direct_deps = []

    for bin in _SUPPORTED_PLATFORMS:
        extname = ".exe" if bin.startswith("opa_windows") else ""
        sha256 = _OPA_SHA256[version][bin]

        maybe(
            http_file,
            name = bin,
            url = "https://github.com/open-policy-agent/opa/releases/download/v%s/%s%s" % (version, bin, extname),
            sha256 = sha256,
            executable = 1,
            downloaded_file_path = "opa%s" % extname,
        )

        direct_deps.append(bin)

    maybe(
        http_file,
        name = "opa_capabilities_json",
        url = "https://raw.githubusercontent.com/open-policy-agent/opa/v%s/capabilities.json" % (version),
        sha256 = _OPA_SHA256[version]["opa_capabilities_json"],
        downloaded_file_path = "capabilities.json",
    )

    maybe(
        http_file,
        name = "opa_builtin_metadata_json",
        url = "https://raw.githubusercontent.com/open-policy-agent/opa/v%s/builtin_metadata.json" % (version),
        sha256 = _OPA_SHA256[version]["opa_builtin_metadata_json"],
        downloaded_file_path = "builtin_metadata.json",
    )

    direct_deps.extend([
        "opa_capabilities_json",
        "opa_builtin_metadata_json",
    ])

    return direct_deps

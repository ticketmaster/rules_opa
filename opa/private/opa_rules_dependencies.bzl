load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

_OPA_SHA256 = {
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
        version = "0.54.0"):
    """Install the opa dependencies

    Args:
        version: version of the opa release to use
    """
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

def opa_register_toolchains(name = "rules_opa"):
    """
    Registers the opa toolchains

    Args:
        name: name of this repository
    """
    native.register_toolchains(
        "@%s//tools:opa_linux_amd64_toolchain" % (name),
        "@%s//tools:opa_linux_arm64_toolchain" % (name),
        "@%s//tools:opa_darwin_amd64_toolchain" % (name),
        "@%s//tools:opa_darwin_arm64_toolchain" % (name),
        "@%s//tools:opa_windows_amd64_toolchain" % (name),
    )

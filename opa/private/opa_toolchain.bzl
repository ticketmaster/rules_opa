OpacInfo = provider(
    doc = "opa cli toolchain",
    fields = ["opa", "capabilities_json", "builtin_metadata_json", "opa_signer"],
)

def _opa_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        opacinfo = OpacInfo(
            opa = ctx.executable.opa,
            capabilities_json = ctx.file.capabilities_json,
            builtin_metadata_json = ctx.file.builtin_metadata_json,
            opa_signer = ctx.executable.opa_signer,
        ),
    )
    return [toolchain_info]

opa_toolchain = rule(
    implementation = _opa_toolchain_impl,
    attrs = {
        "opa": attr.label(
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "capabilities_json": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "builtin_metadata_json": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "opa_signer": attr.label(
            executable = True,
            cfg = "exec",
            default = "//tools:opa_signer",
        ),
        "opa_ctx": attr.label(
            executable = True,
            cfg = "exec",
            default = "//tools:opa_ctx",
        ),
    },
)

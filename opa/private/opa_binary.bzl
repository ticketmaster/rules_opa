load(":opa_library.bzl", "OpaInfo")

def _opa_binary_impl(ctx):
    toolchain = ctx.toolchains["//tools:toolchain_type"].opacinfo
    binary_file = ctx.actions.declare_file("%s_binary.sh" % (ctx.label.name))

    if len(ctx.attr.deps) != 1:
        fail("opa_binary only allow a single deps")

    bundle = ctx.attr.deps[0][OpaInfo].bundle

    runfiles = ctx.runfiles(files = [toolchain.opa, bundle])

    ctx.actions.write(
        output = binary_file,
        content = "%s run -b %s" % (toolchain.opa.short_path, bundle.short_path),
        is_executable = True,
    )

    return [
        DefaultInfo(
            executable = binary_file,
            runfiles = runfiles,
        ),
    ]

opa_binary = rule(
    implementation = _opa_binary_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [OpaInfo],
        ),
    },
    executable = True,
    toolchains = ["//tools:toolchain_type"],
)

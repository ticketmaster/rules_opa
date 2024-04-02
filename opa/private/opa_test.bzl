load(":opa_library.bzl", "OpaInfo")

def _opa_test_impl(ctx):
    toolchain = ctx.toolchains["//tools:toolchain_type"].opacinfo
    test_file = ctx.actions.declare_file("%s_test.sh" % (ctx.label.name))

    if len(ctx.attr.deps) != 1:
        fail("opa_test only allow a single deps")

    bundle = ctx.attr.deps[0][OpaInfo].bundle

    runfiles = ctx.runfiles(files = [toolchain.opa, bundle] + ctx.files.srcs)

    args = ["--explain", ctx.attr.explain]

    if ctx.attr.verbose:
        args.append("--verbose")

    ctx.actions.write(
        output = test_file,
        content = "%s test %s %s" % (toolchain.opa.short_path, bundle.short_path, " ".join(args + [f.short_path for f in ctx.files.srcs])),
        is_executable = True,
    )

    return [
        DefaultInfo(
            executable = test_file,
            runfiles = runfiles,
        ),
    ]

opa_test = rule(
    implementation = _opa_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".rego"],
            mandatory = True,
            doc = "Rego files to test",
        ),
        "deps": attr.label_list(
            providers = [OpaInfo],
            doc = "The bundle to test",
        ),
        "explain": attr.string(
            values = ["fails", "full", "notes", "debug"],
            doc = "enable query explanations (default fails)",
            default = "fails",
        ),
        "verbose": attr.bool(
            doc = "set verbose reporting mode",
            default = False,
        ),
    },
    toolchains = ["//tools:toolchain_type"],
)

load(":opa_library.bzl", "OpaInfo")

def _opa_test_impl(ctx):
    toolchain = ctx.toolchains["//tools:toolchain_type"].opacinfo
    tester_file = ctx.actions.declare_file("%s_tester.sh" % (ctx.label.name))
    bundle = ctx.attr.bundle[OpaInfo]
    runfiles = ctx.runfiles(files = ctx.files.srcs + [toolchain.opa] + bundle.file_deps.to_list())

    ctx.actions.write(
        output = tester_file,
        content = "%s test -v %s" % (toolchain.opa.short_path, bundle.strip_prefix),
    )

    return [
        DefaultInfo(
            executable = tester_file,
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
        "bundle": attr.label(
            providers = [OpaInfo],
            doc = "The bundle to test",
        ),
    },
    toolchains = ["//tools:toolchain_type"],
)

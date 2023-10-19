load(":opa_library.bzl", "OpaInfo")

def _opa_eval_binary_impl(ctx):
    exec_file = ctx.actions.declare_file("%s_exec.sh" % (ctx.label.name))
    toolchain = ctx.toolchains["//tools:toolchain_type"].opacinfo

    if len(ctx.attr.deps) != 1:
        fail("opa_binary only allow a single deps")

    bundle = ctx.attr.deps[0][OpaInfo].bundle

    runfiles = ctx.runfiles(files = [toolchain.opa, bundle])

    args = ["eval", "-b", bundle.short_path]
    suffix = ""

    if ctx.attr.partial:
        args.append("--partial")
    if ctx.file.input_file:
        args.append("--input %s" % (ctx.file.input_file.short_path))
    if ctx.attr.input:
        args.append("--stdin-input")
        suffix = "<< 'EOF'\n%s\nEOF" % (ctx.attr.input)
    if ctx.attr.unknowns:
        args.append("--unknowns %s" % (",".join(ctx.attr.unknowns)))

    args.append("--format=%s" % (ctx.attr.format))
    args.append(ctx.attr.query)

    ctx.actions.write(
        output = exec_file,
        content = "%s %s %s" % (toolchain.opa.short_path, " ".join(args), suffix),
        is_executable = True,
    )

    return [
        DefaultInfo(
            executable = exec_file,
            runfiles = runfiles,
        ),
    ]

opa_eval_binary = rule(
    implementation = _opa_eval_binary_impl,
    executable = True,
    attrs = {
        "deps": attr.label_list(
            providers = [OpaInfo],
            mandatory = True,
            doc = "The bundle to evaluate",
        ),
        "query": attr.string(
            mandatory = True,
            doc = "The query to evaluate",
        ),
        "format": attr.string(
            default = "json",
            values = ["json", "values", "bindings", "pretty", "source", "raw"],
            doc = "The output format (see https://www.openpolicyagent.org/docs/latest/cli/#output-formats)",
        ),
        "partial": attr.bool(
            default = False,
            doc = "perform partial evaluation",
        ),
        "unknowns": attr.string_list(
            doc = "set paths to treat as unknown during partial evaluation",
        ),
        "input": attr.string(
            doc = "input",
        ),
        "input_file": attr.label(
            allow_single_file = True,
            doc = "input",
        ),
    },
    toolchains = ["//tools:toolchain_type"],
)

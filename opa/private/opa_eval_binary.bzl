load(":opa_library.bzl", "OpaInfo")

def _opa_eval_binary_impl(ctx):
    exec_file = ctx.actions.declare_file("%s_exec.sh" % (ctx.label.name))
    toolchain = ctx.toolchains["//tools:toolchain_type"].opacinfo
    runfiles = ctx.runfiles(files = [toolchain.opa] + ctx.attr.bundle[OpaInfo].file_deps.to_list())

    args = []

    if ctx.attr.partial:
        args.append("--partial")
    if ctx.file.input_file:
        args.append("--input %s" % (ctx.file.input_file.short_path))
    if ctx.attr.input:
        args.append("--stdin-input")
    if ctx.attr.unknowns:
        args.append("--unknowns %s" % (",".join(ctx.attr.unknowns)))

    args.append("--format=%s" % (ctx.attr.format))
    args.append(ctx.attr.query)

    ctx.actions.expand_template(
        output = exec_file,
        template = ctx.file._template,
        is_executable = True,
        substitutions = {
            "{OPA_SHORTPATH}": toolchain.opa.short_path,
            "{STDIN}": ctx.attr.input,
            "{STRIP_PREFIX}": ctx.attr.bundle[OpaInfo].strip_prefix,
            "{ARGS}": " ".join(args),
        },
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
        "bundle": attr.label(
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
        "_template": attr.label(
            default = Label("opa_eval.sh.tpl"),
            allow_single_file = True,
        ),
    },
    toolchains = ["//tools:toolchain_type"],
)

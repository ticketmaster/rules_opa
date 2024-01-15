load(":opa_library.bzl", "OpaInfo")

def _opa_eval_impl(ctx):
    toolchain = ctx.toolchains["//tools:toolchain_type"].opacinfo
    out_file = ctx.actions.declare_file(ctx.attr.out)

    if len(ctx.attr.deps) != 1:
        fail("opa_eval only allow a single deps")

    bundle = ctx.attr.deps[0][OpaInfo].bundle
    additional_inputs = []

    args = ctx.actions.args()

    args.add(toolchain.opa)
    args.add("eval")
    args.add("-b").add(bundle)

    if ctx.attr.partial:
        args.add("--partial")
    if ctx.file.input_file:
        additional_inputs.append(ctx.file.input_file)
        args.add("--input").add(ctx.file.input_file)
    if ctx.attr.input:
        input_file = ctx.actions.declare_file(ctx.label.name + "_input.txt")
        ctx.actions.write(output = input_file, content = ctx.attr.input)
        additional_inputs.append(input_file)
        args.add("--input").add(input_file)
    if ctx.attr.unknowns:
        args.add("--unknowns").add(",".join(ctx.attr.unknowns))

    args.add("--format=%s" % (ctx.attr.format))
    args.add(ctx.attr.query)

    ctx.actions.run_shell(
        tools = [toolchain.opa],
        inputs = [bundle] + additional_inputs,
        outputs = [out_file],
        arguments = [args],
        command = "$@ > " + out_file.path,
    )

    return [
        DefaultInfo(
            files = depset([out_file]),
        ),
    ]

opa_eval = rule(
    implementation = _opa_eval_impl,
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
        "out": attr.string(
            mandatory = True,
            doc = "Output file name",
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

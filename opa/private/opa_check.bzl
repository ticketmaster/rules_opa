load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(":opa_library.bzl", "OpaInfo")

def _opa_check_test_impl(ctx):
    tester_file = ctx.actions.declare_file("%s_tester.sh" % (ctx.label.name))
    toolchain = ctx.toolchains["//tools:toolchain_type"].opacinfo

    files = [toolchain.opa, ctx.attr.bundle[OpaInfo].bundle]

    if ctx.file.capabilities:
        files.append(ctx.file.capabilities)
    if ctx.file.schema_dir:
        files.append(ctx.file.schema_dir)
    if ctx.files.schema_files:
        files.extend(ctx.files.schema_files)

    args = ["set -xe\n"]

    args.append(toolchain.opa.short_path)
    args.append("check")
    args.append("-b")
    args.append(ctx.attr.bundle[OpaInfo].bundle.short_path)

    if ctx.file.schema_dir:
        args.append("-s")
        args.append("%s/" % (ctx.file.schema_dir.short_path))
    elif ctx.files.schema_files:
        args.insert(1, "schema_dir=`mktemp -d`\n")
        args.insert(2, "cp %s $schema_dir\n" % (" ".join([f.short_path for f in ctx.files.schema_files])))
        args.append("-s")
        args.append("$schema_dir")

    if ctx.file.capabilities:
        args.append("--capabilities")
        args.append(ctx.file.capabilities.short_path)

    if ctx.attr.strict:
        args.append("--strict")

    ctx.actions.write(
        output = tester_file,
        content = " ".join(args),
    )

    runfiles = ctx.runfiles(
        files = files,
    )

    return [
        DefaultInfo(
            executable = tester_file,
            runfiles = runfiles,
        ),
    ]

_opa_check_test = rule(
    implementation = _opa_check_test_impl,
    doc = "Check Rego source files for parse and compilation errors and optional schema validation",
    test = True,
    attrs = {
        "bundle": attr.label(
            doc = "OPA bundle built with opa_library rule.",
            mandatory = True,
            providers = [OpaInfo],
        ),
        "schema_dir": attr.label(
            doc = "Schema directory path. If both the schema_dir and schema_files are provided, the schema_files will ensure that the change detection works properly, but only the directory will be send to the underlying opa commands.",
            allow_single_file = True,
        ),
        "schema_files": attr.label_list(
            doc = "Schema files",
            allow_files = [".json"],
        ),
        "protos": attr.label_list(
            providers = [ProtoInfo],
            doc = "Protobuf definition to generate json schemas",
        ),
        "strict": attr.bool(
            doc = "enable compiler strict mode",
        ),
        "capabilities": attr.label(
            doc = "set capabilities.json file path",
            allow_single_file = True,
        ),
    },
    toolchains = ["//tools:toolchain_type"],
)

def opa_check(name, protos = None, schema_dir = None, **kwargs):
    _opa_check_test(
        name = name,
        schema_dir = schema_dir,
        protos = protos,
        **kwargs
    )

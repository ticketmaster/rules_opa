load("@bazel_skylib//lib:paths.bzl", "paths")

OpaInfo = provider("opa", fields = ["bundle", "target", "file_deps", "strip_prefix"])

def _opa_toolchain(ctx):
    return ctx.toolchains["//tools:toolchain_type"].opacinfo

def _run_opa_signer(ctx, bundle_file, signed_bundle_file):
    toolchain = _opa_toolchain(ctx)
    args = ctx.actions.args()

    args.add("--bundle").add(bundle_file)

    additional_inputs = []
    additional_tools = []

    if ctx.attr.signing_key:
        args.add("--signing-key").add(ctx.attr.signing_key)
    elif ctx.file.signing_key_pem:
        args.add("--signing-key").add(ctx.file.signing_key_pem)
        additional_inputs.append(ctx.file.signing_key_pem)
    if ctx.attr.signing_alg:
        args.add("--signing-alg").add(ctx.attr.signing_alg)

    args.add("--output").add(signed_bundle_file)

    if ctx.executable.custom_signer:
        additional_tools.append(ctx.executable.custom_signer)
        args.add(ctx.executable.custom_signer)
    else:
        args.add(toolchain.opa).add("sign")

    ctx.actions.run(
        inputs = [bundle_file] + additional_inputs,
        outputs = [signed_bundle_file],
        arguments = [args],
        tools = [toolchain.opa, toolchain.opa_signer] + additional_tools,
        progress_message = "Signing bundle",
        mnemonic = "OpaBuildSign",
        executable = ctx.executable._opa_signer,
    )

def _run_opa_build(ctx, bundle_file):
    toolchain = _opa_toolchain(ctx)
    args = ctx.actions.args()

    strip_prefix = paths.normalize(ctx.attr.strip_prefix)
    opa_relative_path = toolchain.opa.path
    bundle_relative_path = bundle_file.path

    if strip_prefix != ".":
        rel = [".." for _ in strip_prefix.split("/")]
        opa_relative_path = paths.normalize("/".join(rel + [toolchain.opa.path]))
        bundle_relative_path = paths.normalize("/".join(rel + [bundle_file.path]))

    args.add("build")
    args.add("-t")
    args.add(ctx.attr.target)
    args.add("-o")
    args.add("%s" % (bundle_relative_path))

    if ctx.attr.optimize:
        args.add(ctx.attr.optimize, format = "--optimize=%s")

    for entrypoint in ctx.attr.entrypoints:
        args.add(entrypoint, format = "-e %s")

    args.add(".")

    srcs = ctx.files.srcs if ctx.files.srcs else []
    data = ctx.files.data if ctx.files.data else []

    ctx.actions.run_shell(
        inputs = depset(srcs + data, transitive = [d[OpaInfo].file_deps for d in ctx.attr.deps]),
        outputs = [bundle_file],
        arguments = [args],
        tools = [toolchain.opa],
        progress_message = "Bundling policies",
        mnemonic = "OpaBuild",
        command = "cd %s && %s $@" % (strip_prefix, opa_relative_path),
    )

def _opa_library_impl(ctx):
    if ctx.attr.target == "wasm" and len(ctx.attr.entrypoints) == 0:
        fail("At least one entrypoint is required for a wasm target")

    bundle_file = ctx.actions.declare_file("%s.tar.gz" % (ctx.attr.name))

    _run_opa_build(ctx, bundle_file)

    output_files = [bundle_file]

    signed_bundle_file = None

    if ctx.attr.signing_key or ctx.file.signing_key_pem:
        signed_bundle_file = ctx.actions.declare_file("%s-signed.tar.gz" % (ctx.attr.name))
        _run_opa_signer(ctx, bundle_file, signed_bundle_file)
        output_files = [signed_bundle_file] + output_files

    srcs = ctx.files.srcs if ctx.files.srcs else []
    data = ctx.files.data if ctx.files.data else []

    return [
        OpaInfo(
            bundle = bundle_file,
            strip_prefix = paths.normalize(ctx.attr.strip_prefix),
            target = ctx.attr.target,
            file_deps = depset(srcs + data, transitive = [d[OpaInfo].file_deps for d in ctx.attr.deps]),
        ),
        DefaultInfo(files = depset(output_files)),
    ]

opa_library = rule(
    implementation = _opa_library_impl,
    attrs = {
        "entrypoints": attr.string_list(
            doc = "Set slash separated entrypoint path",
        ),
        "srcs": attr.label_list(
            allow_files = [".rego"],
            doc = "Rego files to include in the bundle",
        ),
        "data": attr.label_list(
            allow_files = [".json"],
            doc = "Data files (json) to include in the bundle",
        ),
        "deps": attr.label_list(
            providers = [OpaInfo],
            doc = "Existing libraries to include as transitive in the bundle",
        ),
        "signing_key": attr.string(
            doc = "Set the secret (HMAC)",
        ),
        "signing_key_pem": attr.label(
            doc = "Set the path of the PEM file containing the private key (RSA and ECDSA)",
            allow_single_file = True,
        ),
        "signing_alg": attr.string(
            doc = "name of the signing algorithm (default \"RS256\")",
        ),
        "custom_signer": attr.label(
            doc = "Custom executable that will act like `opa sign` (https://www.openpolicyagent.org/docs/latest/cli/#opa-sign) command. It will receive the same arguments.",
            executable = True,
            cfg = "exec",
        ),
        "target": attr.string(
            values = ["rego", "wasm"],
            default = "rego",
            doc = """Set the output bundle target type (default rego).

rego    The default target emits a bundle containing a set of policy and data files
        that are semantically equivalent to the input files. If optimizations are
        disabled the output may simply contain a copy of the input policy and data
        files. If optimization is enabled at least one entrypoint must be supplied,
        either via the -e option, or via entrypoint metadata annotations.

wasm    The wasm target emits a bundle containing a WebAssembly module compiled from
        the input files for each specified entrypoint. The bundle may contain the
        original policy or data files.
            """,
        ),
        "strip_prefix": attr.string(
            doc = "Prefix to strip from the srcs, data and deps paths included in the bundle. All files must be contained. Defaults on the workspace root.",
        ),
        "optimize": attr.string(
            doc = "Set optimization level",
        ),
        # For some reason, I'm not able to sue the one provided by the toolchain directly
        # AssertionError: Cannot find .runfiles directory for bazel-out/darwin-opt-exec-2B5CBBC6/bin/tools/opa_signer
        "_opa_signer": attr.label(
            default = "//tools:opa_signer",
            executable = True,
            cfg = "exec",
        ),
    },
    toolchains = ["//tools:toolchain_type"],
)

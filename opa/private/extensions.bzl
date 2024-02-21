"""Bzlmod module extensions that are only used internally"""

load("//opa/private:opa_rules_dependencies.bzl", "opa_rules_dependencies")

def _internal_deps_impl(module_ctx):
    return module_ctx.extension_metadata(
        root_module_direct_deps = opa_rules_dependencies(),
        root_module_direct_dev_deps = [],
    )

internal_deps = module_extension(
    doc = "Dependencies for rules_opa",
    implementation = _internal_deps_impl,
)

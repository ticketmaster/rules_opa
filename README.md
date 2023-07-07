# [OPA](https://www.openpolicyagent.org/) rules for [Bazel](https://bazel.build/)

## Contents
* [Overview](#overview)
* [Setup](#setup)
* [Usage](#usage)

## Overview

Wrapper rules on the opa cli.

## Setup

Those dependencies must be installed in the WORKSPACE

* [Skylib](https://github.com/bazelbuild/bazel-skylib)
* [Python Rules](https://github.com/bazelbuild/rules_python)

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_opa",
    sha256 = "510c9e0a2f556ea443a7da567d84e76b3ebc7aea48665109f35c7029d9a6d56e",
    strip_prefix = "rules_opa-0.2.0",
    url = "https://github.com/ticketmaster/rules_opa/archive/refs/tags/v0.2.0.tar.gz",
)

load("@rules_opa//opa:deps.bzl", "opa_register_toolchains", "opa_rules_dependencies")

opa_rules_dependencies()

opa_register_toolchains()
```

## Usage

See [examples](examples) for more information

```starlark
load("@rules_opa//opa:defs.bzl", "opa_check", "opa_eval_binary", "opa_library", "opa_test")

opa_library(
    name = "simple",
    srcs = ["main.rego"],
    data = ["data.json"],
    strip_prefix = package_name(),
)

opa_test(
    name = "simple_test",
    size = "small",
    srcs = ["main_test.rego"],
    bundle = ":simple",
)
```

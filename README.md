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

RULES_OPA_SHA256=#...
RULES_OPA_VERSION=#...
OPA_VERSION=#...

http_archive(
    name = "rules_opa",
    sha256 = RULES_OPA_SHA256,
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.39.0/rules_go-v0.39.0.zip",
        "https://github.com/ticketmaster/rules_opa/releases/download/%s/rules_go-%s.zip"%(RULES_OPA_VERSION,RULES_OPA_VERSION),
    ],
)

load("@rules_opa//opa:deps.bzl", "opa_register_toolchains", "opa_rules_dependencies")

opa_rules_dependencies()

opa_register_toolchains(version = OPA_VERSION)
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

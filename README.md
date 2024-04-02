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

bzlmod usage (until it's available in the registry)

```starlark
bazel_dep(name = "rules_opa", version = <version>)

git_override(
    module_name = "rules_opa",
    commit = <commit>,
    remote = "https://github.com/ticketmaster/rules_opa",
)
```

Legacy workspace

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_opa",
    sha256 = "<SHA256>",
    strip_prefix = "rules_opa-<VERSION>",
    url = "https://github.com/ticketmaster/rules_opa/archive/refs/tags/<VERSION>.tar.gz",
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
    srcs = ["main.rego", "data.json"],
    strip_prefix = package_name(),
)

opa_test(
    name = "simple_test",
    size = "small",
    srcs = ["main_test.rego"],
    bundle = ":simple",
)
```

## Upgrade

To upgrade the opa version, run the following command

```shell
bazel run -- //tools:opa_upgrade --version <version>
```

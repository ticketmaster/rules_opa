# [OPA](https://www.openpolicyagent.org/) rules for [Bazel](https://bazel.build/)

## Contents
* [Overview](#overview)
* [Setup](#setup)
* [protobuf support](#protobuf-support)

## Overview

## Setup

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

## protobuf support

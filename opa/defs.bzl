load("//opa/private:opa_binary.bzl", _opa_binary = "opa_binary")
load("//opa/private:opa_check.bzl", _opa_check = "opa_check")
load("//opa/private:opa_eval.bzl", _opa_eval = "opa_eval")
load("//opa/private:opa_eval_binary.bzl", _opa_eval_binary = "opa_eval_binary")
load("//opa/private:opa_library.bzl", _OpaInfo = "OpaInfo", _opa_library = "opa_library")
load("//opa/private:opa_test.bzl", _opa_test = "opa_test")
load("//opa/private:opa_toolchain.bzl", _OpacInfo = "OpacInfo", _opa_toolchain = "opa_toolchain")

opa_toolchain = _opa_toolchain
opa_library = _opa_library
opa_test = _opa_test
opa_check = _opa_check
opa_eval_binary = _opa_eval_binary
opa_eval = _opa_eval
opa_binary = _opa_binary
OpaInfo = _OpaInfo
OpacInfo = _OpacInfo

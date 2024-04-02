import os
import re
from typing import TypeVar, Optional
from argparse import ArgumentParser, Namespace
from urllib.request import urlopen
from pathlib import Path
from hashlib import sha256

ARTIFACTS = [
    "opa_darwin_amd64",
    "opa_darwin_arm64_static",
    "opa_linux_amd64",
    "opa_linux_amd64_static",
    "opa_linux_arm64_static",
    "opa_windows_amd64",
]

T = TypeVar("T")


def required(value: Optional[T], name: str) -> T:
    if value is None:
        raise ValueError(f"Expected value for {name}")

    return value


def get_sha256(artifact_name: str, version: str) -> str:
    ext = ".exe" if "windows" in artifact_name else ""

    with urlopen(
        f"https://github.com/open-policy-agent/opa/releases/download/v{version}/{artifact_name}{ext}.sha256"
    ) as res:
        return res.read().decode().split(" ")[0]


def get_sha256_file(file: str, version: str) -> str:
    file_url = (
        f"https://raw.githubusercontent.com/open-policy-agent/opa/v{version}/{file}"
    )

    with urlopen(file_url) as res:
        return sha256(res.read()).hexdigest()


def main(args: Namespace):
    d = dict(
        [
            (artifact_name, get_sha256(artifact_name, args.version))
            for artifact_name in ARTIFACTS
        ]
    )

    bzl_path = WORKSPACE_ROOT.joinpath("opa", "private", "opa_rules_dependencies.bzl")

    with open(bzl_path) as bzl_file:
        bzl_content = bzl_file.read()

    version_match = re.search(r"DEFAULT_VERSION\s*=\s*[\"'](.*?)[\"']", bzl_content)

    if version_match is None:
        raise ValueError(f"Could not find DEFAULT_VERSION in file {bzl_path}")

    start_version = version_match.start(1)
    end_version = version_match.end(1)

    bzl_content = bzl_content[:start_version] + args.version + bzl_content[end_version:]

    dict_match = re.search(r"^_OPA_SHA256\s*=\s*{\s*$", bzl_content, re.MULTILINE)

    if dict_match is None:
        raise ValueError(f"Could not find _OPA_SHA256 in file {bzl_path}")

    bzl_content = (
        bzl_content[: dict_match.end()]
        + f'\n    "{args.version}": {{\n'
        + "\n".join(
            [
                f'        "{artifact_name}": "{sha256}",'
                for artifact_name, sha256 in d.items()
            ]
            + [
                f"        \"opa_capabilities_json\": \"{get_sha256_file('capabilities.json', args.version)}\",",
                f"        \"opa_builtin_metadata_json\": \"{get_sha256_file('builtin_metadata.json', args.version)}\",",
            ]
        )
        + "\n    },"
        + bzl_content[dict_match.end() :]
    )

    with open(bzl_path, "w", encoding="utf-8") as bzl_file:
        bzl_file.write(bzl_content)


def get_workspace_root(wd: Path) -> Path:
    while not wd.joinpath("WORKSPACE").exists():
        wd = wd.parent

    return wd


WORKSPACE_ROOT = Path(
    required(os.getenv("BUILD_WORKSPACE_DIRECTORY"), "BUILD_WORKSPACE_DIRECTORY")
)

if __name__ == "__main__":

    parser = ArgumentParser()
    parser.add_argument("--version", "-v", required=True)

    main(parser.parse_args())

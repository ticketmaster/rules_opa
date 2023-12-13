# Create a opa friendly context from bazel sources and generated files.
from dataclasses import dataclass
from argparse import ArgumentParser
from subprocess import run, PIPE, STDOUT
from typing import List, Optional, Union
from pathlib import Path

import os
import sys


@dataclass
class Args:
    output: Optional[str]
    inputs: List[str]
    exec: Path
    command: List[str]
    wd: Path


def parse_args() -> Args:
    parser = ArgumentParser()
    parser.add_argument(
        "-o",
        "--output",
        metavar="FILE:ALIAS",
        help="expected output file to extract from the working directory",
    )
    parser.add_argument("-d", "--working-directory", required=True)
    parser.add_argument(
        "-i",
        "--input",
        nargs="+",
        help="files to put in the context",
        metavar="FILE:ALIAS",
    )
    parser.add_argument("command", nargs="+")

    args = parser.parse_args()

    return Args(
        output=args.output,
        inputs=args.input,
        exec=Path(args.command[0]),
        command=args.command[1:],
        wd=Path(args.working_directory),
    )


# When run with `bazel run` directly when working directly is not the user's working directory


def chdir():
    user_dir = os.getenv("BUILD_WORKING_DIRECTORY")

    if user_dir:
        os.chdir(user_dir)


def split_once_or_double(s: str, delimiter: str) -> List[str]:
    parts = s.split(delimiter, 1)

    return parts if len(parts) == 2 else [s, s]


def copy_file(src: Union[str, Path], dst: Union[str, Path]):
    with open(dst, "wb") as out:
        with open(src, "rb") as input:
            out.write(input.read())


def main():
    chdir()

    args = parse_args()

    if args.exec.exists():
        args.exec = args.exec.absolute()

    args.wd.mkdir(parents=True, exist_ok=True)

    for input in args.inputs:
        src, alias = split_once_or_double(input, ":")
        dst = args.wd.joinpath(alias).absolute()
        dst.parent.mkdir(parents=True, exist_ok=True)

        copy_file(src, dst)

    p = run([args.exec] + args.command, stderr=STDOUT, stdout=PIPE, cwd=args.wd)

    if p.returncode != 0:
        print(
            f"Command exited with {p.returncode}:\n{p.stdout.decode()}", file=sys.stderr
        )
        sys.exit(p.returncode)

    if args.output:
        file, alias = split_once_or_double(args.output, ":")
        copy_file(args.wd.joinpath(alias), file)
        os.chmod(file, 0o644)


if __name__ == "__main__":
    main()

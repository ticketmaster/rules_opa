# Create a opa friendly context from bazel sources and generated files.
from dataclasses import dataclass
from argparse import ArgumentParser
from subprocess import run, PIPE, STDOUT
import os
import sys


@dataclass
class Args:
    output: str | None
    inputs: list[str]
    command: list[str]
    wd: str


def parse_args() -> Args:
    parser = ArgumentParser()
    parser.add_argument("-o", "--output", metavar="FILE:ALIAS",
                        help="expected output file to extract from the working directory")
    parser.add_argument("-d", "--working-directory", required=True)
    parser.add_argument("-i", "--input", nargs="+",
                        help="files to put in the context", metavar="FILE:ALIAS")
    parser.add_argument("command", nargs="+")

    args = parser.parse_args()

    return Args(
        output=args.output,
        inputs=args.input,
        command=args.command,
        wd=args.working_directory,
    )

# When run with `bazel run` directly when working directly is not the user's working directory


def chdir():
    user_dir = os.getenv("BUILD_WORKING_DIRECTORY")

    if user_dir:
        print(f"chdir: {user_dir}")
        os.chdir(user_dir)


def split_once_or_double(s: str, delimiter: str) -> list[str]:
    parts = s.split(delimiter, 1)

    return parts if len(parts) == 2 else [s, s]


def copy_file(src: str, dst: str):
    with open(dst, "wb") as out:
        with open(src, "rb") as input:
            out.write(input.read())


def main():
    chdir()

    args = parse_args()

    if os.path.exists(args.command[0]):
        args.command[0] = os.path.abspath(args.command[0])

    os.makedirs(args.wd, exist_ok=True)

    for input in args.inputs:
        src, alias = split_once_or_double(input, ":")
        dst = os.path.abspath(os.path.join(args.wd, alias))

        os.makedirs(os.path.dirname(dst), exist_ok=True)

        try:
            os.link(src, dst)
        except PermissionError:
            copy_file(src, dst)

    p = run(args.command, stderr=STDOUT, stdout=PIPE, cwd=args.wd)

    if p.returncode != 0:
        print(p.stdout.decode())
        sys.exit(p.returncode)

    if args.output:
        file, alias = split_once_or_double(args.output, ":")
        copy_file(os.path.join(args.wd, alias), file)
        os.chmod(file, 0o644)


if __name__ == "__main__":
    main()

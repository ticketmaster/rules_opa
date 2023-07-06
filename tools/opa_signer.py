from argparse import ArgumentParser
from tarfile import TarFile, TarInfo, open as taropen
from subprocess import run, PIPE,STDOUT
from dataclasses import dataclass
from io import BytesIO
import sys
import os

@dataclass
class Args:
    bundle: str
    output: str
    signing_key: str
    signing_alg: str
    command: list[str]

def parse_args() -> Args:
    parser = ArgumentParser(prog="rules_opa::opa_signer", description="Tool to re-bundle an opa bundle with a signature file")

    parser.add_argument("-b", "--bundle", required=True)
    parser.add_argument("-o", "--output", required=True)
    parser.add_argument("--signing-key", required=True)
    parser.add_argument("--signing-alg", default="RS256")
    parser.add_argument("command", nargs='+')

    ns = parser.parse_args()

    return Args(
        ns.bundle,
        ns.output,
        ns.signing_key,
        ns.signing_alg,
        ns.command,
    )

def perform_signature(args: Args) -> str:
    expected_file = ".signatures.json"
    completed_process = run(args.command + ['--signing-key', args.signing_key, "--signing-alg", args.signing_alg, "--bundle", args.bundle], stdout=PIPE, stderr=STDOUT)
    returncode = completed_process.returncode
    
    if returncode != 0:
        command = " ".join(completed_process.args)
        stdout = completed_process.stdout.decode()
        print(f"Command exited with non-zero return code {returncode}.\n{command}\n{stdout}", file=sys.stderr)
        sys.exit(1)
    
    if not os.path.exists(expected_file):
        command = " ".join(completed_process.args)
        print(f"File {expected_file} not found after running command:\n{command}", file=sys.stderr)
        sys.exit(1)

    return expected_file

def transfer_files(output: TarFile, bundle: TarFile):
    for member in bundle.getmembers():
        output.addfile(member, bundle.extractfile(member))

def addfile(output: TarFile, file_name: str):
    with open(file_name, mode="rb") as f:
        data = f.read()

    info = TarInfo(f"/{file_name}")
    info.size = len(data)
    output.addfile(info, BytesIO(data))


def main():
    args = parse_args()

    signature_file = perform_signature(args)

    with taropen(args.bundle, mode="r:gz") as bundle:
        with taropen(args.output, mode="w:gz") as output:
            addfile(output, signature_file)
            transfer_files(output, bundle)

if __name__ == "__main__":
    main()


from argparse import ArgumentParser
from dataclasses import dataclass

@dataclass
class Args:
    bundle: str
    signing_key: str
    signing_alg: str

def parse_args() -> Args:
    parser = ArgumentParser(prog="rules_opa::opa_signer", description="Tool to re-bundle an opa bundle with a signature file")

    parser.add_argument("-b", "--bundle", required=True)
    parser.add_argument("--signing-key", required=True)
    parser.add_argument("--signing-alg", default="RS256")

    ns = parser.parse_args()

    return Args(
        ns.bundle,
        ns.signing_key,
        ns.signing_alg,
    )


def main():
    args= parse_args()
    signing_key = args.signing_key
    signing_alg = args.signing_alg

    with open(".signatures.json", mode="w") as out:
        out.write(f'{{"signatures":["{signing_key}.{signing_alg}"]}}')


if __name__ == "__main__":
    main()

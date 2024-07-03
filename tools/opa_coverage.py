from typing import List, Dict, Any, cast
from subprocess import run, PIPE
from dataclasses import dataclass
from os import environ

import json
import sys


@dataclass
class CoverageRangeContent:
    row: int

    @classmethod
    def from_dict(cls, data):
        return cls(row=data.get("data") or 0)


@dataclass
class CoverageRange:
    start: CoverageRangeContent
    end: CoverageRangeContent

    @classmethod
    def from_dict(cls, data):
        return cls(
            start=CoverageRangeContent.from_dict(data.get("start")),
            end=CoverageRangeContent.from_dict(data.get("end")),
        )


@dataclass
class CoverageFile:
    covered: List[CoverageRange]
    not_covered: List[CoverageRange]
    covered_lines: int
    not_covered_lines: int
    coverage: float

    @classmethod
    def from_dict(cls, data):
        return cls(
            covered=[CoverageRange.from_dict(r) for r in data.get("covered") or []],
            not_covered=[
                CoverageRange.from_dict(r) for r in data.get("not_covered") or []
            ],
            covered_lines=int(data.get("covered_lines") or 0),
            not_covered_lines=int(data.get("not_covered_lines") or 0),
            coverage=float(data.get("coverage")),
        )


@dataclass
class CoverageReport:
    files: Dict[str, CoverageFile]
    covered_lines: int
    not_covered_lines: int
    coverage: float

    @classmethod
    def from_dict(cls, data):
        return cls(
            files={
                file: CoverageFile.from_dict(report)
                for file, report in data.get("files").items()
            },
            covered_lines=int(data.get("covered_lines")),
            not_covered_lines=int(data.get("not_covered_lines")),
            coverage=float(data.get("coverage")),
        )


def main(argv: List[str]):
    _program, test_name, opa, cmd, *args = argv

    coverage_enabled = bool(environ.get("COVERAGE", 0))
    coverage_output_file = environ.get("COVERAGE_OUTPUT_FILE")

    assert coverage_enabled
    assert coverage_output_file is not None

    proc = run([opa, cmd, "--format=json", "--coverage"] + args, stdout=PIPE)

    if proc.returncode != 0:
        exit(proc.returncode)

    result = CoverageReport.from_dict(json.loads(proc.stdout))

    with open(coverage_output_file, "w") as f:
        for file, report in result.files.items():
            if file in args:
                continue  # Skip test sources
            print(f"TN:{test_name.removeprefix('@@')}", file=f)
            print(f"SF:{file}", file=f)
            print(f"FNF:0", file=f)
            print(f"FNH:0", file=f)

            for r in report.covered:
                for i in range(r.start.row, r.end.row + 1):
                    print(f"DA:{i},1", file=f)

            print(f"LF:{report.covered_lines+report.not_covered_lines}", file=f)
            print(f"LH:{report.covered_lines}", file=f)
            print("end_of_record", file=f)
            print(file=f)


if __name__ == "__main__":
    main(sys.argv)

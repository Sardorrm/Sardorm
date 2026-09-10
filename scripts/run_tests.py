#!/usr/bin/env python3
"""Deterministic Python test entrypoint used by local and CI validation."""
from __future__ import annotations

import compileall
import os
import sys
import unittest


ROOTS = ("tests", "scripts")


def main() -> int:
    os.environ.setdefault("PYTHONHASHSEED", "0")
    for root in ROOTS:
        if not compileall.compile_dir(root, quiet=1, force=False):
            print(f"Python bytecode compilation failed under {root}", file=sys.stderr)
            return 1

    suite = unittest.defaultTestLoader.discover("tests", pattern="test_*.py")
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())

"""Shared fixtures for SolvingMicroDSOPs tests."""

import sys
import os

_repo = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir, os.pardir, os.pardir))
for subdir in ["Code/Python", "Code/Python/snippets", "Calibration"]:
    path = os.path.join(_repo, subdir)
    if path not in sys.path:
        sys.path.insert(0, path)

if _repo not in sys.path:
    sys.path.insert(0, _repo)

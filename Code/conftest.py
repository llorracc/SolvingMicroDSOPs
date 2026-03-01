import sys
import os

# Patch sys.path so bare-module imports (resources, endOfPrd, etc.) resolve
# without requiring __init__.py or package installation.
# This mirrors the manual path manipulation in do_all.py.
_repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for subdir in ["Code/Python", "Code/Python/snippets", "Calibration"]:
    path = os.path.join(_repo, subdir)
    if path not in sys.path:
        sys.path.insert(0, path)

# Also add the repo root (for do_all.py-style imports)
if _repo not in sys.path:
    sys.path.insert(0, _repo)

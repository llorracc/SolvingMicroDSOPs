"""Smoke tests: verify every module can be imported without error."""

import importlib
import pytest


@pytest.mark.parametrize("module_name", [
    "resources",
    "endOfPrd",
    "solution",
    "EstimationParameters",
    "SetupSCFdata",
])
def test_import_core(module_name):
    mod = importlib.import_module(module_name)
    assert mod is not None


def test_import_struct_estimation():
    """StructEstimation triggers heavy HARK imports; test separately."""
    import StructEstimation
    assert hasattr(StructEstimation, "smmObjectiveFxn")

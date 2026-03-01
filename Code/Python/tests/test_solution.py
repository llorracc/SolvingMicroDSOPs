"""Smoke tests for solution containers and value-function transforms."""

import numpy as np
import pytest

from solution import (
    ModelParams,
    PeriodSolution,
    Stage,
    Perch,
    v_to_vinv,
    vinv_to_v,
)


class TestValueTransforms:
    """v_to_vinv and vinv_to_v should be inverses of each other."""

    @pytest.mark.parametrize("rho", [1.5, 2.0, 3.0, 5.0])
    def test_roundtrip(self, rho):
        v = np.linspace(-10, -0.01, 50)
        vP = v_to_vinv(v, rho)
        v_back = vinv_to_v(vP, rho)
        np.testing.assert_allclose(v_back, v, atol=1e-8)

    def test_rho_one(self):
        v = np.linspace(-5, 5, 50)
        vP = v_to_vinv(v, 1.0)
        v_back = vinv_to_v(vP, 1.0)
        np.testing.assert_allclose(v_back, v, atol=1e-10)


class TestModelParams:
    """ModelParams should be immutable and have sensible defaults."""

    def test_defaults(self):
        p = ModelParams()
        assert p.DiscFac == 0.96
        assert p.CRRA == 2.0
        assert p.Rfree == 1.03

    def test_frozen(self):
        p = ModelParams()
        with pytest.raises(Exception):
            p.CRRA = 5.0

    def test_custom(self):
        p = ModelParams(DiscFac=0.99, CRRA=3.0)
        assert p.DiscFac == 0.99
        assert p.CRRA == 3.0


class TestSolutionContainers:
    """PeriodSolution / Stage / Perch hierarchy."""

    def test_period_add_stage(self):
        sol = PeriodSolution(name='test')
        stg = sol.add_stage('my_stage')
        assert isinstance(stg, Stage)
        assert 'my_stage' in sol.stg
        assert 'my_stage' in sol.stg_order

    def test_bracket_access(self):
        sol = PeriodSolution(name='test')
        stg = sol.add_stage('cons')
        stg['dcsn'].c = lambda m: m * 0.5
        assert sol['cons']['dcsn'].c(2.0) == 1.0

    def test_stage_perches(self):
        stg = Stage(name='test_stage')
        assert 'arvl' in stg.prch
        assert 'dcsn' in stg.prch
        assert 'cntn' in stg.prch

    def test_custom_perch_names(self):
        s = Stage("disc", perch_names=["in", "out"])
        assert set(s.prch.keys()) == {"in", "out"}

    def test_multi_stage_order(self):
        ps = PeriodSolution("T-1")
        ps.add_stage("Shr")
        ps.add_stage("cFunc")
        assert ps.stg_order == ["Shr", "cFunc"]

    def test_wire(self):
        ps = PeriodSolution("T-1")
        shr = ps.add_stage("Shr")
        cfn = ps.add_stage("cFunc")
        cfn["arvl"].v = lambda a: -a
        ps.wire("Shr", "cFunc")
        assert shr["cntn"].v(3.0) == -3.0

    def test_full_retrieval_pattern(self):
        """S[t]['stage']['perch'].v(x) pattern from the math notation."""
        S = []
        sol = PeriodSolution("T")
        sol.add_stage("cFunc")
        sol["cFunc"]["cntn"].v = lambda m: -1.0 / m
        S.append(sol)
        assert S[0]["cFunc"]["cntn"].v(2.0) == -0.5

"""Unit tests for Code/Python/solution.py."""

from solution import Perch, Stage, PeriodSolution


class TestPerch:
    def test_construction(self):
        p = Perch("cntn")
        assert p.name == "cntn"

    def test_set_attribute(self):
        p = Perch("dcsn")
        p.v = lambda m: -m
        assert p.v(2.0) == -2.0

    def test_repr(self):
        p = Perch("arvl")
        assert "arvl" in repr(p)


class TestStage:
    def test_default_perches(self):
        s = Stage("cFunc")
        assert "arvl" in s.prch
        assert "dcsn" in s.prch
        assert "cntn" in s.prch

    def test_bracket_access(self):
        s = Stage("cFunc")
        assert s["cntn"] is s.prch["cntn"]

    def test_custom_perch_names(self):
        s = Stage("disc", perch_names=["in", "out"])
        assert set(s.prch.keys()) == {"in", "out"}

    def test_repr(self):
        s = Stage("Shr")
        assert "Shr" in repr(s)


class TestPeriodSolution:
    def test_add_stage(self):
        ps = PeriodSolution("T")
        ps.add_stage("cFunc")
        assert "cFunc" in ps.stg
        assert ps.stg_order == ["cFunc"]

    def test_bracket_access(self):
        ps = PeriodSolution("T")
        ps.add_stage("cFunc")
        assert ps["cFunc"] is ps.stg["cFunc"]

    def test_multi_stage(self):
        ps = PeriodSolution("T-1")
        ps.add_stage("Shr")
        ps.add_stage("cFunc")
        assert ps.stg_order == ["Shr", "cFunc"]

    def test_wire(self):
        ps = PeriodSolution("T-1")
        shr = ps.add_stage("Shr")
        cfn = ps.add_stage("cFunc")
        cfn["arvl"].v = lambda a: -a  # set something on the destination
        ps.wire("Shr", "cFunc")
        # After wiring, Shr's continuation should have cFunc's arrival's v
        assert shr["cntn"].v(3.0) == -3.0

    def test_full_retrieval_pattern(self):
        """S[t]['Shr']['cntn'].v(a) pattern from the math notation."""
        S = []
        sol = PeriodSolution("T")
        sol.add_stage("cFunc")
        sol["cFunc"]["cntn"].v = lambda m: -1.0 / m
        S.append(sol)
        assert S[0]["cFunc"]["cntn"].v(2.0) == -0.5

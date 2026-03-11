"""
Instantiate in code the objects described in _sectn-solving-the-next.tex
the Building the Pile Backward and Act of Creation subsections.
Uses only the standard library.
"""


def u(c, CRRA=2.0):
    """Utility u(c); LaTeX \\uFunc."""
    if c <= 0:
        return -1e10
    return (c ** (1 - CRRA)) / (1 - CRRA)


class CnctrComp:
    """Connector: links next period arrival kNrm to this period end-of-period aNrm (same value)."""

    def __init__(self, from_var, to_var):
        self.from_var = from_var
        self.to_var = to_var

    def map_to_nxt(self, aNrm):
        """kNrm_{t} = aNrm_{t-1}."""
        return aNrm


class pile:
    """Period solution: vBegPrd (arrival), vCntn (continuation), vEndPrd, cFunc."""

    def __init__(self, period_label, vBegPrd=None, vCntn=None, vEndPrd=None, cFunc=None):
        self.period_label = period_label
        self.vBegPrd = vBegPrd
        self.vCntn = vCntn
        self.vEndPrd = vEndPrd
        self.cFunc = cFunc


def make_pile_T(DiscFac, CRRA=2.0):
    """Terminal period T: consume everything, v_T(m) = u(m), cFunc(m) = m."""
    vBegPrd = lambda mNrm: u(mNrm, CRRA)
    cFunc = lambda mNrm: mNrm
    return pile("T", vBegPrd=vBegPrd, vCntn=vBegPrd, vEndPrd=vBegPrd, cFunc=cFunc)


def act_of_creation(C, vBegPrdNxt, DiscFac, m_grid, CRRA=2.0):
    """
    vEndPrd(aNrm) := DiscFac * vBegPrdNxt(aNrm); vCntn = vEndPrd;
    vBegPrd(mNrm) = max_c u(c) + vCntn(mNrm - c). Return vEndPrd, vCntn, vBegPrd, cFunc.
    """
    vEndPrd = lambda aNrm: DiscFac * vBegPrdNxt(C.map_to_nxt(aNrm))
    vCntn = vEndPrd
    vBegPrd_vals = []
    cFunc_vals = []
    n = 40
    for mNrm in m_grid:
        best_v = -1e10
        best_c = mNrm / 2
        for k in range(1, n):
            c = (k / n) * (mNrm - 1e-8) + 1e-8
            aNrm = mNrm - c
            v_val = u(c, CRRA) + vCntn(aNrm)
            if v_val > best_v:
                best_v = v_val
                best_c = c
        vBegPrd_vals.append(best_v)
        cFunc_vals.append(best_c)
    vBegPrd = lambda m: _interp(m_grid, vBegPrd_vals, m)
    cFunc = lambda m: _interp(m_grid, cFunc_vals, m)
    return vEndPrd, vCntn, vBegPrd, cFunc


def _interp(x_list, y_list, x):
    if x <= x_list[0]:
        return y_list[0]
    if x >= x_list[-1]:
        return y_list[-1]
    for i in range(len(x_list) - 1):
        if x_list[i] <= x <= x_list[i + 1]:
            t = (x - x_list[i]) / (x_list[i + 1] - x_list[i])
            return y_list[i] + t * (y_list[i + 1] - y_list[i])
    return y_list[-1]


def insert_before(Pile, C, pile_target):
    """Insert connector C into Pile immediately before pile_target."""
    i = Pile.index(pile_target)
    Pile.insert(i, C)


def prepend(Pile, pile_new):
    """Prepend period solution to front of Pile."""
    Pile.insert(0, pile_new)


def backward_mover_prd(Pile, pile_t, period_label_tm1, DiscFac, m_grid, CRRA=2.0):
    """
    Extend Pile backward: create connector, insert before pile_t, creation of vEndPrd, prepend pile_{t-1}.
    """
    C = CnctrComp(from_var="aNrm_tm1", to_var="kNrm_t")
    insert_before(Pile, C, pile_t)
    vEndPrd, vCntn, vBegPrd, cFunc = act_of_creation(
        C, pile_t.vBegPrd, DiscFac, m_grid, CRRA
    )
    pile_tm1 = pile(period_label_tm1, vBegPrd=vBegPrd, vCntn=vCntn, vEndPrd=vEndPrd, cFunc=cFunc)
    prepend(Pile, pile_tm1)
    return pile_tm1, C


if __name__ == "__main__":
    DiscFac = 0.96
    CRRA = 2.0
    m_grid = [0.1 + 0.35 * i for i in range(30)]

    # In terminal period T, the optimal policy is to consume everything: v_T(m) = u(m).
    pile_T = make_pile_T(DiscFac, CRRA)
    m_test = 2.0
    assert pile_T.vBegPrd(m_test) == u(m_test, CRRA), "v_T(m) = u(m)"
    assert pile_T.cFunc(m_test) == m_test, "cFunc_T(m) = m (consume everything)"

    # This solved period is the first element of the pile. Initially P = {p_T}, a single solved period.
    Pile = [pile_T]
    assert len(Pile) == 1 and Pile[0] is pile_T

    pile_Tm1, CnctrComp_Tm1_T = backward_mover_prd(
        Pile, pile_T, "T-1", DiscFac, m_grid, CRRA
    )

    assert Pile[0] is pile_Tm1
    assert Pile[1] is CnctrComp_Tm1_T
    assert Pile[2] is pile_T
    print("Pile = [pile_Tm1, CnctrComp_Tm1_T, pile_T]")
    print("vBegPrd(T-1)(2.0) =", pile_Tm1.vBegPrd(2.0))
    print("cFunc(T-1)(2.0)   =", pile_Tm1.cFunc(2.0))

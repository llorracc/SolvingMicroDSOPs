Pile = [pile_T]

CnctrComp_Tm1_T = create(kNrm_T=None, aNrm_Tm1=None)
insert_before(Pile, CnctrComp_Tm1_T, pile_T)

vEndPrd = lambda aNrm: DiscFac * vBegPrdNxt(aNrm)
vCntn = vEndPrd
vBegPrd = lambda mNrm: max(u(cNrm) + vCntn(mNrm - cNrm) for cNrm in cNrm_grid)

pile_Tm1 = period_solution(vBegPrd, vCntn)
prepend(Pile, pile_Tm1)

# Pile == [pile_Tm1, CnctrComp_Tm1_T, pile_T]

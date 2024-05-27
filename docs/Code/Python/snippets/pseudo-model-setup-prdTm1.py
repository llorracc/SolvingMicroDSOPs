# construct period T-1 contents for model that has period T already
# MNW, SB, AL to substitute their ideas here
# Using : as the python prompt

# Now let's build what is in the interval Tm1

>>> prdTm1=0
>>> prdT=-1

# add_interval should construct mdl2prd.solution[Tm1]
>>> mdl2prd.add_interval()

# it should set  mdlprd2.solution[Tm1].interval[-1] 

>>> mdl2prd.solution[prdT].interval.add_vEndPrd(
    parse_file_model='vEndTerm_plato.yml' # Platonic description 
    parse_file_setup='mdl2prd_config.yml' # like, simulation_method=monte_carlo
    )

# probably we need to put the stages in a sublist ...
>>> mdl2prd.solution[prdT].interval.make_empty_stage_list()

# The last stage is added first
## Period T is a special case in which no solving is necessary since we know the solution is c=m

>>> mdl2prd.solution[prdT].interval.append_stage(
    stage_name='c',
    parse_file_model='consume_all_m.yml',
    parse_file_stage='consume_all_m_stagefile.yml'
  ) # not sure whether parse_file_stage is needed ... 

# Now add a portfolio stage
## append_stage will test whether there are already any other stages in existence
## If so it will
### - prepend to the list of stages an empty earlier stage
### - set stg[new_stg].vEndStg = stg[successor_stg].vBegStg

>>> mdl2prd.solution[prdT].interval.append_stage(
    stage_name='Shr',
    parse_file_model='portfolio_shr_solve.yml',
    parse_file_model='portfolio_shr_stage.yml' # again not sure if needed
    )

# We are finished adding stages; finish by adding vBeg
>>> mdl2prd.solution[prdT].interval.add_vBeg() # 
>>> mdl2prd.solution[prdT].interval.solution
    [vBeg, [ Shr, c ], vEnd]

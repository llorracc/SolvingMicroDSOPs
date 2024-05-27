# make empty model
# MNW, SB, AL to substitute their ideas here
# Using : as the python prompt

## create empty two-period-model object
>>> mdl2prd = HARK2.modelMake(modelKind=finiteHorizon,
                              [other configs])

## what does the solution object look like?
### - there is only one interval filled in, which is a blank slate:

>>> mdl2prd.solution

[
    interval
]

>>> prdT=0 # To make the stuff below a bit easier to follow
>>> mdl2prd.solution[prdT].interval

(returns whatever info is created for the default interval)

# Now let's build what is in the interval
## Assume there is a yml file 'vEndTerm' for constructing v(S)=0 for all states:

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

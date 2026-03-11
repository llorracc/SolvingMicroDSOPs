>>> prdT=len(mdl2prd.sequential) - 1 # (because transit is last)

>>> mdl2prd.sequential[prdT] # inspect last period 

'(whatever was constructed in prdT)'

# Now let's build what is in T-1
## Assume there is a yml file for the transition

# prepend transition
>>> mdl2prd.sequential.add_transit('transit_consumption_portfolio.yml')

# a <--> k  (a maps to k)
# vBeg for transit should be vBeg for successor
# mdl2prd.sequential[0].vBeg = mdl2prd.sequential[1].vBeg 

# Begin constructing period T-1

>>> mdl2prd.sequential

[
    transit_consumption_portfolio,
    interval_T # = [vBeg, [ Shr, cNrm ], vEnd],
    transit_TtoEnd
    ]

>>> mdl2prd.sequential.add_interval(
    parse_model='consumption_portfolio.yml',
    interval_name='shr_cNrm_T'
    )
>>> 

>>> mdl2prd.sequential
[
    [vEnd],
    transit, # state variable transitions
    [vBeg,[Shr,c],vEnd] # From already-solved prdT
]

>>> mdl2prd.sequential[prdT].interval.make_empty_stage_list()

# The last stage is added first
## Period T is a special case in which no solving is necessary since we know the sequential is c=m

>>> mdl2prd.sequential[prdT].interval.append_stage(
    stage_name='c',
    parse_file_model='consume_all_m.yml',
    parse_file_stage='consume_all_m_stagefile.yml'
  ) # not sure whether parse_file_stage is needed ... 

# Now add a portfolio stage
## append_stage will test whether there are already any other stages in existence
## If so it will
### - prepend to the list of stages an empty earlier stage
### - set prch[new_prch].vCntn = prch[successor_prch].vArvl

>>> mdl2prd.sequential[prdT].interval.append_stage(
    stage_name='Shr',
    parse_file_model='portfolio_shr_solve.yml',
    parse_file_model='portfolio_shr_stage.yml' # again not sure if needed
    )

# We are finished adding stages; finish by adding vBeg
>>> mdl2prd.sequential[prdT].interval.add_vBeg() # 
>>> mdl2prd.sequential[prdT].interval.sequential
    [vBeg, [ Shr, c ], vEnd]

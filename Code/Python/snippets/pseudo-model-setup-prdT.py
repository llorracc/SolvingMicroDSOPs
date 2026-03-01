# make empty model
# MNW, SB, AL to substitute their ideas here

## create empty two-period-model object
>>> modl2prd = HARK2.modelMake(modelKind=finiteHorizon,
                              final_transit='transit_TtoEnd',
                              [other configs])
# where we are supposing that final_transit.yml and interval_prdT.yml
# are the sources for constructing the final transit and interval

## what does the just-created sequential object look like?

# We have two kinds of elements in the sequence:
# -  intervals, and transits

# the modelMake only sets up the final transit

>>> modl2prd.sequential

[
    transit_TtoEnd  # presence of null transition regularizes structure
]

>>> transit_loc=-1 # transparent indexing
>>> interval_loc=0 # transparent indexing

>>> type(modl2prd.sequential[transit_loc])

sequence_object

# What are the contents of the transit location?
>>> modl2prd.sequential[transit_loc]

'vFunc_null or whatever name we want to give to a function that returns 0 for any input'

# Now let's build what is in the interval_prdT sequence object

>>> modl2prd.add_empty_interval(name='periodT')
>>> modl2prd.sequential

[
    periodT,
    transit_TtoEnd
]

>>> prdT=0 # for transparent indexing
>>> modl2prd.sequential[prdT]

[vEndPrd] # should have been set as vFunc_null by add_empty_interval

# put the stages in a sublist ...
>>> modl2prd.sequential[prdT].add_empty_stage_list(name='shr_cNrm')

>>> modl2prd.sequential[prdT]
>>> shr_cnrm_loc=0
[shr_cnrm,vEndPrd]
>>> modl2prd.sequential[prdT][shr_cnrm_loc] # is empty - no stages yet added
[]

# The last stage is added first
## Period T is a special case in which no solving is necessary since we know that c=m

>>> modl2prd.sequential[prdT].prepend_stage(
    stage_name='cNrmStg',
    parse_model='consume_all_m.yml',
    parse_setup='consume_all_m_stage_setup.yml'
    # or maybe _setup info is inherited from modl2prd_config.yml?
  ) 

>>> modl2prd.sequential[prdT]

[[cNrmStg],vEnd]

>>> cNrmStg_loc=0
>>> type(modl2prd.sequential[prdT][cNrmStg_loc])

bellman_object

>>> modl2prd.sequential[prdT][cNrmStg_loc]

[ vArvl, vDcsn, vCntn ]

>>> dcsn_loc = 1

>>> cNrmStg_vDcsn = modl2prd.sequential[prdT][cNrmStg_loc][dcsn_loc] 

# Put the 'period-local' objects on the period's whiteboard namespace
# consumption function is the decision rule from the decision step of the Bellman
>>> modl2prd.sequential[prdT].cFunc = cNrmStg_vDcsn

>>> type(modl2prd.sequential[prdT].cFunc)

decision_rule

# Now add a portfolio stage
## prepend_stage will test whether there are already any other stages in existence
## If so it will
### - prepend to the list of stages an empty earlier stage
### - set stg[new_stg].vCntn = stg[successor_stg].vArvl

>>> modl2prd.sequential[prdT].prepend_stage(
    stage_name='ShrStg',
    parse_model='portfolio_shr_solve.yml',
    parse_setup='portfolio_shr_setup.yml'
    # maybe needed only if want to deviate from modl2prd_config.yml
    )

>>> modl2prd.sequential[prdT]

[[ShrStg,cNrmStg],vEnd]

# Get the portfolio share rule
>>> stages_loc=0
>>> shr_stage_loc=0
>>> vMidShrStg_tmp = modl2prd.sequential[prdT][stages_loc][share_stage_loc][dcsn_loc]
>>> modl2prd.sequential[prdT].shrFunc = vMidShrStg_tmp.dr

# We are finished adding stages; finish interval by adding vBegPrd
>>> modl2prd.sequential[prdT].add_vBegPrd() # inherits ShrStg[0]=vArvl
>>> modl2prd.sequential[prdT]
    [vBegPrd, [ ShrStg, cNrmStg ], vEndPrd]

>>> modl2prd.sequential[prdT+1]
    transit_TtoEnd

    

# Here is pseudocode for setting up a model

## Create an empty object with global parameters (if any)
$ model2prd = modelMake(finiteHorizon,global_parameters)

$ model2prd.solution:

[
    stg_or_prd
]

## endow it with default global parameters for finite horizon
$ model2prd.global_parameters = dict_finite_horizon_defaults

[

$ dir(model2prd.solution[0])

(should display the structure of an empty perch object)


$ solution[0].period_object.period_specific_parameters:

(empty)

$ solution[0].period_object.

$

$ vEndTrm = parse_model('vEndTrm.yml')
$ 

[
    [vEndTrm]
    ]

$ stages_add cPrchAddTo(model2prd):
[
    [cPrch,
     vEndTrm]
    ]

$ 
[
    [ShrStg,
        cPrch,
     vEndTrm]
    ]

$ vBegAddTo(model2prd):

[
    [vBegPrd,
        ShrStg,
        cPrch,
     vEndTrm]
]



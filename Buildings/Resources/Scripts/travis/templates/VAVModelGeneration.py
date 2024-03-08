#!/usr/bin/env python
# coding: utf-8

"""Generate combinations and run simulations.

This script shall be run from the directory `modelica-buildings/Buildings`,
i.e., where the top-level `package.mo` file can be found.

Args:
    - See docstring of core.py for the optional positional arguments of this script.

Returns:
    - 0 if all simulations succeed.
    - 1 otherwise.

Details:
    The script performs the following tasks.
    - Generate all possible combinations of class modifications based on a set of
      parameter bindings and redeclare statements provided in `MODIF_GRID`.
    - Exclude the combinations based on a match with the patterns provided in `EXCLUDE`.
    - This allows excluding unsupported configurations.
    - Exclude the class modifications based on a match with the patterns provided in `REMOVE_MODIF`,
      and prune the resulting duplicated combinations.
    - This allows reducing the number of simulations by excluding class modifications that
      yield the same model, i.e., modifications to parameters that are not used (disabled) in
      the given configuration.
    - For the remaining combinations: run the corresponding simulations for the models in `MODELS`.
"""

from s223ToMo import *
from queryS223VAVBox import *

if __name__ == "__main__":

    g = rdflib.Graph()
    g.parse('vavBoxModel.ttl', format = 'ttl')
    configurations = {}
    vavs = getAllVavs(g)
    for vav in vavs:
        sensorsAndProperties = getAllPropertiesAndSensors(g, vav)
        containsReheat = checkIfReheatCoilPresent(g, vav)
        if containsReheat:
            configurations[vav] = {
                'reheat': True,
                'sensors': sensorsAndProperties
            }
        else:
             configurations[vav] = {
                'reheat': False,
                'sensors': sensorsAndProperties
            }

    for vav in configurations:
        config = configurations.get(vav)
        reheat = config.get('reheat')
        MODELS = []
        model = ""
        if reheat:
            model = 'Buildings.Templates.ZoneEquipment.Validation.VAVBoxReheat'
        else:
             model = 'Buildings.Templates.ZoneEquipment.Validation.VAVBoxCoolingOnly'
        MODELS.append(model)
        
        vavSensors = config.get('sensors')
        MODIF_GRID = {model: {}}
        for sensor in ['occupancy', 'window', 'CO2']:
            if sensor == 'occupancy':
                if sensor in vavSensors:
                    MODIF_GRID[model]['VAVBox_1__ctl__have_occSen']=['true']
                else:
                    MODIF_GRID[model]['VAVBox_1__ctl__have_occSen']=['false']
                    
            if sensor == 'window':
                if sensor in vavSensors:
                    MODIF_GRID[model]['VAVBox_1__ctl__have_winSen']=['true']
                else:
                    MODIF_GRID[model]['VAVBox_1__ctl__have_winSen']=['false']

            if sensor == 'CO2':
                if sensor in vavSensors:
                    MODIF_GRID[model]['VAVBox_1__ctl__have_CO2Sen']=['true']
                else:
                    MODIF_GRID[model]['VAVBox_1__ctl__have_CO2Sen']=['false']
                    
        if reheat:
            ## TODO: how to query these? 
            MODIF_GRID[model]['VAVBox_1__redeclare__coiHea'] = ['Buildings.Templates.Components.Coils.WaterBasedHeating(typVal=Buildings.Templates.Components.Types.Valve.TwoWayModulating)']


        # See docstring of `prune_modifications` function for the structure of EXCLUDE.
        EXCLUDE = None

        # See docstring of `prune_modifications` function for the structure of REMOVE_MODIF.
        REMOVE_MODIF = None

        print(MODELS)
        print(MODIF_GRID)
        args = parse_args()
        tool = args.tool.lower()


        all_experiment_attributes = dict(
            zip(MODELS, map(get_experiment_attributes, MODELS))
        )
        combinations = generate_combinations(models=MODELS, modif_grid=MODIF_GRID)

        # Prune class modifications.
        combinations = prune_modifications(
            combinations=combinations,
            exclude=EXCLUDE,
            remove_modif=REMOVE_MODIF,
            fraction_test_coverage=args.coverage,
        )

        if len(combinations) > 0:
            # Simulate cases.
            results = simulate_cases(
                combinations,
                simulator=tool,
                all_experiment_attributes=all_experiment_attributes,
                asy=False,
            )

        #main(models=MODELS, modif_grid=MODIF_GRID, exclude=EXCLUDE, remove_modif=REMOVE_MODIF)


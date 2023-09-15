import re
from pickle import dump
from os import listdir
import utility.learning_parameters as _lp

# def current_save_ID():
#     _id = 0
#     ids = [int(re.findall('\d+', i)[0]) for i in listdir(_lp.results_save_path)]
#     if len(ids) > 0:
#         _id = max(ids) + 1
#     return _id

def save_parameters(id):
    with open(_lp.config_file_path, 'r') as conf_file:
        with open(_lp.results_save_path+f'{id}_config.json', 'w') as f:
            f.writelines(conf_file.readlines())


# def save_learning_parameters(id):
#     with open(learning_file_path, 'r') as conf_file:
#         with open(results_save_path+f'{id}_parameters.txt', 'w') as f:
#             f.writelines(conf_file.readlines())

def save_learning_parameters(id):
    save_string = f'# GENETIC ALGORITHM PARAMETERS' \
                  f'\n\n# Population' \
                  f'\npopulation_size = {_lp.population_size}' \
                  f'\nprey_network = {_lp.prey_network}' \
                  f'\nprey_network = {_lp.predator_network}' \
                  f'\n\n# Random Init' \
                  f'\ninit_genes = {_lp.init_genes}' \
                  f'\ninit_loc = {_lp.init_loc}' \
                  f'\ninit_scale = {_lp.init_scale}' \
                  f'\n\n# Selection' \
                  f'\nselection_method = {_lp.selection_method}' \
                  f'\ntournament_size = {_lp.tournament_size}' \
                  f'\nelite_size = {_lp.elite_size}' \
                  f'\n\n# Pairing' \
                  f'\npairing_method = {_lp.pairing_method}' \
                  f'\n\n# Crossover' \
                  f'\nmating_method = {_lp.mating_method}' \
                  f'\ncrossover_probability = {_lp.crossover_probability}' \
                  f'\n\n# Mutation' \
                  f'\ngen_mutation_chance = {_lp.gen_mutation_chance}' \
                  f'\nduplication_chance = {_lp.duplication_chance}' \
                  f'\ndeletion_chance = {_lp.deletion_chance}' \
                  f'\nfill_chance = {_lp.fill_chance}'
    with open(_lp.results_save_path+f'{id}_parameters.txt', 'w') as f:
        f.writelines(save_string)

def save_genes(models, id):
    genes = {}
    for model_name, model in models.items():
        temp = [obj.genotype for obj in model.population]
        genes[model_name] = temp

    with open(_lp.results_save_path+f'{id}_genes.pkl', 'wb') as file:
        dump(genes, file)
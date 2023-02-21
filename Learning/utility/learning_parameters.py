import os
import json

pwd_path = os.path.dirname(os.path.abspath(__file__))

root_path = "/home/adrian/Repositories/master_thesis_project/"
config_file_path = root_path + "simulation_config.json"
results_save_path = root_path + "Learning/results/"
learning_file_path = root_path + "Learning/results/learning_params.py"

with open(config_file_path, 'r') as f:
    config = json.loads(f.read())

# ENVIRONMENT PARAMETERS
show_plots = True

number_of_generations = 1000

prey_brain_cells = config['prey']['brain_cells']
predator_brain_cells = config['predator']['brain_cells']

prey_network = config['prey']['brain_type'].lower()
predator_network = config['predator']['brain_type'].lower()

prey_observations_size = config["prey"]["vision"]["cells"] * (3 if config["environment"]["food"]["enabled"] else 2)
predator_observations_size = config["predator"]["vision"]["cells"] * (3 if config["environment"]["food"]["enabled"] else 2)
prey_actions_size = 2
predator_actions_size = 3 if config["predator"]["communication"]["enabled"] else 2

if config["prey"]["communication"]["enabled"]:
    prey_observations_size += config["prey"]["communication"]["hear_cells"]
    if config["environment"]["food"]["enabled"]:
        prey_observations_size += config["prey"]["communication"]["hear_cells"]

if config["predator"]["communication"]["enabled"]:
    predator_observations_size += config["predator"]["communication"]["hear_cells"]


# GENETIC ALGORITHM PARAMETERS
# Population
population_size = 100

# Random Init
init_genes = 0.3
init_loc = 0.
init_scale = 2.

# Selection
selection_method = 'Fittest Half'
tournament_size = 30
elite_size = 2

# Pairing
pairing_method = 'Fittest'

# Crossover
mating_method = 'Single Point'
# mating_method = 'Two Points Per Part'
crossover_probability = 0.3

# Mutation
gen_mutation_chance = 0.01
duplication_chance = 0.01
deletion_chance = 0.01
fill_chance = 0.01

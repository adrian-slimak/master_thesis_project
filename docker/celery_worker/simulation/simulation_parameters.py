# General
number_of_generations = 1000

# Prey & Predator
prey_brain_cells = None
predator_brain_cells = None
prey_network = None
predator_network = None
prey_observations_size = None
predator_observations_size = None
prey_actions_size = None
predator_actions_size = None
prey_observations_size = None
predator_observations_size = None

# Genetic Algorithm
# Population
population_size = None
evolve_prey = None
evolve_predator = None

# Random Init
init_genes = None
init_loc = None
init_scale = None

# Selection
selection_method = None
tournament_size = None
elite_size = None

# Pairing
pairing_method = None

# Crossover
mating_method = None
crossover_probability = None

# Mutation
gen_mutation_chance = None
duplication_chance = None
deletion_chance = None
fill_chance = None

def load_parameters(config: dict):
    # General
    global number_of_generations
    number_of_generations = config['learning']['number_of_generations']

    # Prey & Predator
    global prey_network
    prey_network = config['prey']['brain_type'].lower()
    global predator_network
    predator_network = config['predator']['brain_type'].lower()

    global prey_brain_cells
    prey_brain_cells = config['prey']['brain_cells']
    global predator_brain_cells
    predator_brain_cells = config['predator']['brain_cells']

    global prey_observations_size
    prey_observations_size = config["prey"]["vision"]["cells"] * (3 if config["environment"]["food"]["enabled"] else 2)
    global predator_observations_size
    predator_observations_size = config["predator"]["vision"]["cells"] * (3 if config["environment"]["food"]["enabled"] else 2)
    global prey_actions_size
    prey_actions_size = 2
    global predator_actions_size
    predator_actions_size = 3 if config["predator"]["communication"]["enabled"] else 2

    if config["prey"]["communication"]["enabled"]:
        prey_observations_size += config["prey"]["communication"]["hear_cells"]
        if config["environment"]["food"]["enabled"]:
            prey_observations_size += config["prey"]["communication"]["hear_cells"]

    if config["predator"]["communication"]["enabled"]:
        predator_observations_size += config["predator"]["communication"]["hear_cells"]

    # Genetic Algorithm
    # Population
    global population_size
    population_size = config['learning']['population_size']
    global evolve_prey
    evolve_prey = config['learning']['evolve_prey']
    global evolve_predator
    evolve_predator = config['learning']['evolve_predator']

    # Random Init
    global init_genes
    init_genes = config['learning']['init_genes']
    global init_loc
    init_loc = config['learning']['init_loc']
    global init_scale
    init_scale = config['learning']['init_scale']

    # Selection
    global selection_method
    selection_method = config['learning']['selection_method']
    global tournament_size
    tournament_size = config['learning']['tournament_size']
    global elite_size
    elite_size = config['learning']['elite_size']

    # Pairing
    global pairing_method
    pairing_method = config['learning']['pairing_method']

    # Crossover
    global mating_method
    mating_method = config['learning']['mating_method']
    global crossover_probability
    crossover_probability = config['learning']['crossover_probability']

    # Mutation
    global gen_mutation_chance
    gen_mutation_chance = config['learning']['gen_mutation_chance']
    global duplication_chance
    duplication_chance = config['learning']['duplication_chance']
    global deletion_chance
    deletion_chance = config['learning']['deletion_chance']
    global fill_chance
    fill_chance = config['learning']['fill_chance']

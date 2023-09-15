import numpy as np
from json import dumps
import pickle
from pandas import DataFrame
from . import simulation_parameters as _sp
from . import EnvManager
from .GeneticAlgorithm import GeneticAlgorithm

def run_simulation(simulation_config: dict, prey_weights = None, predator_weights = None, generation_completed_callback = None):
    
    with open("simulation_config.json", "w") as configFile:
        configFile.write(dumps(simulation_config))

    # Set simulation config
    EnvManager.set_parameters("./simulation_config.json")
    _sp.load_parameters(simulation_config)

    # Create fitness and stats arrays
    # Get pointers to them
    prey_fitness = np.zeros(_sp.population_size).astype(np.float32)
    predator_fitness = np.zeros(_sp.population_size).astype(np.float32)
    prey_stats = np.zeros(5).astype(np.float32)
    predator_stats = np.zeros(5).astype(np.float32)
    prey_fitness_pointer = float(prey_fitness.__array_interface__['data'][0])
    predator_fitness_pointer = float(predator_fitness.__array_interface__['data'][0])
    prey_stats_pointer = float(prey_stats.__array_interface__['data'][0])
    predator_stats_pointer = float(predator_stats.__array_interface__['data'][0])

    # Create Environment Manager
    env_manager = EnvManager.EnvManager()
    # EnvManager - set pointers to fitness and stats arrays
    env_manager.set_fitness_pointers(prey_fitness_pointer, predator_fitness_pointer)
    env_manager.set_stats_pointers(prey_stats_pointer, predator_stats_pointer)

    # Create Genetic Algorithms for prey swarm and predator swarm
    GA_prey = GeneticAlgorithm(_sp.prey_observations_size, _sp.prey_brain_cells, _sp.prey_actions_size, _sp.population_size, _sp.prey_network)
    GA_predator = GeneticAlgorithm(_sp.predator_observations_size, _sp.predator_brain_cells, _sp.predator_actions_size, _sp.population_size, _sp.predator_network)

    # Initialize Genetic Algorithms with random genes
    GA_prey.init_population()
    GA_predator.init_population()
    if prey_weights is not None:
        GA_prey.load_population_from_pickle(prey_weights, 'prey')
    if predator_weights is not None:
        GA_predator.load_population_from_pickle(predator_weights, 'predator', genotype_idx=2)

    result_stats = {"Prey fitness - avg" : [],
                    "Prey fitness - best": [],
                    "Prey fitness - worst": [],
                    "Prey mean stats - survivorship" : [],
                    "Prey mean stats - dispersion" : [],
                    "Prey mean stats - density" : [],
                    "Prey mean stats - food" : [],
                    "Predator fitness - avg" : [],
                    "Predator fitness - best": [],
                    "Predator fitness - worst": [],
                    "Predator mean stats - density" : [],
                    "Predator mean stats - dispersion" : [],
                    "Predator mean stats - attacks" : [],
                    "Predator mean stats - hunts" : []}

    # Run N generations
    for generation_n in range(1, _sp.number_of_generations + 1):
        prey_genes = GA_prey.to_genes()
        predator_genes = GA_predator.to_genes()

        prey_genes_pointer = float(prey_genes.__array_interface__['data'][0])
        predator_genes_pointer = float(predator_genes.__array_interface__['data'][0])

        # Evaluate genes
        env_manager.set_prey_genes(prey_genes_pointer, prey_genes.shape[0], prey_genes.shape[1])
        env_manager.set_predator_genes(predator_genes_pointer, predator_genes.shape[0], predator_genes.shape[1])
        env_manager.run_single_episode()
        # time.sleep(0.1)

        if (_sp.evolve_prey):
            GA_prey.calc_fitness(prey_fitness)
        if (_sp.evolve_predator):
            GA_predator.calc_fitness(predator_fitness)

        result_stats["Prey fitness - avg"].append(np.average(prey_fitness))
        result_stats["Prey fitness - best"].append(np.max(prey_fitness))
        result_stats["Prey fitness - worst"].append(np.min(prey_fitness))
        result_stats["Prey mean stats - survivorship"].append(prey_stats[0])
        result_stats["Prey mean stats - dispersion"].append(prey_stats[2])
        result_stats["Prey mean stats - density"].append(prey_stats[1])
        result_stats["Prey mean stats - food"].append(prey_stats[4])
        result_stats["Predator fitness - avg"].append(np.average(predator_fitness))
        result_stats["Predator fitness - best"].append(np.max(predator_fitness))
        result_stats["Predator fitness - worst"].append(np.min(predator_fitness))
        result_stats["Predator mean stats - density"].append(prey_stats[1])
        result_stats["Predator mean stats - dispersion"].append(prey_stats[2])
        result_stats["Predator mean stats - attacks"].append(prey_stats[3])
        result_stats["Predator mean stats - hunts"].append(prey_stats[4])

        GA_prey.next_generation()
        # GA_predator.next_generation()

        if generation_completed_callback is not None:
            generation_completed_callback(generation_n)

    result_stats = DataFrame(result_stats)
    result_stats = result_stats.to_csv(encoding='utf-8', index=False, sep=';')

    result_weights = {}
    result_weights['prey'] = [indv.genotype for indv in GA_prey.population]
    result_weights['predator'] = [indv.genotype for indv in GA_predator.population]
    result_weights = pickle.dumps(result_weights)
    
    # return simulation result
    return (result_stats, result_weights)

import json, time
from celery_base import celery_app, celery_logger, celery_start_process_state, celery_update_process_state, celery_complete_process_state, celery_update_simulation_state
from mongo_base import mongo_update_process_data, mongo_update_process_state, mongo_update_process_result
from simulation.simulation import run_simulation

logger = celery_logger(__name__)

@celery_app.task(bind=True, name='run_learning_process')
def run_learning_process(self, process_id: str, process_config: str):
    process_config = json.loads(process_config)
    
    process_name = process_config['general']['process_name']
    process_simulations = process_config['general']['process_simulations']
    simulation_generations = process_config['learning']['number_of_generations']

    celery_start_process_state(self, process_simulations)
    mongo_update_process_state(process_id, 'Started')
    logger.info(f"Starting Learning Process [{process_name}]")

    simulations_tasks = []

    for simulation_id in range(1, process_simulations + 1):
        task = celery_app.send_task('run_learning_simulation', args = [process_id, simulation_id, process_config])
        simulations_tasks.append(task)

    completed_simulations = 0
    while completed_simulations < len(simulations_tasks):
        time.sleep(1.)

        completed_simulations = 0
        process_progress = 0
        for task in simulations_tasks:
            if task.ready():
                completed_simulations += 1
                process_progress += simulation_generations
            if task.info is not None:
                process_progress += task.info['completed_generations']
        process_progress = f'{((process_progress / process_simulations) / simulation_generations) * 100.:.2f}%'

        celery_update_process_state(self, completed_simulations)
        mongo_update_process_data(process_id, completed_simulations, process_progress)

    celery_complete_process_state(self, process_simulations)
    mongo_update_process_state(process_id, 'Completed')
    logger.info(f'Finished Simulation [{process_name}]"')

@celery_app.task(bind=True, name='run_learning_simulation')
def run_learning_simulation(self, process_id: str, simulation_id: int, simulation_config: dict):
    # simulation_config = json.loads(simulation_config)
 
    process_name = simulation_config['general']['process_name']
    simulation_generations = simulation_config['learning']['number_of_generations']

    prey_weights = None
    predator_weights = None

    logger.info(f"Starting Simulation [{process_name}]")

    def generation_completed_callback(completed_generation):
        celery_update_simulation_state(self, completed_generation, simulation_generations)
        # logger.info(f'Generation {completed_generation}/{simulation_generations}')

    (result_stats, result_weights) = run_simulation(simulation_config, prey_weights, predator_weights, generation_completed_callback)
    mongo_update_process_result(process_id, simulation_id, result_stats, result_weights)

    logger.info(f"Finished Simulation [{process_name}]")

if __name__ == "__main__":
    pass

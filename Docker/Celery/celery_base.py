import os
import logging
from celery import Celery

# config
CELERY_BROKER_URL = os.getenv('CELERY_BROKER_URL', 'redis://127.0.0.1:6379/0')
CELERY_RESULT_BACKEND = os.getenv('CELERY_RESULT_BACKEND', 'redis://127.0.0.1:6379/0')

# logger
def celery_logger(mod_name):
    logger = logging.getLogger(mod_name)

    handler = logging.StreamHandler()
    formatter = logging.Formatter('%(asctime)s [%(name)-12s] %(levelname)-8s %(message)s')
    handler.setFormatter(formatter)

    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    logger.propagate = False

    return logger

# celery
celery_app = Celery(__name__)
celery_app.conf.broker_url = CELERY_BROKER_URL
celery_app.conf.result_backend = CELERY_RESULT_BACKEND

celery_app.conf.task_routes = {
    'run_learning_process': {'queue': 'process_queue'},
    'run_learning_simulation': {'queue': 'simulation_queue'}
}

def celery_start_process_state(process_task, total_simulations: int):
    process_task.update_state(state='STARTED', meta={
        'completed_simulations': 0, 'total_simulations': total_simulations})

def celery_update_process_state(process_task, completed_simulations: int):
    process_task.update_state(meta={
        'completed_simulations': completed_simulations})

def celery_complete_process_state(process_task, completed_simulations: int):
    process_task.update_state(state='COMPLETED', meta={
        'completed_simulations': completed_simulations})

def celery_update_simulation_state(simulation_task, completed_generations:int, total_generations:int):
    simulation_task.update_state(state='RUNNING', meta={
        'completed_generations': completed_generations, 'total_generations': total_generations})

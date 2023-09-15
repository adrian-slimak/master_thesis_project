import os
import json
import random
from datetime import datetime
import redis

# config
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379/1')

# redis
redis_app = redis.from_url(url=REDIS_URL)

def redis_get_process_unique_id():
    process_id = str(random.getrandbits(128).to_bytes(16, 'little'))
    process_id = ''.join(filter(str.isalnum, process_id))
    while redis_app.exists(process_id):
        str(random.getrandbits(128).to_bytes(16, 'little'))
        process_id = ''.join(filter(str.isalnum, process_id))

    return process_id

def redis_create_process_data(process_config: str, prey_weights = None, predator_weights = None):
    process_id = redis_get_process_unique_id()

    process_config = json.loads(process_config)
    process_name = process_config['general']['process_name']
    process_simulations = process_config['general']['process_simulations']
    redis_app.hmset(process_id, {
        'process_name' : process_name,
        'process_state' : 'Created',
        'process_start_date' : datetime.now().strftime("%m/%d/%Y, %H:%M:%S"),
        'process_config' : json.dumps(process_config),
        'prey_weights' : prey_weights if prey_weights is not None else '',
        'predator_weights' : predator_weights if predator_weights is not None else '',
        'completed_simulations' : 0,
        'total_simulations' : process_simulations,
        'process_progress' : "0.00%"
    })

    return process_id

def redis_update_process_state(process_id: str, process_state: str):
    redis_app.hmset(process_id, {
        'process_state' : process_state,
    })

def redis_update_process_data(process_id: str, completed_simulations: int, process_progress: str):
    redis_app.hmset(process_id, {
        'completed_simulations' : completed_simulations,
        'process_progress' : process_progress
    })

def redis_update_process_result(process_id: str, simulation_id: int, result_stats, result_weights):
    redis_app.hmset(process_id, {
        f'result_stats_{simulation_id}' : result_stats,
        f'result_weights_{simulation_id}' : result_weights
    })

def redis_get_process_decoded_info(process_id: str):
    process_data = redis_app.hgetall(process_id)

    process_info = {
        'process_id': process_id.decode("utf-8"),
        'process_name': process_data[b'process_name'].decode("utf-8"),
        'process_state': process_data[b'process_state'].decode("utf-8"),
        'process_start_date': process_data[b'process_start_date'].decode("utf-8"),
        'completed_simulations': int(process_data[b'completed_simulations'].decode("utf-8")),
        'total_simulations': int(process_data[b'total_simulations'].decode("utf-8")),
        'process_progress': process_data[b'process_progress'].decode("utf-8")}

    return process_info

def redis_get_process_decoded_result(process_id: str):
    process_data = redis_app.hgetall(process_id)

    process_result = {
        'process_name': process_data[b'process_name'].decode("utf-8"),
        'process_config': process_data[b'process_config'].decode("utf-8"),
        'total_simulations': int(process_data[b'total_simulations'].decode("utf-8"))}

    for simulation_id in range(1, int(process_data[b'total_simulations'].decode("utf-8")) + 1):
        process_result[f'result_stats_{simulation_id}'] = process_data[bytes(f'result_stats_{simulation_id}', "utf-8")]
        process_result[f'result_weights_{simulation_id}'] = process_data[bytes(f'result_weights_{simulation_id}', "utf-8")]

    return process_result

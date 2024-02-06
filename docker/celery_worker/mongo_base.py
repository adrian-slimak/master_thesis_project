import logging
import os
import pymongo
import json
from datetime import datetime
from bson import ObjectId

# config
MONGO_URL = os.getenv('MONGO_URL', 'mongodb://localhost:27017/')

# logger
def get_module_logger(mod_name):
    """
    To use this, do logger = get_module_logger(__name__)
    """
    logger = logging.getLogger(mod_name)
    handler = logging.StreamHandler()
    formatter = logging.Formatter(
        '%(asctime)s [%(name)-12s] %(levelname)-8s %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
    return logger

logger = get_module_logger(__name__)

logger.info(MONGO_URL)

mongo_client = pymongo.MongoClient(MONGO_URL, directConnection=True)

mtp_db = mongo_client['mtp']
mtp_cl = mtp_db['mtp']

def mongo_create_process_data(process_config: str, prey_weights = None, predator_weights = None):
    process_config = json.loads(process_config)
    process_name = process_config['general']['process_name']
    process_simulations = process_config['general']['process_simulations']

    data = {
        'process_name' : process_name,
        'process_state' : 'Created',
        'process_start_date' : datetime.now().strftime("%m/%d/%Y, %H:%M:%S"),
        'process_config' : json.dumps(process_config),
        'prey_weights' : prey_weights if prey_weights is not None else '',
        'predator_weights' : predator_weights if predator_weights is not None else '',
        'completed_simulations' : 0,
        'total_simulations' : process_simulations,
        'process_progress' : "0.00%"
    }

    return mtp_cl.insert_one(data).inserted_id

def mongo_update_process_state(process_id: str, process_state: str):
    query = { '_id' : ObjectId(process_id) }
    new_values = { '$set' : { 'process_state' : process_state } }
    mtp_cl.update_one(query, new_values)

def mongo_update_process_data(process_id: str, completed_simulations: int, process_progress: str):
    query = { '_id' : ObjectId(process_id) }
    new_values = { '$set' : { 'completed_simulations' : completed_simulations, 'process_progress' : process_progress } }
    mtp_cl.update_one(query, new_values)

def mongo_update_process_result(process_id: str, simulation_id: int, result_stats, result_weights):
    query = { '_id' : ObjectId(process_id) }
    new_values = { '$set' : { f'result_stats_{simulation_id}' : result_stats, f'result_weights_{simulation_id}' : result_weights } }
    mtp_cl.update_one(query, new_values)

def mongo_get_process_info(process_id: str):
    query = { '_id' : ObjectId(process_id) }
    document = mtp_cl.find_one(query)

    process_info = {
        'process_id': process_id,
        'process_name': document['process_name'],
        'process_state': document['process_state'],
        'process_start_date': document['process_start_date'],
        'completed_simulations': int(document['completed_simulations']),
        'total_simulations': int(document['total_simulations']),
        'process_progress': document['process_progress']}

    return process_info

def mongo_get_process_result(process_id: str):
    query = { '_id' : ObjectId(process_id) }
    document = mtp_cl.find_one(query)

    process_result = {
        'process_name': document['process_name'],
        'process_config': document['process_config'],
        'total_simulations': int(document['total_simulations'])}

    # for simulation_id in range(1, int(document['total_simulations']) + 1):
    #     process_result[f'result_stats_{simulation_id}'] = document[bytes('result_stats_{simulation_id}', "utf-8")]
    #     process_result[f'result_weights_{simulation_id}'] = document[bytes('result_weights_{simulation_id}', "utf-8")]

    return process_result

def mongo_get_all_process_ids():
    ids = mtp_cl.find({}, {"_id":1})
    return [str(id) for id in ids]

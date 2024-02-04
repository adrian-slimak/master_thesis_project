import os
import pymongo
import json
from datetime import datetime
from bson import ObjectId

# config
MONGO_URL = os.getenv('MONGO_URL', 'mongodb://localhost:27017/')

mongo_client = pymongo.MongoClient("mongodb://localhost:27017/")

mtp_db = mongo_client["mtp"]
mtp_cl = mtp_db["mtp"]

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

def mongoupdate_process_data(process_id: str, completed_simulations: int, process_progress: str):
    query = { '_id' : ObjectId(process_id) }
    new_values = { '$set' : { 'completed_simulations' : completed_simulations, 'process_progress' : process_progress } }
    mtp_cl.update_one(query, new_values)

def mongo_update_process_result(process_id: str, simulation_id: int, result_stats, result_weights):
    query = { '_id' : ObjectId(process_id) }
    new_values = { '$set' : { f'result_stats_{simulation_id}' : result_stats, f'result_weights_{simulation_id}' : result_weights } }
    mtp_cl.update_one(query, new_values)

# id = mongo_create_process_data('{"general" : {"process_name" : "Bob", "process_simulations" : 10}}')
# print(id)
mongo_update_process_state('65bfdbff778921a8d9b79dcd', "Finished")

result = mtp_cl.find_one({'_id' : ObjectId('65bfdbff778921a8d9b79dcd')})
print(result)

mongo_client.close()

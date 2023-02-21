import os, json
from zipfile import ZipFile
from flask import Flask, request, redirect, url_for, render_template, send_file
from celery_base import celery_app
from redis_base import redis_app, redis_create_process_data, redis_get_process_decoded_info, redis_get_process_decoded_result

flask_app = Flask(__name__)

@flask_app.route("/")
@flask_app.route("/home")
@flask_app.route("/index")
def home():
    return render_template('index.html', learning_tasks = get_processes_data())

@flask_app.route("/start_learning", methods=['POST'])
def start_learning():
    process_config = request.files['config_file']
    if process_config.filename == '':
        return redirect(url_for('home'))
    process_config = process_config.read().decode("utf-8")

    prey_weights = None
    if 'prey_weights' in request.files:
        prey_weights = request.files['prey_weights'].read()

    predator_weights = None
    if 'predator_weights' in request.files:
        predator_weights = request.files['predator_weights'].read()
    
    # config_file.save('config_file.json')
    # with open('config_file.json', 'r') as f:
    #     process_config = f.read()
    
    process_id = redis_create_process_data(process_config, prey_weights, predator_weights)
    celery_app.send_task('run_learning_process', args = [process_id, process_config], kwargs = {})

    return redirect(url_for('home'))

@flask_app.route("/get_processes_data")
def get_processes_data():
    learning_processes = []

    for process_id in redis_app.keys():
        learning_processes.append(redis_get_process_decoded_info(process_id))
    
    return learning_processes

@flask_app.route("/download_process_data")
def download_process_data():
    process_result = redis_get_process_decoded_result(request.args.get('process_id'))

    process_name = process_result['process_name']
    process_simulations = process_result['total_simulations']

    process_config = json.loads(process_result['process_config'])
    with open('process_config.json', 'w') as file:
        json.dump(process_config, file, indent=2)

    with ZipFile('process_data.zip', 'w') as zipFile:
        zipFile.write('process_config.json')

        for simulation_id in range(1, process_simulations + 1):
            with open(f'result_stats_{simulation_id}.csv', 'wb') as csvFile:
                csvFile.write(process_result[f'result_stats_{simulation_id}'])
            zipFile.write(f'result_stats_{simulation_id}.csv')
            with open(f'result_weights_{simulation_id}.pkl', 'wb') as pklFile:
                pklFile.write(process_result[f'result_weights_{simulation_id}'])
            zipFile.write(f'result_weights_{simulation_id}.pkl')
    
    return send_file('process_data.zip', as_attachment=True)

if __name__ == '__main__':
    flask_host = os.getenv('FLASK_HOST', '0.0.0.0')
    flask_port = os.getenv('FLASK_PORT', 5000)
    flask_debug = os.getenv('FLASK_DEBUG', False)
    flask_app.run(host=flask_host, port=flask_port, debug=flask_debug)

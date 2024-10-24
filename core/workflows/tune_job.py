import json
import logging
import logging.config
import random
import time
from pathlib import Path

from omegaconf import OmegaConf

# start experiment
start_time = time.time()

# load experiment params
params_filepath = Path("params.yaml")
params = OmegaConf.load(params_filepath)

# setup logger
logging_config = OmegaConf.to_object(params.logging)
logging.config.dictConfig(logging_config)
logger = logging.getLogger(__name__)

# experiment name
local_experiment_name = params.experiment_name
logging.info("Staring experiment %s with params %s", local_experiment_name, params)

# setup folders for experiments
ray_results_dir = Path(params.ray.results_dir)
experiment_results_dir: Path = ray_results_dir / local_experiment_name
experiment_results_dir.mkdir(exist_ok=True)

# run the actual experiment
logger.info("Running trails ...")
experiment_results = dict()
time.sleep(2)
for i in range(params.tune.num_trials):
    trial_name: Path = local_experiment_name + "_00" + str(i)
    trial_dir: Path = experiment_results_dir / "trials" / trial_name
    trial_dir.mkdir(parents=True, exist_ok=True)

    logger.info("Trial %s. Performing some work ...", trial_name)
    time.sleep(2)

    trial_data = dict(accuracy=random.randint(0, 5), loss=10 - random.randint(0, 5), name=trial_name)

    trial_results = trial_dir / "results.json"
    trial_results.touch()
    with trial_results.open("w") as f:
        json.dump(trial_data, f)
    experiment_results[trial_name] = trial_data

    logger.info("Trial completed successfully!")

# log experiment results
experiment_results_data = experiment_results_dir / "results.json"
experiment_results_data.touch()
with experiment_results_data.open("w") as f:
    json.dump(experiment_results, f)

# finish
end_time = time.time() - start_time
logger.info(f"Experiment finished in {end_time:2f} seconds.")

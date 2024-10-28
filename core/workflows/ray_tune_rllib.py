import logging
import logging.config
import random
import time
from typing import Dict

from omegaconf import OmegaConf
from ray import train, tune

# load params
params = OmegaConf.load("params.yaml")

# build a "root" logger
logging_config = OmegaConf.to_object(params.logging)
logging.config.dictConfig(logging_config)
logger = logging.getLogger(__name__)

# # build callables
# class MyCallback(tune.Callback):
#     pass


# build a trainable
class MyTrainable(tune.Trainable):
    def setup(self, config: dict):
        self.config = config
        self.iteration_i = 0
        pass

    def step(self):
        sleep_time = random.randint(0, 5)
        time.sleep(sleep_time)
        self.iteration_i + +1
        return dict(training_iteration=self.iteration_i)

    def save_checkpoint(self, checkpoint_dir: str) -> Dict | None:
        pass

    def load_checkpoint(self, checkpoint: Dict | None):
        pass


# run a tune job
tune_start_time = time.time()
tuner = tune.Tuner(
    trainable=MyTrainable,
    tune_config=tune.TuneConfig(
        num_samples=1,
        max_concurrent_trials=1,
    ),
    run_config=train.RunConfig(name=params.experiment_name, stop={"time_total_s": 5}),
)
results = tuner.fit()
total_time = time.time() - tune_start_time
logger.info(f"Tune Job completed in {total_time:.2f} seconds.")
logger.info(f"Results: {results}")

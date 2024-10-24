import os
from pathlib import Path

import hydra
from hydra.utils import get_original_cwd, to_absolute_path
from omegaconf import OmegaConf

print(f"Current working directory: {os.getcwd()}")


@hydra.main(version_base="1.1", config_path="../../conf", config_name="config")
def compile_params(cfg):
    # Resolve and compile params.yaml
    params = OmegaConf.to_container(cfg, resolve=True)
    output_path = Path(to_absolute_path("params.yaml"))
    print(f"Creating output file: {output_path}")
    with open(output_path, "w") as f:
        OmegaConf.save(config=OmegaConf.create(params), f=f)
    print(f"params.yaml compiled and saved to {output_path.absolute()}")
    # read the params config file
    metadata_filepath = Path(to_absolute_path(cfg.experiment_metadata_filepath))
    with metadata_filepath.open("w") as f:
        for key, value in params.items():
            if isinstance(value, (int, float, str, bool)):
                f.write(f"{key.upper()}={value}\n")


if __name__ == "__main__":
    compile_params()

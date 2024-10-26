## experimentation 

1. each experiment will be a dvc pipeline. The pipeline will run for a certain time (with or without live logs) and print to main.  


## scripts 

1. `slurm_submit` - will submit a slurm script to SPARTAN. 
    - builds a name for the experiment
    - builds experiment dir in project dir 
    - creates a patch from current workspace, includes untracked!
    - scp patch, job script to project dir 
    - submits job scripts from project dir 
    - transfers submission log 
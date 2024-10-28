## pipelines 

1. tuning a "partially"-specified algorithm. 
    - runs a tune job with a given trainable 
    - saves tune results to experiment dir / data / experiment name
    - builds a metrics json for  

## scripts 

1. `slurm_submit` - will submit a slurm script to SPARTAN. 
    - builds a name for the experiment
    - builds experiment dir in project dir 
    - creates a patch from current workspace, includes untracked!
    - scp patch, job script to project dir 
    - submits job scripts from project dir 
    - transfers submission log 

2. `job_script` - will run an experiment on SPARTAN. 
    - clone the project in the experiment dir
    - apply the patch
    - run dvc pipeline as experiment 
    - save exp
    - cleanup 
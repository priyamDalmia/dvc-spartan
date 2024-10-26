#!/bin/bash
#SBATCH --output="slurmoutput/%j.out"
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=p.dalmia@unimelb.edu.au
#SBATCH --nodes=1
#SBTACH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --partition=cascade
#SBATCH --time=01:00:00

source "${HOME}/.bashrc"
# purge modules 
module purge 
module load GCCcore/11.3.0
module load Python/3.10.4
source .venv/bin/activate  

EXPERIMENT_NAME=$1
JOB_BRANCH=$2
GIT_HASH=$3

echo "$(date +%Y/%m/%d) $(date +%H:%M:%S)"
echo "Running Experiment $EXPERIMENT_NAME on branch $JOB_BRANCH and revision $GIT_HASH at $PWD"


export JOB_SUBMISSION_DIR=$PWD
export JOB_REPO_NAME="dvc-spartan"
export JOB_REPO_URL="git@github.com:priyamDalmia/dvc-spartan.git"
export JOB_REPO_BRANCH=${JOB_BRANCH}
export JOB_REPO_REV=${GIT_HASH}

# Ensure cleanup after job finishes, regardless of exit status
function cleanup_job_dir(){
    echo "Cleaning up the job directory."
    cd $JOB_SUBMISSION_DIR
    rm "${EXPERIMENT_NAME}".patch ${EXPERIMENT_NAME}_*
    rm -rf ${EXPERIMENT_NAME}
}

# trap cleanup_job_dir EXIT

# Create an insulated Git workspace for the current job
# TODO make secure by using HTTP tokens instead 
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_github # Adjust path to your SSH key if needed
echo "Cloning git repo to $EXPERIMENT_NAME"
git clone --branch "${JOB_REPO_BRANCH}" "${JOB_REPO_URL}" "${EXPERIMENT_NAME}"
cp ${EXPERIMENT_NAME}.patch $EXPERIMENT_NAME
cd "${EXPERIMENT_NAME}"
git checkout "${GIT_HASH}"
git apply ${EXPERIMENT_NAME}.patch

# run dvc experiment 
module list
echo "List of modules in env: $(module list)"
dvc exp run --name $EXPERIMENT_NAME
dvc exp push

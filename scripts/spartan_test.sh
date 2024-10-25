#!/bin/bash

source "${HOME}/.bashrc"
set -euxo pipefail

EXPERIMENT_NAME=$1
GIT_HASH=$2
export JOB_REPO_NAME="dvc-spartan"
export JOB_REPO_URL="git@github.com:priyamDalmia/dvc-spartan.git"
export JOB_REPO_BRANCH="dev"
export JOB_REPO_REV=${GIT_HASH}

# Ensure cleanup after job finishes, regardless of exit status
function cleanup_job_dir(){
    echo "Cleaning up the job directory."
    rm "${EXPERIMENT_NAME}".patch
}

trap cleanup_job_dir EXIT

# Create an insulated Git workspace for the current job
echo "Creating Git workspace."
git clone --branch "${JOB_REPO_BRANCH}" "${JOB_REPO_URL}" "${EXPERIMENT_NAME}"
cp ${EXPERIMENT_NAME}.patch $EXPERIMENT_NAME
cd "${EXPERIMENT_NAME}"

# Ensure the job runs on the same revision as was submitted (even if the branch has moved on in the meantime)
git checkout "${GIT_HASH}"
git apply ${EXPERIMENT_NAME}.patch
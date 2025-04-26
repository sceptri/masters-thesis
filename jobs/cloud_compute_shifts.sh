#!/bin/bash
#PBS -N julia_antiphase-tongue_test
#PBS -l select=1:ncpus=20:mem=36gb:scratch_local=150gb
#PBS -l walltime=10:00:00 
# The 4 lines above are options for scheduling system: job will run 10 hour at maximum, 1 machine with 20 processors + 36gb RAM memory + 150gb scratch memory are requested

# define a DATADIR variable: directory where the input files are taken from and where output will be copied to
DATADIR=/storage/brno2/home/sceptri/ # substitute username and path to to your real username and path

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of node it is run on and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt

module add julia/1.11.3

export JULIA_PKGDIR=/storage/brno2/home/sceptri/.julia   
export JULIA_DEPOT_PATH=/storage/brno2/home/sceptri/.julia
export JULIA_PROJECT=/storage/brno2/home/sceptri/.julia 
export JULIA_CPU_THREADS=$PBS_NCPUS   # PBS_NCPUS is number of reserved CPUs

# test if scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# copy input file "h2o.com" to scratch directory
# if the copy operation fails, issue error message and exit
cp -r $DATADIR/Projects/masters-thesis/. $SCRATCHDIR || { echo >&2 "Error while copying input project!"; exit 2; }

# move into scratch directory
cd $SCRATCHDIR

julia --project="./sections" -e 'using Pkg; Pkg.instantiate()'

# if the calculation ends with an error, issue error message an exit
julia -t $PBS_NCPUS --project="./sections" scripts/delay_computation_metacentrum.jl || { echo >&2 "Calculation ended up erroneously (with a code $?) !!"; exit 3; }
julia -t $PBS_NCPUS --project="./sections" scripts/no_delay_computation_metacentrum.jl || { echo >&2 "Calculation ended up erroneously (with a code $?) !!"; exit 3; }

# move the output to user's DATADIR or exit in case of failure
cp data/delay_computation_metacentrum.jld2 $DATADIR/Projects/masters-thesis/data/delay_computation_metacentrum_$PBS_JOBID.jld2 || { echo >&2 "Copying data failed (with a code $?) !!"; exit 4; }
cp data/no_delay_computation_metacentrum.jld2 $DATADIR/Projects/masters-thesis/data/no_delay_computation_metacentrum_$PBS_JOBID.jld2 || { echo >&2 "Copying data failed (with a code $?) !!"; exit 4; }

# clean the SCRATCH directory
clean_scratch
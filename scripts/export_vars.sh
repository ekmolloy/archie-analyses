#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load gcc/4.9.3
module load python/3.7.2
module load R/3.4.0

export PROJECT="archie-analyses"
export HOME="$HOME/project-sriram/$PROJECT"

export DATADIR="/u/scratch/e/ekmolloy/$PROJECT/data"
export EXTERNALDIR="$HOME/external"
export ARCHIESIMDIR="$EXTERNALDIR/ArchIE/simulations"
export ARCHIEDATDIR="$EXTERNALDIR/ArchIE/data"
export SCRIPTDIR="$HOME/scripts"
export TOOLDIR="$HOME/tools"

export PATH="$HOME:$PATH"
export PATH="$TOOLDIR:$PATH"
export PATH="$PYBINDIR:$PATH"
export PATH="$EXTERNALDIR/ArchIE/msmodified:$PATH"  # ms lives here

export PYTHONPATH="$HOME/.local/lib/python3.7/site-packages:$PYTHONPATH"
export PYTHONPATH="$TOOLDIR:$PYTHONPATH"


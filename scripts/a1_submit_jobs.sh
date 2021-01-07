#!/bin/bash

source export_vars.sh

mkdir -p $DATADIR/training-data

qsub -cwd \
     -V \
     -N "a1" \
     -l h_data=32G,time=12:00:00,highp \
     -t 1 \
     -m a \
     -M ekmolloy \
     -b y "bash $SCRIPTDIR/a1_run_ms_for_training.sh"


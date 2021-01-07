#!/bin/bash

source export_vars.sh

mkdir -p $DATADIR/testing-data

qsub -cwd \
     -V \
     -N "a2" \
     -l h_data=32G,time=12:00:00,highp \
     -t 1-77 \
     -m a \
     -M ekmolloy \
     -b y "bash $SCRIPTDIR/a2_run_ms_for_testing.sh"


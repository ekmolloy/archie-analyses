set -e

source export_vars.sh

PARAMS=( $(head -n${SGE_TASK_ID} a1_training_parameters.txt | tail -n1) )
MU=${PARAMS[0]}
R=${PARAMS[1]}

NTAR=100
NREF=100
NSITE=50000
NREPS=10000

TXT="training_data.txt"
LOG="training_data.log"

TRAINDIR="$DATADIR/training-data/msmodified.set-${SGE_TASK_ID}.mu-${MU}.r-${R}"
mkdir -p $TRAINDIR

for REPL in `seq -f "%05g" 1 ${NREPS}`; do
    SIMDIR="$TRAINDIR/$REPL"
    if [ -d $SIMDIR ]; then
        echo "$SIMDIR already exists!"
    else
        mkdir $SIMDIR
        cd $SIMDIR

        if [ $REPL == "00001" ]; then
            echo "3579 27011 59243" > seedms
        else
            cp $LAST/seedms .
        fi

        echo "# Simulation = $REPL" > $LOG
        echo "# Recombination rate = $R" >> $LOG
        echo "# Mutation rate = $MU" >> $LOG

        SEEDS=( $(cat seedms) )
        echo "# seedms file before = ${SEEDS[@]}" >> $LOG

        bash $TOOLDIR/ms.sh $NTAR $NREF $NSITE $MU $R >> $LOG

        SEEDS=( $(cat seedms) )
        echo "# seedms file after = ${SEEDS[@]}" >> $LOG

        if [ $(wc -l out.snp | awk '{print $1}') -gt 0 ]; then
            python3 $ARCHIESIMDIR/calc_stats_ms.py \
                -s out.snp \
                -a out.ADMIXED.geno \
                -r out.1.geno \
                --anc out.ADMIXED.anc \
                -n $NSITE \
                > $TXT
        fi
    fi
    LAST="$SIMDIR"
done


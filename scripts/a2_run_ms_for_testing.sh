set -e

source export_vars.sh

PARAMS=( $(head -n${SGE_TASK_ID} a1_training_parameters.txt | tail -n1) )
MU=${PARAMS[0]}
R=${PARAMS[1]}
SEEDISH=$(echo "$SGE_TASK_ID * 3" | bc)

NTAR=100
NREF=100
NSITE=1000000
NREPS=100

TXT="testing_data.txt"
LOG="testing_data.log"

TESTDIR="$DATADIR/testing-data/msmodified.set-${SGE_TASK_ID}.mu-${MU}.r-${R}"
mkdir -p $TESTDIR

for REPL in `seq -f "%04g" 1 ${NREPS}`; do
    SIMDIR="$TESTDIR/$REPL"
    if [ -d $SIMDIR ]; then
        echo "$SIMDIR already exists!"
    else
        mkdir $SIMDIR
        cd $SIMDIR

        if [ $REPL == "0001" ]; then
            echo "# Seedish = $SEEDISH" > $LOG
            SEED1=$(echo "3579 + $SEEDISH" | bc)
            SEED2=$(echo "27011 + $SEEDISH" | bc)
            SEED3=$(echo "59243 + $SEEDISH" | bc)
            echo "$SEED1 $SEED2 $SEED3" > seedms
        else
            cp $LAST/seedms .
        fi

        echo "# Simulation = $REPL" >> $LOG
        echo "# Recombination rate = $R" >> $LOG
        echo "# Mutation rate = $MU" >> $LOG

        SEEDS=( $(cat seedms) )
        echo "# seedms file before = ${SEEDS[@]}" >> $LOG

        bash $TOOLDIR/ms.sh $NTAR $NREF $NSITE $MU $R >> $LOG

        SEEDS=( $(cat seedms) )
        echo "# seedms file after = ${SEEDS[@]}" >> $LOG

        if [ $(wc -l out.snp | awk '{print $1}') -gt 0 ]; then
            CHR=$(head -n1 out.snp | sed 's/:/ /g' | awk '{print $1}')
            START=$(head -n1 out.snp | sed 's/:/ /g' | awk '{print $2}')
            END=$(tail -n1 out.snp | sed 's/:/ /g' | awk '{print $2}')

            python3 $ARCHIEDATDIR/calc_stats_window_data.py \
                -s out.snp \
                -i out.ADMIXED.ind \
                -a out.ADMIXED.geno \
                -r out.1.geno \
                -c $CHR \
                -b $START \
                -e $END \
                -w 50000 \
                -z 10000 1> $TXT 2>> $LOG
        fi
    fi
    LAST="$SIMDIR"
done


set -e

source export_vars.sh

PARAMS=( $(head -n${SGE_TASK_ID} a2_testing_parameters.txt | tail -n1) )
MU=${PARAMS[0]}
R=${PARAMS[1]}
SEEDISH=${SGE_TASK_ID}

NTAR=100
NREF=100
NSITE=1000000
NREPS=100

WINDOWLEN=50000
STEPLEN=10000

MSLOG="ms.log"
AFOUT="archie_testing_data.txt"
AFLOG="archie_testing_data.log"

TESTDIR="$DATADIR/testing-data/msmodified.set-${SGE_TASK_ID}.mu-${MU}.r-${R}"
mkdir -p $TESTDIR

for REPL in `seq -f "%05g" 1 ${NREPS}`; do
    echo "Processing replicate $REPL..."
    SIMDIR="$TESTDIR/$REPL"

    if [ -d $SIMDIR ]; then
        cd $SIMDIR

	# Check ms completed
        DOMS=1
        if [ -e $MSLOG ]; then
            if [ ! -z $(grep "done" $MSLOG | awk '{print $1}') ]; then
                DOMS=0
            fi
        fi

	# Check ArchIE features completed
        DOAF=1
        if [ -e $AFOUT ]; then
            NHAP=$(wc -l out.ADMIXED.ind | awk '{print $1}')
            START=$(head -n1 out.snp | sed 's/:/ /g' | awk '{print $2}')
            END=$(tail -n1 out.snp | sed 's/:/ /g' | awk '{print $2}')
            WINDOWS=( $(seq $START $STEPLEN $END) )
            NLINES=$( echo "${#WINDOWS[@]} * $NHAP" | bc )
            if [ $NLINES -eq $(wc -l $AFOUT | awk '{print $1}') ]; then
                DOAF=0
            fi
        fi
    else
        mkdir $SIMDIR
        cd $SIMDIR
        DOMS=1
        DOAF=1
    fi

    if [ $DOMS -eq 1 ]; then
        echo "  Simulating data with ms..."
        if [ $REPL == "00001" ]; then
            SEED1=$(echo "3579 + $SEEDISH" | bc)
            SEED2=$(echo "27011 + $SEEDISH" | bc)
            SEED3=$(echo "59243 + $SEEDISH" | bc)
            echo "$SEED1 $SEED2 $SEED3" > seedms
        else
            cp $LASTDIR/seedms .
        fi

        echo "# Simulation model = $SEEDISH" > $MSLOG
        echo "# Recombination rate = $R" >> $MSLOG
        echo "# Mutation rate = $MU" >> $MSLOG
        echo "# Replicate = $REPL" >> $MSLOG

        SEEDS=( $(cat seedms) )
        echo "# seedms file before ms = ${SEEDS[@]}" >> $MSLOG

        bash $TOOLDIR/ms.sh $NTAR $NREF $NSITE $MU $R >> $MSLOG

        SEEDS=( $(cat seedms) )
        echo "# seedms file after ms = ${SEEDS[@]}" >> $MSLOG

	echo "# done" >> $MSLOG
        echo "  ...done"
    fi

    if [ $DOAF -eq 1 ]; then
        echo "  Computing ArchIE features..."
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
                -w $WINDOWLEN \
                -z $STEPLEN 1> $AFOUT 2> $AFLOG
        fi
        echo "  ...done"
    fi
    echo "...done"

    LASTDIR="$SIMDIR"
done


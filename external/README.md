Step 0: Edit and source environmental variables
-----------------------------------------------
```
source scripts/export_vars.sh
```

Step 1: Create a fake python path and install SciKit Learn
----------------------------------------------------------
```
cd $HOME
mkdir $HOME/.local
mkdir $HOME/.local/bin
mkdir $HOME/.local/lib
mkdir $HOME/.local/lib/python3.7
mkdir $HOME/.local/lib/python3.7/site-packages
pip install sklearn --user
```

Step 1. Install ArchIE and build modified ms
--------------------------------------------
```
cd external
git clone https://github.com/sriramlab/ArchIE.git
cd ArchIE/msmodified
gcc -o ms ms.c streec.c rand1.c -lm
cd ../../
```


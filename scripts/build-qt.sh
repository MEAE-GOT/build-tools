#!/bin/bash

### Force script to be run as a bash script and not a sh script
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then
    # Taken from http://unix-linux.questionfor.info/q_unix-linux-programming_85038.html
    bash "$0" "$@"
    exit "$?"
fi

### make the script fail if any command fails
set -e

### arguments
workspace="$1"
qmake="qmake"

if [ -z "$2" ]; then
    echo "No qmake specified, using system default"
else
    qmake="$2"
fi

cd $workspace

### qmake path

#qmake=/home/vagrant/Qt-5.6/5.6/gcc_64/bin/qmake

### java tool to filter out Qt projects and sort them by dependency
projects=$(java -jar ../build-tools/ProjectSorter/deploy/ProjectSorter.jar . .pro)

echo "Compiling..."

for proj in ${projects[@]}; do

    projName=${proj%/*}

    echo "***** Compile $projName *****"
    cd $projName

    eval $qmake 
    make clean
    make

    cd -

    ### compile test code if any
    testDir=$projName/tests/auto/test
    if [ -d $testDir ]; then
        # compile tests code
        echo "***** Compiling test code for $projName *****"
        cd $proj/tests
    	eval $qmake
        make clean
        make
	cd -
    fi

done

echo ""
echo "All source code compiled successfuly!"

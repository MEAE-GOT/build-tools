#!/bin/bash

#
# This script compiles Qt projects and runs GoogleTest unit tests
#

# make the script fail if any command fails
set -e

cd /mnt/sdb1/bamboo/build-dir/LP-W3CSER-COM/thomas-test

projects=$( ls -1p | grep / )

echo "Compiling and running tests..."

# clean old test results
if [ -d "test-results" ]; then
    rm test-results/*
fi

for proj in ${projects[@]}; do

    projName=${proj%/*}

    testDir=$projName/tests/auto/test
    if [ -d $testDir ]; then

        if [ ! -d "test-results" ]; then
            mkdir test-results
        fi

        # compile and run tests
        echo "Compiling $projName:"
        cd $proj/tests
        qmake
        make clean
        make

        echo "Running unit tests for $projName:"
        auto/test/test --gtest_output=xml
        cd -

        mv $projName/tests/test_detail.xml test-results/$projName-test_detail.xml

    else

        # only compile qt-projects
        if [ -f $projName/*.pro ]; then
            echo "Compile $projName"
            cd $projName
            qmake
            make clean
            make
            cd -
        else
           echo "Nothing to do for $projName"
        fi
    fi

done

currentDir=$(pwd)

echo ""
echo "All src/test code compiled successfuly, unit test results saved in $currentDir/test-results"

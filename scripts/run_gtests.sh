#!/bin/bash

### Force script to be run as a bash script and not a sh script
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then
    # Taken from http://unix-linux.questionfor.info/q_unix-linux-programming_85038.html
    bash "$0" "$@"
    exit "$?"
fi

### arguments
workspace="$1"

cd $workspace

if [ ! -d test-results ]; then
    mkdir test-results
fi

### java tool to filter out Qt projects and sort them by dependency
projects=$(java -jar ../build-tools/ProjectSorter/deploy/ProjectSorter.jar . .pro)

echo "running tests..."

for proj in ${projects[@]}; do

    projName=${proj%/*}

    echo "***** Running unit test(s) for $projName *****"
    testDir=$projName/tests/auto/test
    if [ -d $testDir ]; then
        cd $proj/tests
        
        auto/test/test --gtest_output=xml
        cd -

        mv $projName/tests/test_detail.xml test-results/$projName-test_detail.xml
    else
        echo "No tests found!"
    fi

done

echo ""
echo "Done running tests!"

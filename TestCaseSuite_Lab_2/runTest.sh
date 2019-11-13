# runTest.sh
# Author: Taylor Lloyd
# Date: June 27, 2012
#
# USAGE: ./runTest.sh LABFILE TESTFILE
#
# Combines the lab, test, and common execution file,
# then runs the resulting creation. All output generated
# is presented on standard output, after discarding the
# standard SPIM start message, which displays version
# info and could otherwise break tests.

rm -f testBuild.s
cat common.s > testBuild.s
cat $1 >> testBuild.s
spim -file testBuild.s $2 | sed '1,5d'

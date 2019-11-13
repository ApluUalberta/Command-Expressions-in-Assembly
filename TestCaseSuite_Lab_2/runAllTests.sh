# runAllTests.sh
# Author: Taylor Lloyd
# Date: July 4, 2012
#
# USAGE: ./runAllTests.sh LABFILE
#
# Loops through all testfiles in the tests folder,
# calling runTest on each of them. Execution results
# are then compared to expected results, and each test
# reports as Passed or Failed.

echo "Running tests on $1"
for f in tests/*.bin
	do
	rm -f test.out
	./runTest.sh $1 $f > actual.out
	suf=${f%.s}
	echo -n "${suf#**\/} : "
	if diff ${f%.bin}.out actual.out >/dev/null ; then
		echo "Passed"
	else
  		echo "Failed (Diff Below)"
		echo "========================= Expected =========================== ========================== Actual ============================"
		diff -y --left-column ${f%.bin}.out actual.out
		echo "============================================================================================================================="
	fi
done
rm -f test.out actual.out testBuild.s

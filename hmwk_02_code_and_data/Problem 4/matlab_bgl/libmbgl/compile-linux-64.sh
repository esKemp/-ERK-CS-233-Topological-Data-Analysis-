#!/bin/bash -e

BOOST_DIR=${HOME}/dev/lib/boost_1_36_0/
YASMIC_DIR=.

source ccfiles.sh
OFILES=`echo ${CCFILES} | sed -e 's/\.cc/\.o/g'`

CFLAGS="-O2 -fPIC -c -I${BOOST_DIR} -I${YASMIC_DIR}"
CFLAGS="-g -fPIC -c -I${BOOST_DIR} -I${YASMIC_DIR}"

function echocmd {
	echo $@
	$@
}

for file in ${CCFILES}; do
	echocmd g++ $CFLAGS $file
done

echocmd ar rc libmbgl-linux-64.a ${OFILES} 
	
echocmd rm ${OFILES}	

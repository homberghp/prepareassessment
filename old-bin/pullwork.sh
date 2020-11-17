#!/bin/bash
repobase=/home/svn/2014/PRO2-2014-04-07/
#repobase=$1
for i in ${repobase}x*; do
    youngest=$(svnlook youngest ${i})
    if [ ${youngest} -ne 1 ] ; then
	echo svn co file://${i}
    fi
done
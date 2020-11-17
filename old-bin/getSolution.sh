#!/bin/bash
## read solution from repo
source ../default.properties
#echo ${module_repo}
source build.properties 2> /dev/null
#echo ${projects}
## make fresh dir

rm -fr examsolution
mkdir -p examsolution
for p in ${projects}; do
    project ${p}
     
    svn export ${module_repo}/trunk/45_assessment/questions/${p} examsolution/$(basename ${p})
done


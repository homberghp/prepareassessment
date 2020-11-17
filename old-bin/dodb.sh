#!/bin/bash

file=$1
echo "<strong>Db run result</strong><br/>"
cat ${file} | psql -qH president 2>&1 
echo "<br/><strong>end run result</strong><br/>"


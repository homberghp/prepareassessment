#!/bin/bash

## waits for message in pipe /var/run/playmethis and plays it using paplay
(
    while true; do
	song=$(cat /var/run/playmethis)
	if [ -s "${song}" ]; then
	    paplay ${song}
	fi
    done
) &

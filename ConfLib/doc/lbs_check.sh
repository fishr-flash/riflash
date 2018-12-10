#!/bin/sh
if ! pgrep lbs_run.py
then
    /home/dev/lbs/lbs_run.py > /home/dev/lbs/lbs_python.log &
fi
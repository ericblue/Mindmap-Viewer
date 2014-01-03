#!/bin/sh

grep Converting debug.log | awk -FURL: '{print $2}' | sort -u

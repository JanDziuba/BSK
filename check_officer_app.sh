#!/bin/bash

cppcheck --enable=all officer_app.c
gcc -Wconversion  officer_app.c
gcc -fstack-protector officer_app.c
valgrind valgrind ./officer_app

docker run --rm -v ${PWD}:/src facthunder/frama-c:latest -eva -eva-precision 1 *.c officer_app.c > report.txt

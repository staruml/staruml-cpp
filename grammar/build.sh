#!/bin/bash

jison "cpp.jison" "cpp.jisonlex"  -t -p lalr > jisonOutput.txt
tail -n 2 jisonOutput.txt

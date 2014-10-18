#!/bin/bash

jison "$PWD/cpp.jison" "$PWD/cpp.jisonlex"  -t -p lalr

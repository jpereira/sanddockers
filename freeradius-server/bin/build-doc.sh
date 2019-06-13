#!/bin/bash

find doc/raddb/ -iname "*.adoc" -delete

while true; do
   make asciidoc
   sleep 1
done


#!/bin/bash
for file in *.md; do pandoc "$file" --wrap=auto -V geometry:"a4paper" -s -o "${file%.md}.pdf"; done
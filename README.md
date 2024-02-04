# Station network analysis
The purpose of these scripts is to easily modify the spreadsheet in which the volunteer of Batlife from a working document into something that can be used in subsequent data analysis. At the present time no data is provided here for privacy reasons. The actual data will be made available at a later time.

## What is each file?

### compiler.Rproj
An R project file that contains the individual scripts.

### compile.R
The actual runscript that takes an indata file (.xslx) in long format and corrects  errors by converting to title case and fixes knows errors (from corrections.json), then converts it to a wide pivot format that counts the number of observations of each species for a given night as well as the number of social calls by species for the same night.
Calls all functions from...

### cleanup_functions.R
A collection of functions called by compile.R to process the data. Each function is explained within the script.

### corrections.json
Pairs of incorrect entries in the data and their corresponding correction. E.g. "Skräp":"X" corrects "Skräp" to "X". The corrections assume that all entries are in title case. This is handled by

### plotting.R
A script that takes the output of compile.R and plots the data across the year. This is still a work in progress, so while functional the code is messy and will be organized in a proper way later.



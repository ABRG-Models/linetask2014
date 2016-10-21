# The Line Task

A repo for the 2014 Line task 3rd year project analysis and paper, entitled:

Target-distractor Synchrony Affects Performance in a Novel Motor Task for
Studying Action Selection

## Data

The data for the experiment are found in analysis/AllData/

There are sub-directories there for each experimenter, and within each
of these, sub-directories for each participant. In each particpant's
directory there is a directory called 'line' which contains three
files, one file for each condition of the task (no distractor,
synchronous distractor and asynchronous distractor).

## Latency extraction

To repeat the extraction of latencies and errors - that is to create
the file analysis/AllData/fnames.mat do the following:

Install Octave (ideally version 3.8.1 or 3.8.2).

change directory into analysis

call the octave script lt_analyse_all

This will take a few minutes to process the data, a lot of text will
fly past the screen!

For a more interesting look at the latency extraction, try just
lt_analyse. This will provide a dialog box allowing you to open one of
the data files: analysis/AllData/Experimenter/Participant/line/*.txt

Analysing just one trial will show graphs of the data, along with the
extracted latencies.

## Statistical analysis

The statistical analysis can be carried out by running the ipython
notebook called Anova.ipynb

This makes sub-calls to R scripts and displays pertinent results.

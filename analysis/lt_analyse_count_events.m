function A = lt_analyse_count_events (file_path)
%% Count events in the data.
%%
%% @file_path is simply the path to the raw data output by the Line
%% task software.
%%
%% Returns a container with event counts.

% A is the main data container for the analysis.
A = struct();

% Add file_path to A.
A.file_path = file_path;

% Common subroutines of this algorithm in the include dir.
addpath ('./include');

% No paging of output please
more off;

% Running on Octave or Matlab?
isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

% Read the data from the file.
[ data, params ] = lt_readfile (A.file_path);

% Place the data into named variables.
A.target = data(:,2);
A.distract = data(:,3);

% Velocity gives the events:
A.targjumps = [ diff(A.target) ; 0];
A.distractjumps = [ diff(A.distract) ; 0];

% Determine the experimental condition. Adds A.expt_condition
A = lt_analyse_determinecondition (A);

% Find the indexes of the target jumps
A.eventindexes = find (A.targjumps); % finds indexes of non-zero

% How many events are there?
A.num_events = length (A.eventindexes);

return

% Get a file path, then analyse latency

% Does the workspace include a current working directory?
if (~exist ('fpath', 'var'))
    fpath = [pwd filesep()];
elseif (fpath == 0)
    fpath = [pwd filesep()];
end
if (~exist ('fname', 'var'))
    fname = '*.txt';
elseif (fname == 0)
    fname = '*.txt';
end

disp (['Previous working directory: ' fpath]);
disp (['Previous filename: ' fname]);

[ fname, fpath ] = uigetfile('*.txt', 'Select the data file', [fpath fname]);

[ A, R ] = lt_analyse_latency ([fpath fname]);

% echo '0'>count; find . -mindepth 2 -path '*20*.txt' -exec ./outputline.sh {} \;
fnames = {};

% Common base file path
fpath = '/home/seb/linetask2014/analysis/AllData/';

% AllData/allfiles.m lists all the trial data files. Regenerate
% allfiles.m if necessary with the script generate_trial_paths.sh.
addpath('AllData')
allfiles % Builds up contents of fnames

% For each participant:
index = 1;
for name = fnames
    disp(name{1});
    A = lt_analyse_count_events ([fpath name{1}]);
    fnames{2,index} = A.num_events;                   % python 1
    fnames{3,index} = A.expt_condition;               % python 2
    index = index + 1;
end

% Save the resulting output
save ('AllData/eventcounts.odat', 'fnames');
save ('-v7','AllData/eventcounts.mat', 'fnames');

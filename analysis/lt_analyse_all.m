% echo '0'>count; find . -mindepth 2 -path '*20*.txt' -exec ./outputline.sh {} \;
fnames = {};

% Common base file path
fpath = '/home/seb/ownCloud/notremor/Line Task/Psy3rdYearProject_2014/AllData/';

% AllData/allfiles.m lists all the trial data files. Regenerate
% allfiles.m if necessary with the script generate_trial_paths.sh.
addpath('AllData')
allfiles % Builds up contents of fnames

% For each participant:
index = 1;
graphs = 0; % Prevent lt_analyse_latency from showing graphs.
for name = fnames
    disp(name{1});
    [A,R] = lt_analyse_latency ([fpath name{1}], graphs);
    fnames{2,index} = A.params;                   % python 1
    fnames{3,index} = R.latency;                  % python 2
    fnames{4,index} = R.latency_noerror;          % python 3
    fnames{5,index} = R.latency_noerror_target;   % python 4
    fnames{6,index} = R.latency_noerror_distractor; % python 5
    fnames{7,index} = R.latency_error;            % python 6
    fnames{8,index} = R.latency_error_target;     % python 7
    fnames{9,index} = R.latency_error_distractor; % python 8
    fnames{10,index} = R.firstmotion_distance;    % python 9
    index = index + 1;
end

% Save the resulting output
save ('AllData/fnames.odat', 'fnames');
save ('-v7','AllData/fnames.mat', 'fnames');

function [ A, R ] = lt_analyse_latency (file_path, show_graphs)
%% This performs a not entirely simple analysis
%% of the stylus movement data to determine the onset of movements
%% following each target movement event.
%%
%% @file_path is simply the path to the raw data output by the Line
%% task software.
%%
%% return values are the mean and standard deviation of the
%% measured latencies, along with a vector of whether or not the
%% initial motion was in the correct direction.

if nargin < 2
    show_graphs = 1;
end

if show_graphs == 0
    fprintf ('Called to analyse "%s" without graphs\n', file_path);
else
    fprintf ('Called to analyse "%s" with graphs\n', file_path);
end

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
A.time = data(:,1);
A.target = data(:,2);
A.distract = data(:,3);
A.stylus = data(:,4);

% Params for graphing
A.line_width_wide = 2;
A.line_width_narrow = 1;
% Whether or not to show the vertical lines - sometimes good to
% miss them out for publication graphs
A.show_vert_lines = 0;
% Whether to show the stable stylus position information on figure 1
A.show_stable_stylus_lines = 1;
% How many pixels to offset the event numbers by on figure 1
A.event_number_text_offset = 10;

% Here, we work out the velocity data. First for the target: we lost
% one element in the vector from the differentiation, hence the
% additional 0. (This appears no longer to be true: I add the 0 at the
% start, not the end, so that the derivative of the target position
% shows a non-negative value for the index of the destination of the
% target at that target move event.)
A.targjumps = [ diff(A.target) ; 0];

% Find out the distractor jumps, too, so that we can figure out if
% this is the "Distractor only", "Synchronous Distractor" or
% "Asynchronous Distractor" mode.
A.distractjumps = [ diff(A.distract) ; 0];

% Determine the experimental condition.
A = lt_analyse_determinecondition (A);

% Store text version of expt_condition in params object - this is
% used in later analysis code (e.g. The Anova ipython notebook)
params.expt_condition = A.expt_condition;

A.params = params;

% Stylus velocity (px per ms):
A.stylusvel = [ diff(A.stylus) ; 0 ]./[diff(A.time) ; 1];

% Sign of the stylus velocity:
A.svel_pos = A.stylusvel>0;
A.svel_neg = -1.*(A.stylusvel<0);
A.svel = A.svel_pos + A.svel_neg;

% Filter stylus velocity to get latencies:
window = 12;
A.svel_real = filter (ones(window,1)/window, 1, A.svel);

% Now create plots of the raw motion data.
if show_graphs == 1
    f1s1 = lt_analyse_plot_motion (A);
end

% A running average stylus velocity, taken across a number of
% points (+/- 5?).
window = 4;
A.stylusvel_avg = filter (ones(window,1)/window, 1, A.stylusvel);

% A slower average speed.
window = 30;
A.stylusvel_avg_slow = filter (ones(window,1)/window, 1, A.stylusvel);

% The acceleration
A.stylus_accel = [ diff(A.stylusvel_avg_slow) ; 0 ]./[diff(A.time) ; 1];
% Smoothed
accelwindow = 20;
A.stylus_accel_avg = filter (ones(accelwindow,1)/accelwindow, 1, A.stylus_accel);

if show_graphs == 1
    % Now plot velocity data
    lt_analyse_plotvelocity (A);
end

% Find the indexes of the jumps
eventindexesC = find (A.targjumps); % finds indexes of non-zero
                                    % members of targjumps.
col2 = ones (size(eventindexesC)(1),1); % make a column of 1s to
                                        % record that these events are
                                        % of event type "target"

A.eventindexes = [eventindexesC'; col2']; % transpose for use in the
                                          % forthcoming for loop.

% If we have an asynchronous distractor, then every distractor
% change is an event, too, and further complicates the A.
A.adcond = 0;
if strcmp(params.expt_condition, 'Asynchronous Distractor')
    A.adcond = 1;
    eventindexesC = find (A.distractjumps);
    col2 = zeros (size(eventindexesC)(1),1); % 0 means event type distractor
    A.eventindexes = [A.eventindexes [eventindexesC'; col2']];
end
% Sort eventindexes into time order now:
A.eventindexes = sortrows (A.eventindexes');
A.eventindexes = A.eventindexes';

% This struct array is the new way to catalogue information about
% events. Each member will be an event data structure.
A.events = [];

% What's the fastest a subject could make a movement?  What's the
% brain's limit? Chose 220 ms initially. However, young people are
% fast, so lets make this just 100 ms which will still omit the very
% short latencies that occur due to deficiencies in the script.
A.fastest_brain_decision = 100; % ms

% #defines
DIST_EVENT = 0;
TARG_EVENT = 1;

% Populate an initial array of event structures from
% A.eventindexes, adding data about the event movements, but no
% analysis of the stylus movements.
eventnumber = 1;
for eventi = A.eventindexes

    % Initialise a new empty event struct
    event = struct();
    % The event number
    event.number = eventnumber;
    % the index in the data series at which the event occurs.
    event.index = eventi(1);
    % target (1) or distractor (0) event
    event.type = eventi(2);

    % Sanity check length of data series
    if (event.index > length(A.targjumps) || event.index > length(A.target))
        fprintf ('Sanity Fail! Either targjumps(len=%d) or target(len=%d) does not have i=%d members.\n', ...
                 length(A.targjumps), length(A.target), event.index);
        return;
    end

    % Note that the "landing position" of target - where it APPEARS - is
    % at time event.index+1. Sanity check this value.
    if (event.index+1 > length(A.time) || event.index+1 > length(A.target))
        fprintf ('Sanity Fail! Either time(len=%d) or target(len=%d) does not have i+1=%d members.\n', ...
                 length(A.time), length(A.target), event.index+1);
        return;
    end

    % the direction of the event - where the target
    % or distractor moved to. NOT move direction.
    if event.type == TARG_EVENT
        % THIS gives the event size as direction also contains the
        % magnitude of the targjump.
        event.direction = A.targjumps(event.index);
    else
        event.direction = A.distractjumps(event.index);
    end

    % The destination of the event. The new location of the target
    % or distractor.
    event.destination = 0;
    if (event.type == TARG_EVENT)
        event.destination = A.target(event.index+1);
    else
        event.destination = A.distract(event.index+1);
    end

    % For storing the duration of this target event (leave set to 0
    % for distractor events)
    event.duration = 0;

    % The EXPECTED position of the stylus at the start of the event. The
    % position of the target at the start of the event.
    event.startposn = A.target(event.index);

    % The rate of change of position of the stylus at the start of
    % the event (make this a mean to ensure we don't miss movement)
    event.startvel = 0;
    % The move threshold for the stylus to be considered to be
    % moving. This is computed based on the position of the stylus
    % since it last came to rest.
    event.pos_move_thresh = 0;
    % Number of pixels moved by the stylus in response to the
    % event. Encodes movement direction.
    event.stylus_moved = 0;
    % The index at which any stylus movement was detected.
    event.stylus_move_index = 0;
    % latency to movement
    event.latency = 0;
    % Set to 1 if move is in correct dirn, 0 if not, -1 means it's
    % undetermined whether this was a correct move or not. Set to 1 if
    % there is NO movement, but it's a distractor event.
    event.correct_move = -1;
    % This is an index (before the event index) at which the stylus
    % position is stable. It is first filled with the previous event's
    % endmotion_index, but it may need to be brought forward from that
    % value, if the stylus does some "wobbling" about.
    event.stableposition_index = eventi(1);
    % The max speed of the stylus during the stableposition period
    event.stableposition_maxspeed = 0;
    % index at which any stylus movement COULD start.
    event.startmotion_index = eventi(1);
    % index at which any stylus movement ends
    event.endmotion_index = eventi(1);
    % index at which the first smooth stylus movement ends
    event.endfirstmotion_index = eventi(1);
    % The distance in px travelled by the first motion
    event.firstmotion_distance_travelled = 0;
    % The distance between the stylus and the target at the end of
    % the first smooth motion.
    event.firstmotion_distance_to_go = 0;
    % Means that the subject made error for this event
    event.error = 0;
    % what sort of error
    event.errordesc = '';
    % Event is omitted from *latency* analysis. This is ok for ND,
    % when there are only targets. What about when there are
    % distractors? If a target is omitted, then do we omit also a
    % proportional number of distractors? This is easy in the SD
    % case; just omit the distractor that occurs simultaneously
    % with the target. It's less clear what to do in the AD case.
    % For considering error rates, we need to consider all
    % distractors, even those which have been omitted, but
    % omissions DO have to be made for latency analysis.
    event.omit = 0;
    % why it was omitted
    event.omit_reason = '';

    % The time since the last event.
    event.time_since_last = 0;

    % The position of the last distractor line. Meaningful only in
    % the asynchronous distractor case.
    event.last_distractor_dest = 0;

    % difference between last/existing target position and the
    % event.startposn. i.e. startposn - last_distractor_dest
    event.last_distractor_offset = 0;

    % The time since the last distractor event
    event.time_since_last_distractor = 0;

    % Lasty, add the event onto the events array
    A.events = [ A.events, event ];

    eventnumber = eventnumber + 1;
end

% min_move_thresh is a number to use when the line was perfectly
% stationary in the run up to the target moving.
A.min_move_thresh = 2.5; % px

% Maximum move threshold to allow. If we can't find a stylus
% position before an event which wobbles this much or less, then
% omit the event from analysis.
A.max_move_thresh = 15; % px
% Same for distractor events:
A.max_move_thresh_dist = 15; % px

% A threshold velocity above which the stylus is considered to be
% in motion, for the purpose of determining if a distractor event
% is being ignored.
A.min_midmove_speed = 1.5; % px/ms

% Another speed threshold, to work out if the stylus is in
% motion. The speed should be larger than this value, and the
% position should have moved outside pos_move_thresh for the
% movement to be considered valid.
A.min_move_speed = 0.05; % px/ms

% Like A.min_move_speed, but used whe comparing A.stylusvsl_avg
A.min_move_speed_avg = 0.15; % px/ms

% A minimum period during which the stylus should be in a stable
% position prior to an event movement.
A.min_stableposition_period = 200; % ms
% Same for distractor events:
A.min_stableposition_period_dist = 150; % ms

% The time which makes two sequential events "close". If two events
% are too close in time, it can be impossible to determine to which
% one a movement should be ascribed.
A.min_event_to_event_time = 50; % ms

% How far beyond the event change time to extend the stable
% position period.
A.stableposition_period_offset = 60; % ms

% How near we need to be to the target to effectively have arrived.
A.stableposition_close_enough = 5; % px

% The max mean speed allowed in the stableposition period
A.max_avg_drift_speed = 0.01; % px/ms
% Same for distractor events:
A.max_avg_drift_speed_dist = 0.02; % px/ms

% This is a parameter which is the distance from the target which the
% firstmotion of a successful target movement will attain in most
% cases (could be statistically careful about this).
A.firstmotion_is_on_target = 150; % px

% The number of pixels for a target jump for it to be too
% small. Mauro used 100. I think 20 is better.
A.enforce_min_target_jump_size = 20; % Set to 0 to disable

% This is a test which Mauro applies, and which I don't understand
A.enforce_event_duration = 0; % ms. Mauro uses 1500?!

% stylus move threshold number of SD for a movement to count. Here,
% the SD is the standard deviation of the position of the stylus
% between the previous target event's endmotion_index and the
% current event's onset index.
A.N_SDs = 3;

% The last target and distractor events
A.last_target_ev = 0;
A.last_distractor_ev = 0;

% Can't use syntax for ev = A.events, because ev is a *copy* of
% element in A.events.
for ev = 1:length(A.events)

    % Allow sub-routines to access this event, so that we just pass A to
    % subroutines, rather than A AND event. In this script we can
    % refer to ev.index or ev.type, in subroutines the equivalent
    % would be A.events(A.curr_evnum).index or
    % A.events(A.curr_evnum).type.
    A.curr_evnum = ev; % == A.events(ev).number

    % We keep a running memory of the most recent target event
    if A.events(ev).type == TARG_EVENT
        A.last_target_ev = ev;
    end

    % ...and also a running memory of the most recent distractor event.
    if A.events(ev).type == DIST_EVENT
        A.last_distractor_ev = ev;
    end

    lt_analyse_printevheader(A);

    % We'll loop onwards from event.index+1 with an index j.
    j = A.events(ev).index+1;

    % Sanity check on j and length of A.stylus
    if (j > length(A.stylus))
        fprintf (['Sanity Fail! j (%d) is now off the end of the length of stylus ' ...
                  '(%d) - return.\n', j, length(A.stylus)]);
        return;
    end

    %
    % START finding the stylus stableposition_index and pos_move_thresh.
    %
    % The endmotion for the previous event was computed on the previous loop.
    A.events(ev).stableposition_index = lt_analyse_find_prev_target_endmotion(A);

    % Could add a test here "is this period too short?"
    %stableposition_period_duration = A.time(A.events(ev).stableposition_index) - A.time(j)

    fprintf ('Previous target endmotion gives stableposition_index=%d (time %d ms)\n', ...
             A.events(ev).stableposition_index, A.time(A.events(ev).stableposition_index));

    % Compute a stableposition_period_end using the
    % "stableposition_period_offset".  FIXME: Possibly have target and
    % distractor versions of stableposition_period_offset?
    stableposition_period_end = lookup(A.time, A.time(j)+A.stableposition_period_offset)

    % Sanity check order of A.events(ev).stableposition_index, j, and the end index.
    if (A.events(ev).stableposition_index >= stableposition_period_end)

        % Actually, if the current event is a distractor, the prev
        % event could be a target whose endmotion is later than the
        % current event's startmotion. What then? Perhaps get the
        % previous *target* endmotion and use that as the
        % stableposition index. That's ok, we can do that, but it
        % still may be the case that that previous target may have
        % a stable endmotion which occurs after the distractor
        % onset. I think that means that the subject successfully
        % ignored the distractor.
        %ev
        %event_type = A.events(ev).type
        %stable_pos_idx = A.events(ev).stableposition_index
        %stylus_length = length(A.stylus)
        %prev_event_error = A.events(ev-1).error

        if A.events(ev).type == DIST_EVENT && ...
                A.events(ev).stableposition_index < length(A.stylus) && ...
                A.events(ev-1).omit == 0
            fprintf ('Previous endmotion should be valid, apparently (it was a target and there was an endmotion) I dont think this nolds...');
            % Then the previous endmotion should be valid (it was a
            % target and there *was* an endmotion, so mark the
            % current distractor event as a correct movement.
            A.events(ev).correct_move = 1;
            % Previously, I omitted the current distractor event:
            %A.events(ev).omit = 1;
            %A.events(ev).omit_reason = ['A previous target event was ' ...
            %                    'successfully followed; there''s no ' ...
            %                    'stable stylus position for this distractor.'];
            %fprintf ('Omit event %d: %s\n', ev, A.events(ev).omit_reason);
        else
            fprintf (['Sanity fail! A.events(%d).stableposition_index [%d] >= stableposition_period_end [%d], ' ...
                      'returning.\n'], ev, A.events(ev).stableposition_index, stableposition_period_end);
            A.events(ev).omit = 1;
            A.events(ev).omit_reason = 'Previous event stableposition_index is >= current event onset';
        end
    else
        fprintf ('Sanity pass; stableposition_index is earlier than stableposition_period_end.');
    end

    % NB: sanity already checked for this line:
    A.events(ev).pos_move_thresh = std (A.stylus(A.events(ev).stableposition_index:stableposition_period_end)) .* A.N_SDs;
    fprintf ('Initial pos_move_thresh based on stableposition_index=%d is %d\n', ...
             A.events(ev).stableposition_index, A.events(ev).pos_move_thresh);

    % Check for unexpectedly large move threshold and correct or mark for
    % omission. There's quite a lot of logic in
    % lt_analyse_checkthresholdsize. This should be called
    % lt_analyse_improve_stableposition_period or something like that.
    A = lt_analyse_checkthresholdsize(A,stableposition_period_end);

    % Ok, so we now tried hard to find a stable period for the
    % stylus. We may not have been able to, in which case, we might
    % mark the event for omission. But, for a distractor, we may
    % have no stable period, and yet a deflection towards the
    % distractor may occur, which would be an errored movement. So,
    % we test for this here.
    if A.events(ev).stableposition_index == 1 && A.events(ev).type == DIST_EVENT
        fprintf ('stableposition_index was 1 and it''s a DIST EVENT, so analyse distr. accel.\n');
        % This will fail as I have not implemented
        % lt_analyse_distractor_acceleration yet.

        fprintf ('Implement me: lt_analyse_distractor_acceleration\n');
        %A = lt_analyse_distractor_acceleration(A);
    end

    % If the stylus was stationary during this period, then require a
    % minimum move threshold to register a new movement.
    if (A.events(ev).pos_move_thresh < A.min_move_thresh)
        fprintf ('pos_move_thresh=%d is too small; set to min_move_thresh (%.2f px)\n', ...
                 A.events(ev).pos_move_thresh, A.min_move_thresh);
        A.events(ev).pos_move_thresh = A.min_move_thresh;
    else
        fprintf ('pos_move_thresh: Position SD*%d (range %d to %d) = %.2f px\n', ...
             A.N_SDs, A.events(ev).stableposition_index, j, A.events(ev).pos_move_thresh);
    end

    if A.events(ev).omit == 1
        continue
    end
    %
    % END finding pos_move_thresh.
    %

    % Add a "did the target move too small an amount to count?"
    % A. If the stylus's position since attaining the last
    % event's target has an SD which is >
    % abs(target_new-target_old), then omit the event.
    target_delta = A.events(ev).destination-A.events(ev).startposn;
    if (abs(target_delta) < 2*std (A.stylus(A.events(ev).stableposition_index:j)))
        A.events(ev).omit = 1;
        A.events(ev).omit_reason = ['target movement insignificant (' num2str(target_delta) ...
                          ' px) for event ' num2str(A.events(ev).number)];
    end

    % An optional "did the target move less than a threshold"
    % test. Matches Mauro's test for a target movement of at least
    % 100px.
    if A.enforce_min_target_jump_size > 0 && (abs(target_delta) < A.enforce_min_target_jump_size)
        A.events(ev).omit = 1;
        A.events(ev).omit_reason = ['target movement (' num2str(target_delta) ...
                            ' px) less than ' num2str(A.enforce_min_target_jump_size) ...
                            ' for event ' num2str(A.events(ev).number)];
    end

    % Record the last distractor event for a target event (AD
    % condition only)
    if A.adcond && A.events(ev).type == TARG_EVENT && A.last_distractor_ev > 0
        A.events(ev).last_distractor_dest = A.events(A.last_distractor_ev).destination;
        A.events(ev).last_distractor_offset = A.events(ev).startposn - A.events(ev).last_distractor_dest;
        A.events(ev).time_since_last_distractor = A.time(A.events(ev).index) - A.time (A.events(A.last_distractor_ev).index);
    end

    % Compute event duration (only for target events).
    if A.events(ev).type == TARG_EVENT
        if ev == length(A.events)
            % This is the last event.
            A.events(ev).duration = A.time(end) - lookup(A.time, A.time(A.events(ev).index));
        else
            % Compute time until next target event
            next_targ = ev+1;
            while next_targ <= length(A.events)
                if A.events(next_targ).type == TARG_EVENT
                    break;
                end
                next_targ += 1;
            end
            if next_targ > length(A.events)
                next_targ -= 1;
            end
            A.events(ev).duration = lookup(A.time, A.time(A.events(next_targ).index)) - lookup(A.time, A.time(A.events(ev).index));
        end
    end

    % Now possibly enforce event duration:
    if A.events(ev).type == TARG_EVENT && A.enforce_event_duration > 0 && A.events(ev).duration < A.enforce_event_duration
        A.events(ev).omit = 1;
        A.events(ev).omit_reason = ['target movement of ' num2str(A.events(ev).duration) ...
                            ' lasts less than ' ...
                            num2str(enforce_event_duration) ...
                            ' ms for event ' num2str(A.events(ev).number)];
    end

    % This is the "did the stylus move?" analysis (updates
    % A.events(ev).stylus_moved, should also set A.events(ev).latency)
    [A, j_move] = lt_analyse_didstylusmove (A, j);

    if (A.events(ev).stylus_moved ~= 0)

        %
        % START Record information about movement direction errors.
        %

        % Calculate the stylus move direction, and the move
        % direction of the event in the stylus's frame of reference:
        stylus_move_dir = A.events(ev).stylus_moved./abs(A.events(ev).stylus_moved);
        event_move_dir = (A.events(ev).destination - A.stylus(A.events(ev).index)) ...
            ./ abs(A.events(ev).destination - A.stylus(A.events(ev).index));

        if A.last_target_ev > 0
            current_target_move_dir = (A.events(A.last_target_ev).destination - A.stylus(A.events(ev).index)) ...
                ./ abs(A.events(A.last_target_ev).destination - A.stylus(A.events(ev).index));

            % We are "close_to_current_target" if we're close and moving slowly:
            closeness = abs(A.events(A.last_target_ev).destination - A.stylus(A.events(ev).stylus_move_index))
            speediness = A.stylusvel_avg(A.events(ev).stylus_move_index)
            close_to_current_target = closeness <= A.stableposition_close_enough && speediness <= A.min_move_speed_avg

        else
            current_target_move_dir = 0;
            close_to_current_target = 0;
        end

        % First assume it's a correct movement.
        A.events(ev).correct_move = 1;

        beyond_next_target = 0;
        [next_target_index, next_target_num] = lt_analyse_find_next_target_event_index (A);
        fprintf ('A.time(next_target)=%d, A.time(stylus_move)=%d\n', A.time(next_target_index), A.time(A.events(ev).stylus_move_index));
        if (A.time(next_target_index) - A.time(A.events(ev).stylus_move_index) < -150)
            fprintf ('movement occurs >150 ms later than next target, so there was no distraction.\n');
            beyond_next_target = 1;
        end

        % If the event is a distractor, and the stylus movement direction IS
        % in the same direction as the event but NOT in the same
        % direction as the target, then we mark this event as an
        % error.
        %
        % OR if the event is a distractor, and the stylus is
        % more-or-less *on* the current target, but the stylus
        % movement direction is towards the distractor, then mark
        % this as an error.

        on_target_but_distracted_away = ...
            (A.events(ev).type == DIST_EVENT && stylus_move_dir == event_move_dir) ...
            && (close_to_current_target) && ~(beyond_next_target);

        not_nec_on_target_and_distracted_away = ...
            (A.events(ev).type == DIST_EVENT && stylus_move_dir == event_move_dir) ...
            && (current_target_move_dir == 0 || stylus_move_dir ~= current_target_move_dir) && ~(beyond_next_target);

        distracted_away = 0;
        if on_target_but_distracted_away
            distracted_away = 1;
            A.events(ev).errordesc = 'Distracted stylus movement (away from stable target posn)';
        elseif not_nec_on_target_and_distracted_away
            distracted_away = 1;
            A.events(ev).errordesc = 'Distracted stylus movement (not necessary from stable target posn)';
        end

        if distracted_away
            fprintf ('At DIST_EVENT, stylus was distracted\n');

            % Before adding this, just check we haven't already
            % recorded the movement as being a distraction from
            % another distractor event.
            already_counted = 0;
            for ev1 = A.events
                %fprintf ('ev1 number: %d  curr_ev number: %d  ev1 start: %d  curr_ev start: %d\n', ...
                %         ev1.number, A.events(ev).number, ev1.stylus_move_index, A.events(ev).stylus_move_index);
                if ev1.type == DIST_EVENT && ev1.number ~= A.events(ev).number && ev1.stylus_move_index ~= 0 ...
                        && ev1.stylus_move_index == A.events(ev).stylus_move_index
                    fprintf ('Already counted distractor event number %d\n', ev1.number);
                    already_counted = ev1.number;
                    break
                end
            end
            if already_counted ~= 0
                % We must have counted an EARLIER distractor has
                % having caused this movement. Let's mark that
                % earlier distractor for omission and record in
                % THIS event.
                A.events(already_counted).omit = 0;
                A.events(already_counted).error = 0;
                A.events(already_counted).correct_move = 1;
                % Record info in the errordesc, even though there's
                % no error:
                A.events(already_counted).errordesc = ['Counting same motion as distraction due to event ' num2str(ev) ' instead'];
            end
            A.events(ev).error = 1;
            A.events(ev).correct_move = 0;
            % But what if the target is ALSO in the direction of
            % the distractor? Cover this by looking at timing of
            % events and omitting if time of distractor is close to
            % time of target.
            fprintf ('Error for event %d: %s\n', ev, A.events(ev).errordesc);
        end

        % If the event is a target, and the stylus movement
        % direction is NOT in the same direction as the event,
        % then we mark this event as an error - that is an
        % error made by the subject.
        if A.events(ev).type == TARG_EVENT && stylus_move_dir ~= event_move_dir
            A.events(ev).error = 1;
            A.events(ev).correct_move = 0;
            A.events(ev).errordesc = 'Stylus direction error';
            fprintf ('Error for event %d: %s\n', ev, A.events(ev).errordesc);
        end

        % If the movement toward a target is too fast, then mark it as such.
        if A.events(ev).type == TARG_EVENT && A.events(ev).latency < A.fastest_brain_decision
            A.events(ev).omit = 1;
            A.events(ev).omit_reason = 'Too fast (targ)';
        end
        if A.events(ev).type == DIST_EVENT && A.events(ev).error == 1 && A.events(ev).latency < A.fastest_brain_decision
            A.events(ev).omit = 1;
            A.events(ev).omit_reason = 'Too fast (distr)';
        end


        %
        % Determine the end of the stylus motion.
        %
        if j_move > length(A.stylus)
            j_move = length(A.stylus);
        end

        if A.events(ev).type == TARG_EVENT
            A = lt_analyse_find_end_targetmotion (A, j);
        else % A.events(ev).type == DIST_EVENT
             % Start finding end of distract motion from j_move,
             % not from j.
            A = lt_analyse_find_end_distractmotion (A, j_move);
        end

        % Now do a velocity based analysis to find the end of the first
        % clear motion.
        section = A.stylus(j:A.events(ev).endmotion_index);
        velsect = A.stylusvel_avg(j:A.events(ev).endmotion_index);
        efm = lt_analyse_find_end_firstmotion (section, velsect, 0);
        if (j_move + efm) <= length(A.stylus)
            A.events(ev).endfirstmotion_index = j_move + efm;
        else
            A.events(ev).endfirstmotion_index = length(A.stylus);
        end
        A.events(ev).firstmotion_distance_travelled = A.stylus(A.events(ev).endfirstmotion_index) - A.stylus(j_move);
        A.events(ev).firstmotion_distance_to_go = A.events(ev).destination - A.stylus(A.events(ev).endfirstmotion_index);
        fprintf ('First motion ends at: %d px at %d ms (index %d) with %d px to go\n', ...
                 A.stylus(A.events(ev).endfirstmotion_index), ...
                 A.time(A.events(ev).endfirstmotion_index), A.events(ev).endfirstmotion_index, A.events(ev).firstmotion_distance_to_go);
        %
        % Done determining first motion
        %

        %
        % Check on timing of this event and the last event. If this event is
        % very close in time to last event then do some additional
        % logic.
        %
        if ev > 1 % Can't check very first one.

            A.events(ev).time_since_last = A.time(A.events(ev).index) - A.time(A.events(ev-1).index);

            % This is the "are they close together in time?" test:
            if A.events(ev).time_since_last < A.min_event_to_event_time

                fprintf ('Event %d is close in time to event %d, doing special close-in-time logic.\n', ev-1, ev);

                % Categorise type and direction of first (ev1) and
                % second (ev2) events:
                ev1type = A.events(ev-1).type;
                ev2type = A.events(ev).type;
                ev1dir = (A.events(ev-1).destination - A.stylus(A.events(ev-1).index)) ...
                         ./ abs(A.events(ev-1).destination - A.stylus(A.events(ev-1).index));
                ev2dir = (A.events(ev).destination - A.stylus(A.events(ev).index)) ...
                         ./ abs(A.events(ev).destination - A.stylus(A.events(ev).index));

                % Only consider close events if they're of opposite types:
                if (ev1type == DIST_EVENT && ev2type == TARG_EVENT) ...
                             || (ev1type == TARG_EVENT && ev2type == DIST_EVENT)

                    if ev1type == DIST_EVENT
                        % Then the distractor event leads the target event.
                        if ev1dir == ev2dir
                            % It's impossible to tell if the movement
                            % is towards the distractor or the target,
                            % so omit as such? or assume movement is
                            % towards target? or look at distance of
                            % first motion and use that to
                            % determine? Not sure I actually record firstmotion_distance_to_go

                            fprintf ('First motion distance to go for target: %f\n', A.events(ev).firstmotion_distance_to_go);
                            if A.events(ev).firstmotion_distance_to_go < A.firstmotion_is_on_target
                                % Motion was to target (here ev2), assume target won here.
                                A.events(ev).error = 0;
                                A.events(ev).correct_move = 1;
                                % That means distractor was also ok:
                                A.events(ev-1).error = 0;
                                A.events(ev-1).correct_move = 1;
                            else % Motion not towards
                                 % target. Record for the initial
                                 % event, the distractor
                                A.events(ev-1).error = 1;
                                A.events(ev-1).correct_move = 0;
                                A.events(ev-1).errordesc = 'Close targ and distractor. Subject was distracted';
                                % Have to omit the target?
                                A.events(ev).omit = 1;
                                A.events(ev).omit_reason = 'Subject was distracted by closely previous distractor';
                            end

                        else % directions are different
                             % Compare movement direction with ev1dir
                             % and ev2dir.
                            if stylus_move_dir == ev1dir
                                % Record this as a distracted movement
                                % towards the distractor
                                A.events(ev-1).error = 1;
                                A.events(ev-1).errordesc = 'Movement towards this distractor which occurs shortly before next target';
                                A.events(ev-1).correct_move = 0;
                                if A.events(ev).omit == 0
                                    A.events(ev).omit = 1;
                                    A.events(ev).omit_reason = 'Incorrect move recorded in previous distractor event';
                                end

                            else
                                % Record as a correct movement towards
                                % target
                                A.events(ev).error = 0;
                                A.events(ev).correct_move = 1;
                                if A.events(ev-1).omit == 0
                                    A.events(ev-1).omit = 1;
                                    A.events(ev-1).omit_reason = 'This distractor event did not distract the stylus movement';
                                end

                            end
                        end


                    else % ev1type == TARG_EVENT
                         % A target event leads a distractor event.
                        if ev1dir == ev2dir
                            fprintf ('First motion distance to go for target: %f\n', A.events(ev-1).firstmotion_distance_to_go);
                            % It's impossible to tell if the movement
                            % is towards the distractor or the target,
                            % so omit as such? or assume movement is
                            % towards target? or look at distance of
                            % first motion and use that to determine?
                            if A.events(ev-1).firstmotion_distance_to_go < A.firstmotion_is_on_target
                                % Movement was towards target and
                                % distractor event was also ok.
                                A.events(ev-1).error = 0;
                                A.events(ev-1).correct_move = 1;
                                A.events(ev).error = 0;
                                A.events(ev).correct_move = 1;

                            else % Firstmotion of the target event
                                 % doesn't land near target, so
                                 % assume distractor won
                                A.events(ev-1).error = 1;
                                A.events(ev-1).correct_move = 0;
                                A.events(ev-1).errordesc = 'Close targ and distractor, motion doesnt land near target';
                                % Don't record error for the
                                % subsequenct distractor:
                                A.events(ev).error = 0;
                                A.events(ev).correct_move = 1;
                            end

                        else % directions different
                             % Compare movement direction with ev1dir
                             % and ev2dir.
                            if stylus_move_dir == ev1dir % move towards
                                                         % target. tick.

                                A.events(ev-1).error = 0;
                                A.events(ev-1).correct_move = 1;
                                if A.events(ev).omit == 0
                                    A.events(ev).omit = 1;
                                    A.events(ev).omit_reason = 'This distractor event did not distract the stylus movement';
                                end

                            else % Move toward distractor. Wrong.

                                A.events(ev).error = 1;
                                A.events(ev).correct_move = 0;
                                A.events(ev).errordesc = 'Movement towards this distractor which occurs shortly after previous target';
                                if A.events(ev).omit == 0
                                    A.events(ev).omit = 1;
                                    A.events(ev).omit_reason = 'Recorded this stylus movement as a distraction towards the next distractor';
                                end


                            end
                        end
                    end
                end
            end

            %
            % Here's a simplistic approach to "too close" events. Another
            % would be  to look at where the stylus ends up after
            % the first smooth motion; if it's close to the next
            % target, then mark the target motion as good and mark
            % the distractor as good, also.
            %if (A.time(A.events(ev).index) - A.time(A.events(ev-1).index)) < A.min_event_to_event_time
            %    fprintf ('Event %d is too close in time to event %d, omitting both.\n', ev-1, ev);
            %    if A.events(ev-1).omit == 0
            %        A.events(ev-1).omit = 1;
            %        A.events(ev-1).omit_reason = 'Too close in time to next event';
            %    end
            %    if A.events(ev).omit == 0
            %        A.events(ev).omit = 1;
            %        A.events(ev).omit_reason = 'Too close in time to previous event';
            %    end
            %end
        end

        %
        % END Record information about movement direction errors.
        %

    else  % A.events(ev).stylus_moved == 0 (no movement)

        if A.events(ev).omit == 0
            % No movement. This is good for a distractor, bad for a
            % target. In either case, omit the event.
            fprintf ('No movement detected for event number %d\n', A.events(ev).number);
            % Mark that the movement was correct (i.e. there was no movement)
            if A.events(ev).type == DIST_EVENT
                A.events(ev).correct_move = 1;
            else % target
                 % If a target has no movement, then it's probable that
                 % the change in position of the target was negligible
                A.events(ev).omit = 1;
                A.events(ev).omit_reason = 'No movement detected';
            end
            % As there was no movement, latency can be set to 0
            A.events(ev).latency = 0;
        end
    end

end % for

%
% Stylus path analysis is complete. Now we graph, reformat and
% output the information.
%
% Return values.
%
R = lt_analyse_post_analysis (A);

if show_graphs == 1
    lt_analyse_plot_correct_dirn(A, R); % really _plot_noerror_target
    lt_analyse_plot_incorrect_dirn (A, R); % really _plot_error_target
    lt_analyse_plot_error_distractor (A, R);
    lt_analyse_plot_firstmotion_distances (A, R);
    lt_analyse_plot_add_arrows (A, f1s1);
    %    lt_analyse_plot_lat_vs_timesincelast (A, R);
end

% String output of the event information
errorcount = 0;
goodmovecount = 0;
for ev = A.events
    if ev.type == DIST_EVENT
        targdist = 'Distractor';
        targdistshort = 'D';
    else
        targdist = 'Target';
        targdistshort = 'T';
    end
    fprintf ('Event %d [%s]: ', ev.number, targdistshort);
    if ev.omit == 1
        fprintf ('Omitted: %s', ev.omit_reason);
    else
        if ev.error == 0
            if ev.type == TARG_EVENT
                goodmovecount = goodmovecount + 1;
                fprintf ('Successfully followed.\n');
                fprintf ('Start posn: %d, Target posn: %d, Last distractor posn: %d, offset: %d, time since distractor: %d', ev.startposn, ev.destination, ev.last_distractor_dest, ev.last_distractor_offset, ev.time_since_last_distractor);
            else
                fprintf ('Successfully ignored.');
            end
        else
            errorcount = errorcount + 1;
            if ev.type == TARG_EVENT
                fprintf ('Move error: %s.', ev.errordesc);
            else
                fprintf ('Move error: %s.', ev.errordesc);
            end
        end
        fprintf (' Latency: %d ms', ev.latency);
    end
    fprintf ('\n');
end

fprintf ('Final movement error count: %d\n', errorcount);
fprintf ('Final good target movement count: %d\n', goodmovecount);

end % function

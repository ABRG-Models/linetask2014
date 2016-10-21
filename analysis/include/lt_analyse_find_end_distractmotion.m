% For distractor type events, find the end of the motion.  This
% function's task is to add to A.endmotionindexes the index (in
% A.stylus) at which the stylus has returned to the target
% position.
%
function A = lt_analyse_find_end_distractmotion (A, k)

    fprintf ('Find end of distracted motion from index k=%d (time %d ms)...\n', k, A.time(k));

    % If the stylus moved towards the distractor, it needs to
    % return to the current target position before the target next moves.
    return_locn = A.target(A.events(A.curr_evnum).index);
    fprintf ('Correct target location: %d px\n', return_locn);

    start_locn_index = k; % This was j_move in lt_analyse_latency.m

    [next_target_event_index, next_target_event_num] = lt_analyse_find_next_target_event_index (A);
    fprintf ('Next target event index = %d\n', next_target_event_index);

    [next_distractor_event_index, next_distractor_event_num] = lt_analyse_find_next_distractor_event_index (A);
    fprintf ('Next distractor event index = %d\n', next_distractor_event_index);

    % This is a distracted motion, so first of all, we need to
    % allow the stylus to move AWAY from the current target
    % position. This finds the start of the movement.
    distract_start = k

    % Check we haven't moved past the next distractor
    if distract_start >= next_distractor_event_index
        fprintf ('Stylus did not move away from current target position before next distractor\n');
        if A.curr_evnum == length(A.events)
            % This is the last event, so say it ends on the
            % last index of all:
            A.events(A.curr_evnum).endmotion_index = length(A.stylus);
        else
            A.events(A.curr_evnum).endmotion_index = next_distractor_event_index;
        end
        A.events(A.curr_evnum).omit = 1;
        A.events(A.curr_evnum).omit_reason = 'Stylus didn''t move away from target position before next distraction';
        return
    end

    fprintf('Move along until we find that the velocity has ramped up.\n');
    while k <= length(A.stylusvel) && k <= length(A.stylus) && abs (A.stylusvel_avg(k)) <= A.min_move_speed
        k=k+1;
    end
    if k < length(A.time)
        fprintf('Now, stylusvel_avg(k=%d)=%d\n', k, A.stylusvel_avg(k));
    end

    fprintf('Move along until we find that the velocity has ramped down again.\n');
    while k <= length(A.stylusvel) && k <= length(A.stylus) ...
               && abs (A.stylusvel_avg(k)) >= A.min_move_speed
        if (A.curr_evnum == 9)
            fprintf ('while %.4f > %.4f && %.10f > %.10f time(k)=%d...\n', ...
                     abs(A.stylus(k)-return_locn), A.events(A.curr_evnum).pos_move_thresh, ...
                     abs(A.stylusvel_avg(k)), A.min_move_speed, A.time(k));
        end
        k=k+1;
    end
    if k < length (A.time)
        fprintf ('at end %.4f > %.4f? && %.10f > %.10f? time(k)=%d...\n', ...
                 abs(A.stylus(k)-return_locn), A.events(A.curr_evnum).pos_move_thresh, ...
                 abs(A.stylusvel_avg(k)), A.min_move_speed, A.time(k));
    end
    distract_max = k

    % Move along until position attained and stylus velocity is 0.
    fprintf (['k=%d. Still try to find stylus posn within %d of return_locn: %d' ...
              '\n'], k, A.events(A.curr_evnum).pos_move_thresh, return_locn);
    while k <= length(A.stylusvel) && k <= length(A.stylus) ...
               && abs(A.stylus(k)-return_locn) > A.events(A.curr_evnum).pos_move_thresh ...
        k=k+1;
    end
    distract_end = k;

    stylus_move_dir = A.events(A.curr_evnum).stylus_moved./abs(A.events(A.curr_evnum).stylus_moved)
    % This is targ event move direction in the stylus frame of reference!
    targevent_move_dir = (A.events(next_target_event_num).destination - A.stylus(A.events(A.curr_evnum).index)) ...
        ./ abs(A.events(next_target_event_num).destination - A.stylus(A.events(A.curr_evnum).index))

    if k < length(A.stylusvel)
        if A.events(A.curr_evnum).number < length(A.events) ...
                && distract_max >= next_target_event_index ...
                && stylus_move_dir == targevent_move_dir
            % Our distracted motion occurred past the next TARGET event,
            % so fix the end location to be equal to the start location.
            k = start_locn_index;
            fprintf (['Info: middle of distracted motion is at/past the next ' ...
                      'target event index at %d, so stylus was not distracted. End motion==startmotion: %d\n'], ...
                     next_target_event_index, k);
            % Also set the latency for this distractor event to 0.
            display('Setting event latency to 0 inside ..find_end_distractmotion()');
            A.events(A.curr_evnum).latency = 0;
            % Mark event as being omitted
            A.events(A.curr_evnum).omit = 1;
            A.events(A.curr_evnum).omit_reason = 'Movement occurs beyond next target event and is in dirn of target';

        elseif A.events(A.curr_evnum).number < length(A.events) ...
                && distract_max >= next_target_event_index ...
                && stylus_move_dir ~= targevent_move_dir
            % A target occured after this distractor event, but
            % because the stylus is moving towards the distractor,
            % we can say that the distractor movement is valid.
            fprintf ('Distracted motion ends at: %d/time: %d ms (index %d)\n', A.stylus(k), A.time(k), k);

        elseif A.events(A.curr_evnum).number < length(A.events) ...
                && k >= next_target_event_index ...
                && stylus_move_dir == targevent_move_dir
            k = distract_max;
            fprintf (['Info: end of distracted motion is at/past the next ' ...
                      'target event index at %d, so set end motion to be distract_max: %d\n'], ...
                     next_target_event_index, distract_max);
        else
            fprintf ('Distracted motion ends at: %d/time: %d ms (index %d)\n', A.stylus(k), A.time(k), k);
        end

    else % k >= length(A.stylusvel)

        % Force end of movement to be half way between events?
        % Probably ok, this.
        disp('k is off the end of the stylus time series; forcing end of move to be half way');
        if (A.curr_evnum == length(A.events))
            % This is the last event, so say it ends on the
            % last index of all:
            k = length(A.stylus);
        else
            % Put k at the average of the current move event
            % and the next one (but ensure it's an integer!):
            k = round((A.events(A.curr_evnum).index + A.events(A.curr_evnum+1).index) ./ 2);

        end
        fprintf ('Warning: No END of distracted movement detected for event number %d - set k to %d\n', ...
                 A.curr_evnum, k);
    end

    A.events(A.curr_evnum).endmotion_index = k;
end

% Algorithm to determine if the stylus moved or not. This
% function's action is to set analysis.moved.
function [ A, j ] = lt_analyse_didstylusmove (A, j)

    fprintf ('Find any stylus movement...\n');

    debug_it = 0;

    if debug_it
        fprintf ('stylus_initial_pos = A.stylus(%d) = %d\n', j, A.stylus(j));
        fprintf ('A.events(A.curr_evnum).pos_move_thresh = %d\n', A.events(A.curr_evnum).pos_move_thresh);
    end

    stylus_initial_pos = A.stylus(j);
    j_orig = j;

    % Test if the stylus is already moving. If it's already moving, and
    % the event is a distractor, then we assume that the subject is
    % moving due to a previous distractor or target event. It's
    % *possible* that this distractor event would cause a deviation in
    % the trajectory of the stylus, but I've not seen any traces
    % where this happens.
    if A.events(A.curr_evnum).type == 0 && abs(A.stylusvel_avg(j)) > A.min_midmove_speed
        A.events(A.curr_evnum).stylus_moved = 0;
        A.events(A.curr_evnum).omit = 1;
        A.events(A.curr_evnum).omit_reason = 'Stylus moving at event onset';
        fprintf ('Omit distractor event %d: %s\n', A.curr_evnum, A.events(A.curr_evnum).omit_reason);
    end

    if debug_it
        display ('current event omit?:');
        if A.events(A.curr_evnum).omit == 1
            A.events(A.curr_evnum).omit_reason
        end
    end

    while A.events(A.curr_evnum).stylus_moved == 0 ...
            && j <= length(A.stylusvel) ...
            && A.events(A.curr_evnum).omit == 0

        % Compute the horiz_diff from the mean position between the
        % target onset and the current location to get correct
        % direction even with some drift.
        stylus_mean_initial_pos = mean(A.stylus(j_orig:j));

        if debug_it
            fprintf ('A.stylus(%d) = %d\n', j, A.stylus(j));
        end
        horiz_diff = A.stylus(j) - stylus_mean_initial_pos;

        % Test if the stylus has moved a significant amount.
        if (abs (horiz_diff) > A.events(A.curr_evnum).pos_move_thresh
            && abs(A.stylusvel_avg(j)) > A.min_move_speed)

            % The subject moved the stylus a significant amount.
            % put stylusvel into stylus_moved, as this gives direction
            % moved
            fprintf (['Stylus moved more than pos_move_thresh (%.2f); ' ...
                      '%.2f px -> %d px by index %d (%d ms)\n'], ...
                     A.events(A.curr_evnum).pos_move_thresh, ...
                     stylus_initial_pos, A.stylus(j), j, A.time(j));

            % Gives direction of movement. Now step back along this path until
            % we're within 1 SD of stylus stylus_initial_pos.
            A.events(A.curr_evnum).stylus_moved = horiz_diff;

            % Now we're going to step back from the move position
            % to get our best estimate of the start of the
            % motion. We step back until we are near enough and
            % slow enough.
            while j > 1 ...
                    && abs(A.stylus(j)-stylus_initial_pos) > (A.events(A.curr_evnum).pos_move_thresh ./ A.N_SDs) ...
                    && abs(A.stylusvel_avg(j)) >= A.min_move_speed
                j=j-1;
            end
            fprintf ('Stepped back to position %d px at time %d ms at index %d\n', A.stylus(j), A.time(j), j);
            A.events(A.curr_evnum).stylus_move_index = j;

            % Record the time at which the stylus movement starts
            % to calculate the latency
            move_time = A.time(j);
            appearance_time = A.time(A.events(A.curr_evnum).index+1);
            fprintf ('Setting event.latency to %d ms\n', move_time-appearance_time);
            A.events(A.curr_evnum).latency = move_time-appearance_time;
        end

        j=j+1;
    end

    % Did stylus move?
    if A.events(A.curr_evnum).stylus_moved == 0
        fprintf ('No movement of stylus; event latency left as %d ms\n', ...
                 A.events(A.curr_evnum).latency);
    else
        fprintf ('lt_analyse_didstylusmove: Stylus moved at time %d.\n', A.time(j));
    end

end

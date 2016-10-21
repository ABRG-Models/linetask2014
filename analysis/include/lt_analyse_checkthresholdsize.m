function A = lt_analyse_checkthresholdsize (A,stableposition_period_end)

    DIST_EVENT = 0;
    TARG_EVENT = 1;
    RTN_EVENT = 2; % Used in anti-line analysis code

    % Depending on whether this is a distractor or target event,
    % set various parameters from A:
    if (A.events(A.curr_evnum).type == TARG_EVENT || A.events(A.curr_evnum).type == RTN_EVENT)
        min_stableposition_period = A.min_stableposition_period;
        max_move_thresh = A.max_move_thresh;
        max_avg_drift_speed = A.max_avg_drift_speed;
    else
        min_stableposition_period = A.min_stableposition_period_dist;
        max_move_thresh = A.max_move_thresh_dist;
        max_avg_drift_speed = A.max_avg_drift_speed_dist;
    end

    % stableposition_period_end is the stylus position at the moment the target (or
    % distractor) changed PLUS an offset: A.stableposition_period_offset.
    stylus_initial_pos = A.stylus (stableposition_period_end);
    stableposition_period_end_initial = stableposition_period_end;
    fprintf (['lt_analyse_checkthresholdsize: ' ...
              'Passed in stableposition_period_end at time %d ms ' ...
              'stableposition_index time: %d ms pos_move_thresh for this event: %f\n'], ...
             A.time(stableposition_period_end), ...
             A.time(A.events(A.curr_evnum).stableposition_index), A.events(A.curr_evnum).pos_move_thresh);

    % If the move threshold is too large OR if the time between the
    % stylus initial position and the stableposition index is too small:
    if (A.events(A.curr_evnum).pos_move_thresh > max_move_thresh ...
        || A.time(stableposition_period_end) - A.time(A.events(A.curr_evnum).stableposition_index) < min_stableposition_period)

        % Report that we need to recompute the stableposition_period:
        if (A.events(A.curr_evnum).pos_move_thresh > max_move_thresh)
            fprintf ('Stylus not stable during initial stableposition_period, need to recompute...\n');
        elseif (A.time(stableposition_period_end) - A.time(A.events(A.curr_evnum).stableposition_index) < min_stableposition_period)
            fprintf ('Initial stableposition_period is too short, need to re-compute...\n');
        else % Both must be true
            fprintf ('Stylus not stable during too-short stableposition_period, need to re-compute...\n');
        end

        % Try previous min_stableposition_period ms of time.
        fprintf ('Trying prev. %d ms before %d to find pos_move_thresh...\n', min_stableposition_period, A.time(stableposition_period_end));


        spilookup = lookup(A.time, A.time(stableposition_period_end)-min_stableposition_period);

        if spilookup == 0
            spilookup = 1;
        end
        A.events(A.curr_evnum).stableposition_index = spilookup;

        fprintf ('Found index %d (%d ms)\n', A.events(A.curr_evnum).stableposition_index, A.time(A.events(A.curr_evnum).stableposition_index));
        % Re-compute the pos_move_thresh:
        A.events(A.curr_evnum).pos_move_thresh = ...
            std (A.stylus(A.events(A.curr_evnum).stableposition_index:stableposition_period_end)) .* A.N_SDs;

        % Fixme: What if during this period it's drifting too fast?
        % maybe the user's stylus is still moving.
        %if (A.stylus(A.events(A.curr_evnum).stableposition_index) - A.stylus(stableposition_period_end) > max_move_thresh)
        %end

        A.events(A.curr_evnum).stableposition_maxspeed = ...
            abs(max(A.stylusvel_avg(A.events(A.curr_evnum).stableposition_index:stableposition_period_end)));

        if (A.events(A.curr_evnum).pos_move_thresh > max_move_thresh)
            fprintf (['Stylus unstable over current region; trying step ' ...
                      'forward approach to finding pos_move_thresh...\n']);
            % This was the "step forward until the pos_move_thresh was
            % low enough scheme.
            stableposition_period_end = stableposition_period_end_initial;
            while (A.events(A.curr_evnum).pos_move_thresh > max_move_thresh ...
                   && A.events(A.curr_evnum).stableposition_index < stableposition_period_end)
                % Step our candidate stable position forward one index:
                A.events(A.curr_evnum).stableposition_index = ...
                    A.events(A.curr_evnum).stableposition_index + 1;
                % Re-compute the pos_move_thresh:
                A.events(A.curr_evnum).pos_move_thresh = ...
                    std (A.stylus(A.events(A.curr_evnum).stableposition_index:stableposition_period_end)) .* A.N_SDs;
                A.events(A.curr_evnum).stableposition_maxspeed = ...
                    abs(max(A.stylusvel_avg(A.events(A.curr_evnum).stableposition_index:stableposition_period_end)));
            end
        end

        % Report the stable postiion region
        fprintf ('Stable position region is from %d (%d ms) to %d (%d ms)\n', ...
                 A.stylus(A.events(A.curr_evnum).stableposition_index) , ...
                 A.time(A.events(A.curr_evnum).stableposition_index), ...
                 A.stylus(stableposition_period_end), A.time(stableposition_period_end))

        % Report the stable position average speed
        A.events(A.curr_evnum).stableposition_avgspeed ...
            = abs( (A.stylus(A.events(A.curr_evnum).stableposition_index) - A.stylus(stableposition_period_end)) ...
                   ./(A.time(A.events(A.curr_evnum).stableposition_index) - A.time(stableposition_period_end)) );

        fprintf ('stableposition_avgspeed = %f\n', A.events(A.curr_evnum).stableposition_avgspeed);

        % If pos_move_thresh (the move threshold based on the mean
        % position of the stylus - N S.Ds away from the mean) is >
        % the max allowable move threshold...
        if A.events(A.curr_evnum).pos_move_thresh > max_move_thresh
            A.events(A.curr_evnum).omit = 1;
            A.events(A.curr_evnum).omit_reason = 'Failed to find a stable stylus period before this event';

        % Is the stable position period too short?
        elseif A.time(stableposition_period_end) - A.time(A.events(A.curr_evnum).stableposition_index) < min_stableposition_period
            A.events(A.curr_evnum).omit = 1;
            A.events(A.curr_evnum).omit_reason = ['stable stylus period is too short (' ...
                                num2str(A.time(stableposition_period_end) - A.time(A.events(A.curr_evnum).stableposition_index)) 'ms)'];

        % Did the stylus drift too much during the stable period -
        % was it really stable?
        elseif (A.stylus(A.events(A.curr_evnum).stableposition_index) - A.stylus(stableposition_period_end) > max_move_thresh)
            A.events(A.curr_evnum).omit = 1;
            A.events(A.curr_evnum).omit_reason = ['Drift is too great during stable stylus period (' ...
                                num2str(A.time(stableposition_period_end) - A.time(A.events(A.curr_evnum).stableposition_index)) 'ms)'];

        % Did the stylus drift at too high a speed?
        elseif (A.events(A.curr_evnum).stableposition_avgspeed > max_avg_drift_speed)
            A.events(A.curr_evnum).omit = 1;
            A.events(A.curr_evnum).omit_reason = ['Drift is too great (avg speed) during stable stylus period (' ...
                                num2str(A.time(stableposition_period_end) - A.time(A.events(A.curr_evnum).stableposition_index)) 'ms)'];

        else
            fprintf ('Updated this event''s stableposition_index to %.2f by which time pos_move_thresh=%.2f\n', ...
                     A.events(A.curr_evnum).stableposition_index, A.events(A.curr_evnum).pos_move_thresh);
        end
        if A.events(A.curr_evnum).omit == 1
            fprintf ('Event omitted with reason: %s\n', A.events(A.curr_evnum).omit_reason);
        end
    else
        fprintf ('No need to change the stableposition_period computed in lt_analyse_latency.m, returning\n');
    end
end

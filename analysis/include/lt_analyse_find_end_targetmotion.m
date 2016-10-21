% For target type events, find the end of the motion.  This function's
% task is to add to A.endmotionindexes the index (in
% A.stylus) at which the motion has ended.
function A = lt_analyse_find_end_targetmotion (A, k)

    fprintf ('Find end of target motion...\n');
    
    % Do this by moving along until position attained and
    % stylus speed is < A.min_move_speed.
    k_orig = k;
    dest_thresh = A.events(A.curr_evnum).pos_move_thresh;
    while k <= length(A.stylusvel) ...
               && k <= length(A.stylus) ...
               && ((abs(A.stylus(k)-A.events(A.curr_evnum).destination) > dest_thresh) || abs (A.stylusvel_avg(k)) > A.min_move_speed)
        k=k+1;
    end
    % What if subject gets close, but not that close, but stays stable for
    % a long time? In that case, the previous test for end of
    % target motion will have failed, but we can require more stablity,
    % but less closeness.
    if k >= length(A.stylusvel)
        fprintf ('First attempt failed, did not stop within %d of destination\n', dest_thresh);
        k = k_orig;
        dest_thresh = 2 .* A.events(A.curr_evnum).pos_move_thresh;
        % First get "close enough" (note doubling of distance threshold):
        while ((k <= length(A.stylusvel)) && k <= length(A.stylus) ...
               && ((abs(A.stylus(k)-A.events(A.curr_evnum).destination) > dest_thresh) ...
                   || abs (A.stylusvel_avg(k)) > 0.1))
            k=k+1;
        end
        % Now make sure velocity levels off for some number of ms.
        if k < length(A.stylusvel)
            fprintf ('Good, stopped within %d of destination, vel(k)=%.2f\n', dest_thresh, A.stylusvel_avg(k));
            m = k;
            long_enough = 50; % ms
            while ((m < length(A.stylusvel)) && m < length(A.stylus) ...
                   && abs (A.stylusvel_avg(m)) <= 0.1)
                m=m+1;
            end
            fprintf ('Velocity remained low for %d indices (%d ms)\n', ...
                     m-k, A.time(m) - A.time(k));
            if A.time(m) - A.time(k) > long_enough
                % all is good; leave k unchanged.
            else
                % This didn't work either, so signal that we didn't
                % find the end by setting k to the length of stylusvel.
                k = length(A.stylusvel);
            end
        else
            fprintf ('Second attempt failed, did not stop within %d of destination\n', dest_thresh);
        end
    end
        
    if k < length(A.stylusvel)
        ntei = lt_analyse_find_next_target_event_index (A);
        if (A.curr_evnum < length(A.events) && k >= ntei)
            % Our end of motion occurred past the next target event, so fix it to
            % one index before the next event:
            k = ntei - 1;
            
            fprintf (['Warning: end of motion is at/past the next ' ...
                      'target event index at %d, so reset it to %d\n'], ntei, k);
        end
        fprintf ('Final stylusvel(k=%d)=%d abs(stylus(k)-destination)=%d\n', ...
                 k, A.stylusvel(k), abs(A.stylus(k)-A.events(A.curr_evnum).destination));

        fprintf ('motion ends at: %.2f/time: %d ms (index %d)\n', A.stylus(k), A.time(k), k);
    else
        % Force end of movement to be half way between events?
        % Probably ok, this.
        if (A.events(A.curr_evnum).number == length(A.events)) 
            % This is the last event, so say it ends on the
            % last index of all:
            k = length(A.stylus);
        else
            % Put k at the next event index
            k = A.events(A.curr_evnum+1).index;
        end
        fprintf (['Warning: No END of movement detected for event number %d' ...
                  ' - set endmotion_index to %d\n'], ...
                 A.curr_evnum, k);
    end
    
    A.events(A.curr_evnum).endmotion_index = k;    

end
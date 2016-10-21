% Simply print the header line for the event.
function rtn = lt_analyse_printevheader (A)
    fprintf ('---------------------------\nEvent number %d', A.curr_evnum);
    evstr = 'Distractor';
    if A.events(A.curr_evnum).type == 1 % TARG_EVENT
        fprintf (' (target event)\n');
        evstr = 'Target';
    elseif A.events(A.curr_evnum).type == 2 % RTN_EVENT - returning
                                            % to fixation (anti line)
        fprintf (' (return event)\n');
        evstr = 'Return';
    else % Mist be DIST_EVENT
        fprintf (' (distractor event)\n');
        evstr = 'Distractor';
    end

    appearance_time = A.time(A.events(A.curr_evnum).index+1);
    fprintf ('%s position: %d px, appearance time = %d ms at index %d\n', ...
             evstr, A.events(A.curr_evnum).destination, appearance_time, ...
             A.events(A.curr_evnum).index+1);
end
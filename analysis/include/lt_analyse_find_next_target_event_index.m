% Starting at index k (indexing into stylus, target etc), find the
% next target type event.
function [next_target_idx, next_target_num] = lt_analyse_find_next_target_event_index (A)
    fprintf ('Look for next target after event number %d...\n', A.curr_evnum); 
    eventnumber = A.curr_evnum;
    while (eventnumber < length (A.events))
        eventnumber = eventnumber + 1;
        %fprintf ('Event %d is at index %d, has evtype %d\n', ...
        %         eventnumber, A.events(eventnumber).index, ...
        %         A.events(eventnumber).type);
        if A.events(eventnumber).type == 1
            % Then it's the target
            fprintf ('Event %d is the next target.\n', eventnumber);
            break;
        end
    end
    next_target_idx = A.events(eventnumber).index;
    next_target_num = A.events(eventnumber).number;
end

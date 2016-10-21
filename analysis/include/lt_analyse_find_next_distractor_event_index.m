% Starting at index k (indexing into stylus, target etc), find the
% next distractor type event.
function [next_distractor_idx, next_distractor_num] = lt_analyse_find_next_distractor_event_index (A)
    fprintf ('Look for next distractor after event number %d...\n', A.curr_evnum);
    eventnumber = A.curr_evnum;
    while (eventnumber < length (A.events))
        eventnumber = eventnumber + 1;
        if A.events(eventnumber).type == 0
            % Then it's the target
            fprintf ('Event %d is the next distractor.\n', eventnumber);
            break;
        end
    end
    next_distractor_idx = A.events(eventnumber).index;
    next_distractor_num = A.events(eventnumber).number;
end

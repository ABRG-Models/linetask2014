function current_endmotion = lt_analyse_find_prev_target_endmotion (A)
    current_endmotion = 0;
    evnum = A.curr_evnum-1;
    if evnum == 0
        % A.curr_evnum is already the first event.
        current_endmotion = 1;
        return
    end
    
    while current_endmotion == 0
        if (A.events(evnum).type == 1)
            %fprintf ('Event %d is a target\n', evnum);
            current_endmotion = A.events(evnum).endmotion_index;
        else
            %fprintf ('Event %d is a distractor\n', evnum);
            evnum = evnum - 1;
            if evnum == 0
                fprintf ('No previous target endmotion index\n');
                current_endmotion = 1;
            end
        end
    end
    fprintf ('Returning prev target endmotion = %d\n', current_endmotion);
end

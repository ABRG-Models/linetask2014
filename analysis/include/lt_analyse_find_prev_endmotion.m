function current_endmotion = lt_analyse_find_prev_endmotion (A)
    if A.curr_evnum == 1
        current_endmotion = A.events(A.curr_evnum).startmotion_index;
    else
        current_endmotion = A.events(A.curr_evnum-1).endmotion_index;
    end
end

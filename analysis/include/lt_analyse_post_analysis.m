% This collects together relevane results from A.events adn returns
% them in various arrays that can be plotted or saved and handled
% by further analysis.
function R = lt_analyse_post_analysis (A)

    % #defines
    DIST_EVENT = 0;
    TARG_EVENT = 1;

    % Now build the return information.
    R = struct();
    R.events = [];
    R.latency = [];
    R.latency_error = [];
    R.latency_noerror = [];
    R.firstmotion_distance = [];
    R.errors = [];
    R.omissions = [];

    for ev = A.events
        % A full event list
        R.events = [R.events; ev.number, ev.type];
        oreas = 0;
        % All latencies, plus some information about event omission.
        if ev.omit == 1
            % Use ev.omit_reason to create a numeric code to
            % include in

            matchstr = 'target movement insignificant';
            matchid = 1;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'target movement of'; % ...duration
            matchid = 2;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'target movement ('; % smaller than min jump size
            matchid = 3;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Previous event stable'; %...position_index
                                                % > current event onset
            matchid = 4;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Counting same motion as distraction'; % due
                                                              % to
                                                              % another event
            matchid = 5;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Not moving towards distractor';
            matchid = 6;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Too fast (targ)';
            matchid = 7;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Too fast (distr)';
            matchid = 8;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'No movement detected';
            matchid = 9;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Failed to find a'; % stable stylus position
            matchid = 10;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'stable stylus period is too short';
            matchid = 11;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Drift is too great during stable';
            matchid = 12;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Drift is too great (avg';
            matchid = 13;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Stylus moving at event onset';
            matchid = 14;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Stylus didn''t move away from target';
            matchid = 15;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Movement occurs beyond next target';
            matchid = 16;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Subject was distracted by closely previous distractor';
            matchid = 17;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Incorrect move recorded in previous distractor event';
            matchid = 18;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'This distractor event did not distract the stylus movement';
            matchid = 19;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            matchstr = 'Recorded this stylus movement as a distraction towards the next distractor';
            matchid = 20;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end

            % Used in 2016 antiline expt
            matchstr = 'Fixations omitted';
            matchid = 21;
            if length(ev.omit_reason) >= length(matchstr) && strcmp(matchstr,substr(ev.omit_reason,1,length(matchstr)))
                oreas = matchid;
            end
        end

        R.latency = [R.latency; ev.number, ev.type, ev.error, ev.correct_move, ev.latency, ev.omit, oreas, ev.time_since_last, ev.direction, ev.destination];
        % All error latencies
        if ev.omit == 0 && ev.error == 1
            R.latency_error = [R.latency_error; ev.number, ev.type, ev.error, ev.correct_move, ev.latency, ev.time_since_last, ev.direction, ev.destination];
        end
        % All non-error latencies
        if ev.omit == 0 && ev.error == 0
            R.latency_noerror = [R.latency_noerror; ev.number, ev.type, ev.error, ev.correct_move, ev.latency, ev.time_since_last, ev.direction, ev.destination];
        end
        % First motion distances
        if ev.omit == 0 && ev.type == 1 && ev.error == 0
            R.firstmotion_distance = [R.firstmotion_distance; ...
                                ev.number, ev.firstmotion_distance_travelled, ev.firstmotion_distance_to_go, ev.firstmotion_distance_travelled+ev.firstmotion_distance_to_go];
        end
        % Information about targets with movement errors
        if ev.omit == 0
            er_struct = struct();
            er_struct.number = ev.number;
            er_struct.type = ev.type;
            er_struct.error = ev.error;
            er_struct.errordesc = ev.errordesc;
            R.errors = [ R.errors; er_struct ];
        end
        % Information about any event omission
        if ev.omit == 1
            om_struct = struct();
            om_struct.number = ev.number;
            om_struct.type = ev.type;
            om_struct.omit = ev.omit;
            om_struct.omit_reason = ev.omit_reason;
            R.omissions = [ R.omissions, om_struct ];
        end
    end
    display('1');
    % Find all rows in R.latency_noerror which have a 1 in column 2
    % (1 signified that the type is TARG_EVENT; 0 is DIST_EVENT)
    if ~isempty(R.latency_noerror)
        R.latency_noerror_target = R.latency_noerror(find(R.latency_noerror(:,2) == TARG_EVENT),:);
        % And similarly:
        R.latency_noerror_distractor = R.latency_noerror(find(R.latency_noerror(:,2) == DIST_EVENT),:);
    else
        R.latency_noerror_target = [];
        R.latency_noerror_distractor = [];
    end
    if ~isempty(R.latency_error)
        R.latency_error_target = R.latency_error(find(R.latency_error(:,2) == TARG_EVENT),:);
        R.latency_error_distractor = R.latency_error(find(R.latency_error(:,2) == DIST_EVENT),:);
    else
        R.latency_error_target = [];
        R.latency_error_distractor = [];
    end
end

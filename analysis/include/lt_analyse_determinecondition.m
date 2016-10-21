% Use the target/distractor jump data to determine the experimental
% condition. might be better to use the param data than this.
function analysis = lt_analyse_determinecondition (analysis)
    % Get the directions only:
    tj = (analysis.targjumps>0) + (analysis.targjumps<0);
    dj = (analysis.distractjumps>0) + (analysis.distractjumps<0);

    analysis.expt_condition = '';
    % if tj is 0, then it's no distractor
    if sum(analysis.distractjumps) == 0
        analysis.expt_condition = 'No Distractor';
    else
        if (abs(sum(tj) - sum(dj)) < 3) % This allows for 2 instances
                                        % where the target jumps a
                                        % distance, but the distractor
                                        % jumps zero distance which CAN
                                        % happen in synchronous mode.
                                        % Then this is the synchronous condition.
            analysis.expt_condition = 'Synchronous Distractor';
        else
            % async.
            analysis.expt_condition = 'Asynchronous Distractor';
        end
    end
end

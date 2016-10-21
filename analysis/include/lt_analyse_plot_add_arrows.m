% Add the arrows to the time series plot to show where the analysis
% thought the various features occurred. i.e. Switch back to first
% figure and show the calculated latencies so that they can be
% "eyeballed" to see if there are any problems.
function rtn = lt_analyse_plot_add_arrows (A, f1s1)

    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

    % #defines
    DIST_EVENT = 0;
    TARG_EVENT = 1;

    figure(1);

    for ev = A.events

        %fprintf ('Plotting arrows for event %d\n', ev.number);

        % arrowpos is the vertical position at which we'll draw the
        % latency/motion arrows.
        i = ev.index;
        arrowpos = A.stylus(i) + 1;
        % spos is the actual vertical stylus position at the event.
        spos = A.stylus(i);
        % Start of stable position period
        spperiod_idx = ev.stableposition_index;
        % What is the size of one SD of the stylus position in the
        % stable position period?
        one_sd = ev.pos_move_thresh ./ A.N_SDs;
        % Mean stable position

        spperiod_data = A.stylus(spperiod_idx:i);
        if (~isempty(spperiod_data))
            meanspos = mean (spperiod_data);
        else
            % Stable position started AFTER event so fix meanspos:
            meanspos = A.stylus(i);
            %fprintf ('Stable position occurs after event; set meanspos to %d\n', meanspos);
        end

        if ev.omit ~= 1 && ev.type == TARG_EVENT

            % Add the time to motion complete first so it's at the bottom
            if (ev.number == length(A.events))
                % Last one had no endmotionindex, so go to end
                h = plot (f1s1, [A.time(ev.endfirstmotion_index) A.time(length(A.time))], [arrowpos arrowpos]);
            else
                h = plot (f1s1, [A.time(ev.endfirstmotion_index) A.time(ev.endmotion_index)], [arrowpos arrowpos]);
            end
            set (h, 'color', 'black', 'linestyle', ':', 'marker', '>','linewidth', A.line_width_wide);
            if A.show_vert_lines
                % A vertical dotted line:
                h = plot (f1s1, [ A.time(ev.endmotion_index) A.time(ev.endmotion_index)], ...
                          [arrowpos A.stylus(ev.endmotion_index)]);
                set (h, 'color', 'black', 'linestyle', ':', 'linewidth',  A.line_width_narrow);
            end
            % And the time to the end of the very first motion:
            h = plot (f1s1, [A.time(i+1)+ev.latency A.time(ev.endfirstmotion_index)], [arrowpos arrowpos]);
            set (h, 'color', 'black', 'linestyle', '--', 'marker', '>', 'linewidth', A.line_width_wide);
            if A.show_vert_lines
                % vert dotted line:
                h = plot (f1s1, [ A.time(ev.endfirstmotion_index) A.time(ev.endfirstmotion_index)], ...
                          [arrowpos A.stylus(ev.endfirstmotion_index)]);
                set (h, 'color', 'black', 'linestyle', ':', 'linewidth',  A.line_width_narrow);
            end
            % Plot the time to motion start last so it goes on top
            h = plot (f1s1, [A.time(i+1) A.time(i+1)+ev.latency], [arrowpos arrowpos]);
            set (h, 'color', 'green', 'linestyle', '-', 'marker', '>','linewidth',  A.line_width_wide);

        elseif ev.type == TARG_EVENT
            % fprintf ('Not plotting event %d, which was omitted, but add firstmotion info if available...\n', ev.number);
            % fprintf ('Plotting; omitted endfirstmotion_index=%d, time=%d-%d for event num %d\n', ...
            %          ev.endfirstmotion_index, A.time(i+1)+ev.latency, A.time(ev.endfirstmotion_index), ev.number);
            h = plot (f1s1, [A.time(i+1)+ev.latency A.time(ev.endfirstmotion_index)], [arrowpos arrowpos]);
            set (h, 'color', 'black', 'linestyle', ':', 'marker', '>', 'linewidth',  A.line_width_wide);
            if A.show_vert_lines
                % SHOW vert dotted line:
                h = plot (f1s1, [ A.time(ev.endfirstmotion_index) A.time(ev.endfirstmotion_index)], ...
                          [arrowpos A.stylus(ev.endfirstmotion_index)]);
                set (h, 'color', 'black', 'linestyle', ':', 'linewidth',  A.line_width_narrow);
            end
        end

        if (A.show_stable_stylus_lines && (ev.omit ~= 1 && ev.type == TARG_EVENT) || (ev.type == DIST_EVENT && ev.error == 1))
            % Add stable stylus position period here.
            h = plot (f1s1, [A.time(spperiod_idx), A.time(i)], [meanspos+ev.pos_move_thresh, meanspos+ev.pos_move_thresh]);
            set (h, 'color', 'blue', 'linestyle', '--', 'linewidth',  A.line_width_wide);
            h = plot (f1s1, [A.time(spperiod_idx), A.time(i)], [meanspos+one_sd, meanspos+one_sd]);
            set (h, 'color', 'blue', 'linestyle', '-.', 'linewidth',  A.line_width_wide);
            h = plot (f1s1, [A.time(spperiod_idx), A.time(i)], [meanspos, meanspos]);
            set (h, 'color', 'blue', 'linestyle', '-', 'linewidth',  A.line_width_wide);
            h = plot (f1s1, [A.time(spperiod_idx), A.time(i)], [meanspos-one_sd, meanspos-one_sd]);
            set (h, 'color', 'blue', 'linestyle', '-.', 'linewidth',  A.line_width_wide);
            h = plot (f1s1, [A.time(spperiod_idx), A.time(i)], [meanspos-ev.pos_move_thresh, meanspos-ev.pos_move_thresh]);
            set (h, 'color', 'blue', 'linestyle', '--', 'linewidth',  A.line_width_wide);
        end

        % Last, add the event number
        if (isOctave)
            if (ev.type == 1)
                text (A.time(i+1), arrowpos+A.event_number_text_offset, num2str(ev.number), 'color', 'cyan');
            else
                text (A.time(i+1), arrowpos+A.event_number_text_offset, num2str(ev.number), 'color', 'red');
            end
        else
            % The text objects don't work very well in matlab, so
            % omit them.
            fprintf ('Sorry, can''t show text objects on MATLAB plots\n');
        end
    end % for

    % Numerous choices for the legend now...
    if A.show_vert_lines
        if A.show_stable_stylus_lines
            legend ('stylus', 'target', 'distractor', 'full motion', 'vert line', 'first motion', 'vert line', 'latency', 'move threshold', '1 SD', 'mean pre-event posn');
        else
            legend ('stylus', 'target', 'distractor', 'full motion', 'vert line', 'first motion', 'vert line', 'latency');
        end
    else
        if A.show_stable_stylus_lines
            legend ('stylus', 'target', 'distractor', 'full motion', 'first motion', 'latency', 'move threshold', '1 SD', 'mean pre-event posn');
        else
            legend ('stylus', 'target', 'distractor', 'full motion', 'first motion');
        end
    end
    %    legend('boxoff');


end

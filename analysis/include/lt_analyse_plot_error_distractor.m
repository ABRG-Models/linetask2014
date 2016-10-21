function rtn = lt_analyse_plot_error_distractor (A, R)
    if isempty(R.latency_error_distractor)
        fprintf ('No latencies for movement errors to graph.\n');
        return;
    end

    % Plot incorrect-direction latencies.
    latency_mean = mean(R.latency_error_distractor(:,5));
    mean_str = ['Mean = ' num2str(latency_mean) ' ms'];
    latency_std = std(R.latency_error_distractor(:,5));
    std_str = ['SD = ' num2str(latency_std) ' ms'];
    direction_ei = [];
    for evi = R.latency_error_distractor(:,1)
        direction_ei = [direction_ei, ...
                        A.events(evi).direction];
    end

    numpoints = length(R.latency_error_distractor(:,1))
    if numpoints > 0
        figure(5);
        clf;
        hold on;
        fprintf ('Plotting latencies for distractor movement errors...\n');
        h = plot (R.latency_error_distractor(:,1), R.latency_error_distractor(:,5));
        set (h, 'color', 'green', 'linestyle', '-', 'marker', 'o', 'linewidth', 2);
        R.latency_error_distractor(:,1)
        h = plot (R.latency_error_distractor(:,1), latency_mean.*ones(numpoints), 'r--');
        set (h, 'color', 'red', 'linestyle', '--', 'linewidth', 2);
        h = errorbar (max(R.latency_error_distractor(:,1)), latency_mean, latency_std, '~');
        set (h, 'color', 'blue', 'linewidth', 2);
        xlabel ('event number');
        ylabel ('latency to incorrect motion (to distractor) (ms)');
        legend ('latency', mean_str, std_str);
        title (['latency vs. distracted motion event (chronological) [' A.expt_condition ']']);
        omitted_s = sprintf ('Omitted events: all correct direction events, any target events');
        text (numpoints./2, latency_mean+latency_std, omitted_s);
    else
        fprintf ('No valid distracted movement latencies are available to plot.\n');
    end
end

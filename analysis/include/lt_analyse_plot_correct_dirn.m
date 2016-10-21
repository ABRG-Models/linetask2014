% Plot the correct-direction latencies
function rtn = lt_analyse_plot_correct_dirn (A, R)

% Note: latency tables in R have the following cols:
% evnum,evtype,error,correctmove,latency
    
    if isempty(R.latency_noerror_target)
        fprintf ('No correct dirn latencies to graph.\n');
        return;
    end

    latency_mean = mean(R.latency_noerror_target(:,5));
    mean_str = ['Mean = ' num2str(latency_mean) ' ms'];
    latency_std = std(R.latency_noerror_target(:,5));
    std_str = ['SD = ' num2str(latency_std) ' ms'];
    direction_ei = [];
    for evi = R.latency_noerror_target(:,1)
        direction_ei = [direction_ei, A.events(evi).direction];
    end
    numpoints = length(R.latency_noerror_target(:,1));
    if numpoints > 0
        figure(2);
        clf;
        hold on;
        h = plot (R.latency_noerror_target(:,1), R.latency_noerror_target(:,5), 'go-');
        set (h, 'linewidth', 2);
        hhh = plot (R.latency_noerror_target(:,1), latency_mean.* ones(numpoints), 'r--');
        set (hhh, 'linewidth', 2);
        hh = errorbar (numpoints, latency_mean, latency_std);
        set (hh, 'color', 'blue', 'linewidth', 2);
        %h = errorbar (numpoints./2, latency_mean, latency_sem);
        %set (h, 'color', 'green');
        xlabel ('event number');
        ylabel ('latency (ms)');
        legend ('latency', mean_str, std_str);
        title (['latency vs. target event (chronological) [' A.expt_condition ']']);
        outliers_s = '-';
        incorr_s = '-';
        %if (~isempty(r_latency_outliers))
        %    outliers_s = num2str(r_latency_outliers(:,1)');
        %end
        if (~isempty(R.latency_error_target))
            incorr_s = num2str(R.latency_error_target(:,1)');
        end
        omitted_s = '';
        for ev = A.events
            if ev.omit == 1
                omitted_s = [ omitted_s ' ' num2str(ev.number)];
            end
        end
        omitted_s = sprintf ('Incorrect move: %s\nOmitted: %s', incorr_s, omitted_s);
        text (numpoints./2, latency_mean-1.5.*latency_std, omitted_s);

        figure(3);
        clf;
        hold on;
        h = plot (direction_ei, R.latency_noerror_target(:,5), 'go');
        set (h, 'color', 'green', 'marker', 'o', 'linewidth', 2);
        h = plot ([ min(direction_ei) max(direction_ei) ], [ latency_mean latency_mean ]);
        set (h, 'color', 'red', 'linestyle', '--', 'linewidth', 2);
        h = errorbar (max(direction_ei), latency_mean, latency_std);
        set (h, 'linewidth', 2);
        xlabel ('jump length');
        ylabel ('latency (ms)');
        legend ('latency', mean_str, std_str);
        title (['latency vs. target jump size [' A.expt_condition ']']);
        text (numpoints./2, latency_mean-1.5.*latency_std, omitted_s);
    else
        fprintf ('No valid correct-direction movement latencies to plot.\n');
    end
end

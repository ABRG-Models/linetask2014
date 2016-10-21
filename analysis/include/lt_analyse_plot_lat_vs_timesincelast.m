% Plot the latencies vs time-since-last-event
function rtn = lt_analyse_plot_lat_vs_timesincelast (A, R)

% Note: latency tables in R have the following cols:
% evnum,evtype,error,correctmove,latency

    if isempty(R.latency)
        fprintf ('No latencies to graph.\n');
        return;
    end

    figure(22);
    clf;
    hold on;
    h = plot (R.latency_error_distractor(:,6), R.latency_error_distractor(:,5), 'go');
    set (h, 'linewidth', 2);
    h = plot (R.latency_noerror_target(:,6), R.latency_noerror_target(:,5), 'bo');
    xlabel('Time since last event (ms)');
    ylabel('Latency (ms)');
    legend('Distractor movements (errors)','Target movements (non-errors)');
end

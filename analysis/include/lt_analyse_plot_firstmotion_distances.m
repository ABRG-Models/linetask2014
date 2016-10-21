function rtn = lt_analyse_plot_firstmotion_distances (A, R)
    if isempty(R.firstmotion_distance)
        fprintf ('No firstmotion distance info to graph.\n');
        return;
    end

    % Plot first motion distances
    
    direction_ei = [];
    for evi = R.firstmotion_distance(:,1)
        direction_ei = [direction_ei, ...
                        A.events(evi).direction];
    end

    numpoints = length(R.firstmotion_distance(:,1))
    if numpoints > 0
        % distance travelled
        dt_mean = mean(abs(R.firstmotion_distance(:,2)));
        dt_mean_str = ['Mean = ' num2str(dt_mean) ' px'];
        dt_std = std(abs(R.firstmotion_distance(:,2)));
        dt_std_str = ['SD = ' num2str(dt_std) ' px'];

        % distance to go
        dtg_mean = mean(abs(R.firstmotion_distance(:,3)));
        dtg_mean_str = ['Mean = ' num2str(dtg_mean) ' px'];
        dtg_std = std(abs(R.firstmotion_distance(:,3)));
        dtg_std_str = ['SD = ' num2str(dtg_std) ' px'];

        figure(6);
        clf;
        hold on;
        fprintf ('Plotting target motion distances in pixels...\n');

        h = plot (R.firstmotion_distance(:,1), abs(R.firstmotion_distance(:,2)) );
        set (h, 'color', 'green', 'linestyle', '-', 'marker', 'o', 'linewidth', 2);
        h = plot (R.firstmotion_distance(:,1), dt_mean.*ones(numpoints), 'r--');
        set (h, 'color', 'red', 'linestyle', '--', 'linewidth', 2);
        h = errorbar (max(R.firstmotion_distance(:,1)), dt_mean, dt_std, '~');
        set (h, 'color', 'blue', 'linewidth', 2);

        h = plot (R.firstmotion_distance(:,1), abs(R.firstmotion_distance(:,3)));
        set (h, 'color', 'black', 'linestyle', '-', 'marker', 'o', 'linewidth', 2);
        h = plot (R.firstmotion_distance(:,1), dtg_mean.*ones(numpoints), 'r--');
        set (h, 'color', 'red', 'linestyle', '--', 'linewidth', 2);
        h = errorbar (max(R.firstmotion_distance(:,1)-1), dtg_mean, dtg_std, '~');
        set (h, 'color', 'blue', 'linewidth', 2);
        
        xlabel ('event number');
        ylabel ('Distance (px)');
        legend ('distance travelled', dt_mean_str, dt_std_str, 'distance to go', dtg_mean_str, dtg_std_str);
        title (['firstmotion distances vs. motion event (chronological) [' A.expt_condition ']']);
        omitted_s = sprintf ('Omitted events: any distractor events');
        text (numpoints./2, dt_mean+dt_std, omitted_s);
    
        % distance travelled
        dt_mean = mean(abs(R.firstmotion_distance(:,2))./abs(direction_ei)');
        dt_mean_str = ['Mean = ' num2str(dt_mean)];
        dt_std = std(abs(R.firstmotion_distance(:,2))./abs(direction_ei)');
        dt_std_str = ['SD = ' num2str(dt_std)];

        % distance to go
        dtg_mean = mean(abs(R.firstmotion_distance(:,3))./abs(direction_ei)');
        dtg_mean_str = ['Mean = ' num2str(dtg_mean)];
        dtg_std = std(abs(R.firstmotion_distance(:,3))./abs(direction_ei)');
        dtg_std_str = ['SD = ' num2str(dtg_std)];

        figure(7);
        clf;
        hold on;
        fprintf ('Plotting target motion distances as proportion of target move...\n');

        h = plot (R.firstmotion_distance(:,1), abs(R.firstmotion_distance(:,2))./abs(direction_ei)');
        set (h, 'color', 'green', 'linestyle', '-', 'marker', 'o', 'linewidth', 2);
        h = plot (R.firstmotion_distance(:,1), dt_mean.*ones(numpoints), 'r--');
        set (h, 'color', 'red', 'linestyle', '--', 'linewidth', 2);
        h = errorbar (max(R.firstmotion_distance(:,1)), dt_mean, dt_std, '~');
        set (h, 'color', 'blue', 'linewidth', 2);

        h = plot (R.firstmotion_distance(:,1), abs(R.firstmotion_distance(:,3))./abs(direction_ei)');
        set (h, 'color', 'black', 'linestyle', '-', 'marker', 'o', 'linewidth', 2);
        h = plot (R.firstmotion_distance(:,1), dtg_mean.*ones(numpoints), 'r--');
        set (h, 'color', 'red', 'linestyle', '--', 'linewidth', 2);
        h = errorbar (max(R.firstmotion_distance(:,1)-1), dtg_mean, dtg_std, '~');
        set (h, 'color', 'blue', 'linewidth', 2);
        
        xlabel ('event number');
        ylabel ('Distance (proportion)');
        legend ('distance travelled', dt_mean_str, dt_std_str, 'distance to go', dtg_mean_str, dtg_std_str);
        title (['firstmotion distances vs. motion event (chronological) [' A.expt_condition ']']);
        omitted_s = sprintf ('Omitted events: any distractor events');
        text (numpoints./2, dt_mean+dt_std, omitted_s);
    else
        fprintf ('No valid firstmotion information is available to plot.\n');
    end
end

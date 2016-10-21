% Plot the raw velocity data.
function rtn = lt_analyse_plotvelocity (A)
    figure (10);
    clf;
    hold on;
    h = plot (A.time, A.targjumps./max(abs(A.targjumps)), 'b-');
    set (h, 'color', 'cyan', 'linewidth', 2);
    h = plot (A.time, A.stylusvel, 'b-');
    set (h, 'color', 'blue', 'linewidth', 2);
    h = plot (A.time, A.stylusvel_avg, 'g-');
    set (h, 'color', 'green', 'linewidth', 2);
    h = plot (A.time, A.stylusvel_avg_slow, 'k--');
    set (h, 'color', 'black', 'linewidth', 2);
    h = plot (A.time, A.stylus_accel, 'r-');
    set (h, 'color', 'red', 'linewidth', 2);
    h = plot (A.time, A.stylus_accel_avg, 'r--');
    set (h, 'color', 'red', 'linewidth', 2);
    legend ('target vel (normalised)','vel (instantaneous)', ...
            'vel (moving avg)','vel (slow moving avg)','accel','accel (slow)');
    xlabel ('time (ms)');
    ylabel ('position change (px per ms)');
end

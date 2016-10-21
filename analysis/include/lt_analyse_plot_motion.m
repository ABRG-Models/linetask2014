% Graph the motion of the target, stylus and distractor on fig
% 1. Return handle to the subplot on which the plot is made.
function f1s1 = lt_analyse_plot_motion (A)

    htop = figure (1);
    set (htop, 'defaulttextfontsize', 18);
    set (htop, 'defaultaxesfontsize', 18);
    % I can't get ttf font selection to work.
    %set (htop, 'defaulttextfontname', '/usr/share/fonts/truetype/ttf-bitstream-vera/VeraIt.ttf');
    %set (htop, 'defaultaxesfontname', '/usr/share/fonts/truetype/ttf-bitstream-vera/VeraIt.ttf');

    clf;
    f1s1 = subplot (1,1,1); % f1s1: figure 1, subplot 1

    hold on;

    h = plot (A.time, A.stylus, 'k.-');  % stylus position
    set (h, 'color', 'black', 'linewidth', A.line_width_wide);
    h = plot (A.time, A.target, 'g-');   % target position
    set (h, 'color', 'cyan', 'linewidth', A.line_width_wide);

    if isfield(A,'distract')
        h = plot (A.time, A.distract, 'r:'); % distractor
                                             % position
        set (h, 'linewidth', A.line_width_wide);
        legend ('stylus','target','distractor');
    else
        legend ('stylus','target');
    end

    show_velocity = 0;
    if show_velocity == 1
        h = plot (A.time, 1000+(500.*A.svel_real), 'g--'); % vel
        set (h, 'linewidth', A.line_width_wide);
        if isfield(A,'distract')
            legend ('stylus','target','distractor','vel');
        else
            legend ('stylus','target','vel');
        end
    end

    xlabel ('time (ms)');
    ylabel ('position (px)');

    % Print the filepath as a title to this graph
    offset = length(A.file_path);
    if (offset > 40)
        offset = offset - 40;
    else
        offset = 1;
    end
    tstr = ['...' A.file_path(offset:end) ' [' A.expt_condition ']'];
    title (tstr);
end

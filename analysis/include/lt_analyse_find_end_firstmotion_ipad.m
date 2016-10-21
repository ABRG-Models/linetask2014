% Do a velocity based analysis to find the end of the first
% uncorrected movement of the stylus.
function motionend = lt_analyse_find_end_firstmotion_ipad (x, vel, graph)
%dx = abs(diff(x)); % Note abs - make it look like it's in one
                       % direction only
    dx = abs(vel);
    if graph == 1
        figure(57); clf; plot (x, 'ro-'); hold on; plot (abs(x), 'bo-'); title('x');
        figure(58); hold off; plot (dx, 'bo-'); title('dx');
    end
    ddx = diff(dx);
    if graph == 1
        figure(58); hold on; plot (ddx, 'co-');
    end
    window = 3; % This is different for the ipad version
    ddx = filter (ones(window,1)/window, 1, ddx);

    if graph == 1
        figure(58); hold on; plot (ddx, 'ro-'); title('ddx + dx');
        figure(59); plot (ddx, 'ro-'); title('ddx');
    end

    % Start looking for the end of the movement by finding the
    % peak velocity of the first movement:
    maxvel_iter = min(find (ddx < 0));
    fprintf ('the maxvel_iter=%f\n', maxvel_iter);
    if (isempty(maxvel_iter))
        motionend = [];
    else
        %fprintf ('Find end motion...\n');
        % Find the end of the motion, which is the point where the
        % velocity has dropped to its next local minimum.
        motionend = min(find (ddx(maxvel_iter:end) > 0))
        if isempty(motionend)
            %fprintf ('tis empty\n');
            motionend = length(ddx);
        else
            motionend = motionend + maxvel_iter;
        end
        fprintf('the motionend=%d\n', motionend);
    end

    if (isempty(motionend))
        motionend = 1;
    end
end

% Do a velocity based analysis to find the end of the first
% uncorrected movement of the stylus.
function motionend = lt_analyse_find_end_firstmotion (x, vel, graph)
%dx = abs(diff(x)); % Note abs - make it look like it's in one
                       % direction only
    dx = abs(vel);
    if graph == 1
        figure(57); clf; plot (x, 'ro-'); hold on; plot (abs(x), 'bo-'); title('x');
        figure(58); plot (dx, 'bo-'); title('dx');
    end
    ddx = diff(dx);
    window = 20;
    ddx = filter (ones(window,1)/window, 1, ddx);

    if graph == 1
        figure(59); plot (ddx, 'bo-'); title('ddx');
    end

    % Start looking for the end of the movement by finding the
    % peak velocity of the first movement:
    maxvel_iter = min(find (ddx < 0));
    fprintf ('maxvel_iter=%f\n', maxvel_iter);
    if (isempty(maxvel_iter))
        motionend = [];
    else
        % Find the end of the motion, which is the point where the
        % velocity has dropped to its next local minimum.
        motionend = min(find (ddx(maxvel_iter:end) > 0));

        % Old way:
        %fprintf ('Find where velocity drops from max of %f to below %f\n', ...
        %         dx(maxvel_iter), dx(maxvel_iter).*0.1);
        %motionend = min (find (dx(maxvel_iter:end)< ...
        %                       (dx(maxvel_iter).*0.1)))

        motionend = motionend + maxvel_iter;
        fprintf('motionend=%d\n', motionend);
    end

    if (isempty(motionend))
        motionend = 1;
    end
end

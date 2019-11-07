function akZoom(h_ax)

wheel_zoomFactor = 30; % default: 20
h_fig              = get(h_ax, 'Parent');
double_left_click  = 'open'; %pan with wheel button while presed
pan_button         = 'normal'; %pan with left button while presed
cx = []; cy = []; mode = '';
zoom(h_fig, 'off')
pan(h_fig, 'off')
set(h_fig,'WindowScrollWheelFcn' , @scroll_zoom,...
    'WindowButtonDownFcn'  , @MouseDown,...
    'WindowButtonUpFcn'    , @MouseUp,...
    'WindowButtonMotionFcn', @MouseMotion);

    function scroll_zoom(varargin)
        h = hittest(gcf);
        if isempty(h), return, end
        switch get(h,'Type')
            case 'axes'
                currAx = h;
            case 'image'
                currAx = get(h,'Parent');
            case 'line'
                currAx = get(h,'Parent');
            case 'patch'
                currAx = get(h,'Parent');
            otherwise
                return
        end
        if ~any(currAx == h_ax), return, end
        [x,y] = getAbsCoords(currAx);
        if ~coordsWithinLimits(currAx,x,y), return, end
        [x_rel, y_rel] = abs2relCoords(currAx, x, y);
        sc = varargin{2}.VerticalScrollCount;
        zoomFactor = abs(sc)*(1+wheel_zoomFactor/100)^sign(sc);
        if zoomFactor ~= 0 % could happen when fast scrolling
            new_xlim_rel = ([0,1] - x_rel) * zoomFactor + x_rel;
            new_ylim_rel = ([0,1] - y_rel) * zoomFactor + y_rel;
            [new_xlim(1) new_ylim(1)] = rel2absCoords(h_ax, new_xlim_rel(1), new_ylim_rel(1)); %#ok<*NCOMMA>
            [new_xlim(2) new_ylim(2)] = rel2absCoords(h_ax, new_xlim_rel(2), new_ylim_rel(2));
            set(h_ax, 'Xlim', new_xlim);
            set(h_ax, 'Ylim', new_ylim);
        end
        
        % dec2dm
        setTickLabel(h_ax);
        
    end

    function MouseDown(varargin)
        currAx = h_ax( get(gcf, 'currentaxes') == h_ax);
        if isempty(currAx), return, end %return if the current axis is not one of the axes in h_ax
        if cursorOverOtherObject, return, end %return if the cursor is above any other object (e.g. a legend)
        
        mode = '';
        [x, y] = getAbsCoords(currAx);
        if ~coordsWithinLimits(currAx,x,y), return, end
        % save clicked coordinates to cx and cy
        cx = x;   cy = y;
        switch lower(get(gcf, 'selectiontype'))
            case pan_button
                mode = 'pan';
            case double_left_click
                set(h_ax, ...
                    'Xlim', mean(h_ax.XLim)+0.7*[-diff(h_ax.XLim)/2 diff(h_ax.XLim)/2], ...
                    'Ylim', mean(h_ax.YLim)+0.7*[-diff(h_ax.YLim)/2 diff(h_ax.YLim)/2]);
                
        end
        
        % dec2dm
        setTickLabel(h_ax);
        
    end

    function MouseUp(varargin)
        currAx = h_ax( get(gcf, 'currentaxes') == h_ax);
        if isempty(currAx), return, end %return if the current axis is not one of the axes specified in h_ax
        mode = '';
        cx = [];
        cy = [];
        set(gcf,'selected','on')
       
    end

    function MouseMotion(varargin)
        currAx = h_ax;
        [x,y] = getAbsCoords(currAx);
        tf = coordsWithinLimits(h_ax, x, y);
        if tf
            title(h_ax,sprintf('%5.3f , %5.3f',x,y),'visible','on','fontsize',8,'fontweight','normal')
        else
            title(h_ax,'','visible','off')
        end
        
        if strcmp(mode, 'pan')
            if ~coordsWithinLimits(currAx,x,y), return, end %return if we are outside of limits
            % calc change in position
            [x_rel, y_rel]   = abs2relCoords(currAx, x, y);
            [cx_rel, cy_rel] = abs2relCoords(currAx, cx, cy);
            delta_x_rel = x_rel - cx_rel;
            delta_y_rel = y_rel - cy_rel;
            % set new limits
            [new_xlim(1) new_ylim(1)] = rel2absCoords(h_ax, -delta_x_rel, -delta_y_rel);
            [new_xlim(2) new_ylim(2)] = rel2absCoords(h_ax, 1-delta_x_rel, 1-delta_y_rel);
            set(h_ax, 'Xlim', new_xlim);
            set(h_ax, 'Ylim', new_ylim);
            setTickLabel(h_ax);
         
            % save new position
            [cx,cy] = getAbsCoords(currAx);
        else
            return;
        end
    end

    function [x, y] = getAbsCoords(h_ax)
        crd = get(h_ax, 'CurrentPoint');
        x = crd(2,1);
        y = crd(2,2);
    end

    function tf = cursorOverOtherObject()
        tf = false;
        % check if cursor is over legend
        ax = overobj('axes');
        if ~isempty(ax) && strcmp(get(ax,'Tag'),'legend')
            tf = true;
        end
        % check if cursor is over DataTip object
        h_dt = findall(h_fig,'Tag','DataTipMarker');
        if ~isempty(h_dt)
            for i=1:numel(h_fig)
                h = hittest(h_fig(i));
                if any(h == h_dt)
                    tf = true;
                    return
                end
            end
        end
    end

    function [x_rel, y_rel] = abs2relCoords(h_ax, x, y)
        XLim = get(h_ax, 'xlim');
        if strcmp(get(h_ax, 'XScale'), 'log')
            x_rel = ( log(x) - log(XLim(1)) ) / ( log(XLim(2)) - log(XLim(1)) );
        else
            x_rel = (x-XLim(1))/(XLim(2)-XLim(1));
        end
        YLim = get(h_ax, 'ylim');
        if strcmp(get(h_ax, 'YScale'), 'log')
            y_rel = ( log(y) - log(YLim(1)) ) / ( log(YLim(2)) - log(YLim(1)) );
        else
            y_rel = (y-YLim(1))/(YLim(2)-YLim(1));
        end
    end

    function [x, y] = rel2absCoords(h_ax, x_rel, y_rel)
        XLim = get(h_ax, 'xlim');
        x = x_rel*diff(XLim)+XLim(1);
        YLim = get(h_ax, 'ylim');
        y = y_rel*diff(YLim)+YLim(1);
    end

    function tf = coordsWithinLimits(h_ax, x, y)
        XLim = get(h_ax, 'xlim');
        YLim = get(h_ax, 'ylim');
        tf = x>XLim(1) && x<XLim(2) && y>YLim(1) && y<YLim(2);
    end


end
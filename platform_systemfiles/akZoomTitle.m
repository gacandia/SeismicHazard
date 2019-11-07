function akZoomTitle(h_ax)

h_fig        = get(h_ax, 'Parent');
cx = []; cy = []; mode = '';
zoom(h_fig, 'off')
pan(h_fig, 'off')
set(h_fig, 'WindowButtonMotionFcn', @MouseMotion);

    function MouseMotion(varargin)
        currAx = h_ax;
        [x,y] = getAbsCoords(currAx);
        tf = coordsWithinLimits(h_ax, x, y);
        if tf
            title(h_ax,sprintf('%5.3f , %5.3f',x,y),'visible','on','fontsize',10,'fontweight','normal')
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
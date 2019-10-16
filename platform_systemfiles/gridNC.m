function [h_atp] = gridNC(h_ax,s)

h_fig  = get(h_ax,'parent');
ch     = findall(h_fig,'tag','patchselect');delete(ch);
set(h_fig,'Pointer','cross');
flag = 1;
k    = 0;
ish  = ishold;
hold on

switch s
    case 'polygone'
        ss=1;
        h_atp = patch('parent',h_ax,...
            'vertices',[],...
            'faces',[],...
            'facecolor','b',...
            'facealpha',0.1,...
            'marker','.',...
            'edgecolor',[0 0.7490 0.7490],...
            'tag','patchselect',...
            'linewidth',2);
    case 'polyline'
        ss=2;
        h_atp=plot(gca,NaN,NaN,'.-',...
            'color',[0 0.7490 0.7490],...
            'linewidth',2,...
            'tag','patchselect');
end

while flag ~= 27 && flag~=3
    set(h_fig,'Pointer','cross');
    [x,y,flag] = ginpt(1);
    
    if isempty(flag)
        flag=3;
    end
    tf    = coordsWithinLimits(h_ax, x, y);
    if tf && flag==1
        k = k+1;
        if k == 1
            X = x;
            Y = y;
            vert = [X,Y];
            if ss==1, set(h_atp,'vertices',vert,'faces',1:k);end
            if ss==2, set(h_atp,'xdata',vert(:,1),'ydata',vert(:,2));end
        else
            X = [X; x]; %#ok<*AGROW>
            Y = [Y; y];
            vert = [X,Y];
            if ss==1, set(h_atp,'vertices',vert,'faces',1:k);end
            if ss==2, set(h_atp,'xdata',vert(:,1),'ydata',vert(:,2));end
        end
    end
    
    if flag==32 && ss==2
        flag=3;
        X = [X; X(1)];
        Y = [Y; Y(1)];
        vert = [X,Y];
        set(h_atp,'xdata',vert(:,1),'ydata',vert(:,2));
    end
    
    
end

if ish == 0
    hold off
end
set(h_fig,'Pointer','arrow');
set(h_ax  ,'ButtonDownFcn', []);
end

function tf = coordsWithinLimits(h_ax, x, y)
XLim = get(h_ax, 'xlim');
YLim = get(h_ax, 'ylim');
if isempty(x) || isempty(y)
    tf=0;
else
    tf = x>XLim(1) && x<XLim(2) && y>YLim(1) && y<YLim(2);
end
end

function [out1,out2,out3] = ginpt(arg1)

out1 = []; out2 = []; out3 = []; y = [];
c = computer;
if ~strcmp(c(1:2),'PC')
    tp = get(0,'TerminalProtocol');
else
    tp = 'micro';
end

if ~strcmp(tp,'none') && ~strcmp(tp,'x') && ~strcmp(tp,'micro')
    if nargout == 1
        if nargin == 1
            out1 = trmginput(arg1);
        else
            out1 = trmginput;
        end
    elseif nargout == 2 || nargout == 0
        if nargin == 1
            [out1,out2] = trmginput(arg1);
        else
            [out1,out2] = trmginput;
        end
        if  nargout == 0
            out1 = [ out1 out2 ];
        end
    elseif nargout == 3
        if nargin == 1
            [out1,out2,out3] = trmginput(arg1);
        else
            [out1,out2,out3] = trmginput;
        end
    end
else
    
    fig = gcf;
    figure(gcf);
    
    if nargin == 0
        how_many = -1;
        b = [];
    else
        how_many = arg1;
        b = [];
        if  ischar(how_many) ...
                || size(how_many,1) ~= 1 || size(how_many,2) ~= 1 ...
                || ~(fix(how_many) == how_many) ...
                || how_many < 0
            error('MATLAB:ginput:NeedPositiveInt', 'Requires a positive integer.')
        end
        if how_many == 0
            ptr_fig = 0;
            while(ptr_fig ~= fig)
                ptr_fig = get(0,'PointerWindow');
            end
            scrn_pt = get(0,'PointerLocation');
            loc = get(fig,'Position');
            pt = [scrn_pt(1) - loc(1), scrn_pt(2) - loc(2)];
            out1 = pt(1); y = pt(2);
        elseif how_many < 0
            error('MATLAB:ginput:InvalidArgument', 'Argument must be a positive integer.')
        end
    end
    
    % Suspend figure functions
    state = uisuspend(fig);
    
    toolbar = findobj(allchild(fig),'flat','Type','uitoolbar');
    if ~isempty(toolbar)
        ptButtons = [uigettool(toolbar,'Plottools.PlottoolsOff'), ...
            uigettool(toolbar,'Plottools.PlottoolsOn')];
        ptState = get (ptButtons,'Enable');
        set (ptButtons,'Enable','off');
    end
    
    %    set(fig,'pointer','fullcrosshair');
    fig_units = get(fig,'units');
    char = 0;
    
    % We need to pump the event queue on unix
    % before calling WAITFORBUTTONPRESS
    drawnow
    
    while how_many ~= 0
        % Use no-side effect WAITFORBUTTONPRESS
        waserr = 0;
        try
            keydown = wfbp;
        catch
            waserr = 1;
        end
        if(waserr == 1)
            if(ishghandle(fig))
                set(fig,'units',fig_units);
                uirestore(state);
                error('MATLAB:ginput:Interrupted', 'Interrupted');
            else
                error('MATLAB:ginput:FigureDeletionPause', 'Interrupted by figure deletion');
            end
        end
        % g467403 - ginput failed to discern clicks/keypresses on the figure it was
        % registered to operate on and any other open figures whose handle
        % visibility were set to off
        figchildren = allchild(0);
        if ~isempty(figchildren)
            ptr_fig = figchildren(1);
        else
            error('MATLAB:ginput:FigureUnavailable','No figure available to process a mouse/key event');
        end
        %         old code -> ptr_fig = get(0,'CurrentFigure'); Fails when the
        %         clicked figure has handlevisibility set to callback
        if(ptr_fig == fig)
            if keydown
                char = get(fig, 'CurrentCharacter');
                button = abs(get(fig, 'CurrentCharacter'));
                scrn_pt = get(0, 'PointerLocation');
                set(fig,'units','pixels')
                loc = get(fig, 'Position');
                % We need to compensate for an off-by-one error:
                pt = [scrn_pt(1) - loc(1) + 1, scrn_pt(2) - loc(2) + 1];
                set(fig,'CurrentPoint',pt);
            else
                button = get(fig, 'SelectionType');
                if strcmp(button,'open')
                    button = 1;
                elseif strcmp(button,'normal')
                    button = 1;
                elseif strcmp(button,'extend')
                    button = 2;
                elseif strcmp(button,'alt')
                    button = 3;
                else
                    error('MATLAB:ginput:InvalidSelection', 'Invalid mouse selection.')
                end
            end
            pt = get(gca, 'CurrentPoint');
            
            how_many = how_many - 1;
            
            if(char == 13) % & how_many ~= 0)
                % if the return key was pressed, char will == 13,
                % and that's our signal to break out of here whether
                % or not we have collected all the requested data
                % points.
                % If this was an early breakout, don't include
                % the <Return> key info in the return arrays.
                % We will no longer count it if it's the last input.
                break;
            end
            
            out1 = [out1;pt(1,1)];
            y = [y;pt(1,2)];
            b = [b;button];
        end
    end
    
    uirestore(state);
    if ~isempty(toolbar) && ~isempty(ptButtons)
        set (ptButtons(1),'Enable',ptState{1});
        set (ptButtons(2),'Enable',ptState{2});
    end
    set(fig,'units',fig_units);
    
    if nargout > 1
        out2 = y;
        if nargout > 2
            out3 = b;
        end
    else
        out1 = [out1 y];
    end
    
end
end

function key = wfbp
fig = gcf;
% current_char = [];
waserr = 0;
try
    h=findall(fig,'type','uimenu','accel','C');   % Disabling ^C for edit menu so the only ^C is for
    set(h,'accel','');                            % interrupting the function.
    keydown = waitforbuttonpress;
    current_char = double(get(fig,'CurrentCharacter')); % Capturing the character.
    if~isempty(current_char) && (keydown == 1)           % If the character was generated by the
        if(current_char == 3)                       % current keypress AND is ^C, set 'waserr'to 1
            waserr = 1;                             % so that it errors out.
        end
    end
    
    set(h,'accel','C');                                 % Set back the accelerator for edit menu.
catch
    waserr = 1;
end
drawnow;
if(waserr == 1)
    set(h,'accel','C');                                % Set back the accelerator if it errored out.
    error('MATLAB:ginput:Interrupted', 'Interrupted');
end

if nargout>0, key = keydown; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
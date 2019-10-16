function outputVariable = GEOptions(varargin)

MapType = {'roadmap','satellite','terrain','hybrid'};
pllist={'Yes','No'};

if nargin==0
    % default values and continues with user inquiry
    Alpha    = '1';
    Scale    = '2';
    val1     = 3;
    val2     = 2;
elseif nargin>0 && ~isstruct(varargin{1})
    % default values and exits
    outputVariable.Alpha      = 1;
    outputVariable.Scale      = 2;
    outputVariable.MapType    = 'terrain';
    outputVariable.ShowLabels = 0;
    return
elseif nargin>0 && isstruct(varargin{1})
    % fills boxes with previous data
    opt     = varargin{1};
    Alpha   = num2str(opt.Alpha);
    Scale   = num2str(opt.Scale);
    val1    = find(strcmp(MapType,opt.MapType));
    switch opt.ShowLabels
        case 0, val2 = 2;
        case 1, val2 = 1;
    end
end

% Any variables declared here will be accessible to the callbacks
hdl.mainfig = figure(...
    'Name','Hazard Map Options',...
    'NumberTitle','off',...
    'CloseRequestFcn',@closefunction,...
    'position',[397 298 235 237],...
    'units','normalized');
axis off
set(hdl.mainfig, 'MenuBar', 'none');
set(hdl.mainfig, 'ToolBar', 'none');

uipanel('FontSize',10,'Position',[.05 .05 .9 .9]);

uicontrol('style','text','String','Transparency','Units','normalized'      ,'position',[0.15 0.76 0.5 0.1],'horizontalalignment','left');
uicontrol('style','text','String','Scale','Units','normalized'         ,'position',[0.15  0.5833 0.5 0.1],'horizontalalignment','left');
uicontrol('style','text','String','Map Type','Units','normalized'          ,'position',[0.15 0.4067 0.5 0.1],'horizontalalignment','left');
uicontrol('style','text','String','ShowLabels','Units','normalized'        ,'position',[0.15 0.24 0.5 0.1],'horizontalalignment','left');

hdl.box1 = uicontrol('style','edit'   ...
    ,'String',Alpha,...
    'Units', 'normalized'     ...
    ,'position',[0.6 0.78 0.3 0.1],...
    'backgroundcolor',[1 1 1],...
    'Tooltipstring','Transparency level of the map');
hdl.box2= uicontrol('style','edit'...
    ,'String',Scale,...
    'Units', 'normalized'    ...
    ,'position',[0.6 0.6033 0.3 0.1],...
    'backgroundcolor',[1 1 1],...
    'Tooltipstring','(1/2) Resolution scale factor. Using Scale=2 will double the resulotion of the downloaded image (up to 1280x1280) and will result in finer rendering, but processing time will be longer.');
hdl.box3 = uicontrol('Style', 'popup' ,'String', MapType,'value',val1,'Units', 'normalized','Position',[0.6 0.4267 0.3 0.1],'backgroundcolor',[1 1 1]);
hdl.box4 = uicontrol('Style', 'popup' ,'String', pllist,'value',val2,'Units', 'normalized','Position',[0.6 0.25 0.3 0.1],'backgroundcolor',[1 1 1]);
hdl.donePushButton = uicontrol(hdl.mainfig, 'Units', 'normalized',           'Position',[0.6 0.1 0.3 0.1], 'String', 'Done', 'Callback', @closefunction);

    function closefunction(~,~)
        % This callback is executed if the user closes the gui
        % Assign Output
        outputVariable.Alpha = str2double(get(hdl.box1,'string'));
        outputVariable.Scale = str2double(get(hdl.box2,'string'));
        MapType = MapType(get(hdl.box3,'value'));
        outputVariable.MapType = MapType{1};
        outputVariable.ShowLabels = get(hdl.box4,'value')==1;
        
        % Close figure
        delete(hdl.mainfig); % close GUI
    end

% Pause until figure is closed ---------------------------------------%
waitfor(hdl.mainfig);
end
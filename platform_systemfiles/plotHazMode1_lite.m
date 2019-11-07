function str=plotHazMode1_lite(handles)

%% -------------  initialization ----------------------------------
isREGULAR = find(horzcat(handles.model.isregular)==1);
isPCE     = find(horzcat(handles.model.isregular)==0);
site    = handles.site_menu.Value; % site pointer
IM_ptr  = handles.IM_select.Value;
nrows   = size(handles.opt.im,2);
if nrows==1
    im  = handles.opt.im;
else
    im  = handles.opt.im(:,IM_ptr);
end
im = im(:)';

if ~isempty(isREGULAR) && ~isempty(isPCE)
    y0REG = handles.MRE   (site,:,IM_ptr);
    y0PCE = handles.MREPCE(site,:,IM_ptr);
    y0    = y0REG.*y0PCE; % TRUCAZO :)
end

if ~isempty(isREGULAR) && isempty(isPCE)
    y0 = handles.MRE   (site,:,IM_ptr);
end

if  isempty(isREGULAR) && ~isempty(isPCE)
    y0 = handles.MREPCE{site,:,IM_ptr};
    y0 = prctile(y0,50,5);
end

%% -------------  plot hazard--------------------------------------
y0clean      = y0;
handles.ax2.ColorOrderIndex=1;
plot(handles.ax2,im',y0clean','-','ButtonDownFcn',{@myfun,handles},'tag','lambda0','linewidth',2,'DisplayName','Default Weights');


%% -------------  xlabel & ylabel & legend --------------------------------
if iscell(handles.IM_select.String)
    xlabel(handles.ax2,handles.IM_select.String{IM_ptr},'fontsize',10)
else
    xlabel(handles.ax2,handles.IM_select.String,'fontsize',10)
end
ylabel(handles.ax2,'Mean Rate of Exceedance','fontsize',10)
str = 'Default Weights';

% -------------  ui context menu ------------------------------------------
IMstr = handles.IM_select.String{IM_ptr};
data  = num2cell([zeros(1,2);[im',y0']]);

data{1,1}=IMstr;
data(1,2:end)={str};
c2 = uicontextmenu;
uimenu(c2,'Label','Copy data','Callback'            ,{@data2clipboard_uimenu,data(2:end,:)});
uimenu(c2,'Label','Copy data & headers','Callback'  ,{@data2clipboard_uimenu,data(1:end,:)});
uimenu(c2,'Label','Undock','Callback'               ,{@figure2clipboard_uimenu,handles.ax2});
uimenu(c2,'Label','Undock & compare','Callback'     ,{@figurecompare_uimenu,handles.ax2});
set(handles.ax2,'uicontextmenu',c2);

function[]=myfun(hObject, eventdata, handles) %#ok<INUSL>

H=datacursormode(handles.FIGSeismicHazard);
set(H,'enable','on','DisplayStyle','window','UpdateFcn',{@gethazarddata,handles.HazOptions.dbt(1)});
w = findobj('Tag','figpanel');
set(w,'Position',[ 409   485   150    60]);

function output_txt = gethazarddata(~,event_obj,dbt)

pos = get(event_obj,'Position');

if dbt==1
    output_txt = {...
        ['IM   : ',num2str(pos(1),4)],...
        ['Rate : ',num2str(pos(2),4)],...
        ['T    : ',num2str(1/pos(2),4),' years']};
end

if dbt==0
    output_txt = {...
        ['IM             : ',num2str(pos(1),4)],...
        ['P(IM>im|t) : ',num2str(pos(2),4)]};
end

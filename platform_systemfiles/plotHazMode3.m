function str=plotHazMode3(handles)

%% -------------  initialization ----------------------------------
haz     = handles.HazOptions;
site    = handles.site_menu.Value; % site pointer

IM_ptr  = handles.IM_select.Value;
nrows   = size(handles.opt.im,2);
if nrows==1, im  = handles.opt.im; else , im  = handles.opt.im(:,IM_ptr);end;im      = im(:)';
do_tests=0; if  isfield(handles.sys,'lambdaTest'), do_tests=1; end
delete(findall(handles.ax1,'tag','scenario'));
delete(findall(handles.ax2,'type','line'));
delete(findall(handles.ax2,'tag','histogram'));
handles.ax2.ColorOrderIndex = 1;

%% -------------  compute lambda1 and lambda0 ----------------------------
model_ptr = haz.sbh(1);
lambda1   = handles.MREPCE{model_ptr}(site,:,IM_ptr,:,:);
lambda1   = nansum(lambda1,4);
lambda1   = permute(lambda1,[5,2,1,3,4]);

if haz.dbt(2)==1
    Nreal   = size(lambda1,1);
    for kkk=1:Nreal
        lambda1(kkk,:)= MREDer(im,-lambda1(kkk,:),1)';
    end
    lambda1(lambda1<0)=0;
end

switch haz.pce(1)
    case 1
        loglambda1=log(lambda1);
        loglambda1(isinf(loglambda1))=nan;
        lambda0 = real(exp(nanmean(loglambda1,1))); % trucazo
    case 0 
        lambda0 = prctile(lambda1,haz.pce(3),1);
end

switch haz.dbt(3)
    case 0
        y0 = lambda0;
        y1 = lambda1;
    case 1
        y0 = 1-exp(-lambda0*haz.dbt(4));
        y1 = 1-exp(-lambda1*haz.dbt(4));
end

if do_tests
    IM       = handles.sys.IM;
    lambdaTest=handles.sys.lambdaTest(site,:);
    switch haz.dbt(3)
        case 0
            yT = lambdaTest;
        case 1
            yT = 1-exp(-lambdaTest*haz.dbt(4));
    end
end

%% -------------  plot hazard--------------------------------------
y0(y0<0)= nan;
y1(y1<0)=nan;


if haz.sbh(4)
    plot(handles.ax2,nan,nan,'-','color',[1 1 1]*0.8,'ButtonDownFcn',{@myfun,handles},'tag','lambda1','visible','on')
    plot(handles.ax2,im',y1','-','color',[1 1 1]*0.8,'ButtonDownFcn',{@myfun,handles},'tag','lambda1','visible','on','HandleVisibility','off')
end
handles.ax2.ColorOrderIndex=1;
plot(handles.ax2,im',y0','-','ButtonDownFcn',{@myfun,handles},'tag','lambda0','linewidth',2);

handles.ax2.Layer='top';
if do_tests
    plot(handles.ax2,IM',yT','ko','tag','lambdaTest','markerfacecolor',[1 1 1]);
end

%% -------------  xlabel & ylabel ----------------------------------
if iscell(handles.IM_select.String)
    xlabel(handles.ax2,handles.IM_select.String{IM_ptr},'fontsize',10)
else
    xlabel(handles.ax2,handles.IM_select.String,'fontsize',10)
end

switch find(haz.dbt(1:3))
    case 1,ylabel(handles.ax2,'Mean Rate of Exceedance','fontsize',10)
    case 2,ylabel(handles.ax2,'Mean Rate Density','fontsize',10)
    case 3,ylabel(handles.ax2,'Probability of Exceedance','fontsize',10)
end

%% -------------  legend  -----------------------------------------
switch handles.opt.CGMM{2}
    case 'PC'
        str = sprintf('Branch %g (PCE)',model_ptr);
        if haz.sbh(4), str = [{'Simulations (PCE)'},str];  end
    case 'MC'
        str = sprintf('Branch %g (MCS)',model_ptr);
        if haz.sbh(4), str = [{'Simulations (MCS)'},str];  end
end

if do_tests,   str = [str,{'Benchmark'}];          end

%%  -------------  ui context menu ------------------------------------------
IMstr = handles.IM_select.String{IM_ptr};
data  = num2cell([zeros(1,2);[im',y0']]);

data{1,1}=IMstr;
if do_tests==0
    if size(data,2)==2
        data(1,2:end)={str};
    else
        data(1,2:end)=str;
    end
else
    if size(data,2)==2
        data(1,2:end)=str(1);
    else
        data(1,2:end)=str(1:end-1);
    end
end

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

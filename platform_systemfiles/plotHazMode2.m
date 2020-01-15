function str=plotHazMode2(handles)

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

if haz.dbt(2)==0
    lambda1   = handles.MRE(site,:,IM_ptr,:,model_ptr);
    lambda1   = permute(lambda1,[4,2,1,3]);
    lambda0   = nansum(lambda1,1);
else
    opt2    = handles.opt;
    opt2.IM = opt2.IM(IM_ptr);
    h2.p    = handles.h.p(site,:);
    h2.Vs30 = handles.h.Vs30(site,:);
    lambda1 = runlogictree1_MRD(handles.sys,handles.model(model_ptr),opt2,h2,1);
    lambda1 = permute(lambda1,[4,2,1,3]);
    lambda0 = nansum(lambda1,1);
end

if haz.sbh(2)==1
    NOTNAN    = ~isnan(lambda1(:,1));
    lambda1   = lambda1(NOTNAN,:);
end

if haz.sbh(3)==1
    mechs     = {handles.model(model_ptr).source.mechanism};
    m1        = strcmp(mechs,'system');
    m2        = strcmp(mechs,'interface');
    m3        = strcmp(mechs,'intraslab');
    m4        = strcmp(mechs,'slab');
    m5        = strcmp(mechs,'crustal');
    m6        = strcmp(mechs,'fault');
    m7        = strcmp(mechs,'grid');
    m8        = strcmp(mechs,'shallowcrustal');
    lambda1   = [...
        nansum(lambda1(m1,:),1);
        nansum(lambda1(m2,:),1);
        nansum(lambda1(m3,:),1);
        nansum(lambda1(m4,:),1);
        nansum(lambda1(m5,:),1);
        nansum(lambda1(m6,:),1);
        nansum(lambda1(m7,:),1);
        nansum(lambda1(m8,:),1)
        ];
    NOTNAN    = (sum(lambda1,2)>0);
    lambda1   = lambda1(NOTNAN,:);
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
y0(y0<0)=nan;
plot(handles.ax2,im',y0','-','ButtonDownFcn',{@myfun,handles},'tag','lambda0','linewidth',2);

% Ny = size(y1,1);
% c1 = [0.4660    0.6740    0.1880];
% c2 = [0.3010    0.7450    0.9330];
% mycolor = [linspace(c1(1),c2(1),Ny)',linspace(c1(2),c2(2),Ny)',linspace(c1(3),c2(3),Ny)'];
% handles.ax2.ColorOrder=[0 0.477 0.741; mycolor];
y1(y1<0)=nan;
if isempty(y1)
    y1=nan(size(im));
end
if or(haz.sbh(2),haz.sbh(3))
    plot(handles.ax2,im',y1','-','ButtonDownFcn',{@myfun,handles},'tag','lambda1','visible','on')
else
    plot(handles.ax2,im',y1','-','ButtonDownFcn',{@myfun,handles},'tag','lambda1','visible','off')
end

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
str = handles.model(model_ptr).id;

if haz.sbh(2)==1
    str = [{str},{handles.model(model_ptr).source(NOTNAN).label}];
end

if haz.sbh(3)==1
    mechs = {'system','interface','intraslab','slab','crustal','fault','grid','shallowcrustal'};
    str = [{str},mechs(NOTNAN)];
end

if do_tests,   str = [str,{'Benchmark'}];        end

%%  -------------  ui context menu ------------------------------------------
IMstr = handles.IM_select.String{IM_ptr};
notnan=find(~isnan(sum(lambda1,2)));

if haz.sbh(2)==0 && haz.sbh(3)==0
    data  = num2cell([zeros(1,2);[im',y0']]);
else
    Ncol  = size(y0,1)+1+length(notnan);
    data  = num2cell([zeros(1,Ncol);[im',y0',y1(notnan,:)']]);
end


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
        data(1,2:end)=str(2:end);
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

function str=plotHazMode1(handles)

%% -------------  initialization ----------------------------------
haz     = handles.HazOptions;
isPCE   = find(horzcat(handles.model.isregular)==0);
site    = handles.site_menu.Value; % site pointer
IM_ptr  = handles.IM_select.Value;
nrows   = size(handles.opt.im,2);
if nrows==1, im  = handles.opt.im; else , im  = handles.opt.im(:,IM_ptr);end;im      = im(:)';
do_tests=0; if  isfield(handles.sys,'lambdaTest'), do_tests=1; end
delete(findall(handles.ax1,'tag','scenario'));
delete(findall(handles.ax2,'type','line'));
delete(findall(handles.ax2,'tag','histogram'));
handles.ax2.ColorOrderIndex = 1;

%% -------------  compute lambda1----------------------------------
if haz.dbt(2)==0
    lambda1  = nansum(handles.MRE(site,:,IM_ptr,:,:),4);
    lambda1  = permute(lambda1,[5,2,1,3,4]);
    
    for kk=isPCE
        lambda1PCE = nansum(handles.MREPCE{kk}(site,:,IM_ptr,:,:),4);
        switch haz.pce(1)
            case 1, lambda1(kk,:) = real(exp(nanmean(log(lambda1PCE),5))); % trucazo
            case 0, lambda1(kk,:) = prctile(lambda1PCE,haz.pce(3),5);
        end
    end
else % Probability density function
    opt2    = handles.opt;
    opt2.IM = opt2.IM(IM_ptr);
    h2.p    = handles.h.p(site,:);
    h2.Vs30 = handles.h.Vs30(site,:);
    
    MRD     = runlogictree1_MRD(handles.sys,handles.model,opt2,h2,1);
    lambda1  = nansum(MRD,4);
    lambda1  = permute(lambda1,[5,2,1,3,4]);
    for kk=isPCE
        MREPCE  = nansum(handles.MREPCE{kk}(site,:,IM_ptr,:,:),4);
        MREPCE  = permute(MREPCE,[5 2 1 3 4]);
        MRDPCE  = zeros(size(MREPCE));
        Nreal   = size(MREPCE,1);
        for kkk=1:Nreal
            MRDPCE(kkk,:)= MREDer(im,-MREPCE(kkk,:),1)';
        end
        MRDPCE(MRDPCE<0)=0;
        switch haz.pce(1)
            case 1, lambda1(kk,:) = nanmean(MRDPCE,1); % trucazo
            case 0, lambda1(kk,:) = prctile(MRDPCE,haz.pce(3),1);
        end
    end
    
end

%% -------------  compute lambda0----------------------------------

switch find(haz.avg(1:3))
    case 1
        weights = handles.sys.WEIGHT(:,4);
        lambda0 = prod(bsxfun(@power,lambda1,weights(:)),1);
    case 2
        weights  = haz.rnd;
        lambda0 = prod(bsxfun(@power,lambda1,weights(:)),1);
    case 3
        lambda0 = prctile(lambda1,haz.avg(4),1);
end

if haz.dbt(1)==1
    y0 = lambda0;
    y1 = lambda1;
end

if haz.dbt(3)==1
    y0 = 1-exp(-lambda0*haz.dbt(4));
    y1 = 1-exp(-lambda1*haz.dbt(4));
end

% notnan = true(size(im));
if do_tests
    lambdaTest=handles.sys.lambdaTest(site,:);
%     notnan=~isnan(lambdaTest);
    IM       = handles.sys.IM;
    switch haz.dbt(3)
        case 0
            yT = lambdaTest;
        case 1
            yT = 1-exp(-lambdaTest*haz.dbt(4));
    end
end

%% -------------  plot hazard--------------------------------------
y0clean      = y0; y0clean(y0<0)= nan;
y1clean      = y1; y1clean(y1<0)=nan;

switch haz.avg(5)
    case 0
        plot(handles.ax2,im',y0clean','-','ButtonDownFcn',{@myfun,handles},'tag','lambda0','linewidth',2);
        if do_tests, plot(handles.ax2,IM',yT','ko','tag','lambdaTest','markerfacecolor','none');end
    case 1
        handles.ax2.ColorOrderIndex=2;
        plot(handles.ax2,im',y1clean','-','ButtonDownFcn',{@myfun,handles},'tag','lambda1','visible','on')
        plot(handles.ax2,im',y0clean','-','color',[0 0.447 0.741],'ButtonDownFcn',{@myfun,handles},'tag','lambda0','linewidth',2);
        if do_tests, plot(handles.ax2,IM',yT','ko','tag','lambdaTest','markerfacecolor','none');end
end

%% -------------  xlabel & ylabel ----------------------------------
if iscell(handles.IM_select.String)
    xlabel(handles.ax2,handles.IM_select.String{IM_ptr},'fontsize',8)
else
    xlabel(handles.ax2,handles.IM_select.String,'fontsize',8)
end

switch find(haz.dbt(1:3))
    case 1,ylabel(handles.ax2,'Mean Rate of Exceedance','fontsize',8)
    case 2,ylabel(handles.ax2,'Mean Rate Density','fontsize',8)
    case 3,ylabel(handles.ax2,'Probability of Exceedance','fontsize',8)
end

%% -------------  legend  -----------------------------------------
switch find(haz.avg(1:3))
    case 1, str1 = 'Default Weights';
    case 2, str1 = 'Random Weights';
    case 3, str1 = sprintf('Percentile %g',haz.avg(4));
end
if haz.avg(5)
    str2 = {handles.model.id};
else
    str2={};
end
if do_tests
    str3 = {'Benchmark'};
else
    str3 = {};
end
str = [str2,str1,str3];

% -------------  ui context menu ------------------------------------------
IMstr = handles.IM_select.String{IM_ptr};
notnan=find(~isnan(sum(lambda1,2)));

if ~haz.avg(5)
    data  = num2cell([zeros(1,2);[im',y0']]);
else
    Ncol  = size(y0,1)+1+length(notnan);
    data  = num2cell([zeros(1,Ncol);[im',y1(notnan,:)',y0']]);
end


data{1,1}=IMstr;
if do_tests==0
    if size(data,2)==2
        data(1,2:end)={str};
    else
        data(1,2:end)=str;
    end
    handles.OpenRef.Visible='off';
else
    if size(data,2)==2
        data(1,2:end)=str(1);
    else
        data(1,2:end)=str(1:end-1);
    end
    handles.OpenRef.Visible='on';
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

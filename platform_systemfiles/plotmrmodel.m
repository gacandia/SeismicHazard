function plotmrmodel(handles)


% gmpe parameters
param     = mMRgetparam(handles);
x         = 4:0.005:9;
TOL       = 1e-14;
switch func2str(handles.fun)
    case 'truncexp'
        tr1=-TOL + param.Mmin;
        tr2=-TOL + param.Mmax;
        tr3=+TOL + param.Mmax;
        x = sort([x,tr1,param.Mmin,param.Mmax,tr2,tr3]);
        ptr_SR = 'e5';
        ptr_Mo = 'e6';
        
    case 'truncnorm'
        tr1=-TOL + param.Mchar-param.sigmaM;
        tr2=       param.Mchar-param.sigmaM;
        tr3=+TOL + param.Mchar+param.sigmaM;
        tr4=       param.Mchar+param.sigmaM;
        x = sort([x,tr1,tr2,tr3,tr4]);
        ptr_SR = 'e6';
        ptr_Mo = 'e7';
        
    case 'delta'
        tr1=-TOL + param.M;
        tr2=+TOL + param.M;
        x = sort([x,tr1,param.M,tr2]);
        ptr_SR = 'e3';
        ptr_Mo = 'e4';
        
    case 'youngscoppersmith'
        tr1 = -TOL + param.Mmin;
        tr2 = param.Mmin;
        tr3 = param.Mchar-0.25-TOL;
        tr4 = param.Mchar-0.25;
        tr5 = param.Mchar+0.25;
        tr6 = param.Mchar+0.25+TOL;
        x = sort([x,tr1,tr2,tr3,tr4,tr5,tr6]);
        ptr_SR = 'e5';
        ptr_Mo = 'e6';
end

switch handles.uibuttongroup1.SelectedObject.String
    case 'rate',[~,y,meanMo] = handles.fun(x,param); ylabel(handles.ax1,'Magnitude rate');y = param.NMmin*(1-y); 
    case 'pdf', [y,~,meanMo] = handles.fun(x,param); ylabel(handles.ax1,'Magnitude pdf')
    case 'cdf', [~,y,meanMo] = handles.fun(x,param); ylabel(handles.ax1,'Magnitude cdf')
end

if isfield(handles,'CurrentArea')
    mu       = handles.mu; % dyne/cm
    Area     = handles.CurrentArea*1e10; % de km2 a cm2
    NMmin    = param.NMmin; %eq/yer
    SlipRate = 10*NMmin*meanMo/(mu*Area); % en mm/year
    handles.(ptr_SR).String=sprintf('%3.4g',SlipRate);
    handles.(ptr_Mo).String=sprintf('%3.4g',meanMo);
end

switch handles.HoldPlot.Value
    case 0
        ch=findall(handles.ax1,'tag','curves');delete(ch);
        handles.ax1.ColorOrderIndex = 1;
    case 1
end
y(y<=0)=nan;
plot(handles.ax1,x,y,'tag','curves','ButtonDownFcn',@click_on_curve,'handlevisibility','off');
handles.xlabel=xlabel(handles.ax1,'Magnitude','fontsize',10);


%% -------------- data2clipboard ---------------------------
% cF=get(0,'format');
% format long g
% data  = num2cell([x(:),y(:)]);
% c2 = uicontextmenu;
% uimenu(c2,'Label','Copy data','Callback'    ,{@data2clipboard_uimenu,data});
% uimenu(c2,'Label','Undock','Callback'       ,{@figure2clipboard_uimenu,handles.ax1});
% set(handles.ax1,'uicontextmenu',c2);
% format(cF);


function click_on_curve(hObject,eventdata)

switch eventdata.Button
    case 1 %click izquierdo
    case 3 %click derecho
        delete(hObject)
end


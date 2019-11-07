function plotgmpe(handles)

epsilon = handles.epsilon;
Neps    = length(epsilon);

% gmpe parameters
param     = mGMPEgetparam(handles);

if handles.rad1.Value==1
    IM=max(handles.IM,0.01);
    
    Sa        = nan(Neps,length(IM)+1);
    for i=1:length(IM)
        [lny,sigma] = handles.fun(IM(i),param{:});
        for j=1:Neps
            Sa(j,i) = exp(lny+epsilon(j)*sigma);
        end
    end
    
    switch handles.HoldPlot.Value
        case 0
            ch=findall(handles.ax1,'tag','curves');delete(ch);
            handles.ax1.ColorOrderIndex = 1;
        case 1
    end
    x = repmat([IM,nan],1,Neps);
    Sa = Sa';
    y = Sa(:)';
    plot(handles.ax1,x,y,'tag','curves','ButtonDownFcn',@click_on_curve);
    handles.xlabel=xlabel(handles.ax1,'T(s)','fontsize',10);
else
    Rrup   = logsp(1,300,20)';
    imptr  = handles.targetIM.Value;
    param2 = mGMPErrupLoop(handles.fun,Rrup,param);
    if isempty(param2)
        Sa = nan(length(Rrup)+1,Neps);
    else
        IM     = handles.IM(imptr);
        [lny,sigma] = handles.fun(IM,param2{:});
        Sa = nan(length(lny)+1,Neps);
        for i=1:Neps
            Sa(1:end-1,i) = exp(lny+epsilon(i)*sigma);
        end
    end
    
    
    switch handles.HoldPlot.Value
        case 0
            ch=findall(handles.ax1,'tag','curves');delete(ch);
            handles.ax1.ColorOrderIndex = 1;
        case 1
    end
    x = repmat([Rrup;nan],Neps,1);
    y = Sa(:);
    plot(handles.ax1,x,y,'tag','curves','ButtonDownFcn',@click_on_curve);
    handles.xlabel=xlabel(handles.ax1,'Rrup(km)','fontsize',10);
end

%% -------------- data2clipboard ---------------------------
cF=get(0,'format');
format long g
data  = num2cell([x(:),y(:)]);
c2 = uicontextmenu;
uimenu(c2,'Label','Copy data','Callback'    ,{@data2clipboard_uimenu,data});
uimenu(c2,'Label','Undock','Callback'       ,{@figure2clipboard_uimenu,handles.ax1});
set(handles.ax1,'uicontextmenu',c2);
format(cF);
function click_on_curve(hObject,eventdata)

switch eventdata.Button
    case 1 %click izquierdo
    case 3 %click derecho
        delete(hObject)
end


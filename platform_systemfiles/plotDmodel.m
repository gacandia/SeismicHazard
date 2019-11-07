function plotDmodel(handles)

func  = handles.fun;

Nd    = 50;
im    = logsp(handles.im_1,handles.im_2,Nd);
[param,implot] = dDISPgetparam(handles,im);
param = cell2mat(param');

lnd     = nan(1,Nd);
s       = nan(1,Nd);

for i=1:Nd
    parami=num2cell(param(:,i));
    vout=func(parami{:});
    lnd(i)= vout(1);
    s(i)= vout(2);
end

lnd(exp(lnd)<1e-3)=nan;

Neps = 1;
x1 = im;  y1 = exp(lnd);
x2 = [im nan im]; y2 = exp([lnd-s*Neps nan lnd+s*Neps]);

% plot on ax1
delete(findall(handles.ax1,'type','line'))
handles.ax1.ColorOrderIndex=1;
handles.ax1.XLimMode='auto';
handles.ax1.YLimMode='auto';
plot(handles.ax1,x1,y1,'tag','D')
plot(handles.ax1,x2,y2,'--','tag','D')
L=legend(handles.ax1,'d','d \pm \sigma');
L.Box='off';
L.Location='SouthEast';

handles.ax1.YLim(1)=max(handles.ax1.YLim(1),0.1);
handles.ax1.XLim(1)=0;

handles.ch1=plot(handles.ax1,[implot implot],handles.ax1.YLim,'k--','tag','refline','handlevisibility','off');

% plot on ax2
XL = handles.ax1.YLim;
delete(findall(handles.ax2,'tag','D'))
handles.ax2.ColorOrderIndex=1;
handles.ax2.XLim = XL;
switch handles.plotmodeax2
    case 'pdf'
        plotmodeax2 = 1;
        handles.ax2.YLimMode='auto';
    case 'cdf'
        plotmodeax2 = 2;
        handles.ax2.YLim=[0 1];
    case 'ccdf'
        plotmodeax2 = 3;
        handles.ax2.YLim=[0 1];
end


param = dDISPgetparam(handles,implot);
dcontrol = [0.5-eps 0.5+eps 1-eps 1+eps];
x = sort([0 logsp(XL(1),XL(2),70),dcontrol]);
y = x;
for i=1:length(x)
    y(i) = func(param{:},x(i),handles.plotmodeax2);
end

switch plotmodeax2
    case 1,handles.ylabel2.String='Probability Density';
    case 2,handles.ylabel2.String=sprintf('P(D < d | %3.2f)',implot);
    case 3,handles.ylabel2.String=sprintf('P(D > d | %3.2f)',implot);
end
handles.ch2 = plot(handles.ax2,x,y,'tag','D','handlevisibility','off');

set (handles.figure1, 'WindowButtonMotionFcn', {@mouseMove,handles,x,param,func,handles.plotmodeax2,plotmodeax2});

function mouseMove(~,~,handles,x,param,func,dmode,plotmode)

[xi,yi] = getAbsCoords(handles.ax1);
tf1     = coordsWithinLimits1(handles.ax1, xi,yi);

if tf1 
    param{3}=xi;
    y = x;
    for i=1:length(x)
        y(i) = func(param{:},x(i),dmode);
    end
%     y=y/trapz(x,y);
    handles.ch1.XData=[xi xi];
    handles.ch2.YData=y;
    
    switch plotmode
        case 2,handles.ylabel2.String=sprintf('P(D < d | %3.2f)',xi);
        case 3,handles.ylabel2.String=sprintf('P(D > d | %3.2f)',xi);
    end
end

function [x, y] = getAbsCoords(h_ax)
crd = get(h_ax, 'CurrentPoint');
x = crd(2,1);
y = crd(2,2);

function tf = coordsWithinLimits1(h_ax, x, y)
XLim = get(h_ax, 'xlim');
YLim = get(h_ax, 'ylim');
tf = x>XLim(1) && x<XLim(2) && y<YLim(2);

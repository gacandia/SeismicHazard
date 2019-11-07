function[h_atp]=grid2C(h_ax,s)


switch s
    case 'point' , clickfun=@clickline;   motionfun = [];
    case 'line'  , clickfun=@clickline;   motionfun = @motionline;
    case 'square', clickfun=@clicksquare; motionfun = @motionsquare;
    case 'poly'  , clickfun=@clickpoly;   motionfun = @motionpoly;
end
h_fig  = get(h_ax,'parent');
set(h_fig,'Pointer','cross');
ch     = findall(h_fig,'tag','patchselect');delete(ch);
h_lin  = findall(h_fig,'type','line');
h_img  = findall(h_fig,'type','image');
h_ras  = findall(h_fig,'tag','raster');
h_mic  = findall(h_fig,'tag','microzone');
h_atp  = patch('parent',h_ax,...
    'vertices',[],...
    'faces',[],...
    'facecolor','b',...
    'facealpha',0.1,...
    'edgecolor',[0 0.7490 0.7490],...
    'linewidth',2,...
    'tag','patchselect',...
    'ButtonDownFcn', clickfun);

set(h_ax  ,'ButtonDownFcn', clickfun);
set(h_lin ,'ButtonDownFcn', clickfun);
set(h_img ,'ButtonDownFcn', clickfun);
set(h_ras ,'ButtonDownFcn', clickfun);
set(h_mic ,'ButtonDownFcn', clickfun);
set(h_fig ,'WindowButtonMotionFcn', motionfun)

waitforbuttonpress;
if ~strcmp(s,'point')
    waitforbuttonpress;
end
set(h_ax  ,'ButtonDownFcn', []);
set(h_lin ,'ButtonDownFcn', []);
set(h_atp ,'ButtonDownFcn', []);
set(h_img ,'ButtonDownFcn', []);
set(h_ras ,'ButtonDownFcn', []);
set(h_fig,'Pointer','arrow');

function clickline(object, eventdata) %#ok<*INUSL>

p = findall(gca,'tag','patchselect');
corners = get(p,'vertices');
Cs  = get (gca, 'CurrentPoint');Cs=Cs(1,1:2);

if eventdata.Button==1 && size(corners,1)==0
    corners=Cs;
elseif eventdata.Button==1&& size(corners,1)~=0
    corners=[corners(1,:);Cs];
end
set(p,'vertices',corners,'faces',1:size(corners,1),'visible','on')

function motionline(object, eventdata) %#ok<*INUSD>

[x,y] = getAbsCoords(gca);
tf    = coordsWithinLimits(gca, x, y);

if ~tf,  return, end

title(gca,sprintf('%5.3f , %5.3f',x,y),'visible','on','fontsize',10,'fontweight','normal')
% checks if there is a first node
p = findall(gca,'tag','patchselect');
corners = get(p,'vertices');

if isempty(corners)
    return
end

% draws the square
Cs  = get (gca, 'CurrentPoint');Cs=Cs(1,1:2);
corners_temp=[corners(1,:);Cs];
set(p,'vertices',corners_temp,'faces',1:size(corners_temp,1),'visible','on')
set(gca,'ButtonDownFcn', @clickrectangle);

function clicksquare(object, eventdata) %#ok<*INUSL>

p = findall(gca,'tag','patchselect');
corners = get(p,'vertices');
Cs  = get (gca, 'CurrentPoint');Cs=Cs(1,1:2);

if eventdata.Button==1 && size(corners,1)==0
    corners=Cs;
elseif eventdata.Button==1&& size(corners,1)~=0
    corners=[corners(1,:);[Cs(1),corners(1,2)]
        Cs;corners(1,1),Cs(2)];
end

set(p,'vertices',corners,'faces',1:size(corners,1),'visible','on')

function motionsquare(object, eventdata) %#ok<*INUSD>

[x,y] = getAbsCoords(gca);
tf    = coordsWithinLimits(gca, x, y);

% checks if mouse is within xlim and ylim
if ~tf
    return
end

title(gca,sprintf('%5.3f , %5.3f',x,y),'visible','on','fontsize',10,'fontweight','normal')
% checks if there is a first node
p = findall(gca,'tag','patchselect');
corners = get(p,'vertices');

if isempty(corners)
    return
end

% draws the square
Cs  = get (gca, 'CurrentPoint');Cs=Cs(1,1:2);
corners_temp=[
    corners(1,:);
    [Cs(1),corners(1,2)]
    Cs;
    corners(1,1),Cs(2)];
set(p,'vertices',corners_temp,'faces',1:size(corners_temp,1),'visible','on')
set(gca,'ButtonDownFcn', @clickrectangle);

function tf = coordsWithinLimits(h_ax, x, y)
XLim = get(h_ax, 'xlim');
YLim = get(h_ax, 'ylim');
tf = x>XLim(1) && x<XLim(2) && y>YLim(1) && y<YLim(2);






function [x, y] = getAbsCoords(h_ax)
crd = get(h_ax, 'CurrentPoint');
x = crd(2,1);
y = crd(2,2);
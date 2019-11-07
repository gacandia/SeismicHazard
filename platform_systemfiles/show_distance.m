function[p]=show_distance(h_ax,s)

h_fig  = get(h_ax,'parent');
set(h_fig,'Pointer','cross');
p  = patch('parent',h_ax,...
    'vertices',[],...
    'faces',[],...
    'facecolor','b',...
    'facealpha',0.1,...
    'edgecolor',[0 0.7490 0.7490],...
    'linewidth',2,...
    'tag','patchselect');

text(h_ax,NaN,NaN,'','tag','patchtxt','horizontalalignment','center');
set(h_fig ,'WindowButtonMotionFcn', @motionline)

% 1st click
waitforbuttonpress;
Cs  = get (gca, 'CurrentPoint');Cs=Cs(1,1:2);
corners=Cs;
set(p,'vertices',corners,'faces',1:size(corners,1),'visible','on')

% 2nd click
waitforbuttonpress;
Cs  = get (gca, 'CurrentPoint');Cs=Cs(1,1:2);
corners=[corners(1,:);Cs];
set(p,'vertices',corners,'faces',1:size(corners,1),'visible','on')
set(h_fig,'Pointer','arrow');
akZoom(h_ax) % no other way!

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
h_txt=findall(gca,'tag','patchtxt');
h_txt.Position=[mean(corners_temp),0];

angs = corners_temp*pi/180;

phi1    = angs(1,2);
phi2    = angs(2,2);
dlambda = angs(1,1)-angs(2,1);
dphi    = phi1-phi2;
dsigma = 2*asin(sqrt(sin(dphi/2)^2+cos(phi1)*cos(phi2)*sin(dlambda/2)^2));
h_txt.String  = sprintf('%4.3f',6371.00877141506*dsigma); 
set(p,'vertices',corners_temp,'faces',1:size(corners_temp,1),'visible','on')

function tf = coordsWithinLimits(h_ax, x, y)
XLim = get(h_ax, 'xlim');
YLim = get(h_ax, 'ylim');
tf = x>XLim(1) && x<XLim(2) && y>YLim(1) && y<YLim(2);

function [x, y] = getAbsCoords(h_ax)
crd = get(h_ax, 'CurrentPoint');
x = crd(2,1);
y = crd(2,2);
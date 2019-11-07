function sSCEN_plotSource(handles,source,Data,vorR) %#ok<*INUSD>

switch handles.mesh
    case 0, usermesh(handles,source,Data,vorR);
    case 1, automesh(handles,source,Data,vorR);
end



function usermesh(handles,source,Data,vorR)
geom     = source.geom;
vertices = source.vertices(:,[2,1]);
Nnodes   = size(vertices,1);
ellip    = handles.opt.ellipsoid;

M      = Data{3};
Amax   = geom.Area;
model  = source.rupt.RA{1};
param  = source.rupt.RA{2};
RA     = rupRelation(M,0,Amax,model,param);
Rad    = sqrt(RA/pi);
t      = (0:pi/30:2*pi)';
X      = Data{4};
Y      = Data{5};
meanRadius = ellip.MeanRadius;
vertRA = [180/pi*Rad/meanRadius*cos(t)+X,180/pi*Rad/meanRadius*sin(t)+Y,t*0];
NodesRA= length(t);

FIXED_DATA=handles.t.Data(:,[1:2,3]);
ind = [];
for i=1:size(FIXED_DATA,1)
    if isempty(FIXED_DATA{i,1})
        ind=[ind;i]; %#ok<AGROW>
    else
        FIXED_DATA{i,3}=num2str(FIXED_DATA{i,3});
    end
end
FIXED_DATA(ind,:)=[];
Data{3}=num2str(Data{3});

ind = sum(ismember(FIXED_DATA,Data(:,[1:2,3])),2)==3;
xx  = cell2mat(handles.t.Data(ind,4));
yy  = cell2mat(handles.t.Data(ind,5));

set(handles.area  ,'faces',1:Nnodes ,'vertices',vertices);
set(handles.RA    ,'faces',1:NodesRA,'vertices',vertRA(:,[2,1]));
set(handles.hyp   ,'XData',Y,'YData',X);
set(handles.meshR ,'XData',yy,'YData',xx);

if ~isempty(handles.tessel)
    vor = vertcat(handles.tessel{ind,2});
    set(handles.voroni ,'XData',vor(:,1),'YData',vor(:,2));
end
set(handles.voroni2,'XData',vorR(:,1),'YData',vorR(:,2));

function automesh(handles,source,Data,vorR)
geom     = source.geom;
vertices = geom.p(:,1:2);
Nnodes   = size(vertices,1);

handles.ax1.XLim=[-1 1]/10;
handles.ax1.YLim=[-1 1]/10;
XL = handles.ax1.XLim;
YL = handles.ax1.YLim;
DL = 1.1*max(abs(vertices(:)));
LIMS = [-max(abs([XL,YL,DL])) max(abs([XL,YL,DL]))];
handles.ax1.XLim=LIMS;
handles.ax1.YLim=LIMS;

switch source.rupt.type
    case 'circular'
        M      = Data{3};
        Amax   = geom.Area;
        model  = source.rupt.RA{1};
        param  = source.rupt.RA{2};
        RA     = rupRelation(M,0,Amax,model,param);
        Rad    = sqrt(RA/pi);
        t      = (0:pi/30:2*pi)';
        X      = Data{4};
        Y      = Data{5};
        vertRA = [Rad*cos(t)+X,Rad*sin(t)+Y];
        NodesRA= length(t);
    case 'rectangular'
        M      = Data{3};
        rupt   = source.rupt;
        As     = geom.Area;
        aratio = rupt.aratio;
        RA     = rupRelation(M,0,As,rupt.RA{1},rupt.RA{2});
        XN     = [-1  1 1 -1]'*sqrt(RA*aratio)/2;
        YN     = [-1 -1 1  1]'*sqrt(RA/aratio)/2;
        X      = Data{4};
        Y      = Data{5};
        vertRA =[X+XN,Y+YN];
        NodesRA= 4;
    case 'adaptive'
end

% patch to get rid on annoying matlab limitations :(
FIXED_DATA=handles.t.Data(:,[1:2,3]);
ind = [];
for i=1:size(FIXED_DATA,1)
    if isempty(FIXED_DATA{i,1})
        ind=[ind;i]; %#ok<AGROW>
    else
        FIXED_DATA{i,3}=num2str(FIXED_DATA{i,3});
    end
end
FIXED_DATA(ind,:)=[];
Data{3}=num2str(Data{3});

ind = sum(ismember(FIXED_DATA,Data(:,[1:2,3])),2)==3;
xx  = cell2mat(handles.t.Data(ind,4));
yy  = cell2mat(handles.t.Data(ind,5));

set(handles.area  ,'faces',1:Nnodes ,'vertices',vertices);
set(handles.RA    ,'faces',1:NodesRA,'vertices',vertRA);
set(handles.hyp   ,'XData',X,'YData',Y);
set(handles.meshR ,'XData',xx,'YData',yy);

if ~isempty(handles.tessel)
    vor = vertcat(handles.tessel{ind,2});
    set(handles.voroni ,'XData',vor(:,1),'YData',vor(:,2));
end
set(handles.voroni2,'XData',vorR(:,1),'YData',vorR(:,2));

function handles = create_shape_select(handles,fname,Nmax,varargin)

if isempty(fname)
    return
end

delete(handles.smplot)
set(handles.smtable,'data',cell(0,3),'visible','off');

shape = shaperead(fname, 'UseGeoCoords', true);

Lon   = horzcat(shape.Lon);
Lat   = horzcat(shape.Lat);
ch = findall(handles.ax1,'tag','shape1');
ch.XData=Lon;
ch.YData=Lat;

j=[];
for i=1:length(shape)
    if length(shape(i).Lon)<Nmax
        j=[j,i]; %#ok<*AGROW>
    end
end
shape(j)=[];
Ng = size(shape,1);
mLat = zeros(Ng,1);

for i=1:Ng
    mLat(i)=max(shape(i).BoundingBox(:,2));
end

[~,ind]=sort(mLat,'descend');
shape=shape(ind);

handles.shape = shape;

if nargin == 4
    ac = varargin{1};
else
    ac = false(length(shape),1);
end

for i=1:length(shape)
    x  = shape(i).Lon;
    y  = shape(i).Lat;
    fn = find(isnan(x));
    pos = [1,fn(1:end-1)+1;fn-1]';
    sfaces = diff(pos,1,2)+1;
    faces  = nan(size(pos,1),max(sfaces));
    for ii=1:length(fn)
        IND = 1:sfaces(ii);
        faces(ii,IND)=pos(ii,1):pos(ii,2);
    end
    
    handles.smplot(i) = patch('vertices',[x(:),y(:)],'faces',faces);
    set(handles.smplot(i),'parent',handles.ax1,'visible','off','edgecolor','none','facecolor',[0.8 1 0.7],'ButtonDownFcn',@ax1_ButtonDownFcn2,'tag','regionedge');
    handles.shape(i).active=ac(i);
	handles.shape(i).faces = faces;
    uistack(handles.smplot(i),'bottom')
end

h = findall(handles.ax1,'tag','gmap');
uistack(h,'bottom')

smtable = cell(Ng,2);
for i=1:Ng
    smtable{i,1}=['shape_',num2str(i)];
    smtable{i,2}=ac(i);
end
set(handles.smtable,'data',smtable,'visible','on');
handles=create_mesh_select(handles);


function ax1_ButtonDownFcn2(hObject, ~, ~)

handles = guidata(hObject);
coordinates = get(handles.ax1,'CurrentPoint');
coordinates = [coordinates(1,[2,1]),0];
set(handles.siteclick,'xdata',coordinates(2),'ydata',coordinates(1),'linestyle','none');
set(handles.latitude_single,'string',num2str(coordinates(1)));
set(handles.longitude_single,'string',num2str(coordinates(2)));
guidata(hObject,handles);

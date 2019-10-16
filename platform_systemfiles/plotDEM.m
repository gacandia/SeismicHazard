function[]=plotDEM(vertices,faces,value,ellipsoid)

fig=figure;
set(fig,'position',[403   246   886   420],'color',[1 1 1])
fig.MenuBar='none';
ax = axes;
cameratoolbar(fig);
vertices2 = vertices;
vertices2(:,1)=vertices2(:,1)-min(vertices2(:,1));
vertices2(:,2)=vertices2(:,2)-min(vertices2(:,2));

R= EarthRadius(vertices(:,1),ellipsoid);
vertices2(:,1:2)=vertices2(:,1:2).*[R R]*pi/180;

set(ax,'box','on','nextplot','add','fontsize',10)
rotate3d(ax);

switch size(faces,2)
    case 2    , val=1;edgecol='k';
    otherwise , val=0;edgecol='none';
end

p=patch(...
    'parent',ax,...
    'vertices',vertices,...
    'faces',faces,...
    'FaceVertexCData',value,...
    'FaceColor','interp',...
    'edgecolor',edgecol);
xlabel(ax,'Long (°)')
ylabel(ax,'Lat (°)')

dar=get(ax,'dataaspectratio');
dar1=[mean(dar(1:2))*[1 1],dar(3)];
dar2=[mean(dar(1:2))*[1 1],dar(3)*pi/180];
set(ax,'dataaspectratio',dar1)

H=colorbar;
set(get(H,'title'),'string','Elev (km)')


% Create push button
b1 = uicontrol('Style', 'checkbox', 'String', 'Grid',...
    'Position', [20 20 50 20],...
    'value',0,...
    'background',[1 1 1],...
    'Callback', @addgrid); %#ok<*NASGU>

b2 = uicontrol('Style', 'checkbox', 'String', 'Box',...
    'Position', [20 50 50 20],...
    'value',1,...
    'background',[1 1 1],...
    'Callback', @addbox);


switch size(faces,2)
    case 2    , val=1;
    otherwise , val=0;
end
b3 = uicontrol('Style', 'checkbox', 'String', 'Patch Edges',...
    'Position', [20 80 100 20],...
    'value',val,...
    'background',[1 1 1],...
    'Callback', @addedges);

b4 = uicontrol('Style', 'checkbox', 'String', 'lat-long',...
    'Position', [20 110 100 20],...
    'value',1,...
    'background',[1 1 1],...
    'Callback', @addlatlong);

b5 = uicontrol('Style', 'checkbox', 'String', 'colorbar',...
    'Position', [20 140 100 20],...
    'value',1,...
    'background',[1 1 1],...
    'Callback', @addcolorbar);


    function addgrid(source,callbackdata) %#ok<*INUSD>
        switch get(source,'value')
            case 0, grid(ax,'off')
            case 1, grid(ax,'on')
        end
    end

    function addbox(source,callbackdata)
        switch get(source,'value')
            case 0, box(ax,'off')
            case 1, box(ax,'on')
        end
    end

    function addedges(source,callbackdata)
        if isnumeric(get(p,'edgecolor'))
            set(p,'edgecolor','none')
        elseif ischar(get(p,'edgecolor'))
            set(p,'edgecolor','k')
        end
    end

    function addlatlong(source,callbackdata)
        switch get(source,'value')
            case 1, set(p,'vertices',vertices);xlabel('Long (°)');ylabel('Lat (°)')
                set(gca,'dataaspectratio',dar1)
            case 0, set(p,'vertices',vertices2);xlabel('X(km)');ylabel('Y(km)')
                set(gca,'dataaspectratio',dar2)
        end
    end

    function addcolorbar(source,callbackdata)
        switch get(source,'value')
            case 0, set(H,'visible','off')
            case 1, set(H,'visible','on')
        end
    end

end

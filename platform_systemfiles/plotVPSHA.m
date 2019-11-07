function plotVPSHA(handles)

C = findall(handles.figure1,'tag','cbar');
switch handles.butt2.Value
    case 0, set(get(C,'Title'),'String','MRE')
    case 1, set(get(C,'Title'),'String','MRD')
end
delete(findall(handles.figure1,'tag','cbar'))
if ~isfield(handles,'MRE'), return; end

switch handles.butt2.Value
    case 0, y = handles.MRE; str = 'MRE';
    case 1, y = handles.MRD; str = 'MRD';
end

x1 = handles.im(:,1);
x2 = handles.im(:,2);

delete(findall(handles.ax1,'tag','pat'))
delete(findall(handles.ax1,'tag','pat2'))

set(handles.ax1,'xscale','log','yscale','log','zscale','linear','xlim',x1([1 end]),'ylim',x2([1 end]))
view(handles.ax1,[0 90])
xlabel(handles.ax1,IM2str(handles.IM(1)),'fontsize',10)
ylabel(handles.ax1,IM2str(handles.IM(2)),'fontsize',10)
zlabel(handles.ax1,str,'fontsize',10)

modo = ismember({handles.ptype1.Checked,handles.ptype2.Checked,handles.ptype3.Checked},'on');
switch find(modo)
    case 1
        tplot(handles.ax1,x1,x2,y,1);
    case 2
        tplot(handles.ax1,x1,x2,y,2);
        switch handles.butt2.Value
            case 0,handles.ax1.ZScale='log';
            case 1,handles.ax1.ZScale='linear';
        end
        if handles.butt2.Value==0 && contains(handles.scalarhazard.Checked,'on')
            im = handles.im; o  = ones(size(im,1),1);
            plot3(im(:,1)   ,im(1,2).^o ,handles.lambda(:,1),'r.-','tag','pat2');
            plot3(im(1,1).^o,im(:,2)    ,handles.lambda(:,2),'r.-','tag','pat2');
        end
    case 3
        tplot(handles.ax1,x1,x2,y,3);
end

caxis([min(y(:)) max(y(:))])
colorbar('peer',handles.ax1,'location','eastoutside','tag','cbar');
handles.ax1.Layer='top';

function F=tplot(ax,im1,im2,rho,ptype)

[T1,T2] = meshgrid(im1,im2);
p       = [T1(:),T2(:)];
F       =  scatteredInterpolant(log(T1(:)),log(T2(:)),rho(:),'linear','none');
nx      = length(im1);
ny      = length(im2);
nsource = reshape(1:nx*ny,nx,ny);
p1 = nsource(1:end-1,1:end-1);p1=p1';p1=p1(:);
p2 = nsource(2:end,1:end-1);p2=p2';p2=p2(:);
p3 = nsource(2:end,2:end);p3=p3';p3=p3(:);
p4 = nsource(1:end-1,2:end);p4=p4';p4=p4(:);

switch ptype
    case 1
        t = [p1,p2,p3,p4];
        patch(...
            'parent',ax,...
            'vertices',p,...
            'faces',t,...
            'facevertexcdata',rho(:),...
            'facecol','interp',...
            'edgecol','none',...
            'tag','pat',...
            'ButtonDownFcn',{@site_click_VPSHA,ax,F});
        rotate3d(ax,'off')
    case 2
        t = [p1,p2,p3,p4];
        patch(...
            'parent',ax,...
            'vertices',[p,rho(:)],...
            'faces',t,...
            'facevertexcdata',rho(:),...
            'facecol','interp',...
            'edgecol','k',...
            'tag','pat',...
            'ButtonDownFcn',{@site_click_VPSHA,ax,F});
        rotate3d(ax,'on')
    case 3
        contour(ax,im1,im2,rho,30,...
            'tag','pat',...
            'ButtonDownFcn',{@site_click_VPSHA,ax,F});
        rotate3d(ax,'off')
end

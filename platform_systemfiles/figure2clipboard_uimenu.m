function figure2clipboard_uimenu(~, ~,ax,tit)

fig=figure;
copyobj(ax,fig);

set(gca,'ActivePositionProperty','outerposition')
set(gca,'Units','normalized')
set(gca,'OuterPosition',[0 0 1 1])
set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
XL=get(gca,'xlim');
YL=get(gca,'ylim');
if strcmp(get(gca,'xscale'),'linear') && strcmp(get(gca,'yscale'),'linear')
    f = uimenu('Label','akZoom');
    uimenu(f,'Label','Zoom X Y','Callback',{@switchzoom,{0,XL,YL}});
    uimenu(f,'Label','Zoom X','Callback',{@switchzoom,{1,XL,YL}});
    uimenu(f,'Label','Zoom Y','Callback',{@switchzoom,{2,XL,YL}});
end

try
    L=legend;
    L.Box='off';
catch
end

if nargin==4
    T=title(tit,'fontsize',10,'fontweight','normal');
end

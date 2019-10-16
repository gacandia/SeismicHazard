function figurecompare_uimenu(~, ~,ax)

fig = findobj(allchild(groot), 'flat', 'type', 'figure', 'number', 1000);


if isempty(fig)
    fig=figure(1000);
    copyobj(ax,fig);
    set(gca,'ActivePositionProperty','outerposition')
    set(gca,'Units','normalized')
    set(gca,'OuterPosition',[0 0 1 1])
    set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
    XL=get(gca,'xlim');
    YL=get(gca,'ylim');
    ch = findall(gcf,'tag','redballs');delete(ch);
    ch = findall(gcf,'tag','nanvalues');delete(ch);
    ch = get(gca,'title'); delete(ch);
    if strcmp(get(gca,'xscale'),'linear') && strcmp(get(gca,'yscale'),'linear')
        f = uimenu('Label','akZoom');
        uimenu(f,'Label','Zoom X Y','Callback',{@switchzoom,{0,XL,YL}});
        uimenu(f,'Label','Zoom X','Callback',{@switchzoom,{1,XL,YL}});
        uimenu(f,'Label','Zoom Y','Callback',{@switchzoom,{2,XL,YL}});
    end
else
    newlines = findall(ax,'type','line');
    copyobj(newlines,findobj(1000,'type','axes'));
    figure(1000);
    f = uimenu('Label','Data');
    uimenu(f,'Label','Flip','Callback',{@dataflip,fig});
end

function dataflip(~,~,fid)
linea = findall(fid,'type','line');
uistack(linea(end),'top');




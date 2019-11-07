function site_click_VPSHA(~, eventdata,ax,F)

delete(findall(ax,'Tag','txt'))

if eventdata.Button==1
    coordinates = get(ax,'CurrentPoint');
    x   = coordinates(1,1);
    y   = coordinates(1,2);
    Fxy = F(log(x),log(y));
    str = sprintf('%3.2g',Fxy);
    text(x,y,str,'parent',ax,'Tag','txt','visible','on');
end




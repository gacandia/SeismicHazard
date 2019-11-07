function handles=plot_geomean(handles)

if handles.showgeomean.Value==1
    ch=get(handles.axes3,'children');
    [~,B]=intersect(char(ch.Tag),'design','rows');
    ch(B)=[];
    
    if isempty(ch)
        return
    end
    x=ch(1).XData;
    y=vertcat(ch.YData);

    % nangeomean
    n = sum(~isnan(y),1);
    y=exp(nansum(log(y),1)./n);
    
    plot(handles.axes3,x,y,'r','tag','geomean');
end
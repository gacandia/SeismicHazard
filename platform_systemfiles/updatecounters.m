function updatecounters(handles)

t1=sum(cell2mat(handles.tabla.Data(:,13)));
t2=sum(cell2mat(handles.tabla.Data(:,14)));
t3=sum(cell2mat(handles.tabla.Data(:,15)));

handles.countH1.String=['# H1 = ',num2str(t1)];
handles.countH2.String=['# H2 = ',num2str(t2)];
handles.countUP.String=['# UP = ',num2str(t3)];
handles.CountAll.String=['Total = ',num2str(t1+t2+t3)];
function handles=parsetup(handles)

switch get(handles.Parpoolsetup,'checked')
    case 'on',set(handles.Parpoolsetup,'checked','off')
    case 'off',set(handles.Parpoolsetup,'checked','on')
end

switch get(handles.Parpoolsetup,'checked')
    case 'on' % turn on
        distcomp.feature( 'LocalUseMpiexec', false );
        poolobj = gcp;
        handles.poolsize=poolobj.NumWorkers;
        
    case 'off' % turn off
        distcomp.feature( 'LocalUseMpiexec', false );
        delete(gcp)
        handles.poolsize=0;
end




  

  
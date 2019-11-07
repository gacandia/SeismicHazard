function u=getGRDfield(handles,modo)

% mod = 0, gets fields from PSHA
% mod = 1, gets fields from user defined UHS
% GRD analysis.
% This code performs a super-fast search of IM associated to the
% specified return period.

switch modo
    case 'PSHA'
        val       = handles.select_IM.Value;
        model_ptr = handles.IM_menu.Value;
        site_ptr  = handles.site_menu.Value;
        IM        = handles.data.T(val-1);
        site      = handles.h.p(site_ptr,:);
        Vs30      = handles.h.Vs30(site_ptr);
        Ns        = length(handles.model(model_ptr).source);
        haz       = 1/str2double(handles.retperiod.String);
        RSR       = handles.data.MapRSR(:,:,val-1);
        
        % round 1: seach of PGA
        im        = logsp(0.01,3,5)';
        MRE       = runhazard1(im,IM,site,Vs30,handles.opt,handles.model(model_ptr),Ns,1);
        MRE       = nansum(MRE,4)';
        IM0       = exp(interp1(log(MRE),log(im),log(haz),'spline'));
        
        % round 2
        immin     = 0.98*IM0;
        immax     = 1.02*IM0;
        im        = logsp(immin,immax,5)';
        MRE       = runhazard1(im,IM,site,Vs30,handles.opt,handles.model(model_ptr),Ns,1);
        MRE       = nansum(MRE,4)';
        IM0       = exp(interp1(log(MRE),log(im),log(haz),'spline'));
        u         = RSR*IM0;
    case 'Event'
        val       = handles.select_IM.Value;
        To        = handles.data.T(val-1);
        x         = handles.uhs(:,1);
        y         = handles.uhs(:,2);
        IM0       = exp(interp1(log(x),log(y),log(To),'spline'));
        RSR       = handles.data.MapRSR(:,:,val-1);
        u         = RSR*IM0;
end
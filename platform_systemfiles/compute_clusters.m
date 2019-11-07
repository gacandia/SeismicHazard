function[indx,hc]=compute_clusters(handles)

indx      = [];
hc.id     = cell(0,1);
hc.p      = zeros(0,3);
hc.Vs30   = [];
hc.t      = cell(0,2);
hc.shape  = [];

switch handles.opt.Clusters{1}
    case 'off'
        
    case 'on'
        Nsites = length(handles.h.id);
        if Nsites==0
            return
        end
        
        Nc = min(handles.opt.Clusters{2}(1),Nsites);
        if Nsites==Nc
            indx = 1:Nsites;
            hc   = handles.h;
        else
            Nr = handles.opt.Clusters{2}(2);
            stream  = RandStream('mlfg6331_64');  % Random number stream
            options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);
            
            % Lat,Lon,Elev clusters
            [indx,Y] = kmeans([handles.h.p,handles.h.Vs30],Nc,'Options',options,'MaxIter',10000,'Display','final','Replicates',Nr);
            hc.id    = compose('C%i',1:Nc)';
            hc.p     = Y(:,1:3);
            hc.Vs30  = Y(:,4);
        end
        
end

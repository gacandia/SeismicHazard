function[indx,hc]=compute_clusters(handles)

indx      = [];
hc.p      = cell(0,4);
hc.t      = cell(0,2);
hc.shape  = [];
hc.lmax   = 50;
hc.Vs30   = [];

switch handles.opt.Clusters{1}
    case 'off'
        
    case 'on'
        Nsites = size(handles.h.p,1);
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
            [indx,Y] = kmeans(cell2mat((handles.h.p(:,2:4))),Nc,'Options',options,'MaxIter',10000,'Display','final','Replicates',Nr);
            hc.p     = cell(Nc,4);
            hc.p(:,2:4)=num2cell(Y);
            str = strtrim(sprintf(repmat('C%i ',1,Nc),1:Nc));
            str = textscan(str,'%s','Delimiter',' ')';
            hc.p(:,1)= str{1};
            Vs30    = handles.h.Vs30;
            hc.Vs30 = zeros(Nc,1);
            for i=1:Nc
                hc.Vs30(i)=mean(Vs30(indx==i));
            end
        end
        
end

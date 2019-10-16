function export_siberrisk_nitro(handles)

handles.out.accunits  = handles.accunits;
handles.out.filterOpt = handles.param;
ROOT      = handles.pathname;
out       = handles.out;
Neq       = size(handles.tabla.Data,1);
do_H1     = any(out.compoments([1,4,5,6]));
do_H2     = any(out.compoments([2,4,5,6]));
do_HZ     = out.compoments(3);
do_GM     = out.compoments(4);
do_RotDpp = any(out.compoments([5 6])); Dpp = out.compoments(7);
% do_RotIpp = out.compoments(6);          Ipp = out.compoments(8);

%% loads horizontal component H1
if do_H1
    fprintf('Loading Horizontal Component H1\n')
    [H1,ind1] = buildGMstruct(handles,'H1');
    parfor i=1:length(H1)
        if ind1(i)
            fprintf('%g - %3.3f\n',labindex,i/Neq);
            FULLPATH = fullfile(ROOT,H1(i).earthquake,H1(i).filename);
            H1(i)    = retrieveIM(@readSIBERRISK,H1(i),FULLPATH,out);
        end
    end
end

%% loads horizontal component H2
if do_H2
    fprintf('Loading Horizontal Component H2\n')
    [H2,ind2] = buildGMstruct(handles,'H2');
    parfor i=1:length(H2)
        if ind2(i)
            fprintf('%g - %3.3f\n',labindex,i/Neq);
            FULLPATH = fullfile(ROOT,H2(i).earthquake,H2(i).filename);
            H2(i)   = retrieveIM(@readSIBERRISK,H2(i),FULLPATH,out);
        end
    end
end

%% loads vertical component HZ
if do_HZ
    fprintf('Loading Vertical Component HZ\n')
    [HZ,ind3] = buildGMstruct(handles,'HZ');
    parfor i=1:length(HZ)
        if ind3(i)
            fprintf('%g - %3.3f\n',labindex,i/Neq);
            FULLPATH = fullfile(ROOT,HZ(i).earthquake,HZ(i).filename);
            HZ(i)   = retrieveIM(@readSIBERRISK,HZ(i),FULLPATH,out);
        end
    end
end

%% GEOMETRIC MEAN
if do_GM
    fprintf('Computing Geometric Mean GM\n')
    GM = buildGMstruct(handles,'Geometric Mean');
    GM = GMSelect_GeometricMean(GM,H1,H2,out);
end

%% RotDpp
if do_RotDpp
    fprintf('Computing Orientation-Independent Geometric Mean, Using Period-Dependent Rotation Angles, RotDpp\n')
    RotDpp = buildGMstruct(handles,sprintf('RotD%g',Dpp));
    RotDpp = GMSelect_RotDpp(RotDpp,H1,H2,Dpp,out,ROOT);
end

%% RotIpp future development
% if do_RotIpp
%     fprintf('GMRotIpp: Orientation-Independent Geometric Mean, Using Period-Independent Rotation Angle, RotIpp\n')
%     RotIpp = buildGMstruct(handles,sprintf('RotD%g',Ipp));
%     RotIpp = GMSelect_RotIpp(RotIpp,H1,H2,Ipp,out,ROOT);
% end

%% collect data
comp = out.compoments(1:6);
ind  = find(comp);
eq   = repmat(buildGMstruct(handles,''),1,length(ind));
cont = 0;
for i=1:length(ind)
    cont=cont+1;
    switch ind(i)
        case 1,eq(:,cont)=H1;
        case 2,eq(:,cont)=H2;
        case 3,eq(:,cont)=HZ;
        case 4,eq(:,cont)=GM;
        case 5,eq(:,cont)=RotDpp;
            %case 6,eq(:,cont)=RotIpp;
    end
end

%%
fname = out.fname;
save(fname,'eq')
[FOLD,FILE,EXT]=fileparts(fname);
ffile = [FILE,EXT];
uiwait(msgbox(['File ',ffile,' saved to ',FOLD],'Ground Motion Selection','modal'));



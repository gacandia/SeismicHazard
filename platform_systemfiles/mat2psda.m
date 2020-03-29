function[handles]=mat2psda(handles,varargin)

%% loads sys, opt, h, model
if nargin==3
    pathname=varargin{1};
    filename=varargin{2};
    if contains(filename,'.mat')
        load([pathname,filename],'sys','opt','h')
    elseif contains(filename,'.txt')
        [sys,opt,h]=loadPSHA(fullfile(pathname,filename));
    end
elseif nargin==5
    sys    = varargin{1};
    opt    = varargin{3};
    h      = varargin{4};
end

opt.MagDiscrete  = {'uniform',0.1};
models           = process_model(sys,opt);
isREGULAR        = horzcat(models.isregular);
handles.sys      = sys;
handles.model    = models(isREGULAR==1);
handles.modelcdm = models(isREGULAR==0);
handles.opt      = opt;
handles.h        = h;
ME               = pshatoolbox_methods(5);

%% updates weights
handles.sys.WEIGHT = handles.sys.WEIGHT(isREGULAR==1,:);
handles.sys.WEIGHT(:,4) = handles.sys.WEIGHT(:,4)/sum(handles.sys.WEIGHT(:,4));
handles.sys.WEIGHT(:,1:3)=nan; 

%% loads default models
func   = {ME.str};
ptrs   = sys.PTRS;

[d_default,Sadef,Ddef,SMLIB_default,default_reg,default_cdm]=loadPSDADefaultParam(handles.model,handles.modelcdm);

% d values
if ~isnan(ptrs(10,1))
    str = sys.DATA(ptrs(10,1):ptrs(10,2),:);
    str = regexp(str,'\ : ','split');
    handles.paramPSDA.d         = eval(str{1}{2});
    handles.paramPSDA.realSa    = str2double(str{2}{2});
    handles.paramPSDA.realD     = str2double(str{3}{2});
    handles.paramPSDA.imhazard  = str{4}{2};
    handles.paramPSDA.rng       = str{5}{2};
    handles.paramPSDA.method    = str{6}{2};
    handles.paramPSDA.optimize  = str{7}{2};
else
    handles.paramPSDA.d         = d_default;
    handles.paramPSDA.realSa    = Sadef;
    handles.paramPSDA.realD     = Ddef;
    handles.paramPSDA.imhazard  = 'full';
    handles.paramPSDA.rng       = 'shuffle';
    handles.paramPSDA.method    = 'MC';
    handles.paramPSDA.optimize  = 'on';
    
end

% ky and Ts
if ~isnan(ptrs(11,1))
    str = sys.DATA(ptrs(11,1):ptrs(11,2),:);
    str = regexp(str,'\ : ','split');
    
    % param 1
    fld = [str{1}{1},'_param'];
    val = lower(regexp(str{1}{2},'\ ','split'));
    val = struct(val{:});
    handles.(fld) = [str2double(val.mean),str2double(val.cov),str2double(val.samples)];
    
    %param2
    fld = [str{2}{1},'_param'];
    val = lower(regexp(str{2}{2},'\ ','split'));
    val = struct(val{:});
    handles.(fld) = [str2double(val.mean),str2double(val.cov),str2double(val.samples)];
else
    handles.Ts_param = default_reg.Ts_param;
    handles.ky_param = default_reg.ky_param;
end

% displacement model library
if ~isnan(ptrs(12,1))
    
    str = sys.DATA(ptrs(12,1):ptrs(12,2),:);
    str = regexp(str,'\ handle ','split');
    
    Nmodels = length(str);
    SMLIB(1:Nmodels,1) = struct('id',[],'label',[],'str',[],'func',[],'isregular',[],'integrator',[],'primaryIM',[],'Safactor',[]);
    for i=1:Nmodels
        stri = regexp(str{i}{2},'\ ','split');
        [~,C]=intersect(func,stri{1});
        SMLIB(i).id = str{i}{1};
        SMLIB(i).str        = ME(C).str;
        SMLIB(i).func       = ME(C).func;
        SMLIB(i).isregular  = ME(C).isregular;
        SMLIB(i).integrator = ME(C).integrator;
        SMLIB(i).primaryIM  = ME(C).primaryIM;
        SMLIB(i).Safactor   = ME(C).Safactor;
        SMLIB(i).param      = [];
        if length(stri)>2
            fixparam = struct(stri{2:end});
            flds     = fields(fixparam);
            for j=1:length(flds)
                fixparam.(flds{j})=str2double(fixparam.(flds{j}));
            end
            SMLIB(i).param   = fixparam;
        end
    end
    handles.sys.SMLIB=SMLIB;
else
    handles.sys.SMLIB = SMLIB_default;
end

% Displacement Models for regular PSDA Analysis
if ~isnan(ptrs(13,1))
    str = sys.DATA(ptrs(13,1):ptrs(13,2),:);
    Nmodels = size(str,1)-1;
    T3    = cell(Nmodels,6);
    newline = regexp(str{1},'\ ','split');
    slopeweights = str2double(newline(3:end)');
    slopeweights = slopeweights / sum(slopeweights);
    T3(:,6) = num2cell(slopeweights);
    
    str(1,:)=[];
    
    for j=1:Nmodels
        strj = regexp(str{j},'\ ','split');
        T3{j,1}=strj{1};
        modelassig = struct(strj{2:9});
        T3{j,2} = modelassig.interface;
        T3{j,3} = modelassig.intraslab;
        T3{j,4} = modelassig.crustal;
        T3{j,5} = modelassig.grid;
    end
    handles.T3=T3;
else
    handles.T3=default_reg.T3;
end

%% Displacement Models for CDM PSDA Analysis
if ~isnan(ptrs(14,1))
    str = sys.DATA(ptrs(14,1):ptrs(14,2),:);
    str = regexp(str,'\ ','split');
    
    Nmodels  = size(str,1);
    DataCDM  = cell(Nmodels,7);
    
    notCDM  = zeros(Nmodels,1);
    for j=1:Nmodels
        [~,Bj]=intersect(sys.BRANCH,str2double(str{j}(3:5)),'rows');
        modelassig   = struct(str{j}{6:end});
        model_ID     = models(Bj).id;
        if contains(model_ID,'(CGMM)')
            DataCDM{j,1} = model_ID;
            DataCDM{j,2} = sprintf('%s, %s',modelassig.meanTs,modelassig.covTs);
            DataCDM{j,3} = sprintf('%s, %s',modelassig.meanky,modelassig.covky);
            DataCDM{j,4} = modelassig.interface;
            DataCDM{j,5} = modelassig.intraslab;
            DataCDM{j,6} = modelassig.crustal;
            DataCDM{j,7} = modelassig.grid;
        else
            fprintf('Warning: Hazard from model ID: "%s" is not CGMM-compatible\n',model_ID)
            notCDM(j)=true;
        end
    end
    DataCDM(notCDM==1,:)=[];
    
    isCDMGMM = ~horzcat(SMLIB.isregular);
    handles.tableCDM.ColumnFormat{4}={SMLIB(isCDMGMM).id};
    handles.tableCDM.ColumnFormat{5}={SMLIB(isCDMGMM).id};
    handles.tableCDM.ColumnFormat{6}={SMLIB(isCDMGMM).id};
    handles.tableCDM.ColumnFormat{7}={SMLIB(isCDMGMM).id};
    handles.tableCDM.Data = DataCDM;
    
else
    if ~isempty(handles.modelcdm)
        handles.tableCDM.Data = default_cdm;
    end
end

%% setup GUI for regular models
if any(isREGULAR)
    handles.pop_site.String=handles.h.id;
    handles.pop_site.Enable='on';
    handles.pop_site.Value=1;
    
    % Tables T1,T2
    pshaweights = sys.WEIGHT(isREGULAR==1,4);
    w1          = pshaweights/sum(pshaweights);
    id          = {handles.model.id}';
    handles.T1  = [id,num2cell(w1)];
    [Ts,~,dPTs] = trlognpdf_psda(handles.Ts_param);
    [ky,~,dPky] = trlognpdf_psda(handles.ky_param);
    Ts          = round(Ts*1e10)/1e10;
    [ind1,ind2] = meshgrid(1:length(Ts),1:length(ky));
    ind1        = ind1(:);
    ind2        = ind2(:);
    Nparam      = length(ind1);
    param_id    = cell(Nparam,1);
    for i=1:Nparam
        param_id{i}=sprintf('set%g',i);
    end
    handles.T2  = [param_id,num2cell([Ts(ind1),ky(ind2),dPTs(ind1).*dPky(ind2)])];
    
    [handles.tableREG.Data,handles.IJK]=main_psda(handles.T1,handles.T2,handles.T3);
    handles.EditLogicTree.Enable='on';
end

%% two models
if ~isempty(handles.model) && ~isempty(handles.modelcdm)
    handles.mode1.Value       = 1;
    handles.tableREG.Enable   = 'on';
    handles.runREG.Enable     = 'on';
    handles.treebutton.Enable = 'on';
    handles.REG_DisplayOptions.Enable = 'on';
    handles.tableCDM.Enable = 'off';
    handles.runCDM.Enable   = 'inactive';
    handles.CDM_DisplayOptions.Enable='inactive';
end

%% REG yes, CDM no
if ~isempty(handles.model) && isempty(handles.modelcdm)
    handles.mode1.Value       = 1;
    handles.tableREG.Enable   = 'on';
    handles.runREG.Enable     = 'on';
    handles.treebutton.Enable = 'on';
    handles.REG_DisplayOptions.Enable = 'on';
    handles.tableCDM.Enable = 'off';
    handles.runCDM.Enable   = 'inactive';
    handles.CDM_DisplayOptions.Enable='inactive';
end

%% REG yes, CDM no
if isempty(handles.model) && ~isempty(handles.modelcdm)
    handles.mode2.Value       = 1;
    handles.tableREG.Enable   = 'off';
    handles.runREG.Enable     = 'inactive';
    handles.treebutton.Enable = 'inactive';
    handles.REG_DisplayOptions.Enable = 'inactive';
    handles.tableCDM.Enable = 'on';
    handles.runCDM.Enable   = 'on';
    handles.CDM_DisplayOptions.Enable='on';
end

%% validation data
ind1 =sys.PTRS(15,1);
ind2 =sys.PTRS(15,2);
if ~isnan(ind1)
    line          = regexp(sys.DATA{ind1},'\ ','split');
    handles.sys.D = str2double(line(1,2:end));
    ND            = length(handles.sys.D);
    line          = sys.DATA(ind1+1:ind2,:);
    Nrows         = size(line,1);
    handles.sys.Dlabels     = cell(Nrows,1);
    handles.sys.lambdaDTest = zeros(Nrows,ND);
    
    for i=1:size(line,1)
        line_i = regexp(line{i},'\ ','split');
        lab_i  = strjoin(line_i(1:end-ND),' ');
        line_i = line_i(end-ND+1:end);
        handles.sys.Dlabel{i}=lab_i;
        handles.sys.lambdaDTest(i,:)=str2double(line_i);
    end
end

%% SPC Data
ind1 =sys.PTRS(16,1);
ind2 =sys.PTRS(16,2);
if ~isnan(ptrs(16,1))
    line1 = regexp(sys.DATA{ind1},'\ ','split');
    line2 = regexp(sys.DATA{ind2},'\ ','split');
    handles.SPCData=[1/eval(line1{2}),str2double(line2{2})];
end


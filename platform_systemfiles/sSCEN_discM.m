function[handles]=sSCEN_discM(handles,varargin)

if strcmp(handles.UniformBins.Checked       ,'on'),method = 'UNI'; end
if strcmp(handles.GaussianSampling.Checked ,'on'), method = 'GS';  end
if strcmp(handles.ImportantSampling.Checked,'on'), method = 'IS';  end

if nargin==1
    current = handles.current(:,1)';
    if isempty(current),return;end
    
    switch method
        case 'UNI'
            answer=inputdlg({'Number of Sampling Points'},...
                'UNI Sampling',[1,50],...
                {'10'});
            if isempty(answer)
                return
            end
            answerN    = str2double(answer(1));
            nM_default = round(answerN(1));
            nM_default = repmat(nM_default,length(current),1);
            
        case 'GS'
            answer=inputdlg({'Number of Sampling Points'},...
                'Gauss Sampling',[1,50],...
                {'10'});
            if isempty(answer)
                return
            end
            answerN    = str2double(answer(1));
            nM_default = round(answerN(1));
            nM_default = repmat(nM_default,length(current),1);
            
        case 'IS'
            answer=inputdlg({'Number of Sampling Points','alfa'},...
                'Important Sampling',[1,50],...
                {'10','0.8'});
            if isempty(answer)
                return
            end
            answerN    = str2double(answer(1:2));
            nM_default = round(answerN(1));
            alfa       = answerN(2);
    end
    
elseif nargin==2
    current    = handles.current(:,1)';
    twiz       = varargin{1};
    nM_default = vertcat(twiz{:,3});
    alfa       = 0.8;
end

cont=0;
for row = current
    cont=cont+1;
    DataM = handles.t.Data(row,:);
    
    mlib = handles.t.ColumnFormat{1};
    [~,ptr1] = intersect(mlib,DataM{1});
    slib = handles.t.ColumnFormat{2};
    [~,ptr2] = intersect(slib,DataM{2});
    
    source  = handles.model(ptr1).source(ptr2);
    msparam = source.mscl.msparam;
    Taper   = handles.TaperEnds.Checked;
    
    
    switch func2str(source.mscl.handle)
        case 'delta'
            nM = 1;
            msparam.Mmax = msparam.M; %dirt trick
            msparam.Mmin = msparam.M; %dirt trick
            
        case {'truncexp','truncnorm','youngscoppersmith'}
            nM = nM_default(cont);
            
    end
    
    switch Taper
        case 'off', Mmax = msparam.Mmax;
        case 'on' , Mmax = getMMax(source,msparam.Mmax,DataM{4},DataM{5});
    end
    Mmin      = min(msparam.Mmin,Mmax);
    
    % MAGNITUDE SAMPLING
    invfun  = str2func(['inv',func2str(source.mscl.handle)]);
    
    switch method
        case 'UNI' % Uniform Bins
            M    = linspace(Mmin,Mmax,nM+1);
            [~,mcdf]=source.mscl.handle(M,msparam);
            m     = M(1:end-1)+diff(M)/2;
            rateM = diff(mcdf);
        case 'GS'
            M = gaussquad(nM+1,[Mmin,Mmax]);
            M(1)=Mmin;M(end)=Mmax;
            [~,mcdf] = source.mscl.handle(M,msparam);
            m     = M(1:end-1)+diff(M)/2;
            rateM = diff(mcdf);
            
            
        case 'IS'  % Imortant Sampling of M
            DM   = (Mmax-Mmin)/sum(alfa.^(0:nM-1));
            M      = Mmin+[0,DM*cumsum(alfa.^(0:nM-1))];
            [~,mcdf] = source.mscl.handle(M,msparam);
            m     = M(1:end-1)+diff(M)/2;
            rateM = diff(mcdf);
    end
    
    switch func2str(source.mscl.handle)
        case 'delta'
            rateM    = 1;
            mi       = invfun(0.5,msparam);
            DataM    = repmat(DataM,nM,1);
            DataM(:,[3,7])=num2cell([mi,rateM]);
            handles.t.Data(row,:)=[];
            handles.t.Data=[handles.t.Data;DataM];
            handles.tessel(row,:)=[];
            emptytessel = repmat({[],zeros(0,2)},nM,1);
            handles.tessel=[handles.tessel;emptytessel];
        otherwise
            DataM    = repmat(DataM,nM,1);
            DataM(:,[3,7])=num2cell([m(:),rateM(:)]);
            handles.t.Data=[handles.t.Data;DataM];
            emptytessel = repmat({[],zeros(0,2)},nM,1);
            handles.tessel=[handles.tessel;emptytessel];
    end
end

handles.t.Data(current,:)=[];
handles.tessel(current,:)=[];


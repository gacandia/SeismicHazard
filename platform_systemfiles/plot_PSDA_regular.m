function plot_PSDA_regular(handles)

if ~isfield(handles,'sys'), return;end
if ~isfield(handles,'lambdaD'),return;end

delete(findall(handles.ax1,'type','line'));
handles.ax1.NextPlot='add';
handles.ax1.ColorOrderIndex=1;
site_ptr = handles.pop_site.Value;

haz  = handles.REG_Display;
d    = handles.paramPSDA.d;
flatcolor=handles.ColorSecondaryLines.Value;
gris = [0.76 0.76 0.76];

if haz.L0
    lambdaD = nansum(handles.lambdaD(site_ptr,:,:,:),3);
    lambdaD = permute(lambdaD,[4 2 3 1]);
    
    if haz.L6 % CDM branches
        lam1 = lambdaD;
        lam1(lam1==0)=nan;
        Nbranch = size(lambdaD,1);
        str = compose('Branch %i',1:Nbranch);
        ind = find(any(lambdaD,2))';
        for jj=ind
            if flatcolor
                plot(handles.ax1,d',lam1(jj,:)','color',gris,'DisplayName',str{jj})
            else
                plot(handles.ax1,d',lam1(jj,:)','DisplayName',str{jj})
            end
        end
    end
    
    handles.ax1.ColorOrderIndex=1;
    
    if haz.L1 % default weights
        handles.table.Data = main_psda(handles.T1,handles.T2,handles.T3);
        weights = cell2mat(handles.table.Data(:,end));
        lam2    = nanprod(bsxfun(@power,lambdaD,weights),1);
        plot(handles.ax1,d',lam2','linewidth',2,'DisplayName','Default Weights');
    end
    
    if haz.L2 % random weights
        weights = handles.REG_Display.rnd;
        handles.table.Data(:,4)=num2cell(weights);
        lam2 = nanprod(bsxfun(@power,lambdaD,weights),1);
        plot(handles.ax1,d',lam2','linewidth',2,'DisplayName','Random Weights');
    end
    
    if haz.L3 % mean
        lambdaD(lambdaD<0)=nan;
        lam2 = exp(nanmean(log(lambdaD),1));
        plot(handles.ax1,d',lam2','linewidth',2,'DisplayName','Mean');
    end
    
    if haz.L4 % percentiles
        percentile = haz.L5;
        str  = compose('Percentile %g',percentile);
        Nt   = length(str);
        handles.table.Data(:,4)=cell(Nt,1);
        lambdaD(lambdaD<0)=nan;
        lam2 = exp(prctile(log(lambdaD),percentile,1));
        for jj=1:Nt
            plot(handles.ax1,d',lam2(jj,:)','linewidth',2,'DisplayName',str{jj});
        end
    end
    
    Leg=legend(handles.ax1);
    Leg.FontSize=8;
    Leg.Box='off';
    Leg.Location='SouthWest';
    Leg.Tag='hazardlegend';
    
    switch handles.toggle1.Value
        case 0,Leg.Visible='off';
        case 1,Leg.Visible='on';
    end
end

if haz.R0
    branch_ptr = haz.R1;
    lambdaD    = handles.lambdaD(site_ptr,:,:,branch_ptr);
    lambdaD    = permute(lambdaD,[2 3 1]);
    lam2       = nansum(lambdaD,2)';
    
    if haz.R2 % displays source contribution
        haz_ptr      = handles.IJK(branch_ptr,1);
        NOTZERO      = nansum(lambdaD,1)>-1;
        source_label = {handles.model(haz_ptr).source.label};
        str          = source_label(NOTZERO);
        lam1         = lambdaD(:,NOTZERO)';
        handles.ax1.ColorOrderIndex=1;
        
        for jj=1:size(lam1,1)
            if flatcolor
                plot(handles.ax1,d,lam1(jj,:),'color',gris,'DisplayName',str{jj})
            else
                plot(handles.ax1,d,lam1(jj,:),'DisplayName',str{jj})
            end
        end
        
    end
    
    if haz.R3 % displays mechanism contribution
        model_ptr  = handles.IJK(branch_ptr,1);
        mechs      = {handles.model(model_ptr).source.mechanism};
        m1         = strcmp(mechs,'system');
        m2         = strcmp(mechs,'interface');
        m3         = strcmp(mechs,'intraslab');
        m4         = strcmp(mechs,'slab');
        m5         = strcmp(mechs,'crustal');
        m6         = strcmp(mechs,'shallowcrustal');
        m7         = strcmp(mechs,'fault');
        m8         = strcmp(mechs,'grid');
        lambdaD    = [nansum(lambdaD(:,m1),2) nansum(lambdaD(:,m2),2) nansum(lambdaD(:,m3),2) nansum(lambdaD(:,m4),2) nansum(lambdaD(:,m5),2) nansum(lambdaD(:,m6),2) nansum(lambdaD(:,m7),2) nansum(lambdaD(:,m8),2)];
        NOTNAN     = (nansum(lambdaD,1)>0);
        lam1       = lambdaD(:,NOTNAN)';
        handles.ax1.ColorOrderIndex=1;
        handles.ax1.ColorOrderIndex=1;
        mechs = {'system','interface','intraslab','slab','crustal','shallowcrustal','fault','grid'};
        str = mechs(NOTNAN);
        
        for jj=1:length(str)
            if flatcolor
                handles.ax1.ColorOrderIndex=1;
                plot(handles.ax1,d,lam1(jj,:),'color',gris,'DisplayName',str{jj});
            else
                plot(handles.ax1,d,lam1(jj,:),'DisplayName',str{jj});
            end
        end
    end
    handles.ax1.ColorOrderIndex=1;
    plot(handles.ax1,d',lam2','linewidth',2,'DisplayName','Mean');
    
    Leg=legend(handles.ax1);
    Leg.FontSize=8;
    Leg.EdgeColor=[1 1 1];
    Leg.Location='SouthWest';
    Leg.Tag='hazardlegend';
    switch handles.toggle1.Value
        case 0,Leg.Visible='off';
        case 1,Leg.Visible='on';
    end
end

axis(handles.ax1,'auto')
cF   = get(0,'format');
format long g
if exist('lam1','var')
    data = num2cell([d;lam2;lam1]); % branches
else
    data = num2cell([d;lam2]); % average
end
c    = uicontextmenu;
uimenu(c,'Label','Copy data','Callback',        {@data2clipboard_uimenu,data'});
uimenu(c,'Label','Undock','Callback',           {@figure2clipboard_uimenu,handles.ax1});
uimenu(c,'Label','Undock & compare','Callback', {@figurecompare_uimenu,handles.ax1});
set(handles.ax1,'uicontextmenu',c);
format(cF);

if isfield(handles.sys,'D') && isfield(handles.sys,'lambdaDTest')
   Nrows = size(handles.sys.lambdaDTest,1);
   handles.ax1.ColorOrderIndex=1;
   for i=1:Nrows
       lab_i = handles.sys.Dlabel{i};
       plot(handles.ax1,handles.sys.D,handles.sys.lambdaDTest(i,:),'o','DisplayName',lab_i);
   end
end



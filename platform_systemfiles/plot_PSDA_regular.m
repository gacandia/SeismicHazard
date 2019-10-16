function plot_PSDA_regular(handles)

if ~isfield(handles,'sys'), return;end
if ~isfield(handles,'lambdaD'),return;end

delete(findall(handles.ax1,'type','line'));
handles.ax1.NextPlot='add';
handles.ax1.ColorOrderIndex=1;
site_ptr = handles.pop_site.Value;

haz  = handles.REG_Display;
d    = handles.paramPSDA.d;
col  = handles.col;
cfun = str2func(col{5});

default_color=[            0        0.447        0.741
         0.85        0.325        0.098
        0.929        0.694        0.125
        0.494        0.184        0.556
        0.466        0.674        0.188
        0.301        0.745        0.933
        0.635        0.078        0.184];
handles.ax1.ColorOrder=default_color;
handles.ax1.ColorOrderIndex=1;

if haz.L0
    lambdaD = nansum(handles.lambdaD(site_ptr,:,:,:),3);
    lambdaD = permute(lambdaD,[4 2 3 1]);
    
    if haz.L6 % CDM branches
        lam1 = lambdaD;
        lam1(lam1==0)=nan;
        if col{3}
            plot(handles.ax1,d',lam1','color',col{4},'linewidth',col{6})
            handles.ax1.ColorOrderIndex=1;
        else
            handles.ax1.ColorOrder=cfun(size(lam1,1));
            handles.ax1.ColorOrderIndex=1;
            plot(handles.ax1,d',lam1','linewidth',col{6})
            handles.ax1.ColorOrder=default_color;
            handles.ax1.ColorOrderIndex=1;
        end
    end
    
    if haz.L1 % default weights
        handles.table.Data = main_psda(handles.T1,handles.T2,handles.T3);
        weights = cell2mat(handles.table.Data(:,end));
        lam2    = nanprod(bsxfun(@power,lambdaD,weights),1);
        plot(handles.ax1,d',lam2','linewidth',col{2});
        str     = {'Default Weights'};
    end
    
    if haz.L2 % random weights
        weights = handles.REG_Display.rnd;
        handles.table.Data(:,4)=num2cell(weights);
        lam2 = nanprod(bsxfun(@power,lambdaD,weights),1);
        plot(handles.ax1,d',lam2','linewidth',col{2});
        str     = {'Random Weights'};
    end
    
    if haz.L3 % mean
        lambdaD(lambdaD<0)=nan;
        lam2 = exp(nanmean(log(lambdaD),1));
        plot(handles.ax1,d',lam2','linewidth',col{2});
        str  = {'Mean'};
    end
    
    if haz.L4 % percentiles
        percentile = haz.L5;
        Nt  = size(lambdaD,1);
        handles.table.Data(:,4)=cell(Nt,1);
        lambdaD(lambdaD<0)=nan;
        lam2 = exp(prctile(log(lambdaD),percentile,1));
        plot(handles.ax1,d',lam2','linewidth',col{2});
        str  = compose('Percentile %g',percentile);
    end
    
    if haz.L6==0 % legend
        Leg=legend(handles.ax1,str);
        Leg.Box='off';
    else
        Nbranches = size(handles.tableREG.Data,1);
        strb=compose('Branch %g',1:Nbranches);
        strb(~any(lambdaD,2))=[];
        Leg=legend(handles.ax1,[strb(:);str(:)]);
        Leg.FontSize=8;
        Leg.Box='off';
        Leg.Location='SouthWest';
        Leg.Tag='hazardlegend';
    end
    
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
    str        = cell(0,1);
    
    if haz.R2 % displays source contribution
        haz_ptr      = handles.IJK(branch_ptr,1);
        NOTZERO      = nansum(lambdaD,1)>0;
        source_label = {handles.model(haz_ptr).source.label};
        str          = source_label(NOTZERO);
        lam1         = lambdaD(:,NOTZERO)';
        
        switch col{3}
            case 1
                handles.ax1.ColorOrderIndex=1;
                plot(handles.ax1,d,lam1','color',col{4},'linewidth',col{6})
            case 0
                handles.ax1.ColorOrder=cfun(size(lam1,1));
                handles.ax1.ColorOrderIndex=1;
                plot(handles.ax1,d,lam1','linewidth',col{6})
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
        handles.ax1.ColorOrder=cfun(size(lam1,1));
        handles.ax1.ColorOrderIndex=1;
        
        switch col{3}
            case 1
                handles.ax1.ColorOrderIndex=1;
                plot(handles.ax1,d,lam1','color',col{4},'linewidth',col{6})
            case 0
                handles.ax1.ColorOrder=cfun(size(lam1,1));
                handles.ax1.ColorOrderIndex=1;
                plot(handles.ax1,d,lam1','linewidth',col{6})
        end
        
        mechs = {'system','interface','intraslab','slab','crustal','shallowcrustal','fault','grid'};
        str = mechs(NOTNAN);
    end
    
    handles.ax1.ColorOrderIndex=1;
    plot(handles.ax1,d',lam2','color',col{1},'linewidth',col{2});
    str = [str,sprintf('Branch %g',branch_ptr)];
    
    Leg=legend(handles.ax1,str);
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
uimenu(c,'Label','Copy data','Callback',        {@data2clipboard_uimenu,data});
uimenu(c,'Label','Undock','Callback',           {@figure2clipboard_uimenu,handles.ax1});
uimenu(c,'Label','Undock & compare','Callback', {@figurecompare_uimenu,handles.ax1});
set(handles.ax1,'uicontextmenu',c);
format(cF);


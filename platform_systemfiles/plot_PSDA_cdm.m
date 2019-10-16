function plot_PSDA_cdm(handles)

if ~isfield(handles,'sys'), return;end
if ~isfield(handles,'lambdaCDM'),return;end

delete(findall(handles.ax1,'type','line'));
handles.ax1.NextPlot='add';

d        = handles.paramPSDA.d;
haz      = handles.CDM_Display;
site_ptr = handles.pop_site.Value;

model_ptr  = haz.mptr;
col    = handles.col;
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
    lambdaCDM2 = nansum(handles.lambdaCDM(:,site_ptr,:,:,model_ptr),4);
    lambdaCDM2 = permute(lambdaCDM2,[1 3 2]);
    lambdaCDM2(lambdaCDM2<0)=nan;
    notnan = true(size(lambdaCDM2,1),1);
    Leg1   = cell(0,1);
    if haz.L4
        plot(handles.ax1,nan,nan,'-','color',col{4},'visible','off','HandleVisibility','on');
        plot(handles.ax1,d,lambdaCDM2(notnan,:),'-','color',col{4},'visible','on' ,'HandleVisibility','off');
        handles.ax1.ColorOrderIndex=1;
        switch handles.paramPSDA.method
            case 'PC', Leg1 = {'PC simulations'};
            case 'MC', Leg1 = {'MC simulations'};
        end
    end
    
    % plot median
    Leg2   = cell(0,1);
    yplot  = zeros(0,length(d));
    if haz.L1
        lambdaCDM2(all(lambdaCDM2==0,2),:)=[];
        y = exp(nanmean(log(lambdaCDM2),1));
        plot(handles.ax1,d,y,'linewidth',col{2});
        yplot=[yplot;y];
        Leg2=[Leg2;'Median'];
    end
    
    % plot percentile
    if haz.L2
        Per = haz.L3;
        y   = prctile(lambdaCDM2,Per,1);
        plot(handles.ax1,d,y,'-','linewidth',col{2});
        yplot=[yplot;y];
        Leg2 = [Leg2;compose('Percentile %g',Per)];
    end
    
    Leg=legend([Leg1;Leg2]);
    Leg.FontSize=8;
    Leg.EdgeColor=[1 1 1];
    Leg.Location='SouthWest';
    Leg.Tag='hazardlegend';
    set(handles.ax1,'layer','top')
    
end

if haz.R0
    
    lambdaCDM2 = handles.lambdaCDM(:,site_ptr,:,:,model_ptr);
    lambdaCDM2 = permute(lambdaCDM2,[1 3 4 2]);
    lambdaCDM2(lambdaCDM2<0)=nan;
    
    med = exp(nanmean(log(nansum(lambdaCDM2,3)),1));
    plot(handles.ax1,d,med,'linewidth',col{2});
    yplot  = med;
    Leg1 = {'Median'};
    
    if haz.R1
        yy=nansum(nansum(lambdaCDM2,1),2);yy=permute(yy,[3 1 2]);
        NOTZERO=find(yy>0);
        lam1 = lambdaCDM2(:,:,NOTZERO);
        lam1 = exp(nanmean(log(lam1),1));
        lam1 = permute(lam1,[3 2 1]);
        plot(d',lam1','color',col{4},'linewidth',col{6});
        yplot = [yplot;lam1];
        source_label = {handles.modelcdm(model_ptr).source.label};
        Leg2 = source_label(NOTZERO);
    end
    
    if haz.R2
        mechs      = {handles.modelcdm(model_ptr).source.mechanism};
        m1         = strcmp(mechs,'system');
        m2         = strcmp(mechs,'interface');
        m3         = strcmp(mechs,'intraslab');
        m4         = strcmp(mechs,'slab');
        m5         = strcmp(mechs,'crustal');
        m6         = strcmp(mechs,'shallowcrustal');
        m7         = strcmp(mechs,'fault');
        m8         = strcmp(mechs,'grid');
        
        fix1 =log(nansum(lambdaCDM2(:,:,m1),3)); fix1(isinf(fix1))=nan;
        fix2 =log(nansum(lambdaCDM2(:,:,m2),3)); fix2(isinf(fix2))=nan;
        fix3 =log(nansum(lambdaCDM2(:,:,m3),3)); fix3(isinf(fix3))=nan;
        fix4 =log(nansum(lambdaCDM2(:,:,m4),3)); fix4(isinf(fix4))=nan;
        fix5 =log(nansum(lambdaCDM2(:,:,m5),3)); fix5(isinf(fix5))=nan;
        fix6 =log(nansum(lambdaCDM2(:,:,m6),3)); fix6(isinf(fix6))=nan;
        fix7 =log(nansum(lambdaCDM2(:,:,m7),3)); fix7(isinf(fix7))=nan;
        fix8 =log(nansum(lambdaCDM2(:,:,m8),3)); fix8(isinf(fix8))=nan;
        
        lam1 = [...
            exp(nanmean(fix1,1));...
            exp(nanmean(fix2,1));...
            exp(nanmean(fix3,1));...
            exp(nanmean(fix4,1));...
            exp(nanmean(fix5,1));...
            exp(nanmean(fix6,1));...
            exp(nanmean(fix7,1));...
            exp(nanmean(fix8,1))];
        NOTZERO = (nansum(lam1,2)>0);
        lam1   = lam1(NOTZERO,:);
        plot(handles.ax1,d',lam1','-');
        yplot=[yplot;lam1];
        mechs = {'system','interface','intraslab','slab','crustal','shallowcrustal','fault','grid'};
        Leg2 = mechs(NOTZERO);
        
    end
    Leg=legend([Leg1,Leg2]);
    
    Leg.FontSize=8;
    Leg.EdgeColor=[1 1 1];
    Leg.Location='SouthWest';
    Leg.Tag='hazardlegend';
    set(handles.ax1,'layer','top')
    
end


cF   = get(0,'format');
format long g
data = num2cell([d;yplot]); % average
c    = uicontextmenu;
uimenu(c,'Label','Copy data','Callback',        {@data2clipboard_uimenu,data});
uimenu(c,'Label','Undock','Callback',           {@figure2clipboard_uimenu,handles.ax1});
uimenu(c,'Label','Undock & compare','Callback', {@figurecompare_uimenu,handles.ax1});
set(handles.ax1,'uicontextmenu',c);
format(cF);



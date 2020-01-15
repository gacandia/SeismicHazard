function plot_PSDA_cdm(handles)

if ~isfield(handles,'sys'), return;end
if ~isfield(handles,'lambdaCDM'),return;end

delete(findall(handles.ax1,'type','line'));
handles.ax1.NextPlot='add';

d         = handles.paramPSDA.d;
haz       = handles.CDM_Display;
site_ptr  = handles.pop_site.Value;
model_ptr = haz.mptr;
flatcolor = handles.ColorSecondaryLines.Value;
gris      = [0.76 0.76 0.76];

if haz.L0
    lambdaCDM2 = nansum(handles.lambdaCDM(:,site_ptr,:,:,model_ptr),4);
    lambdaCDM2 = permute(lambdaCDM2,[1 3 2]);
    lambdaCDM2(any(lambdaCDM2<0,2),:)=[];
    notnan = true(size(lambdaCDM2,1),1);
    
    if haz.L4
        switch handles.paramPSDA.method
            case 'PC', plot(handles.ax1,d,d*NaN,'color',gris,'DisplayName','PC simulations');
            case 'MC', plot(handles.ax1,d,d*NaN,'color',gris,'DisplayName','MC simulations');
        end
        plot(handles.ax1,d,lambdaCDM2(notnan,:),'-','color',gris,'visible','on' ,'HandleVisibility','off');
    end
    handles.ax1.ColorOrderIndex=1;
    % plot median
    yplot  = zeros(0,length(d));
    if haz.L1
        y = exp(nanmean(log(lambdaCDM2),1));
        plot(handles.ax1,d,y,'linewidth',2,'DisplayName','Median');
        yplot=[yplot;y];
    end
    
    % plot percentile
    if haz.L2
        Per = haz.L3;
        y   = prctile(lambdaCDM2,Per,1);
        Legp= compose('Percentile %g',Per);
        for jj=1:length(Per)
            plot(handles.ax1,d,y(jj,:),'-','linewidth',2,'DisplayName',Legp{jj});
        end
        yplot=[yplot;y];
    end
    
    Leg=legend;
    Leg.FontSize=8;
    Nlines = size(yplot,1);
    Leg.NumColumns = ceil(Nlines/5);
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
    plot(handles.ax1,d,med,'color',[0 0.447 0.741],'linewidth',2,'DisplayName','Median');
    yplot  = med;
    
    if haz.R1
        yy=nansum(nansum(lambdaCDM2,1),2);yy=permute(yy,[3 1 2]);
        NOTZERO=find(yy>0);
        lam1 = lambdaCDM2(:,:,NOTZERO);
        lam1 = exp(nanmean(log(lam1),1));
        lam1 = permute(lam1,[3 2 1]);
        
        [~,B]=intersect({handles.modelcdm.id},handles.tableCDM.Data{model_ptr,1});
        source_label = {handles.modelcdm(B).source.label};
        str = source_label(NOTZERO);
        handles.ax1.ColorOrderIndex=2;
        for jj=1:length(str)
            if flatcolor
                plot(handles.ax1,d,lam1(jj,:),'color',gris,'DisplayName',str{jj});
            else
                plot(handles.ax1,d,lam1(jj,:),'DisplayName',str{jj});
            end
        end
        yplot = [yplot;lam1];
    end
    
    if haz.R2
        [~,B]      = intersect({handles.modelcdm.id},handles.tableCDM.Data{model_ptr,1});
        mechs      = {handles.modelcdm(B).source.mechanism};
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
        lam1  = lam1(NOTZERO,:);
        mechs = {'system','interface','intraslab','slab','crustal','shallowcrustal','fault','grid'};
        str   = mechs(NOTZERO);
        handles.ax1.ColorOrderIndex=2;
        for jj=1:length(str)
            if flatcolor
                plot(handles.ax1,d,lam1(jj,:),'color',gris,'DisplayName',str{jj});
            else
                
                plot(handles.ax1,d,lam1(jj,:),'-','DisplayName',str{jj});
            end
        end
        yplot=[yplot;lam1];
    end
    
    Leg=legend(handles.ax1);
    Leg.FontSize=8;
    Nlines = size(yplot,1);
    Leg.NumColumns = ceil(Nlines/5);
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



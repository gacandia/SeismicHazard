function plot_histogram_PSDA(handles,varargin)

XSC        = handles.ax2.XScale;
YSC        = handles.ax2.YScale;

ind        = handles.pop_scenario.Value;
shakefield = handles.shakefield(ind);
site_ptr   = handles.site_menu_psda.Value;
num        = str2double(handles.Znum.String);

% create scenario
Nsites  = size(handles.h.p,1);
val     = handles.pop_field.Value;
str     = handles.pop_field.String{val};
II      = (1:Nsites)+Nsites*(val-1);
mulogIM = shakefield.mulogIM(II(site_ptr),:);
L       = shakefield.L(II(site_ptr),:);
switch PSDA_display_mode.Value
    case 1
    case 2
end
% Z = shakefield.Z; lnY  = mulogIM+L*Z; Y = exp(lnY);

delete(findall(handles.ax2,'type','line'))
delete(findall(handles.ax2,'tag','histogram'));
handles.ax2.ButtonDownFcn=[];
handles.ax2.ColorOrderIndex=1;


switch handles.PSDA_display_mode.Value
    case 1
        histogram(handles.ax2,Y,'tag','histogram')
        xlabel(handles.ax2,str,'fontsize',10)
        ylabel(handles.ax2,'Frequency','fontsize',10)
    case 2
        plot(handles.ax2,Y,'ko','tag','histogram')
        xlabel(handles.ax2,'Simulation N°','fontsize',10)
        ylabel(handles.ax2,str,'fontsize',10)        
        if ~isnan(num)
            plot(handles.ax2,num,Y(num),'ro',...
                'markerfacecolor','r',...
                'markeredgecolor','k',...
                'tag','histogram')
        else
            plot(handles.ax2,handles.ax2.XLim,[1 1]*exp(mulogIM),'r--','tag','histogram')
        end
        
end

ch=findall(handles.FIGSeismicHazard,'type','legend');
if ~isempty(ch)
    ch.Visible='off';
end

handles.ax2.XScale=XSC;
handles.ax2.YScale=YSC;




function[]=setTickLabel(h_ax)

h_ax.XTickMode='auto';
h_ax.YTickMode='auto';
h_ax.XTickLabelMode='auto';
h_ax.YTickLabelMode='auto';

if strcmpi(h_ax.XLabel.String,'lon')
    XTL = h_ax.XTickLabel;
    for i=1:length(XTL)
        if ~isempty(XTL{i})
            XTL{i}=[XTL{i},'°'];
        end
    end
    h_ax.XTickLabel=XTL;
    
    YTL = h_ax.YTickLabel;
    for i=1:length(YTL)
        if ~isempty(YTL{i})
            YTL{i}=[YTL{i},'°'];
        end
    end
    h_ax.YTickLabel=YTL;
end

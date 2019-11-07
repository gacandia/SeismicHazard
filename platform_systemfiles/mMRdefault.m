function handles=mMRdefault(handles,txt,edi)

handles.e1.BackgroundColor=[1 1 1]; handles.e1.Enable='on';
handles.e2.BackgroundColor=[1 1 1]; handles.e2.Enable='on';
handles.e3.BackgroundColor=[1 1 1]; handles.e3.Enable='on';
handles.e4.BackgroundColor=[1 1 1]; handles.e4.Enable='on';
handles.e5.BackgroundColor=[1 1 1]; handles.e5.Enable='on';
handles.e6.BackgroundColor=[1 1 1]; handles.e6.Enable='on';
handles.e7.BackgroundColor=[1 1 1]; handles.e7.Enable='on';
% handles.e8.BackgroundColor=[1 1 1]; handles.e1.Enable='on';
% handles.e9.BackgroundColor=[1 1 1]; handles.e1.Enable='on';
% handles.e10.BackgroundColor=[1 1 1]; handles.e1.Enable='on';
% handles.e11.BackgroundColor=[1 1 1]; handles.e1.Enable='on';
% handles.e12.BackgroundColor=[1 1 1]; handles.e1.Enable='on';
% handles.e13.BackgroundColor=[1 1 1]; handles.e1.Enable='on';
% handles.e14.BackgroundColor=[1 1 1]; handles.e1.Enable='on';

methods = pshatoolbox_methods(2);

switch methods(handles.MRselect.Value).str
    case 'delta'
        handles.fun=@delta;
        set(txt(1:4),'Visible','on');
        set(edi(1:4),'Visible','on');
        
        handles.t1.String='N(Mmin)';
        handles.t2.String='M';
        handles.t3.String='Slip Rate (mm/yr)';
        handles.t4.String='MeanMo (dynecm)';
        
        handles.e1.String='2';
        handles.e2.String='7';
        handles.e3.String='-'; handles.e3.Enable='off';
        handles.e4.String='-'; handles.e4.Enable='off';
        
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 1];
        handles.e4.BackgroundColor=[1 1 1];
        
    case 'truncexp'
        handles.fun=@truncexp;
        set(txt(1:6),'Visible','on');
        set(edi(1:6),'Visible','on');
        
        handles.t1.String='N(Mmin)';
        handles.t2.String='b-value';
        handles.t3.String='Mmin';
        handles.t4.String='Mmax';
        handles.t5.String='Slip Rate (mm/yr)';
        handles.t6.String='MeanMo (dyne cm)';
        
        
        handles.e1.String='2';
        handles.e2.String='0.9';
        handles.e3.String='5.0';
        handles.e4.String='8.5';
        handles.e5.String='-'; handles.e5.Enable='off';
        handles.e6.String='-'; handles.e6.Enable='off';
        
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 1];
        handles.e6.BackgroundColor=[1 1 1];

    case 'truncnorm'
        handles.fun=@truncnorm;
        set(txt(1:7),'Visible','on');
        set(edi(1:7),'Visible','on');
        
        handles.t1.String='N(Mmin)';
        handles.t2.String='Mmin';
        handles.t3.String='Mmax';
        handles.t4.String='Mchar';
        handles.t5.String='SigmaM';
        handles.t6.String='Slip Rate (mm/yr)';
        handles.t7.String='MeanMo (dyne cm)';
        
        handles.e1.String='2';
        handles.e2.String='5.0';
        handles.e3.String='8.5';
        handles.e4.String='7.0';
        handles.e5.String='0.2';
        handles.e6.String='-'; handles.e6.Enable='off';
        handles.e7.String='-'; handles.e7.Enable='off';
        
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 0.7];
        handles.e6.BackgroundColor=[1 1 1];
        handles.e7.BackgroundColor=[1 1 1];
        
    case 'youngscoppersmith'
        handles.fun=@youngscoppersmith;
        set(txt(1:6),'Visible','on');
        set(edi(1:6),'Visible','on');
        
        handles.t1.String='N(Mmin)';
        handles.t2.String='b-value';
        handles.t3.String='Mmin';
        handles.t4.String='Mchar';
        handles.t5.String='Slip Rate (mm/yr)';
        handles.t6.String='MeanMo (dyne cm)';
        
        handles.e1.String='2.0';
        handles.e2.String='0.9';
        handles.e3.String='5.0';
        handles.e4.String='8.0';
        handles.e5.String='-';     handles.e5.Enable='off';
        handles.e6.String='-';     handles.e6.Enable='off';
        
        handles.e1.BackgroundColor=[1 1 0.7];
        handles.e2.BackgroundColor=[1 1 0.7];
        handles.e3.BackgroundColor=[1 1 0.7];
        handles.e4.BackgroundColor=[1 1 0.7];
        handles.e5.BackgroundColor=[1 1 1];
        handles.e6.BackgroundColor=[1 1 1];
end

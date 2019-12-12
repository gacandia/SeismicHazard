function handles=mGMPEfromfigures(handles,filename)

ch=get(handles.panel2,'children');
set(ch(handles.text),'Visible','off')
set(ch(handles.edit),'Visible','off','Style','edit');
units0 = 1;
switch filename
    case {'Abrahamson2016_1.png','Abrahamson2016_2.png','Abrahamson2016_3.png','Abrahamson2016_4.png','Abrahamson2016_5.png','Abrahamson2016_6.png','Abrahamson2016_7.png'}
        str = 'Abrahamson et al. 2016';
    case {'AbrahamsonSilva2008_NGA_1.png','AbrahamsonSilva2008_NGA_2.png',  'AbrahamsonSilva2008_NGA_3.png',  'AbrahamsonSilva2008_NGA_4.png',  'AbrahamsonSilva2008_NGA_5.png'}
        str = 'Abrahamson Silva 2008 - NGA';
    case {'Boore_Atkinson2008_NGA_1.png','Boore_Atkinson2008_NGA_2.png','Boore_Atkinson2008_NGA_3.png'}
        str='Boore Atkinson 2008 - NGA';
    case {'CampbellBozorgnia2008_NGA_1.png','CampbellBozorgnia2008_NGA_2.png','CampbellBozorgnia2008_NGA_3.png','CampbellBozorgnia2008_NGA_4.png'}
        str='Campbell Bozorgnia 2008 - NGA';
    case {'ChiouYoungs2008_NGA_1.png','ChiouYoungs2008_NGA_1a.png','ChiouYoungs2008_NGA_1b.png','ChiouYoungs2008_NGA_1c.png','ChiouYoungs2008_NGA_1d.png'}
        str='Chiou Youngs 2008 - NGA';
    case {'Contreras_Boroschek2012_1.png','Contreras_Boroschek2012_2.png','Contreras_Boroschek2012_3.png','Contreras_Boroschek2012_4.png','Contreras_Boroschek2012_5.png','Contreras_Boroschek2012_6.png'}
        str='Boroschek et al. 2012';
    case {'Idini2016_1.png','Idini2016_2.png','Idini2016_3.png','Idini2016_4.png','Idini2016_5.png','Idini2016_6.png'}
        str='Idini et al. 2016';
    case {'Idriss2008_nga_strike_slip.png','Idriss2008_nga_reverse.png'}
        str='Idriss 2008 - NGA';
    case {'Montalva2017_1_interface.png','Montalva2017_2_interface.png','Montalva2017_3_interface.png','Montalva2017_4_interface.png','Montalva2017_5_intraslab.png','Montalva2017_6_intraslab.png','Montalva2017_7_intraslab.png','Montalva2017_8_intraslab.png'}
        str='Montalva et al. 2017';
    case {'Youngs1997_1.png','Youngs1997_2.png','Youngs1997_4.png','Youngs1997_5.png'}
        str='Youngs et al. 1997';
    case {'Sadigh1997_1a.png','Sadigh1997_1b.png','Sadigh1997_1c.png','Sadigh1997_1d.png'}
        str='Sadigh et al. 1997';
    case {'AbrahamsonSilva1997h_1.png','AbrahamsonSilva1997h_2.png'}
        str='Abrahamson Silva 1997 (Horz)';
    case {'Arteta2018.png'}
        str='Arteta et al. 2018';
end

[~,GMPEValue]=intersect(handles.GMPEselect.String,str);
if isempty(GMPEValue)
    return
end

ln=findall(handles.ax1,'tag','curves');delete(ln);
handles.ax1.ColorOrderIndex = 1;
handles.HoldPlot.Value=1;
handles.GMPEselect.Value=GMPEValue;
handles=mGMPEdefault(handles,ch(handles.text),ch(handles.edit));

switch filename
    case 'Arteta2018.png'
        % Figure 10a from Abrahamson 2016
        handles.e1.String=7.2;
        handles.e2.String=120;
        handles.e3.Value=1;
        handles.e3.Value=1;
        plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Abrahamson2016_1.png'
        % Figure 10a from Abrahamson 2016
        handles.e2.String=25;
        handles.e3.String=25;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.Value=2;
        handles.e7.String=760;
        handles.e1.String=7.0; plotgmpe(handles);
        handles.e1.String=8.0; plotgmpe(handles);
        handles.e1.String=9.0; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Abrahamson2016_2.png'
        % Figure 10b from Abrahamson 2016
        handles.e2.String=50;
        handles.e3.String=50;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.Value=2;
        handles.e7.String=760;
        handles.e1.String=7.0; plotgmpe(handles);
        handles.e1.String=8.0; plotgmpe(handles);
        handles.e1.String=9.0; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Abrahamson2016_3.png'
        % Figure 10c from Abrahamson 2016
        handles.e2.String=100;
        handles.e3.String=100;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.Value=2;
        handles.e7.String=760;
        handles.e1.String=7.0; plotgmpe(handles);
        handles.e1.String=8.0; plotgmpe(handles);
        handles.e1.String=9.0; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Abrahamson2016_4.png'
        % Figure 10d from Abrahamson 2016
        handles.e2.String=200;
        handles.e3.String=200;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.Value=2;
        handles.e7.String=760;
        handles.e1.String=7.0; plotgmpe(handles);
        handles.e1.String=8.0; plotgmpe(handles);
        handles.e1.String=9.0; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Abrahamson2016_5.png'
        % Figure 11a from Abrahamson 2016
        handles.e1.String=5.5;
        handles.e3.String=50;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.Value=2;
        handles.e7.String=760;
        handles.e2.String=50;  plotgmpe(handles);
        handles.e2.String=75;  plotgmpe(handles);
        handles.e2.String=100; plotgmpe(handles);
        handles.e2.String=150; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.00001 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Abrahamson2016_6.png'
        % Figure 11b from Abrahamson 2016
        handles.e1.String=6.5;
        handles.e3.String=50;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.Value=2;
        handles.e7.String=760;
        handles.e2.String=50;  plotgmpe(handles);
        handles.e2.String=75;  plotgmpe(handles);
        handles.e2.String=100; plotgmpe(handles);
        handles.e2.String=150; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Abrahamson2016_7.png'
        % Figure 11c from Abrahamson 2016
        handles.e1.String=7.5;
        handles.e3.String=50;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.Value=2;
        handles.e7.String=760;
        handles.e2.String=50;  plotgmpe(handles);
        handles.e2.String=75;  plotgmpe(handles);
        handles.e2.String=100; plotgmpe(handles);
        handles.e2.String=150; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Montalva2017_1_interface.png'
        % Figure 3a from Montalva and Bastias 2017
        handles.e2.String=25;
        handles.e3.String=25;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.String=300;
        handles.e1.String=6.5; plotgmpe(handles);
        handles.e1.String=8.5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Montalva2017_2_interface.png'
        % Figure 3b from Montalva and Bastias 2017
        handles.e2.String=50;
        handles.e3.String=50;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.String=300;
        handles.e1.String=6.5; plotgmpe(handles);
        handles.e1.String=8.5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Montalva2017_3_interface.png'
        % Figure 3c from Montalva and Bastias 2017
        handles.e2.String=100;
        handles.e3.String=100;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.String=300;
        handles.e1.String=6.5; plotgmpe(handles);
        handles.e1.String=8.5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Montalva2017_4_interface.png'
        % Figure 3d from Montalva and Bastias 2017
        handles.e2.String=150;
        handles.e3.String=150;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.String=300;
        handles.e1.String=6.5; plotgmpe(handles);
        handles.e1.String=8.5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Montalva2017_5_intraslab.png'
        % Figure 4a from Montalva and Bastias 2017
        handles.e2.String=75;
        handles.e3.String=100;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.String=300;
        handles.e1.String=6.5; plotgmpe(handles);
        handles.e1.String=8.5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Montalva2017_6_intraslab.png'
        % Figure 4b from Montalva and Bastias 2017
        handles.e2.String=100;
        handles.e3.String=100;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.String=300;
        handles.e1.String=6.5; plotgmpe(handles);
        handles.e1.String=8.5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.0001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Montalva2017_7_intraslab.png'
        % Figure 4c from Montalva and Bastias 2017
        handles.e2.String=150;
        handles.e3.String=100;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.String=300;
        handles.e1.String=6.5; plotgmpe(handles);
        handles.e1.String=8.5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[1e-5 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Montalva2017_8_intraslab.png'
        % Figure 4d from Montalva and Bastias 2017
        handles.e2.String=200;
        handles.e3.String=100;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.String=300;
        handles.e1.String=6.5; plotgmpe(handles);
        handles.e1.String=8.5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[1e-5 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Idini2016_1.png'
        % Figure 9a from Idini 2016
        handles.e1.String=8.5;
        handles.e2.String=50;
        handles.e3.String=50;
        handles.e4.Value=1;
        handles.e6.String=400;
        handles.e5.Value=1; plotgmpe(handles);
        handles.e5.Value=2; plotgmpe(handles);
        handles.e5.Value=5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Idini2016_2.png'
        % Figure 9b from Idini 2016
        handles.e1.String=7.5;
        handles.e2.String=100;
        handles.e3.String=100;
        handles.e4.Value=2;
        handles.e6.String=400;
        handles.e5.Value=1; plotgmpe(handles);
        handles.e5.Value=2; plotgmpe(handles);
        handles.e5.Value=5; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Idini2016_3.png'
        % Figure 10a from Idini 2016
        handles.e2.String=30;
        handles.e3.String=30;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.String=1100;
        handles.e1.String=9; plotgmpe(handles);
        handles.e1.String=8; plotgmpe(handles);
        handles.e1.String=7; plotgmpe(handles);
        handles.e1.String=6; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 5];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Idini2016_4.png'
        % Figure 10b from Idini 2016
        handles.e2.String=60;
        handles.e3.String=60;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.String=1100;
        handles.e1.String=8; plotgmpe(handles);
        handles.e1.String=7; plotgmpe(handles);
        handles.e1.String=6; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 5];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Idini2016_5.png'
        % Figure 10a from Idini 2016
        handles.e2.String=100;
        handles.e3.String=100;
        handles.e4.Value=1;
        handles.e5.Value=1;
        handles.e6.String=1100;
        handles.e1.String=9; plotgmpe(handles);
        handles.e1.String=8; plotgmpe(handles);
        handles.e1.String=7; plotgmpe(handles);
        handles.e1.String=6; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 5];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Idini2016_6.png'
        % Figure 10b from Idini 2016
        handles.e2.String=100;
        handles.e3.String=100;
        handles.e4.Value=2;
        handles.e5.Value=1;
        handles.e6.String=1100;
        handles.e1.String=8; plotgmpe(handles);
        handles.e1.String=7; plotgmpe(handles);
        handles.e1.String=6; plotgmpe(handles);
        handles.ax1.XLim=[0.01 10];
        handles.ax1.YLim=[0.001 5];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Contreras_Boroschek2012_1.png'
        % Figure 9a Contreras and Boroschek 2012
        handles.e1.String=7.7;
        handles.e2.String=175.6;
        handles.e3.String=38.9;
        handles.e4.Value=2; plotgmpe(handles);
        handles.ax1.XLim=[0 2];
        handles.ax1.YLim=[0 0.429];
        handles.ax1.XScale='linear';
        handles.ax1.YScale='linear';
        
    case 'Contreras_Boroschek2012_2.png'
        % Figure 9b Contreras and Boroschek 2012
        handles.e1.String=7.9;
        handles.e2.String=120.3;
        handles.e3.String=33;
        handles.e4.Value=2; plotgmpe(handles);
        handles.ax1.XLim=[0 2];
        handles.ax1.YLim=[0 0.693];
        handles.ax1.XScale='linear';
        handles.ax1.YScale='linear';
        
    case 'Contreras_Boroschek2012_3.png'
        % Figure 9c Contreras and Boroschek 2012
        handles.e1.String=7.9;
        handles.e2.String=38;
        handles.e3.String=33;
        handles.e4.Value=1; plotgmpe(handles);
        handles.ax1.XLim=[0 2];
        handles.ax1.YLim=[0 0.65];
        handles.ax1.XScale='linear';
        handles.ax1.YScale='linear';
        
    case 'Contreras_Boroschek2012_4.png'
        % Figure 9d Contreras and Boroschek 2012
        handles.e1.String=7.7;
        handles.e2.String=118.5;
        handles.e3.String=38.9;
        handles.e4.Value=1; plotgmpe(handles);
        handles.ax1.XLim=[0 2];
        handles.ax1.YLim=[0 0.3];
        handles.ax1.XScale='linear';
        handles.ax1.YScale='linear';
        
    case 'Contreras_Boroschek2012_5.png'
        % Figure 9d Contreras and Boroschek 2012
        handles.e1.String=8.8;
        handles.e2.String=34;
        handles.e3.String=30;
        handles.e4.Value=2; plotgmpe(handles);
        handles.ax1.XLim=[0 2];
        handles.ax1.YLim=[0 2.29];
        handles.ax1.XScale='linear';
        handles.ax1.YScale='linear';
        
    case 'Contreras_Boroschek2012_6.png'
        % Figure 9d Contreras and Boroschek 2012
        handles.e1.String=8.8;
        handles.e2.String=99;
        handles.e3.String=30;
        handles.e4.Value=2; plotgmpe(handles);
        handles.ax1.XLim=[0 2];
        handles.ax1.YLim=[0 1.578];
        handles.ax1.XScale='linear';
        handles.ax1.YScale='linear';
        
    case 'Idriss2008_nga_strike_slip.png'
        handles.e1.String=6;
        handles.e2.String=6;
        handles.e3.Value=1;
        handles.e4.String='500'; plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Idriss2008_nga_reverse.png'
        handles.e1.String=7;
        handles.e2.String=6;
        handles.e3.Value=2;
        handles.e4.String='500'; plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
       
    case 'ChiouYoungs2008_NGA_1.png'
        %M, Rrup,    Rjb,   Rx, Ztor,    dip, lambda,   event, Vs30, Z10, FVS30
        handles.e1.String=6.8;    % M
        handles.e2.String=5;      % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=5;      % Rx        
        handles.e5.String=0;      % Ztor
        handles.e6.String=60;     % dip
        handles.e7.String=5.744229155; %Z1.0
        handles.e8.Value=4;         % mechanism
        handles.e9.Value=1;         % event
        handles.e10.String=1100;   % Vs30
        
        handles.e11.Value=2;        %FVS30
        plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.001 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'ChiouYoungs2008_NGA_1a.png'
        %M, Rrup,    Rjb,   Rx, Ztor,    dip, lambda,   event, Vs30, Z10, FVS30
        handles.e2.String=1;      % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=1;      % Rx
        handles.e5.String=0;      % Ztor
        handles.e6.String=90;     % dip
        handles.e7.String=num2str(exp(28.5-3.82/8*log(520^8+378.8^8))); %Z1.0
        handles.e8.Value=1;         % mechanism
        handles.e9.Value=1;         % event
        handles.e10.String=520;    % Vs30
        handles.e11.Value=2;           %FVS30
        
        handles.e1.String=5.5;   plotgmpe(handles);
        handles.e1.String=6.5;   plotgmpe(handles);
        handles.e1.String=7.5;   plotgmpe(handles);
        handles.e1.String=8.5;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0007 2];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'ChiouYoungs2008_NGA_1b.png'
        %M, Rrup,    Rjb,   Rx, Ztor,    dip, lambda,   event, Vs30, Z10, FVS30
        handles.e2.String=10;      % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=10;      % Rx
        handles.e5.String=0;      % Ztor
        handles.e6.String=90;     % dip
        handles.e7.String=num2str(exp(28.5-3.82/8*log(520^8+378.8^8))); %Z1.0
        handles.e8.Value=1;         % mechanism
        handles.e9.Value=1;         % event
        handles.e10.String=520;    % Vs30
        
        handles.e11.Value=2;           %FVS30
        handles.e1.String=5.5;   plotgmpe(handles);
        handles.e1.String=6.5;   plotgmpe(handles);
        handles.e1.String=7.5;   plotgmpe(handles);
        handles.e1.String=8.5;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0007 2];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'ChiouYoungs2008_NGA_1c.png'
        %M, Rrup,    Rjb,   Rx, Ztor,    dip, lambda,   event, Vs30, Z10, FVS30
        handles.e2.String=30;     % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=30;     % Rx
        handles.e5.String=0;      % Ztor
        handles.e6.String=90;     % dip
        handles.e7.String=num2str(exp(28.5-3.82/8*log(520^8+378.8^8))); %Z1.0
        handles.e8.Value=1;         % mechanism
        handles.e9.Value=1;         % event
        handles.e10.String=520;    % Vs30
        
        handles.e11.Value=2;           %FVS30
        handles.e1.String=5.5;   plotgmpe(handles);
        handles.e1.String=6.5;   plotgmpe(handles);
        handles.e1.String=7.5;   plotgmpe(handles);
        handles.e1.String=8.5;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0007 2];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'ChiouYoungs2008_NGA_1d.png'
        %M, Rrup,    Rjb,   Rx, Ztor,    dip, lambda,   event, Vs30, Z10, FVS30
        handles.e2.String=70;      % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=70;      % Rx
        handles.e5.String=0;      % Ztor
        handles.e6.String=90;     % dip
        handles.e7.String=num2str(exp(28.5-3.82/8*log(520^8+378.8^8))); %Z1.0
        handles.e8.Value=1;         % mechanism
        handles.e9.Value=1;         % event
        handles.e10.String=520;    % Vs30
        
        handles.e11.Value=2;           %FVS30
        handles.e1.String=5.5;   plotgmpe(handles);
        handles.e1.String=6.5;   plotgmpe(handles);
        handles.e1.String=7.5;   plotgmpe(handles);
        handles.e1.String=8.5;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0007 2];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Boore_Atkinson2008_NGA_1.png'
        %M, Rjb, Fault_Type, Vs30
        handles.e2.String=0;      % Rjb
        handles.e3.Value=1;         % Fault_type
        handles.e4.String=760;    % Vs30
        handles.units = 'cm/s2';
        handles.e1.String=8; plotgmpe(handles);
        handles.e1.String=7; plotgmpe(handles);
        handles.e1.String=6; plotgmpe(handles);
        handles.e1.String=5; plotgmpe(handles);
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.01 2000];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Boore_Atkinson2008_NGA_2.png'
        %M, Rjb, Fault_Type, Vs30
        handles.e2.String=30;      % Rjb
        handles.e3.Value=1;         % Fault_type
        handles.e4.String=760;    % Vs30
        handles.units = 'cm/s2';
        handles.e1.String=8; plotgmpe(handles);
        handles.e1.String=7; plotgmpe(handles);
        handles.e1.String=6; plotgmpe(handles);
        handles.e1.String=5; plotgmpe(handles);
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.01 2000];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Boore_Atkinson2008_NGA_3.png'
        %M, Rjb, Fault_Type, Vs30
        handles.e2.String=200;      % Rjb
        handles.e3.Value=1;         % Fault_type
        handles.e4.String=760;    % Vs30
        handles.units = 'cm/s2';
        handles.e1.String=8; plotgmpe(handles);
        handles.e1.String=7; plotgmpe(handles);
        handles.e1.String=6; plotgmpe(handles);
        handles.e1.String=5; plotgmpe(handles);
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.01 2000];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'CampbellBozorgnia2008_NGA_1.png'
        %M, Rrup, Rjb, Ztor, dip, mechanism, Vs30, Zvs, arb, A1100
        handles.e2.String=0;      % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=0;      % Ztor
        handles.e5.String=90;     % dip
        handles.e6.Value=1;         % mechanism
        handles.e7.String=760;    % Vs30
        handles.e8.String=2;      % 2
        handles.e9.Value=1;       %FVS30
        handles.e10.String=0;     %A1100
        handles.e1.String=5;   plotgmpe(handles);
        handles.e1.String=6;   plotgmpe(handles);
        handles.e1.String=7;   plotgmpe(handles);
        handles.e1.String=8;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[1e-5 1.001];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'CampbellBozorgnia2008_NGA_2.png'
        %M, Rrup, Rjb, Ztor, dip, mechanism, Vs30, Zvs, arb, A1100
        handles.e2.String=10;     % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=0;      % Ztor
        handles.e5.String=90;     % dip
        handles.e6.Value=1;         % mechanism
        handles.e7.String=760;    % Vs30
        handles.e8.String=2;      % 2
        handles.e9.Value=1;         %FVS30
        handles.e10.String=0;     %A1100
        handles.e1.String=5;   plotgmpe(handles);
        handles.e1.String=6;   plotgmpe(handles);
        handles.e1.String=7;   plotgmpe(handles);
        handles.e1.String=8;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[1e-5 1.001];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'CampbellBozorgnia2008_NGA_3.png'
        %M, Rrup, Rjb, Ztor, dip, mechanism, Vs30, Zvs, arb, A1100
        handles.e2.String=50;     % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=0;      % Ztor
        handles.e5.String=90;     % dip
        handles.e6.Value=1;         % mechanism
        handles.e7.String=760;    % Vs30
        handles.e8.String=2;      % 2
        handles.e9.Value=1;         %FVS30
        handles.e10.String=0;     %A1100
        handles.e1.String=5;   plotgmpe(handles);
        handles.e1.String=6;   plotgmpe(handles);
        handles.e1.String=7;   plotgmpe(handles);
        handles.e1.String=8;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[1e-5 1.001];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'CampbellBozorgnia2008_NGA_4.png'
        %M, Rrup, Rjb, Ztor, dip, mechanism, Vs30, Zvs, arb, A1100
        handles.e2.String=200;      % Rrup
        handles.e3.String=0;      % Rjb
        handles.e4.String=0;      % Ztor
        handles.e5.String=90;     % dip
        handles.e6.Value=1;         % mechanism
        handles.e7.String=760;    % Vs30
        handles.e8.String=2;      % 2
        handles.e9.Value=1;         %FVS30
        handles.e10.String=0;     %A1100
        handles.e1.String=5;   plotgmpe(handles);
        handles.e1.String=6;   plotgmpe(handles);
        handles.e1.String=7;   plotgmpe(handles);
        handles.e1.String=8;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[1e-5 1.001];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'AbrahamsonSilva2008_NGA_1.png'
        %1  2     3    4   5    6     7   8   9    10         11     12       13
        %M, rrup, rjb, rx, dip, ztor, W, Z10, Vs30,mechanism, event, location, Vs30type
        handles.e3.String = 30; %rjb
        handles.e4.String = 30; %rx
        handles.e5.String = 90; %dip
        handles.e7.String = 10;
        handles.e9.String = 270;
        handles.e10.Value = 1; %{'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e11.Value = 2; %{'aftershock','mainshock','foreshock','swarms'};
        handles.e12.Value = 1; % {'measured','inferred'};
        handles.e1.String = 5; handles.e2.String = 30; handles.e6.String = 7; handles.e8.String = Z10_default_AS08_NGA(270); plotgmpe(handles);
        handles.e1.String = 6; handles.e2.String = 30; handles.e6.String = 3; handles.e8.String = Z10_default_AS08_NGA(270); plotgmpe(handles);
        handles.e1.String = 7; handles.e2.String = 30; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(270); plotgmpe(handles);
        handles.e1.String = 8; handles.e2.String = 30; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(270); plotgmpe(handles);
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0001 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'AbrahamsonSilva2008_NGA_2.png'
        %1-M, 2-Vs30, 3-Rrup, 4-Rjb, 5-Rx, 6-dip, 7-Ztor, 8-Z10, 9-W, 10-mechanism, 11-eventtype, 12-side, 13-Vs30source
        handles.e3.String = 30;
        handles.e4.String = 30;
        handles.e5.String = 90;
        handles.e7.String = 10;
        handles.e9.String = 550;        
        handles.e10.Value = 1; %{'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e11.Value = 2; %{'aftershock','mainshock','foreshock','swarms'};
        handles.e12.Value = 1; %{'hangingwall','foot wall','other'};
        handles.e13.Value = 1; % {'measured','inferred'};
        handles.e1.String=5; handles.e2.String = 30; handles.e6.String = 7; handles.e8.String = Z10_default_AS08_NGA(550); plotgmpe(handles);
        handles.e1.String=6; handles.e2.String = 30; handles.e6.String = 3; handles.e8.String = Z10_default_AS08_NGA(550); plotgmpe(handles);
        handles.e1.String=7; handles.e2.String = 30; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(550); plotgmpe(handles);
        handles.e1.String=8; handles.e2.String = 30; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(550); plotgmpe(handles);
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[1e-5 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'AbrahamsonSilva2008_NGA_3.png'
        handles.e3.String = 30;
        handles.e4.String = 30;
        handles.e5.String = 90;
        handles.e7.String = 10;
        handles.e9.String = 760;
        handles.e10.Value = 1; %{'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e11.Value = 2; %{'aftershock','mainshock','foreshock','swarms'};
        handles.e12.Value = 1; %{'hangingwall','foot wall','other'};
        handles.e13.Value = 1; % {'measured','inferred'};
        handles.e1.String=5; handles.e2.String = 30; handles.e6.String = 7; handles.e8.String = Z10_default_AS08_NGA(760); plotgmpe(handles);
        handles.e1.String=6; handles.e2.String = 30; handles.e6.String = 3; handles.e8.String = Z10_default_AS08_NGA(760); plotgmpe(handles);
        handles.e1.String=7; handles.e2.String = 30; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(760); plotgmpe(handles);
        handles.e1.String=8; handles.e2.String = 30; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(760); plotgmpe(handles);
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[1e-5 1];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'AbrahamsonSilva2008_NGA_4.png'
        handles.e3.String = 1;
        handles.e4.String = 1;
        handles.e5.String = 90;
        handles.e7.String = 15;
        handles.e9.String = 270;
        handles.e10.Value = 1; %{'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e11.Value = 2; %{'aftershock','mainshock','foreshock','swarms'};
        handles.e12.Value = 1; %{'hangingwall','foot wall','other'};
        handles.e13.Value = 1; % {'measured','inferred'};
        handles.e1.String=5; handles.e2.String = 1; handles.e6.String = 7; handles.e8.String = Z10_default_AS08_NGA(270); plotgmpe(handles);
        handles.e1.String=6; handles.e2.String = 1; handles.e6.String = 3; handles.e8.String = Z10_default_AS08_NGA(270); plotgmpe(handles);
        handles.e1.String=7; handles.e2.String = 1; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(270); plotgmpe(handles);
        handles.e1.String=8; handles.e2.String = 1; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(270); plotgmpe(handles);
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[1e-4 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'AbrahamsonSilva2008_NGA_5.png'
        %1-M, 2-Vs30, 3-Rrup, 4-Rjb, 5-Rx, 6-dip, 7-Ztor, 8-Z10, 9-W, 10-mechanism, 11-eventtype, 12-side, 13-Vs30source
        
        handles.e3.String = 1;
        handles.e4.String = 1;
        handles.e5.String = 90;
        handles.e7.String = 15;
        handles.e9.String = 550;
        handles.e10.Value = 1; %{'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e11.Value = 2; %{'aftershock','mainshock','foreshock','swarms'};
        handles.e12.Value = 1; %{'hangingwall','foot wall','other'};
        handles.e13.Value = 1; % {'measured','inferred'};
        handles.e1.String=5; handles.e2.String = 1; handles.e6.String = 7; handles.e8.String = Z10_default_AS08_NGA(550); plotgmpe(handles);
        handles.e1.String=6; handles.e2.String = 1; handles.e6.String = 3; handles.e8.String = Z10_default_AS08_NGA(550); plotgmpe(handles);
        handles.e1.String=7; handles.e2.String = 1; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(550); plotgmpe(handles);
        handles.e1.String=8; handles.e2.String = 1; handles.e6.String = 0; handles.e8.String = Z10_default_AS08_NGA(550); plotgmpe(handles);
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[1e-4 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Sadigh1997_1a.png'
        handles.e2.String='1';  %Rrup
        handles.e3.Value=2;     % mechanism: 1 reverse/thrust or 2 strike-slip 
        handles.e4.Value=1;     % media:  1 rock or 2 deepsoil
        handles.e1.String=5.5;   plotgmpe(handles);
        handles.e1.String=6.5;   plotgmpe(handles);
        handles.e1.String=7.5;   plotgmpe(handles);
        handles.e1.String=8.5;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0007 2];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Sadigh1997_1b.png'
        handles.e2.String=10;  %Rrup
        handles.e3.Value=2;     % mechanism: 1 reverse/thrust or 2 strike-slip 
        handles.e4.Value=1;     % media:  1 rock or 2 deepsoil
        handles.e1.String=5.5;   plotgmpe(handles);
        handles.e1.String=6.5;   plotgmpe(handles);
        handles.e1.String=7.5;   plotgmpe(handles);
        handles.e1.String=8.5;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0007 2];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Sadigh1997_1c.png'
        handles.e2.String=30;  %Rrup
        handles.e3.Value=2;     % mechanism: 1 reverse/thrust or 2 strike-slip 
        handles.e4.Value=1;     % media:  1 rock or 2 deepsoil
        handles.e1.String=5.5;   plotgmpe(handles);
        handles.e1.String=6.5;   plotgmpe(handles);
        handles.e1.String=7.5;   plotgmpe(handles);
        handles.e1.String=8.5;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0007 2];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';
        
    case 'Sadigh1997_1d.png'
        handles.e2.String=70;  %Rrup
        handles.e3.Value=2;     % mechanism: 1 reverse/thrust or 2 strike-slip 
        handles.e4.Value=1;     % media:  1 rock or 2 deepsoil
        handles.e1.String=5.5;   plotgmpe(handles);
        handles.e1.String=6.5;   plotgmpe(handles);
        handles.e1.String=7.5;   plotgmpe(handles);
        handles.e1.String=8.5;   plotgmpe(handles);
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.0007 2];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';      
        
    case 'AbrahamsonSilva1997h_1.png'
        %1  2     3      4         5         6
        %M, rrup, media, mechanism, location, sig
        handles.e1.String = 7;
        handles.e4.Value  = 1; %{'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e5.Value  = 2; %{'hangingwall','footwall'};
        handles.e6.Value  = 1; % {'measured','inferred'};
        handles.e2.String = 1;   handles.e3.Value = 1; plotgmpe(handles);
        handles.e2.String = 10;  handles.e3.Value = 1; plotgmpe(handles);
        handles.e2.String = 30;  handles.e3.Value = 1; plotgmpe(handles);
        handles.e2.String = 100; handles.e3.Value = 1; plotgmpe(handles);
        
        handles.e2.String = 1;   handles.e3.Value = 2; plotgmpe(handles);
        handles.e2.String = 10;  handles.e3.Value = 2; plotgmpe(handles);
        handles.e2.String = 30;  handles.e3.Value = 2; plotgmpe(handles);
        handles.e2.String = 100; handles.e3.Value = 2; plotgmpe(handles);

        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.01 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log'; 
        
    case 'AbrahamsonSilva1997h_2.png'
        %1  2     3      4         5         6
        %M, rrup, media, mechanism, location, sig
        handles.e2.String = 10;
        handles.e4.Value  = 1; %{'strike-slip','normal','normal-oblique','reverse','reverse-oblique','thrust'};
        handles.e5.Value  = 2; %{'hangingwall','footwall'};
        handles.e6.Value  = 1; % {'measured','inferred'};
        
        handles.e1.String = 5.5;  handles.e3.Value = 1; plotgmpe(handles);
        handles.e1.String = 6.5;  handles.e3.Value = 1; plotgmpe(handles);
        handles.e1.String = 7.5;  handles.e3.Value = 1; plotgmpe(handles);
        
        handles.e1.String = 5.5;  handles.e3.Value = 2; plotgmpe(handles);
        handles.e1.String = 6.5;  handles.e3.Value = 2; plotgmpe(handles);
        handles.e1.String = 7.5;  handles.e3.Value = 2; plotgmpe(handles);        
        
        handles.ax1.XLim=[0.01  10];
        handles.ax1.YLim=[0.01 10];
        handles.ax1.XScale='log';
        handles.ax1.YScale='log';         
        
end

handles.units=units0;
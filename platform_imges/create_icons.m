%% psha buttons
c1  = double(imread('form1.jpg'))/255;
c2  = double(imread('form2.jpg'))/255;
c3  = double(imread('engine.jpg'))/255;
c4  = double(imread('form1.jpg'))/255;
c5  = double(imread('Legend.jpg'))/255;
c6  = double(imread('Limits.jpg'))/255;
c7  = double(imread('exit.jpg'))/255;
c8  = double(imread('Scale.jpg'))/255;
c9  = double(imread('Refresh.jpg'))/255;
c10 = double(imread('Refresh2.jpg'))/255;
c11 = double(imread('book_open.jpg'))/255;
c12 = double(imread('Pallet.jpg'))/255;

save pshabuttons c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12

handles.form1                      = c1;
handles.form2                      = c2;
handles.engine.CData               = c3;
handles.switchmode.CData           = c4;
handles.addLeg.CData               = c5;
handles.ax2Limits.CData            = c6;
handles.Exit_button.CData          = c7;
handles.Distance_button.CData      = c8;
handles.po_refresh_GE.CData        = c9;
handles.RefreshButton.CData        = c10;
handles.OpenRef.CData              = c11;
handles.ColorSecondaryLines.CData  = c12;

%% scenarios buttons 
Undockbutton = double(imread('Undock.jpg'))/255;
sumbuttonbutton = double(imread('Sum.jpg'))/255;
ExitButtonbutton = double(imread('exit.jpg'))/255;
plotTesselbutton=double(imresize(imread('Tessel.jpg'),[20 20]))/255;
GridManagerbutton=double(imread('AxisGrid.jpg'))/255;
ShowNodesbutton=double(imread('Nodes.jpg'))/255;
AddNewScenariobutton=double(imread('AddNew.jpg'))/255;
DeleteButtonbutton=double(imread('selection_delete.jpg'))/255;
DiscretizeMButtonbutton=double(imread('MagnitudeDisc.jpg'))/255;
DiscretizeRButtonbutton=double(imread('Grid.jpg'))/255;
SortButtonbutton =double(imread('Sort.jpg'))/255;
Rulerbutton = double(imread('Scale.jpg'))/255;
invokeWizbutton = double(imresize(imread('MagicWand.jpg'),[20 20]))/255;
save All_Scenario_Buttons

%% psda buttons

c1  = double(imread('Open_Lock.jpg'))/255;
c2  = double(imread('Closed_Lock.jpg'))/255;
c3  = double(imread('Legend.jpg'))/255;
c4  = double(imread('Play.jpg'))/255;
c5  = double(imread('Limits.jpg'))/255;
c6  = double(imread('Settings.jpg'))/255;
c7  = double(imread('tree.jpg'))/255;
c8  = c1;
c9  = double(imread('undock.jpg'))/255;
c10 = double(imread('PlayCDM.jpg'))/255;
c11 = double(imread('Settings.jpg'))/255;
c12 = double(imread('Pallet.jpg'))/255;
c13 = double(imread('book_open.jpg'))/255;
save psdabuttons c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13

handles.CDataOpen                 = c1;
handles.CDataClosed               = c2;
handles.toggle1.CData             = c3;
handles.runREG.CData              = c4;
handles.ax2Limits.CData           = c5;
handles.REG_DisplayOptions.CData  = c6;
handles.treebutton.CData          = c7;
handles.deleteButton.CData        = c8;
handles.undock.CData              = c9;
handles.runCDM.CData              = c10;
handles.CDM_DisplayOptions.CData  = c11;
handles.ColorSecondaryLines.CData = c12;
handles.ref1.CData                = c13;

%% grd buttons
clearvars

c1  = double(imread('Exit.jpg'))/255;
c2  = double(imread('Scale.jpg'))/255;
c3  = double(imread('Refresh.jpg'))/255;
c4  = double(imread('Undock.jpg'))/255;
save grdbuttons c1 c2 c3 c4

handles.Exit_button.CData     = c1;
handles.Distance_button.CData = c2;
handles.po_refresh_GE.CData   = c3;
handles.undock.CData          = c4;

%% css buttons
c1  = double(imread('Legend.jpg'))/255;
c2  = double(imresize(imread('MagicWand.jpg'),[20 20]))/255;
c3  = double(imread('Undock.jpg'))/255;
c4  = double(imread('Play.jpg'))/255;
c5  = double(imread('Limits.jpg'))/255;

save CSSbuttons c1 c2 c3 c4 c5
handles.createFiles.CData = c1;
handles.wand.CData        = c2;
handles.Undock.CData      = c3;
handles.Run.CData         = c4;


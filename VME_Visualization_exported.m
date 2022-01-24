classdef VME_Visualization_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        VisualizationtabsUIFigure      matlab.ui.Figure
        VMEVisualizationToolPanel      matlab.ui.container.Panel
        LoaddatafilesPanel             matlab.ui.container.Panel
        AHUPanel                       matlab.ui.container.Panel
        ImportAHUdataButton            matlab.ui.control.Button
        SelectdatafileButton           matlab.ui.control.Button
        VAVzonesPanel                  matlab.ui.container.Panel
        ImportVAVzonedataButton        matlab.ui.control.Button
        SelectdatafilesButton          matlab.ui.control.Button
        Panel                          matlab.ui.container.Panel
        TextArea                       matlab.ui.control.TextArea
        SeasonalavailabilityEditField  matlab.ui.control.NumericEditField
        SeasonalavailabilityEditFieldLabel  matlab.ui.control.Label
        BuildingEditField              matlab.ui.control.EditField
        BuildingEditFieldLabel         matlab.ui.control.Label
        VAVzonesEditField              matlab.ui.control.EditField
        VAVzonesEditFieldLabel         matlab.ui.control.Label
        AHUEditField                   matlab.ui.control.EditField
        AHUEditFieldLabel              matlab.ui.control.Label
        SelectdatesPanel               matlab.ui.container.Panel
        StartDateEditField             matlab.ui.control.EditField
        Label                          matlab.ui.control.Label
        StartdateButton                matlab.ui.control.Button
        EndDateEditField               matlab.ui.control.EditField
        EnddateButton                  matlab.ui.control.Button
        ApplydatesButton               matlab.ui.control.Button
        VisualizationPanel             matlab.ui.container.Panel
        VisualizecurrentselectionButton  matlab.ui.control.Button
        AddanothervisualizationButton  matlab.ui.control.Button
    end


    properties (Access = private)
        % Prperties for AHU and VAV zones raw data files for visualization 1
        tRdAHU1 % raw data table from AHU
        AHUfile1 % AHU raw data excel file name 
        fNs1 % AHUfile name split (buildingname_AHUnum)
        VAVfolder1 % Selected folder for VAV zones
        VAVfiles1 % VAV files in VAVfolder directory
        fileNumber1 % vav zone file sequential number
        fullName1 % vav zone file name and path [name,path]
        tZa1 % zone air temperature (degC)
        fVAV1 % airflow rate from VAV box (L/s)
        fVAV1Sp % airflow rate setpoint from VAV box (L/s)
        vRad1 % radiator heater valve position (%)
        dVAV1 % vav terminal damper position (%)
        oCC1 % occupancy indicator (between 9 am and 5 pm)
        
        % Propoerties for date-time for vis 1
        sDc1 % Start date picker (Character format) 
        sDn1 % Start date (Datenum format) 
        eDc1 % End date picker (Character format) 
        eDn1 % End date (Datenum format) 
        
        % Properties of filtered raw data based on date selection for visualization 1
        tRdAHU1F % raw data table from AHU filtered
        tZa1F % zone air temperature (degC) filtered
        fVAV1F % airflow rate from VAV box (L/s) filtered
        vRad1F % radiator heater valve position (%) filtered
        dVAV1F % vav terminal damper position (%) filtered
        oCC1F % occupancy indicator (between 9 am and 5 pm) filtered
        
        % Properties of results from visualization 1
        oAf1 % Outdoor air fraction for AHU
        tVm1 % Table of virtual metering results for the entire dataset
        tVm1F % Table of filtered virtual metering results based on date selection
    end

    properties (Access = public)
        SDB % Start date button
        SDEF % Start date edit field
        EDB % End date button
        EDEF % End date edit field 
        ASDB % Apply selected dates button
        ENVM % Energy virtual meters for the selected dates
        HCVM % Energy supplied by the heating coil (MWh)
        CCVM % Energy supplied by the cooling coil (MWh)
        SFVM % Energy supplied by the supply fan (MWh)
        RADVM % Energy supplied by radiant heaters (MWh)
        Vfig % visualization UIFig 
        uiax % UI axes of visualization figure
        uiaxRAD % UI axes of RAD visualization figure
        rHc  % Radiant heater center as percentage of fig height
        hCc % Heating coil center as percentage of fig height
        cCc  % Cooling coil center as percentage of fig height
        sFc % Supply fan center as percentage of fig height
        cMh  % Component maximum hight
        scale % UI figure scale
        ix % AHU image x location
        iy % AHU image location
        R1
        T1
        R2
        T2
        R31
        T31
        R32
        R33
        R41
        R42
        T42
        R51
        T51
        R52
        R53
        R61
        R62
        T62
        remove
        tVm1F_oCC
        tVm1F_UnoCC
        ERAD % Explore VAV zone radiant heaters
        RADMF % Filtered and sorted RAD matrix
        zF % Zone file number 
        sL % Square length for RAD visualization
        sLa % Adjusted square length for RAD visualization
        eRad % Sum of heat added by radiant heater for each zone
        Dup % Duplicate push button
        ENVMUnFil % Total energy table from each component for the entire date range (for scale)
        SA % Seasonal availability (1: heating available in winter only and cooling available in summer only. 0: heating and cooling available yearround
       
    end

    methods (Access = public)
    
 % (1) Start date function 
        function StartDate(app)
            fig = uifigure('Position',[500 500 420 280]);
    fig.Name = "Start date";
    fig.Color = [0.94 0.97 1];
    app.sDc1 = uidatepicker(fig,'DisplayFormat','dd-MM-yyyy',...
    'Position',[130 190 150 22],...
    'Value',min(app.tRdAHU1.dT)-1,...
    'ValueChangedFcn', @datechange); % Start date from the minimum of datetime stamp in raw data

    function datechange (src,event)
        lastdate = char(event.PreviousValue);
        newdate = char(event.Value);
        msg = ['Change date from ' lastdate ' to ' newdate '?'];
        %Confirm new date
        selection = uiconfirm(fig,msg,'Confirm Date','CloseFcn',@(h,e)mycallback(fig));
        function mycallback(fig)
            app.StartDateEditField.Value = datestr(app.sDc1.Value);
            app.SDEF.Value = datestr(app.sDc1.Value);
            app.sDn1 = datenum(app.sDc1.Value); % Start date in datenum format
            app.SDEF.Value = datestr(app.sDc1.Value);
        close(fig)
        end 
        
        if (strcmp(selection,'Cancel'))
        %Revert to previous selection if cancelled
            app.sDc1.Value = event.PreviousValue;
            app.StartDateEditField.Value = datestr(app.sDc1.Value);
            app.SDEF.Value = datestr(app.sDc1.Value);
            app.sDn1 = datenum(app.sDc1.Value); % Start date in datenum format
        end
        
    end 
            
        end
       
% (2) End date function 
        function EndDate(app)
            fig = uifigure('Position',[500 500 420 280]);
    fig.Name = "End date";
    fig.Color = [0.94 0.97 1];
    app.eDc1 = uidatepicker(fig,'DisplayFormat','dd-MM-yyyy',...
    'Position',[130 190 150 22],...
    'Value',min(app.tRdAHU1.dT),...
    'ValueChangedFcn', @datechange); % End date from the minimum of datetime stamp in raw data

    function datechange (src,event)
        lastdate = char(event.PreviousValue);
        newdate = char(event.Value);
        msg = ['Change date from ' lastdate ' to ' newdate '?'];
        %Confirm new date
        selection = uiconfirm(fig,msg,'Confirm Date','CloseFcn',@(h,e)mycallback(fig));
        
        function mycallback(fig)
            app.EndDateEditField.Value = datestr(app.eDc1.Value);
            app.EDEF.Value = datestr(app.eDc1.Value);
            app.eDn1 = datenum(app.eDc1.Value); % End date in datenum format
        close(fig)
        end 
        
        if (strcmp(selection,'Cancel'))
        %Revert to previous selection if cancelled
            app.eDc1.Value = event.PreviousValue;
            app.EndDateEditField.Value = datestr(app.eDc1.Value);
            app.EDEF.Value = datestr(app.eDc1.Value);
            app.eDn1 = datenum(app.eDc1.Value); % End date in datenum format
        end
    end 
    end 

% (3) Apply dates function 

        function ApplyDates(app)
            WB = waitbar(0, 'Processing selection', 'Name', 'Applying user input selection',...
                'CreateCancelBtn', 'setappdata(gcbf,     ''canceling'', 1)');
                setappdata(WB,'canceling',0);
   
            app.tRdAHU1F = []; % Filtered VM table for visualization # 1
            numRows = size(app.tRdAHU1,1);
            
            k = 1;
           
            for i = 1:numRows
                if datenum(app.tRdAHU1{i,1}) >= app.sDn1 && datenum(app.tRdAHU1{i,1}) <= addtodate(app.eDn1,1,'day')
                    RowstoUse(1,k) = i;
                    k = k + 1;
                end
            end
            
            % Filtered raw data from AHU table and VAV zones based on the date selection for vis 1
            app.tRdAHU1F = app.tRdAHU1(RowstoUse,:);
            app.tZa1F = app.tZa1(RowstoUse,:);
            app.fVAV1F = app.fVAV1(RowstoUse,:);
            app.vRad1F = app.vRad1(RowstoUse,:);
            app.dVAV1F = app.dVAV1(RowstoUse,:);
            app.oCC1F = app.oCC1(RowstoUse,:);
   
 waitbar(0.3,WB,'Reading data');
 
            %% Virtual meters 
% AHU
% x1 and x2 for outdoor air fraction, x3 and x4 for heating coil, x5 and x6
% for cooling coil, x7 for supply fan, and x8 the error term
x = [0.489336981	0.001250208	11.86373667	0.406593697	25.43898859	0.686382059	0.00089324	-1.842505702];

timeStep = hours(app.tRdAHU1{3,1}-app.tRdAHU1{2,1}); % Timestep interval of raw data in hours

% Predicted outdoor air fraction
app.oAf1=x(1).*((app.tRdAHU1.dOa./100))+x(2); 

% Predicted heat added by heating coil
% Estimate heating load in W using the formula:
% heating load = (dennsity of air).(specific heat capacity of air).
%(volumetric flow rate of supply air).(temp rise across the heating coil)

app.SA = 1; % Seasonal availability, 1 indicates that heating is available in the winter only 
            %and cooling is available in summer only, 0 indicates that heating and cooling available yeararound 
            
tdHc = (3390.*(x(3).*(app.tRdAHU1.vHc./100)+x(4)))./(app.tRdAHU1.fSa); % Predicted temp. difference across the heating coil
tdHc(app.tRdAHU1.fSa<=0)=0;

if app.SA ==1
  tdHc((month(app.tRdAHU1.dT) > 5 & month(app.tRdAHU1.dT) < 10)) = 0;    
else 
 tdHc(app.tRdAHU1.fSa<=0)=0;
end 

qHc=tdHc.*((app.tRdAHU1.fSa)./1000).*1006.*1.225 ;

% Estimate heating energy injected into the supply air in kWh,
eHc = qHc.*(timeStep)./1000;
eHc_total = sum (eHc);

% Predicted heat extracted by the cooling coil
tdCc = (3390.*(x(5).*(app.tRdAHU1.vCc./100)+x(6)))./(app.tRdAHU1.fSa); % Predicted temp. difference across the cooling coil
tdCc(app.tRdAHU1.fSa<=0)=0;   

if app.SA ==1  
  tdCc((month(app.tRdAHU1.dT) > 10 | month(app.tRdAHU1.dT) < 5)) = 0;    
else 
 tdCc(app.tRdAHU1.fSa<=0)=0;
end 

qCc=tdCc.*((app.tRdAHU1.fSa)./1000).*1006.*1.225 ;
% Estimate cooling energy injected into the supply air in kWh,
eCc = qCc.*(timeStep)./1000;
eCc_total = sum (eCc);

% Predicted heat gains from the supply fan
tdSf=((x(7).*app.tRdAHU1.pSf));
% Estimate of heating load of the supply fan in Watts:
qSf = tdSf.*((app.tRdAHU1.fSa)./1000).*1006.*1.225 ; 
% Energy injected into the supply air by the supply fan in kWh
eSf = qSf.*(timeStep)./1000;
eSf_total = sum (eSf);

waitbar(0.6,WB,'Updating data');

%Predicted heat added by radiant heaters 

% Estimated heat added by radiant heaters in kW
vavParamaters = [];
    vavParamaters = readtable('Parameters.xlsx',"Sheet","data");

    vavParamaters.Properties.VariableNames{1} = 'zF'; % Zone file number
    vavParamaters.Properties.VariableNames{2} = 'zID'; % Zone ID
    vavParamaters.Properties.VariableNames{3} = 'pX'; % Parameter value
    vavParamaters.Properties.VariableNames{4} = 'mSn'; % Matlab reading order sequential number

    vavParamatersS = sortrows(vavParamaters,"zF");
    X = vavParamatersS.pX;
    mSn = vavParamatersS.mSn;
    app.zF = vavParamatersS.zF;
    zID = string(vavParamatersS.zID);

qRad = [];
for i = 1:length(app.vRad1(1,:))
    qRadP=((X(i).*(app.vRad1(:,i)./100))./1000);
     qRad(:,i)=[qRadP];
end 

% 2.2 Estimated heat added by radiant heaters in kWh

k = length(app.vRad1(1,:));
eRad_h = qRad.*(timeStep); % hourly energy in kWh
eRad_hT = sum(eRad_h,2); % total hourly energy from all zones in kWh
%eRad_d = permute(sum(reshape(eRad_h,24,365,k)),[2 3 1]); % daily energy in kWh
%eRad = sum(eRad_d); % total heat supplied by rad heater in kWh for the entire dataset
app.eRad = sum (eRad_h);
eRadT = sum(app.eRad);

%AA = [mSn zF zID(2:end) X eRad']; % For the entire dataset

%{
f = uifigure('Position',[500 500 420 180]); % [left bottom width height]
        mess = ['Dates from ',datestr(app.sDn1),' to ',datestr(app.eDn1),' applied!'];
        title = "Success";    
        uialert(f, mess, title,'Icon','success','CloseFcn',@(h,e) close(f));
%} 

waitbar(0.9,WB,'Applying selection');

% sort matrix AA in an ascending order based on the vav zone ID

%A = sortrows(AA,3);


% Total occupancy at each timestep
oCC1_h = sum(app.oCC1,2); % total hourly energy from all zones in kWh

% Convert datetime format into datenum format
dN = datenum(app.tRdAHU1.dT);
dT = app.tRdAHU1.dT;
app.tVm1 = table(dT,dN,eHc,eCc,eSf,eRad_hT,oCC1_h,app.tRdAHU1.vHc,app.tRdAHU1.vCc,app.tRdAHU1.fSa); % hourly VM table #1 for the entire date range

app.ENVMUnFil = [sum(app.tVm1.eHc)./1000 sum(app.tVm1.eCc)./1000 sum(app.tVm1.eSf)./1000 sum(app.tVm1.eRad_hT)./1000]; % Total energy from each component for the entire date range (for scale)
 
app.tVm1F = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1,1);
            
            k = 1;
           
            for i = 1:numRows
                if datenum(app.tVm1{i,1}) >= app.sDn1 && datenum(app.tVm1{i,1}) <= addtodate(app.eDn1,1,'day')
                    RowstoUse(1,k) = i;
                    k = k + 1;
                end
            end
            
app.tVm1F = app.tVm1(RowstoUse,:);
eRad_hF = eRad_h(RowstoUse,:);
eRadF = sum(eRad_hF);
A = [mSn app.zF zID X eRadF'];

% sort matrix AA in an ascending order based on the vav zone ID

app.RADMF = sortrows(A,3); % Filtered and sorted RAD matrix

app.HCVM = sum(app.tVm1F.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(app.tVm1F.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(app.tVm1F.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(app.tVm1F.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

 delete (WB);
 
        end
       
% (4) Visualization function
    
        function Visualize(app)
         
            % Set the plot scale based on max. of input data
    %app.scale = app.cMh/(max(app.ENVM));
    
     % (1) Heat supplied by the heating coil
    x1 = app.ix(1,2); % Starts when the AHU image ends
    y1 = app.hCc - (app.HCVM*app.scale/2); % Heating coil center - (HCVM*scale/2)
    w1 = 500 - app.ix(1,2);
    h1 = app.HCVM*app.scale; % Height = amount of virual metered energy*scale 

hold(app.uiax,'on')   
app.R1 = rectangle(app.uiax,'Position',[x1 y1 w1 h1],'FaceColor','1	0.388235294	0.278431373 0.5',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

txt = [num2str(round(app.HCVM,2)) ' MWh'];
app.T1 = text(app.uiax,(app.ix(1,2)+10),app.hCc,txt, 'Color','k','FontSize',10);

% (2) Heat extracted by the cooling coil
    x2 = app.ix(1,2); % Starts when the AHU image ends
    y2 = app.cCc - (app.CCVM*app.scale/2); %Cooling coil center - (CCVM*scale/2)
    w2 = 950 - app.ix(1,2);
    h2 = app.CCVM*app.scale; % Height = amount of virual metered energy*scale 

app.R2 = rectangle(app.uiax,'Position',[x2 y2 w2 h2],'FaceColor','0.690196 0.878431 0.90196 0.5',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

txt = [num2str(round(app.CCVM,2)) ' MWh'];
app.T2 = text(app.uiax,(app.ix(1,2)+10),app.cCc,txt, 'Color','k','FontSize',10);

% (3) Heat added by the supply fan
%Consists of 3 parts

x31 = app.ix(1,2); % Starts when the AHU image ends
y31 = app.sFc - (app.SFVM*app.scale/2); %Supply fan center - (SFVM*scale/2)
w31 = 250 - app.ix(1,2);
h31 = app.SFVM*app.scale; % Height = amount of virual metered energy*scale 

app.R31 = rectangle(app.uiax,'Position',[x31 y31 w31 h31],'FaceColor','0.98 0.5019 0.447 0.3',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

txt = [num2str(round(app.SFVM,2)) ' MWh'];
app.T31 = text(app.uiax,(app.ix(1,2)+10),app.sFc,txt, 'Color','k','FontSize',10);

x32 = app.ix(1,2)+w31; 
y32 = app.sFc - (app.SFVM*app.scale/2); %Supply fan center - (SFVM*scale/2)
w32 = app.SFVM*app.scale;
h32 = (y1+h1+(app.SFVM*app.scale))-y32; 

app.R32 = rectangle(app.uiax,'Position',[x32 y32 w32 h32],'FaceColor','0.98 0.5019 0.447 0.3',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

x33 = x32+w32; 
y33 = y1+h1; %Supply fan center - (eHc*scale/2)
w33 = (x1+w1)-x33;
h33 = app.SFVM*app.scale; 

app.R33 = rectangle(app.uiax,'Position',[x33 y33 w33 h33],'FaceColor','0.98 0.5019 0.447 0.3',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

% (4) A rectangle connecting the heat added by supply fan with heat added by heating coil
% consists of two parts

x41 = x33+w33; 
y41 = y1; %Supply fan center - (SFVM*scale/2)
w41 = 20;
h41 = app.SFVM*app.scale+app.HCVM*app.scale; 

app.R41 = rectangle(app.uiax,'Position',[x41 y41 w41 h41],'FaceColor','0.662745098	0.662745098	0.662745098 0.2',...
    'EdgeColor','k','LineWidth',0.5,'LineStyle','none'); %position [x y w h]

x42 = x41+w41; 
y42 = y1; %Supply fan center - (SFVM*scale/2)
w42 = 200;
h42 = app.SFVM*app.scale+app.HCVM*app.scale; 

app.R42 = rectangle(app.uiax,'Position',[x42 y42 w42 h42],'FaceColor','1	0	0 0.5',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

txt = [num2str(round((app.SFVM+app.HCVM),2)) ' MWh'];
app.T42 = text(app.uiax,(x42+10),(y42+h42/2),txt, 'Color','k','FontSize',10);

% (5) Heat added by the radiant heaters
% consists of 3 parts

x51 = app.ix(1,2); % Starts when the AHU image ends
y51 = app.rHc - (app.RADVM*app.scale/2); % Radiant heater center - (RADVM*scale/2)
w51 = (x42) - app.ix(1,2);
h51 = app.RADVM*app.scale; % Height = amount of virual metered energy*scale 

app.R51 = rectangle(app.uiax,'Position',[x51 y51 w51 h51],'FaceColor','0.862745098	0.078431373	0.235294118 0.5',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

txt = [num2str(round((app.RADVM),2)) ' MWh'];
app.T51 = text(app.uiax,(app.ix(1,2)+10),app.rHc,txt, 'Color','k','FontSize',10);

x52 = x51+w51; % Starts when the AHU image ends
y52 = y42+h42; % Radiant heater center - (RADVM*scale/2)
w52 = app.RADVM*app.scale;
h52 = (y51+h51)-(y42+h42); % Height = amount of virual metered energy*scale 

app.R52 = rectangle(app.uiax,'Position',[x52 y52 w52 h52],'FaceColor','0.862745098	0.078431373	0.235294118 0.5',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

x53 = x52+w52; % Starts when the AHU image ends
y53 = y52; % Radiant heater center - (RADVM*scale/2)
w53 = x42+w42-x53;
h53 = app.RADVM*app.scale; % Height = amount of virual metered energy*scale 

app.R53 = rectangle(app.uiax,'Position',[x53 y53 w53 h53],'FaceColor','0.862745098	0.078431373	0.235294118 0.5',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

% (6) A rectangle connecting the heat added by supply fan and heating coil with
% heat added by radiant heaters, consists of 2 parts

x61 = x42+w42; 
y61 = y1; %Supply fan center - (SFVM*scale/2)
w61 = 20;
h61 = app.SFVM*app.scale+app.HCVM*app.scale+app.RADVM*app.scale; 

app.R61 = rectangle(app.uiax,'Position',[x61 y61 w61 h61],'FaceColor','0.662745098	0.662745098	0.662745098 0.2',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

x62 = x61+w61; 
y62 = y1; %Supply fan center - (SFVM*scale/2)
w62 = 210;
h62 = app.SFVM*app.scale+app.HCVM*app.scale+app.RADVM*app.scale; 

app.R62 = rectangle(app.uiax,'Position',[x62 y62 w62 h62],'FaceColor','1	0	0 0.7',...
    'EdgeColor','b','LineWidth',3,'LineStyle','none'); %position [x y w h]

txt = [num2str(round((app.SFVM+app.HCVM+app.RADVM),2)) ' MWh'];
app.T62 = text(app.uiax,(x62+10),(y61+h61/2),txt, 'Color','k','FontSize',10);

 %(7) Building level rectangle

txt = ['VAV zones'];
text(app.uiax,(x61+30),(870),txt, 'Color','k','FontSize',11,'Rotation',0,'FontAngle','italic')

line (app.uiax,[x61 x61],[200 900],'Color','k','LineWidth',0.25,'LineStyle','-');
line (app.uiax,[950 950],[200 900],'Color','k','LineWidth',0.25,'LineStyle','-');
line (app.uiax,[x61 950],[200 200],'Color','k','LineWidth',0.25,'LineStyle','--');
line (app.uiax,[x61 950],[900 900],'Color','k','LineWidth',0.25,'LineStyle','--');
             
        end    

    %(5) Delete variable UI figure elements function
        
        function DeletePlot(app)
            
           app.remove = [app.R1,app.T1,app.R2,app.T2,app.R31,app.T31,app.R32,app.R33,...
               app.R41,app.R42,app.T42,app.R51,app.T51,app.R52,app.R53,app.R61,app.R62,app.T62];

           delete(app.remove) 
           
        end
    
    % (6) Occupied filter function 
    
     function FilterOccupied(app)
         
     app.tVm1F_oCC = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F{ii,7} > 0
                    RowstoUse_oCC(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        app.tVm1F_oCC = app.tVm1F(RowstoUse_oCC,:);
        %app.RADMF = app.RADMF(RowstoUse_oCC,:);

app.HCVM = sum(app.tVm1F_oCC.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(app.tVm1F_oCC.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(app.tVm1F_oCC.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(app.tVm1F_oCC.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

     end 
 
  % (7) Unoccupied filter function 
    
        function FilterUnoccupied(app)
         
     app.tVm1F_UnoCC = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F{ii,7} == 0
                    RowstoUse_UnoCC(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        app.tVm1F_UnoCC = app.tVm1F(RowstoUse_UnoCC,:);
        

app.HCVM = sum(app.tVm1F_UnoCC.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(app.tVm1F_UnoCC.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(app.tVm1F_UnoCC.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(app.tVm1F_UnoCC.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

        end 
    
    % (8) Heating coil on filter function regardless occupancy
   
        function FilterHeatingCoilOn(app)
         
     tVm1F_HcOn = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F{ii,8} > 0 && app.tVm1F{ii,10} > 0 
                    RowstoUse_HcOn(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_HcOn = app.tVm1F(RowstoUse_HcOn,:);
        

app.HCVM = sum(tVm1F_HcOn.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_HcOn.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_HcOn.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_HcOn.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

 end 
     % (9) Heating coil on filter function during occupied hours
   
        function FilterHeatingCoilOnOcc(app)
         
     tVm1F_HcOnOcc = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F_oCC,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F_oCC{ii,8} > 0 && app.tVm1F_oCC{ii,10} > 0
                    RowstoUse_HcOnOcc(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_HcOnOcc = app.tVm1F_oCC(RowstoUse_HcOnOcc,:);
        

app.HCVM = sum(tVm1F_HcOnOcc.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_HcOnOcc.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_HcOnOcc.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_HcOnOcc.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

        end 
    
     % (10) Heating coil on filter function during unoccupied hours
   
        function FilterHeatingCoilOnUnOcc(app)
         
     tVm1F_HcOnUnOcc = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F_UnoCC,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F_UnoCC{ii,8} > 0 && app.tVm1F_UnoCC{ii,10} > 0
                    RowstoUse_HcOnUnOcc(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_HcOnUnOcc = app.tVm1F_UnoCC(RowstoUse_HcOnUnOcc,:);
        

app.HCVM = sum(tVm1F_HcOnUnOcc.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_HcOnUnOcc.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_HcOnUnOcc.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_HcOnUnOcc.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

        end 
    
     % (11) Cooling coil on filter function regardless occupancy
   
        function FilterCoolingCoilOn(app)
         
     tVm1F_CcOn = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F{ii,9} > 0 && app.tVm1F{ii,10} > 0 
                    RowstoUse_CcOn(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_CcOn = app.tVm1F(RowstoUse_CcOn,:);
        

app.HCVM = sum(tVm1F_CcOn.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_CcOn.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_CcOn.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_CcOn.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

 end 
     % (12) Cooling coil on filter function during occupied hours
   
        function FilterCoolingCoilOnOcc(app)
         
     tVm1F_CcOnOcc = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F_oCC,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F_oCC{ii,9} > 0 && app.tVm1F_oCC{ii,10} > 0
                    RowstoUse_CcOnOcc(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_CcOnOcc = app.tVm1F_oCC(RowstoUse_CcOnOcc,:);
        

app.HCVM = sum(tVm1F_CcOnOcc.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_CcOnOcc.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_CcOnOcc.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_CcOnOcc.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

        end 
    
     % (13) Cooling coil on filter function during unoccupied hours
   
        function FilterCoolingCoilOnUnOcc(app)
         
     tVm1F_CcOnUnOcc = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F_UnoCC,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F_UnoCC{ii,9} > 0 && app.tVm1F_UnoCC{ii,10} > 0
                    RowstoUse_CcOnUnOcc(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_CcOnUnOcc = app.tVm1F_UnoCC(RowstoUse_CcOnUnOcc,:);
        

app.HCVM = sum(tVm1F_CcOnUnOcc.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_CcOnUnOcc.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_CcOnUnOcc.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_CcOnUnOcc.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

        end 
    
    % (14) Both heating and cooling coil valves on filter function
   
        function FilterHeatingCoolingCoilOn(app)
         
     tVm1F_HcCcOn = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F{ii,8} > 0 && app.tVm1F{ii,9} > 0 && app.tVm1F{ii,10} > 0
                    RowstoUse_HcCcOn(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_HcCcOn = app.tVm1F(RowstoUse_HcCcOn,:);
        

app.HCVM = sum(tVm1F_HcCcOn.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_HcCcOn.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_HcCcOn.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_HcCcOn.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];
        end 
    
    % (15) Both heating and cooling coil valves on filter function during occupied hours
   
        function FilterHeatingCoolingCoilOnOcc(app)
         
     tVm1F_HcCcOnOcc = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F_oCC,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F_oCC{ii,8} > 0 && app.tVm1F_oCC{ii,9} > 0 && app.tVm1F_oCC{ii,10} > 0
                    RowstoUse_HcCcOnOcc(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_HcCcOnOcc = app.tVm1F_oCC(RowstoUse_HcCcOnOcc,:);
        

app.HCVM = sum(tVm1F_HcCcOnOcc.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_HcCcOnOcc.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_HcCcOnOcc.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_HcCcOnOcc.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

        end 
    
    % (16) Both heating and cooling coil valves on filter function during unoccupied hours
   
        function FilterHeatingCoolingCoilOnUnOcc(app)
         
     tVm1F_HcCcOnUnOcc = []; % Filtered VM table for visualization # 1
            numRows = size(app.tVm1F_UnoCC,1);
            
            kk = 1;
           
            for ii = 1:numRows
                if app.tVm1F_UnoCC{ii,8} > 0 && app.tVm1F_UnoCC{ii,9} > 0 && app.tVm1F_UnoCC{ii,10} > 0
                    RowstoUse_HcCcOnUnOcc(1,kk) = ii;
                    kk = kk + 1;
                end
            end
            
        tVm1F_HcCcOnUnOcc = app.tVm1F_UnoCC(RowstoUse_HcCcOnUnOcc,:);
        

app.HCVM = sum(tVm1F_HcCcOnUnOcc.eHc)./1000; % Energy supplied by the heating coil (MWh)
app.CCVM = sum(tVm1F_HcCcOnUnOcc.eCc)./1000; % Energy supplied by the cooling coil (MWh)
app.SFVM = sum(tVm1F_HcCcOnUnOcc.eSf)./1000; % Energy supplied by the supply fan (MWh)
app.RADVM = sum(tVm1F_HcCcOnUnOcc.eRad_hT)./1000; % Energy supplied by radiant heaters (MWh)

app.ENVM = [app.HCVM app.CCVM app.SFVM app.RADVM];

        end 
    
     % (17) Explore radiant heater VAV zones 
   
        function ExploreRADVAVZones(app)
            
            fig = uifigure;
    fig.Name = ['Heat added by radiant heaters'];
    fig.Position = [890 440 500 400]; % %[left bottom width height]in pixels
    set ( fig, 'Color', [1 1 1] )
    
% Define plot axes and set their limits
    app.uiaxRAD=uiaxes(fig);
    app.uiaxRAD.Position = [app.uiaxRAD.Position(1:2) [fig.Position(3:4) - 2*app.uiaxRAD.Position(1:2)]];
    app.uiaxRAD.XLim = [0 1600];
    app.uiaxRAD.YLim = [0 1400];
    axis(app.uiaxRAD,'off')
 
% Divide the plot area into squares based on the number of vav zones. Total
% squares area is 1200x1200
app.sL = sqrt(1200.*1200./length (app.zF)); % squar length 

columns = ceil(1200/app.sL); % number of square columns in the plot
rows = floor(1200/app.sL); % number of square rows in the plot
app.sLa = 1200/columns; % adjusted square length

% rearrange eRad into (rowsxcolumns) matrix corresponding to squares
% respresenting vav zones

% eRad from string to double 
eRada = str2double(app.RADMF(:,5))';

% find extra squares in the plot
extra = columns*ceil(numel(eRada)/columns) - numel(eRada); % extra squares in the plot

% reshape eRada into rowsxcolumns corresponding to square plot matrix and
% set extra cells to -1
eRadr = reshape([eRada nan(extra,1)],columns,rows);
eRadr(isnan(eRadr))=-1;

% reshape vav zone ID to match squares in the plot
zIDa = app.RADMF(:,3)';
zIDr = reshape([zIDa nan(extra,1)],columns,rows);
zIDr(ismissing(zIDr))=" ";

% plot squares representing vav zones
for j = 1:rows
    
    for m = 1:columns
    x1 = (m-1)*app.sLa+(50*m);
    y1 = ((j-1)*app.sLa)+(50*j);
    w1 = app.sLa;
    h1 = app.sLa;
    
    rectangle(app.uiaxRAD,'Position',[x1 y1 w1 h1],'FaceColor','w',...
    'EdgeColor','k','LineWidth',1,'LineStyle','-'); %squares for vav zones

    rectangle(app.uiaxRAD,'Position',[(x1-50) (y1-50) 50 (h1+50)],'FaceColor','0.6875	0.765625	0.8671875 0.5',...
    'EdgeColor','k','LineWidth',1,'LineStyle','-'); %squares for vav zone ID

    rectangle(app.uiaxRAD,'Position',[x1 (y1-50) w1 50],'FaceColor','w',...
    'EdgeColor','k','LineWidth',1,'LineStyle','-'); %squares for heat added by rad. heaters

    % adding vav zone ID text
    txt1 = zIDr(m,j);
    text(app.uiaxRAD,(x1-25),(y1),txt1, 'Color','k','FontSize',9,'FontWeight','bold','Rotation',90)

    % adding heat supplied by radiant heater (in MWh)
   
    if eRadr(m,j)>=0
    txt2 = [num2str(round((eRadr(m,j))./1000,2)) ' MWh'];
    text(app.uiaxRAD,(x1+w1/2),(y1-25),txt2, 'Color','k','FontSize',9,'FontAngle','italic','Rotation',0, 'HorizontalAlignment','center')
    else
    txt3 = [" "];
    text(app.uiaxRAD,(x1+w1/2),(y1-25),txt3, 'Color','k','FontSize',9,'FontAngle','italic','Rotation',0, 'HorizontalAlignment','center') 
    end 
    
    % adding circles with varialble size correlated to the heat added in
    % each vav zone
    w2 = (app.sLa.*eRadr(m,j))/max(app.eRad);
    h2 = (app.sLa.*eRadr(m,j))/max(app.eRad);
    x2 = (x1+w1/2)-(w2/2);
    y2 = (y1+h1/2)-(h2/2);
    
    if eRadr(m,j)>0
    rectangle(app.uiaxRAD, 'Position', [x2 y2 w2 h2], 'Curvature', [1 1],...
        'FaceColor','0.8627 0.07843 0.23529 0.5','EdgeColor','0.8627 0.07843 0.23529 1',...
        'LineWidth',1,'LineStyle','-');
    hold(app.uiaxRAD,'on')
    
    elseif eRadr(m,j)==0
    plot(app.uiaxRAD,[x1 (x1+app.sLa)],[y1 (y1+app.sLa)],'Color','k',...
    'LineWidth',1,'LineStyle','--'); 

    else 
     rectangle(app.uiaxRAD,'Position',[x1 y1 w1 h1],'FaceColor','0.82421875	0.82421875	0.82421875 0.5',...
    'EdgeColor','k','LineWidth',1,'LineStyle','-'); 
    %rectangle(uiax,'Position',[x1 (y1+sLa/3) sLa sLa/3],'FaceColor','w',...
    %'EdgeColor','b','LineWidth',1,'LineStyle','-'); %position [x y w h]
    
    end

    end 
end 
            
        end 
    
    end 
           
   
      


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, SDB)
            app.VisualizationtabsUIFigure.Position = [5 130 321 600]; % Main UIFigure position [left bottom width height]
        end

        % Button pushed function: SelectdatafileButton
        function SelectdatafileButtonPushed(app, event)
          [file,filepath,filter] = uigetfile({'*.xlsx'},'Select the Excel file');
          app.AHUfile1 = fullfile(filepath, file);
          
          [filepath,name,ext] = fileparts(app.AHUfile1);
          app.fNs1 = strsplit(name,'_');
          
          f = uifigure('Position',[500 500 420 180]); % [left bottom width height]
        mess = ['File ',file,' successfully selected!'];
        title = "Success";    
        uialert(f, mess, title,'Icon','success','CloseFcn',@(h,e) close(f));
        
          drawnow;
          figure(app.VisualizationtabsUIFigure)
            
        end

        % Button pushed function: ImportAHUdataButton
        function ImportAHUdataButtonPushed(app, event)
    WB = waitbar(0, 'Importing AHU data', 'Name', 'xlsread AHU file progress',...
       'CreateCancelBtn', 'setappdata(gcbf,     ''canceling'', 1)');
   setappdata(WB,'canceling',0);
            
            app.tRdAHU1 = [];
    app.tRdAHU1 = readtable(app.AHUfile1,"Sheet","data");
    
    VN1 = ["date","time"];
    TF1= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN1),1));
    app.tRdAHU1.Properties.VariableNames{TF1} = 'dT'; % Datetime
    
    VN2 = ["sat","tsa"];
    TF2= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN2),1));
    app.tRdAHU1.Properties.VariableNames{TF2} = 'tSa'; % Supply air temperature (deg.C)
    
    waitbar(0.3,WB,'Reading data');
    VN3 = ["rat","tra"];
    TF3= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN3),1));
    app.tRdAHU1.Properties.VariableNames{TF3} = 'tRa'; % Return air temperature (deg.C)
    
    VN4 = ["oat","toa"];
    TF4= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN4),1));
    app.tRdAHU1.Properties.VariableNames{TF4} = 'tOa'; % Outdoor air temperature (deg.C)
    
    VN5 = ["sap","psa","fdp","fdsp","sfp"];
    TF5= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN5),1));
    app.tRdAHU1.Properties.VariableNames{TF5} = 'pSf'; % Supply fan pressure (Pa)
    
    waitbar(0.6,WB,'Reading data');
    VN6 = ["oad","doa"];
    TF6= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN6),1));
    app.tRdAHU1.Properties.VariableNames{TF6} = 'dOa'; % Outdoor air damper position (0 - 100)
    
    VN7 = ["hcv","vhc","hwv","hvmod"];
    TF7= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN7),1));
    app.tRdAHU1.Properties.VariableNames{TF7} = 'vHc'; % Heating coil valve position (0 - 100)
    
    VN8 = ["ccv","vcc","cwv","cvmod"];
    TF8= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN8),1));
    app.tRdAHU1.Properties.VariableNames{TF8} = 'vCc'; % Cooling coil valve position (0 - 100)
    
    waitbar(0.9,WB,'Reading data');
    VN9 = ["sf","sfs"];
    TF9= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN9),1));
    app.tRdAHU1.Properties.VariableNames{TF9} = 'sFs'; % Supply fan state (0 or 1)
    
    VN10 = ["saf","fsa","scf","scfav"];
    TF10= find(any(contains(string(app.tRdAHU1.Properties.VariableNames),VN10),1));
    app.tRdAHU1.Properties.VariableNames{TF10} = 'fSa'; % Supply airflow rate (L/s)
     
    delete (WB);
    
   f = uifigure('Position',[500 500 420 180]); % [left bottom width height]
        mess = ['Data for ',app.fNs1{2},' from ',app.fNs1{1},' building successfully loaded!'];
        title = "Success";    
        uialert(f, mess, title,'Icon','success','CloseFcn',@(h,e) close(f));
        app.BuildingEditField.Value = app.fNs1{1};
        app.AHUEditField.Value = app.fNs1{2};

        end

        % Button pushed function: SelectdatafilesButton
        function SelectdatafilesButtonPushed(app, event)
   
            [FileName,PathName] = uigetfile('*.xlsx', 'Open file','MultiSelect','on');
            app.VAVfiles1 = string(FileName);
            app.fileNumber1 = 1:length(app.VAVfiles1);
            app.fullName1 = string(fullfile(PathName, FileName));
            
    
    f = uifigure('Position',[500 500 420 180]); % [left bottom width height]
        mess = ['VAV folder successfully selected!'];
        title = "Success";    
        uialert(f, mess, title,'Icon','success','CloseFcn',@(h,e) close(f));
    
    drawnow;
          figure(app.VisualizationtabsUIFigure)
   
    

            
        end

        % Callback function
        function BuildingEditFieldValueChanged(app, event)
           
            
        end

        % Button pushed function: StartdateButton
        function StartdateButtonPushed(app, event)
           StartDate(app) % Call StartDate public function 
       
        end

        % Button pushed function: EnddateButton
        function EnddateButtonPushed(app, event)

            EndDate(app) % Call EndDate public function 
    
        end

        % Button pushed function: ApplydatesButton
        function ApplydatesButtonPushed(app, event)
            
            ApplyDates(app) % Call ApplyDates function 
        
        end

        % Button pushed function: VisualizecurrentselectionButton
        function VisualizecurrentselectionButtonPushed(app, event)
              
 % Fixed UI figure elements

    app.Vfig = uifigure;
    app.Vfig.Name = ['Visualization 1'];
    app.Vfig.Position = [330 440 560 400]; % %[left bottom width height]in pixels
    set ( app.Vfig, 'Color', [1 1 1] )
 
 % Define plot axes and set their limits
    app.uiax=uiaxes(app.Vfig);
    app.uiax.Position = [app.uiax.Position(1:2) [app.Vfig.Position(3:4) - 2*app.uiax.Position(1:2)]];
    app.uiax.XLim = [0 1400];
    app.uiax.YLim = [0 1000];
    
    axis(app.uiax,'off')
    
    
    %ax1 = uiaxes(fig,'position',[0.05 0.05 1000 1000]); %axis off; %[left bottom width height]
    
 % Insert an AHU and Rad Heaters convention image and define its location
    AHU_Rad = imread('AHU_Rad.png');
    opengl hardware
    app.ix = [0 147];
    app.iy = [0 900]; 
    image(app.uiax,app.ix,app.iy,(flip(AHU_Rad)));
    set(app.uiax,'YDir','normal');
    
     % Centers of imported AHU image,
    app.rHc = 0.863831489*app.iy(1,2); % Radiant heater center as percentage of fig height
    app.hCc = 0.553286229*app.iy(1,2); % Heating coil center as percentage of fig height
    app.cCc = 0.341154513*app.iy(1,2); % Cooling coil center as percentage of fig height
    app.sFc = 0.136*app.iy(1,2); % Supply fan center as percentage of fig height
    app.cMh = 0.157472.*app.iy(1,2); % Component maximum hight (e.g., 0.3937*900=94.475)
    
    % Set the plot scale based on max. of input data
    app.scale = app.cMh/(max(app.ENVMUnFil));
    

txt = ['RAD'];
text(app.uiax,30,870,txt, 'Color','k','FontSize',11,'Rotation',0, 'FontAngle','italic')

txt = ['AHU'];
text(app.uiax,30,590,txt, 'Color','k','FontSize',11,'Rotation',0, 'FontAngle','italic')

txt = ['HC'];
text(app.uiax,45,405,txt, 'Color','k','FontSize',11,'Rotation',0, 'FontAngle','italic')

txt = ['CC'];
text(app.uiax,45,218,txt, 'Color','k','FontSize',11,'Rotation',0, 'FontAngle','italic')

txt = ['SF'];
text(app.uiax,45,30,txt, 'Color','k','FontSize',11,'Rotation',0, 'FontAngle','italic')

% Insert legend

line (app.uiax,[400 980],[110 110],'Color','k','LineWidth',0.7,'LineStyle',':'); 

    txt = ['AHU: air handling unit'];
text(app.uiax,400,90,txt, 'Color','k','FontSize',9,'Rotation',0, 'FontAngle','italic')

txt = ['CC: cooling coil'];
text(app.uiax,400,60,txt, 'Color','k','FontSize',9,'Rotation',0, 'FontAngle','italic')

txt = ['HC: heating coil'];
text(app.uiax,400,30,txt, 'Color','k','FontSize',9,'Rotation',0, 'FontAngle','italic')

txt = ['RAD: radiant heaters'];
text(app.uiax,700,90,txt, 'Color','k','FontSize',9,'Rotation',0, 'FontAngle','italic')

txt = ['SF: supply fan'];
text(app.uiax,700,60,txt, 'Color','k','FontSize',9,'Rotation',0, 'FontAngle','italic')

txt = ['VAV: variable air volume'];
text(app.uiax,700,30,txt, 'Color','k','FontSize',9,'Rotation',0, 'FontAngle','italic')

    % User interaction panel

x71 = 980; 
y71 = 0; 
w71 = 420;
h71 = 1000; 

rectangle(app.uiax,'Position',[x71 y71 w71 h71],'FaceColor','0.94	0.97 1 0.5',...
    'EdgeColor','0.94	0.97 1','LineWidth',2,'LineStyle','-'); %position [x y w h]

txt = ['User Interaction'];
text(app.uiax,(1030),(970),txt, 'Color','k','FontSize',14,'Rotation',0,...
    'FontAngle','normal', 'FontWeight','bold')

line (app.uiax,[980 1400],[999 999],'Color','k','LineWidth',0.7,'LineStyle','-');
line (app.uiax,[980 1400],[940 940],'Color','k','LineWidth',0.7,'LineStyle','-');

% User interaction - select

x72 = 980; 
y72 = 870; 
w72 = 420;
h72 = 60; 

rectangle(app.uiax,'Position',[x72 y72 w72 h72],'FaceColor','0.9 0.93 1 0.5',...
    'EdgeColor','0.94	0.97 1','LineWidth',2,'LineStyle','-'); %position [x y w h]

txt = ['Select'];
text(app.uiax,(1130),(900),txt, 'Color','k','FontSize',12,'Rotation',0,...
    'FontAngle','normal', 'FontWeight','bold')             

app.SDB = uibutton(app.Vfig,'push','Text','Start Date',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
             'BackgroundColor',[0.9 0.9 0.98],...
             'Position',[390 310 60 22],...
             'ButtonPushedFcn', @(s,e)StartDate(app)); % Start date button %[left bottom width height]in pixels
         
app.SDEF = uieditfield(app.Vfig,'text','Position',[455 310 80 22],...
             'Value', datestr(app.sDn1),...
             'FontSize',11,'FontWeight','normal','FontAngle','normal',...
             'HorizontalAlignment','center'); % Start date edit field [left bottom width height]
         
app.EDB = uibutton(app.Vfig,'push','Text','End Date',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
             'BackgroundColor',[0.9 0.9 0.98],...
             'Position',[390 280 60 22],...
             'ButtonPushedFcn', @(s,e)EndDate(app)); % End date button
         
app.EDEF = uieditfield(app.Vfig,'text','Position',[455 280 80 22],...
             'Value', datestr(app.eDn1),...
             'FontSize',11,'FontWeight','normal','FontAngle','normal',...
             'HorizontalAlignment','center'); % End date edit field [left bottom width height]
         
Visualize (app) % Call Visualization function

app.ASDB = uibutton(app.Vfig,'push','Text','Apply selection',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
             'BackgroundColor',[0.9 0.9 0.98],...
             'Position',[407 250 110 22],...
             'ButtonPushedFcn', @(s,e) NewVisualization(app,event)); % Apply selected dates button
         
            function  NewVisualization(app,event)
                DeletePlot(app)
                %cla(app.uiax)
                %delete(app.Vfig)
                ApplyDates(app)
                Visualize(app)
            end 
      
% User interaction - Filter

x73 = 980; 
y73 = 540; 
w73 = 420;
h73 = 60; 

rectangle(app.uiax,'Position',[x73 y73 w73 h73],'FaceColor','0.9 0.93 1 0.5',...
    'EdgeColor','0.94	0.97 1','LineWidth',2,'LineStyle','-'); %position [x y w h]

txt = ['Filter'];
text(app.uiax,(1130),(570),txt, 'Color','k','FontSize',12,'Rotation',0,...
    'FontAngle','normal', 'FontWeight','bold')

% Create checkboxes to filter the data

% Checkbox 1: filter the data based on occupied periods
cbx1 = uicheckbox(app.Vfig,'Text','Occupied',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
    'Position',[407 198 110 22],...
   'ValueChangedFcn', @(s,e) FilterOccupiedData(app,event));

 function  FilterOccupiedData(app,event) 
     
     if cbx1.Value == 0  && cbx2.Value == 0 && cbx3.Value == 0 && cbx4.Value == 0
         DeletePlot(app)
         ApplyDates(app)
         Visualize(app)
     end
     
     if cbx1.Value == 0  && cbx2.Value == 1 && cbx3.Value == 0 && cbx4.Value == 0
         FilterUnoccupied(app)  
         DeletePlot(app) 
         Visualize(app)
     end
     
     if cbx1.Value == 0  && cbx2.Value == 1 && cbx3.Value == 1 && cbx4.Value == 0
         FilterHeatingCoilOnUnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 0  && cbx2.Value == 1 && cbx3.Value == 1 && cbx4.Value == 1
         FilterHeatingCoolingCoilOnUnOcc(app) 
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 0  && cbx2.Value == 0 && cbx3.Value == 1 && cbx4.Value == 0
         FilterHeatingCoilOn(app)
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 0  && cbx2.Value == 0 && cbx3.Value == 0 && cbx4.Value == 1
         FilterCoolingCoilOn(app)
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 1  && cbx2.Value == 0 && cbx3.Value == 0 && cbx4.Value == 0
         FilterOccupied(app)  
         DeletePlot(app) 
         Visualize(app)
     end
     
     if cbx1.Value == 1  && cbx2.Value == 1 && cbx3.Value == 0 && cbx4.Value == 0
         DeletePlot(app)
         ApplyDates(app)
         Visualize(app)
     end
     
      if cbx1.Value == 1  && cbx2.Value == 1 && cbx3.Value == 1 && cbx4.Value == 0
         FilterHeatingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app)   
      end
      
      if cbx1.Value == 1  && cbx2.Value == 1 && cbx3.Value == 1 && cbx4.Value == 1
         FilterHeatingCoolingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
      end
      
      if cbx1.Value == 1  && cbx2.Value == 0 && cbx3.Value == 1 && cbx4.Value == 0
         FilterHeatingCoilOnOcc(app)
         DeletePlot(app) 
         Visualize(app) 
      end
      
      if cbx1.Value == 1  && cbx2.Value == 0 && cbx3.Value == 0 && cbx4.Value == 1
         FilterCoolingCoilOnOcc(app)
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 0  && cbx2.Value == 0 && cbx3.Value == 1
         FilterHeatingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
     end 
     
      if cbx1.Value == 0  && cbx2.Value == 1 && cbx3.Value == 1
         FilterHeatingCoilOnUnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 1  && cbx2.Value == 0 && cbx3.Value == 1
         FilterHeatingCoilOnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 1  && cbx2.Value == 1 && cbx3.Value == 1
         FilterHeatingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 0  && cbx2.Value == 0 && cbx4.Value == 1
         FilterCoolingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
       end 
     
      if cbx1.Value == 0  && cbx2.Value == 1 && cbx4.Value == 1
         FilterCoolingCoilOnUnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 1  && cbx2.Value == 0 && cbx4.Value == 1
         FilterCoolingCoilOnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 1  && cbx2.Value == 1 && cbx4.Value == 1
         FilterCoolingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
     end 
 end 

% Checkbox 2: filter the data based on unoccupied periods
cbx2 = uicheckbox(app.Vfig,'Text','Unoccupied',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
    'Position',[407 178 110 22],...
   'ValueChangedFcn', @(s,e) FilterUnoccupiedData(app,event));

  function  FilterUnoccupiedData(app,event)
                
             if cbx1.Value == 0  && cbx2.Value == 0 && cbx3.Value == 0 && cbx4.Value == 0
         DeletePlot(app)
         ApplyDates(app)
         Visualize(app)
     end
     
     if cbx1.Value == 0  && cbx2.Value == 1 && cbx3.Value == 0 && cbx4.Value == 0
         FilterUnoccupied(app)  
         DeletePlot(app) 
         Visualize(app)
     end
     
     if cbx1.Value == 0  && cbx2.Value == 1 && cbx3.Value == 1 && cbx4.Value == 0
         FilterHeatingCoilOnUnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 0  && cbx2.Value == 1 && cbx3.Value == 1 && cbx4.Value == 1
         FilterHeatingCoolingCoilOnUnOcc(app) 
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 0  && cbx2.Value == 0 && cbx3.Value == 1 && cbx4.Value == 0
         FilterHeatingCoilOn(app)
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 0  && cbx2.Value == 0 && cbx3.Value == 0 && cbx4.Value == 1
         FilterCoolingCoilOn(app)
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 1  && cbx2.Value == 0 && cbx3.Value == 0 && cbx4.Value == 0
         FilterOccupied(app)  
         DeletePlot(app) 
         Visualize(app)
     end
     
     if cbx1.Value == 1  && cbx2.Value == 1 && cbx3.Value == 0 && cbx4.Value == 0
         DeletePlot(app)
         ApplyDates(app)
         Visualize(app)
     end
     
      if cbx1.Value == 1  && cbx2.Value == 1 && cbx3.Value == 1 && cbx4.Value == 0
         FilterHeatingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app)   
      end
      
      if cbx1.Value == 1  && cbx2.Value == 1 && cbx3.Value == 1 && cbx4.Value == 1
         FilterHeatingCoolingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
      end
      
      if cbx1.Value == 1  && cbx2.Value == 0 && cbx3.Value == 1 && cbx4.Value == 0
         FilterHeatingCoilOnOcc(app)
         DeletePlot(app) 
         Visualize(app) 
      end
      
      if cbx1.Value == 1  && cbx2.Value == 0 && cbx3.Value == 0 && cbx4.Value == 1
         FilterCoolingCoilOnOcc(app)
         DeletePlot(app) 
         Visualize(app) 
     end
     
     if cbx1.Value == 0  && cbx2.Value == 0 && cbx3.Value == 1
         FilterHeatingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
     end 
     
      if cbx1.Value == 0  && cbx2.Value == 1 && cbx3.Value == 1
         FilterHeatingCoilOnUnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 1  && cbx2.Value == 0 && cbx3.Value == 1
         FilterHeatingCoilOnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 1  && cbx2.Value == 1 && cbx3.Value == 1
         FilterHeatingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 0  && cbx2.Value == 0 && cbx4.Value == 1
         FilterCoolingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
       end 
     
      if cbx1.Value == 0  && cbx2.Value == 1 && cbx4.Value == 1
         FilterCoolingCoilOnUnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 1  && cbx2.Value == 0 && cbx4.Value == 1
         FilterCoolingCoilOnOcc(app)  
         DeletePlot(app) 
         Visualize(app) 
      end 
      
      if cbx1.Value == 1  && cbx2.Value == 1 && cbx4.Value == 1
         FilterCoolingCoilOn(app)  
         DeletePlot(app) 
         Visualize(app) 
     end 
 end 

% Checkbox 3: filter the data based on heating coil valve on
cbx3 = uicheckbox(app.Vfig,'Text','HC valve on',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
    'Position',[407 158 110 22],...
   'ValueChangedFcn', @(s,e) FilterHcOn(app,event));

            function  FilterHcOn(app,event)
      
              if cbx3.Value == 1 && cbx1.Value == 0 && cbx2.Value == 0 && cbx4.Value == 0
                    FilterHeatingCoilOn(app)  
                    DeletePlot(app) 
                    Visualize(app)
              end
              
              if cbx3.Value == 1 && cbx1.Value == 1 && cbx2.Value == 0 && cbx4.Value == 0
                    FilterHeatingCoilOnOcc(app)  
                    DeletePlot(app) 
                    Visualize(app)
              end      
              
               if cbx3.Value == 1 && cbx1.Value == 0 && cbx2.Value == 1 && cbx4.Value == 0
                    FilterHeatingCoilOnUnOcc(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end      
               
               if cbx3.Value == 1 && cbx1.Value == 1 && cbx2.Value == 1 && cbx4.Value == 0
                    FilterHeatingCoilOn(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end 
               
               if cbx3.Value == 1 && cbx1.Value == 0 && cbx2.Value == 0 && cbx4.Value == 1
                    FilterHeatingCoolingCoilOn(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end   
               
               if cbx3.Value == 1 && cbx1.Value == 1 && cbx2.Value == 0 && cbx4.Value == 1
                    FilterHeatingCoolingCoilOnOcc(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end  
               
               if cbx3.Value == 1 && cbx1.Value == 0 && cbx2.Value == 1 && cbx4.Value == 1
                    FilterHeatingCoolingCoilOnUnOcc(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end  
               
                if cbx3.Value == 0 && cbx1.Value == 0 && cbx2.Value == 0 && cbx4.Value == 0
                    DeletePlot(app) 
                    ApplyDates(app)
                    Visualize(app)
                end 
                
                if cbx3.Value == 0 && cbx1.Value == 1 && cbx2.Value == 0 && cbx4.Value == 0
                    DeletePlot(app) 
                    FilterOccupied(app)
                    Visualize(app)
                end 
                
                if cbx3.Value == 0 && cbx1.Value == 0 && cbx2.Value == 1 && cbx4.Value == 0
                    DeletePlot(app) 
                    FilterUnoccupied(app)
                    Visualize(app)
                end 
                
                if cbx3.Value == 0 && cbx1.Value == 1 && cbx2.Value == 1 && cbx4.Value == 0 
                    DeletePlot(app) 
                    ApplyDates(app)
                    Visualize(app)
                end 
                
                 if cbx3.Value == 0 && cbx1.Value == 0 && cbx2.Value == 0 && cbx4.Value == 1
                    DeletePlot(app) 
                    FilterCoolingCoilOn(app)
                    Visualize(app)
                end 
                
                if cbx3.Value == 0 && cbx1.Value == 1 && cbx2.Value == 0 && cbx4.Value == 1
                    DeletePlot(app) 
                    FilterCoolingCoilOnOcc(app)
                    Visualize(app)
                end 
                
                if cbx3.Value == 0 && cbx1.Value == 0 && cbx2.Value == 1 && cbx4.Value == 1
                    DeletePlot(app) 
                    FilterCoolingCoilOnUnOcc(app)
                    Visualize(app)
                end 
                
                if cbx3.Value == 0 && cbx1.Value == 1 && cbx2.Value == 1 && cbx4.Value == 1
                    DeletePlot(app) 
                    FilterCoolingCoilOn(app)
                    Visualize(app)
                end 
               
            end 
        
% Checkbox 4: filter the data based on cooling coil valve on

cbx4 = uicheckbox(app.Vfig,'Text','CC valve on',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
    'Position',[407 138 110 22],...
   'ValueChangedFcn', @(s,e) FilterCcOn(app,event));

            function  FilterCcOn(app,event)     
                
              if cbx4.Value == 1 && cbx1.Value == 0 && cbx2.Value == 0 && cbx3.Value == 0
                    FilterCoolingCoilOn(app)  
                    DeletePlot(app) 
                    Visualize(app)
              end
              
              if cbx4.Value == 1 && cbx1.Value == 1 && cbx2.Value == 0 && cbx3.Value == 0
                    FilterCoolingCoilOnOcc(app)  
                    DeletePlot(app) 
                    Visualize(app)
              end      
              
               if cbx4.Value == 1 && cbx1.Value == 0 && cbx2.Value == 1 && cbx3.Value == 0
                    FilterCoolingCoilOnUnOcc(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end      
               
               if cbx4.Value == 1 && cbx1.Value == 1 && cbx2.Value == 1 && cbx3.Value == 0
                    FilterCoolingCoilOn(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end      
               
               if cbx4.Value == 1 && cbx1.Value == 0 && cbx2.Value == 0 && cbx3.Value == 1
                    FilterHeatingCoolingCoilOn(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end   
               
               if cbx4.Value == 1 && cbx1.Value == 1 && cbx2.Value == 0 && cbx3.Value == 1
                    FilterHeatingCoolingCoilOnOcc(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end  
               
               if cbx4.Value == 1 && cbx1.Value == 0 && cbx2.Value == 1 && cbx3.Value == 1
                    FilterHeatingCoolingCoilOnUnOcc(app)  
                    DeletePlot(app) 
                    Visualize(app)
               end  
               
                if cbx4.Value == 0 && cbx1.Value == 0 && cbx2.Value == 0 && cbx3.Value == 0 
                    DeletePlot(app) 
                    ApplyDates(app)
                    Visualize(app)
                end 
                
                if cbx4.Value == 0 && cbx1.Value == 1 && cbx2.Value == 0 && cbx3.Value == 0
                    DeletePlot(app) 
                    FilterOccupied(app)
                    Visualize(app)
                end 
                
                if cbx4.Value == 0 && cbx1.Value == 0 && cbx2.Value == 1 && cbx3.Value == 0  
                    DeletePlot(app) 
                    FilterUnoccupied(app)
                    Visualize(app)
                end 
                
                if cbx4.Value == 0 && cbx1.Value == 1 && cbx2.Value == 1 && cbx3.Value == 0
                    DeletePlot(app) 
                    ApplyDates(app)
                    Visualize(app)
                end 
                
                if cbx4.Value == 0 && cbx1.Value == 0 && cbx2.Value == 0 && cbx3.Value == 1
                    DeletePlot(app) 
                    FilterHeatingCoilOn(app)
                    Visualize(app)
                end 
                
                if cbx4.Value == 0 && cbx1.Value == 1 && cbx2.Value == 0 && cbx3.Value == 1
                    DeletePlot(app) 
                    FilterHeatingCoilOnOcc(app)
                    Visualize(app)
                end 
                
                if cbx4.Value == 0 && cbx1.Value == 0 && cbx2.Value == 1 && cbx3.Value == 1
                    DeletePlot(app) 
                    FilterHeatingCoilOnUnOcc(app)
                    Visualize(app)
                end 
                
                if cbx4.Value == 0 && cbx1.Value == 1 && cbx2.Value == 1 && cbx3.Value == 1
                    DeletePlot(app) 
                     FilterHeatingCoilOn(app)
                    Visualize(app)
                end 
               
            end 
        
% User interaction - Explore

x73 = 980; 
y73 = 240; 
w73 = 420;
h73 = 60; 

rectangle(app.uiax,'Position',[x73 y73 w73 h73],'FaceColor','0.9 0.93 1 0.5',...
    'EdgeColor','0.94	0.97 1','LineWidth',2,'LineStyle','-'); %position [x y w h]

txt = ['Explore'];
text(app.uiax,(1130),(270),txt, 'Color','k','FontSize',12,'Rotation',0,...
    'FontAngle','normal', 'FontWeight','bold')



app.ERAD = uibutton(app.Vfig,'push','Text','RAD VAV Zones',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
             'BackgroundColor',[0.9 0.9 0.98],...
             'Position',[407 88 110 22],...
             'ButtonPushedFcn', @(s,e) RADVAVZones(app,event)); % Explore radiant heater VAV zones button
         
              function  RADVAVZones(app,event)
                ExploreRADVAVZones(app)
              end 

%line (app.uiax,[980 1400],[110 110],'Color','k','LineWidth',0.7,'LineStyle','--');
%line (app.uiax,[980 980],[110 940],'Color','k','LineWidth',0.7,'LineStyle','--');
%line (app.uiax,[1400 1400],[110 940],'Color','k','LineWidth',0.7,'LineStyle','--');

app.Dup = uibutton(app.Vfig,'push','Text','Duplicate',...
    'FontSize',11,'FontWeight','normal','FontAngle','normal',...
             'BackgroundColor',[0.68627451	0.933333333	0.933333333],...
             'Position',[407 38 110 22],...
             'ButtonPushedFcn', @(s,e) Duplicate(app,event)); % Duplicate screen button
         
             function  Duplicate(app,event)
               VisualizecurrentselectionButtonPushed(app, event)
               app.Vfig.Position = [330 15 560 400]; % %[left bottom width height]in pixels
             end 
             
        end

        % Button pushed function: ImportVAVzonedataButton
        function ImportVAVzonedataButtonPushed(app, event)
            WB = waitbar(0, 'Importing VAV zones data', 'Name', 'xlsread VAV zone files progress',...
            'CreateCancelBtn', 'setappdata(gcbf,     ''canceling'', 1)');
            setappdata(WB,'canceling',0);
            
            for k=1:length(app.VAVfiles1)
                zone =readtable(app.fullName1(k),"Sheet","data");

                zone.Properties.VariableNames{1} = 'dT'; % Date time
                zone.Properties.VariableNames{2} = 'tZa1'; % Zone air temp (degC)
                zone.Properties.VariableNames{3} = 'fVAV1'; % % Airflow rate (L/s)
                zone.Properties.VariableNames{4} = 'fVAV1Sp'; % Airflow rate setpoint (L/s)
                zone.Properties.VariableNames{5} = 'vRad1'; % radiator heater valve position (%)
                zone.Properties.VariableNames{6} = 'dVAV1';  % Vav terminal damper position (%)
                zone.Properties.VariableNames{7} = 'oCC1';  % occupancy indicator (between 9 am and 5 pm)

                app.tZa1(:,k) = zone.tZa1; % indoor temperature (degC)
                app.fVAV1(:,k) = zone.fVAV1; % airflow rate (L/s)
                app.fVAV1Sp(:,k) = zone.fVAV1Sp; % airflow rate setpoint (L/s)
                app.vRad1(:,k) = zone.vRad1; % radiator heater valve position (%)
                app.dVAV1(:,k) = zone.dVAV1; % vav terminal damper position (%)
                app.oCC1(:,k) = zone.oCC1; % occupancy indicator (between 9 am and 5 pm)

             waitbar(k/length(app.VAVfiles1),WB, sprintf('Reading VAV zone .xls file %d of %d', k, length(app.VAVfiles1)));
                if getappdata(WB,'canceling')
                 break
                end
            end
            
delete(WB)

app.VAVzonesEditField.Value = num2str(length(app.VAVfiles1));

        f = uifigure('Position',[500 500 420 180]); % [left bottom width height]
        mess = ['Data from ', num2str(length(app.VAVfiles1)),' VAV zones successfully loaded!'];
        title = "Success";    
        uialert(f, mess, title,'Icon','success','CloseFcn',@(h,e) close(f));
        end

        % Value changed function: SeasonalavailabilityEditField
        function SeasonalavailabilityEditFieldValueChanged(app, event)
           
            value = app.SeasonalavailabilityEditField.Value;

            if value == 1
                    app.SA = 1;
                    
            else 
                    app.SA= 0;
            end 
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create VisualizationtabsUIFigure and hide until all components are created
            app.VisualizationtabsUIFigure = uifigure('Visible', 'off');
            app.VisualizationtabsUIFigure.Position = [100 100 328 605];
            app.VisualizationtabsUIFigure.Name = 'UI Figure';

            % Create VMEVisualizationToolPanel
            app.VMEVisualizationToolPanel = uipanel(app.VisualizationtabsUIFigure);
            app.VMEVisualizationToolPanel.TitlePosition = 'centertop';
            app.VMEVisualizationToolPanel.Title = 'VME Visualization Tool';
            app.VMEVisualizationToolPanel.BackgroundColor = [0.9412 0.9686 1];
            app.VMEVisualizationToolPanel.FontName = 'Nirmala UI';
            app.VMEVisualizationToolPanel.FontWeight = 'bold';
            app.VMEVisualizationToolPanel.FontSize = 16;
            app.VMEVisualizationToolPanel.Position = [1 2 327 602];

            % Create VisualizationPanel
            app.VisualizationPanel = uipanel(app.VMEVisualizationToolPanel);
            app.VisualizationPanel.TitlePosition = 'centertop';
            app.VisualizationPanel.Title = 'Visualization';
            app.VisualizationPanel.BackgroundColor = [0.8588 0.8902 1];
            app.VisualizationPanel.FontName = 'Nirmala UI';
            app.VisualizationPanel.FontWeight = 'bold';
            app.VisualizationPanel.Position = [0 0 323 108];

            % Create AddanothervisualizationButton
            app.AddanothervisualizationButton = uibutton(app.VisualizationPanel, 'push');
            app.AddanothervisualizationButton.BackgroundColor = [0.902 0.902 0.9804];
            app.AddanothervisualizationButton.FontName = 'Nirmala UI';
            app.AddanothervisualizationButton.Position = [79 13 154 26];
            app.AddanothervisualizationButton.Text = 'Add another visualization';

            % Create VisualizecurrentselectionButton
            app.VisualizecurrentselectionButton = uibutton(app.VisualizationPanel, 'push');
            app.VisualizecurrentselectionButton.ButtonPushedFcn = createCallbackFcn(app, @VisualizecurrentselectionButtonPushed, true);
            app.VisualizecurrentselectionButton.BackgroundColor = [0.902 0.902 0.9804];
            app.VisualizecurrentselectionButton.FontName = 'Nirmala UI';
            app.VisualizecurrentselectionButton.Position = [78 50 153 26];
            app.VisualizecurrentselectionButton.Text = 'Visualize current selection';

            % Create SelectdatesPanel
            app.SelectdatesPanel = uipanel(app.VMEVisualizationToolPanel);
            app.SelectdatesPanel.TitlePosition = 'centertop';
            app.SelectdatesPanel.Title = 'Select dates';
            app.SelectdatesPanel.BackgroundColor = [0.902 0.9294 1];
            app.SelectdatesPanel.FontName = 'Nirmala UI';
            app.SelectdatesPanel.FontWeight = 'bold';
            app.SelectdatesPanel.Position = [0 107 323 168];

            % Create ApplydatesButton
            app.ApplydatesButton = uibutton(app.SelectdatesPanel, 'push');
            app.ApplydatesButton.ButtonPushedFcn = createCallbackFcn(app, @ApplydatesButtonPushed, true);
            app.ApplydatesButton.BackgroundColor = [0.902 0.902 0.9804];
            app.ApplydatesButton.FontName = 'Nirmala UI';
            app.ApplydatesButton.Position = [92 15 134 26];
            app.ApplydatesButton.Text = 'Apply dates';

            % Create EnddateButton
            app.EnddateButton = uibutton(app.SelectdatesPanel, 'push');
            app.EnddateButton.ButtonPushedFcn = createCallbackFcn(app, @EnddateButtonPushed, true);
            app.EnddateButton.BackgroundColor = [0.902 0.902 0.9804];
            app.EnddateButton.FontName = 'Nirmala UI';
            app.EnddateButton.Position = [24 62 100 26];
            app.EnddateButton.Text = 'End date';

            % Create EndDateEditField
            app.EndDateEditField = uieditfield(app.SelectdatesPanel, 'text');
            app.EndDateEditField.Position = [155 64 143 22];

            % Create StartdateButton
            app.StartdateButton = uibutton(app.SelectdatesPanel, 'push');
            app.StartdateButton.ButtonPushedFcn = createCallbackFcn(app, @StartdateButtonPushed, true);
            app.StartdateButton.BackgroundColor = [0.902 0.902 0.9804];
            app.StartdateButton.FontName = 'Nirmala UI';
            app.StartdateButton.Position = [25 105 100 26];
            app.StartdateButton.Text = 'Start date';

            % Create Label
            app.Label = uilabel(app.SelectdatesPanel);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [142 107 25 22];
            app.Label.Text = '';

            % Create StartDateEditField
            app.StartDateEditField = uieditfield(app.SelectdatesPanel, 'text');
            app.StartDateEditField.Position = [155 107 143 22];

            % Create LoaddatafilesPanel
            app.LoaddatafilesPanel = uipanel(app.VMEVisualizationToolPanel);
            app.LoaddatafilesPanel.TitlePosition = 'centertop';
            app.LoaddatafilesPanel.Title = 'Load data files';
            app.LoaddatafilesPanel.FontName = 'Nirmala UI';
            app.LoaddatafilesPanel.FontWeight = 'bold';
            app.LoaddatafilesPanel.Position = [0 277 323 295];

            % Create Panel
            app.Panel = uipanel(app.LoaddatafilesPanel);
            app.Panel.ForegroundColor = [0.149 0.149 0.149];
            app.Panel.TitlePosition = 'centertop';
            app.Panel.BackgroundColor = [0.9412 0.9686 1];
            app.Panel.FontName = 'Nirmala UI';
            app.Panel.Position = [0 -3 319 148];

            % Create AHUEditFieldLabel
            app.AHUEditFieldLabel = uilabel(app.Panel);
            app.AHUEditFieldLabel.HorizontalAlignment = 'center';
            app.AHUEditFieldLabel.FontName = 'Nirmala UI';
            app.AHUEditFieldLabel.Position = [11 87 49 22];
            app.AHUEditFieldLabel.Text = 'AHU';

            % Create AHUEditField
            app.AHUEditField = uieditfield(app.Panel, 'text');
            app.AHUEditField.HorizontalAlignment = 'center';
            app.AHUEditField.FontName = 'Nirmala UI';
            app.AHUEditField.Position = [75 89 64 22];

            % Create VAVzonesEditFieldLabel
            app.VAVzonesEditFieldLabel = uilabel(app.Panel);
            app.VAVzonesEditFieldLabel.HorizontalAlignment = 'center';
            app.VAVzonesEditFieldLabel.FontName = 'Nirmala UI';
            app.VAVzonesEditFieldLabel.Position = [157 90 71 22];
            app.VAVzonesEditFieldLabel.Text = 'VAV zones';

            % Create VAVzonesEditField
            app.VAVzonesEditField = uieditfield(app.Panel, 'text');
            app.VAVzonesEditField.HorizontalAlignment = 'center';
            app.VAVzonesEditField.FontName = 'Nirmala UI';
            app.VAVzonesEditField.Position = [235 91 51 22];

            % Create BuildingEditFieldLabel
            app.BuildingEditFieldLabel = uilabel(app.Panel);
            app.BuildingEditFieldLabel.HorizontalAlignment = 'right';
            app.BuildingEditFieldLabel.FontName = 'Nirmala UI';
            app.BuildingEditFieldLabel.Position = [11 120 49 22];
            app.BuildingEditFieldLabel.Text = 'Building';

            % Create BuildingEditField
            app.BuildingEditField = uieditfield(app.Panel, 'text');
            app.BuildingEditField.HorizontalAlignment = 'center';
            app.BuildingEditField.FontName = 'Nirmala UI';
            app.BuildingEditField.Position = [75 120 211 22];

            % Create SeasonalavailabilityEditFieldLabel
            app.SeasonalavailabilityEditFieldLabel = uilabel(app.Panel);
            app.SeasonalavailabilityEditFieldLabel.HorizontalAlignment = 'right';
            app.SeasonalavailabilityEditFieldLabel.FontName = 'Nirmala UI';
            app.SeasonalavailabilityEditFieldLabel.Position = [16 56 111 22];
            app.SeasonalavailabilityEditFieldLabel.Text = 'Seasonal availability';

            % Create SeasonalavailabilityEditField
            app.SeasonalavailabilityEditField = uieditfield(app.Panel, 'numeric');
            app.SeasonalavailabilityEditField.ValueChangedFcn = createCallbackFcn(app, @SeasonalavailabilityEditFieldValueChanged, true);
            app.SeasonalavailabilityEditField.BackgroundColor = [0.9608 0.9608 0.9608];
            app.SeasonalavailabilityEditField.Position = [231 56 55 22];

            % Create TextArea
            app.TextArea = uitextarea(app.Panel);
            app.TextArea.HorizontalAlignment = 'center';
            app.TextArea.FontName = 'Nirmala UI';
            app.TextArea.FontSize = 10;
            app.TextArea.FontAngle = 'italic';
            app.TextArea.Position = [20 12 274 33];
            app.TextArea.Value = {' 1: Heating in winter and cooling in summer'; '0: Heating and cooling available year-round'};

            % Create VAVzonesPanel
            app.VAVzonesPanel = uipanel(app.LoaddatafilesPanel);
            app.VAVzonesPanel.ForegroundColor = [0.149 0.149 0.149];
            app.VAVzonesPanel.TitlePosition = 'centertop';
            app.VAVzonesPanel.Title = 'VAV zones';
            app.VAVzonesPanel.BackgroundColor = [0.9412 0.9686 1];
            app.VAVzonesPanel.FontName = 'Nirmala UI';
            app.VAVzonesPanel.Position = [140 144 179 127];

            % Create SelectdatafilesButton
            app.SelectdatafilesButton = uibutton(app.VAVzonesPanel, 'push');
            app.SelectdatafilesButton.ButtonPushedFcn = createCallbackFcn(app, @SelectdatafilesButtonPushed, true);
            app.SelectdatafilesButton.BackgroundColor = [0.902 0.902 0.9804];
            app.SelectdatafilesButton.FontName = 'Nirmala UI';
            app.SelectdatafilesButton.Position = [35 61 100 26];
            app.SelectdatafilesButton.Text = 'Select data files';

            % Create ImportVAVzonedataButton
            app.ImportVAVzonedataButton = uibutton(app.VAVzonesPanel, 'push');
            app.ImportVAVzonedataButton.ButtonPushedFcn = createCallbackFcn(app, @ImportVAVzonedataButtonPushed, true);
            app.ImportVAVzonedataButton.BackgroundColor = [0.902 0.902 0.9804];
            app.ImportVAVzonedataButton.FontName = 'Nirmala UI';
            app.ImportVAVzonedataButton.Position = [19 14 132 26];
            app.ImportVAVzonedataButton.Text = 'Import VAV zone data';

            % Create AHUPanel
            app.AHUPanel = uipanel(app.LoaddatafilesPanel);
            app.AHUPanel.ForegroundColor = [0.149 0.149 0.149];
            app.AHUPanel.TitlePosition = 'centertop';
            app.AHUPanel.Title = 'AHU';
            app.AHUPanel.BackgroundColor = [0.9412 0.9686 1];
            app.AHUPanel.FontName = 'Nirmala UI';
            app.AHUPanel.Position = [0 144 141 127];

            % Create SelectdatafileButton
            app.SelectdatafileButton = uibutton(app.AHUPanel, 'push');
            app.SelectdatafileButton.ButtonPushedFcn = createCallbackFcn(app, @SelectdatafileButtonPushed, true);
            app.SelectdatafileButton.BackgroundColor = [0.902 0.902 0.9804];
            app.SelectdatafileButton.FontName = 'Nirmala UI';
            app.SelectdatafileButton.Position = [20 61 100 26];
            app.SelectdatafileButton.Text = 'Select data file';

            % Create ImportAHUdataButton
            app.ImportAHUdataButton = uibutton(app.AHUPanel, 'push');
            app.ImportAHUdataButton.ButtonPushedFcn = createCallbackFcn(app, @ImportAHUdataButtonPushed, true);
            app.ImportAHUdataButton.BackgroundColor = [0.902 0.902 0.9804];
            app.ImportAHUdataButton.FontName = 'Nirmala UI';
            app.ImportAHUdataButton.Position = [16 14 107 26];
            app.ImportAHUdataButton.Text = 'Import AHU data';

            % Show the figure after all components are created
            app.VisualizationtabsUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = VME_Visualization_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.VisualizationtabsUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.VisualizationtabsUIFigure)
        end
    end
end
function varargout = gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)
handles.simulationStepStr = 'Simulation step [s] ';
handles = loadStructures(handles);
handles.nodes = handles.structures.square.nodes;
handles.adjMatrix = handles.structures.square.adjMatrix;
handles.fileName = 'dataSquare.xlsx';

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function handles = loadStructures(handles)
    handles.structures.square.nodes = {[0,0],[1250,0],[0,1250],[1250,1250]};
    handles.structures.square.adjMatrix = [0,1,1,0;
                                        1,0,0,1;
                                        1,0,0,1;
                                        0,1,1,0];
    handles.structures.eight.nodes = {[0,0],[700,0],[1400,0],[1400,700],[700,700],[0,700]};
    handles.structures.eight.adjMatrix = [0,1,0,0,0,1;
                                         1,0,1,0,1,0;
                                         0,1,0,1,0,0;
                                         0,0,1,0,1,0;
                                         0,1,0,1,0,1;
                                         1,0,0,0,1,0];


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbuttonSimulateSingleStep_Callback(hObject, eventdata, handles)
    handles.sim.simulate(1);
    handles.simPrinter.update();
    updateGuiAfterSimulationStep(handles);

function pushbuttonSimulateTill_Callback(hObject, eventdata, handles)
    set(handles.pushbuttonSimulateSingleStep, 'Enable', 'off');
    set(handles.pushbuttonReset, 'Enable', 'off');

    steps = str2num(get(handles.editSteps, 'String'));
    pauseTime = str2num(get(handles.editPauseTime, 'String'));
    if(pauseTime == 0)
        tic
        handles.sim.simulate(steps);
        handles.simPrinter.update();
        toc
    else
        for i = 1:steps        
            handles.sim.simulate(1);
            pause(pauseTime);
            handles.simPrinter.update();
            if(get(hObject, 'Value') == 0)
                break;
            end
            set(handles.textSimulationStep, 'String', ...
            [handles.simulationStepStr num2str(handles.sim.step) '/' num2str(handles.periodValue)]);
        end
    end
    updateGuiAfterSimulationStep(handles);
    
    set(handles.pushbuttonSimulateSingleStep, 'Enable', 'on');
    set(handles.pushbuttonReset, 'Enable', 'on');
    
    
function updateGuiAfterSimulationStep(handles)
    updateGuiWithResults(handles);
    updateRangeStr(handles);
    updateEditStepsValue(handles);
    set(handles.textSimulationStep, 'String', ...
        [handles.simulationStepStr num2str(handles.sim.step) '/' num2str(handles.periodValue)]);
    
    if(isSimulationEnded(handles))
        handleEndOfSimulation(handles);
    end

function numGroup1_Callback(hObject, eventdata, handles)
    validateNumGroupRanges(hObject);
    handleSumChanges(handles);

function numGroup2_Callback(hObject, eventdata, handles)
    validateNumGroupRanges(hObject);
    handleSumChanges(handles);
    
function validateNumGroupRanges(hObject)
    currentValue = str2num(get(hObject, 'String'));
    if(currentValue > 8)
        set(hObject, 'String', '8');
    elseif(currentValue < 3)
        set(hObject, 'String', '3');
    end
    
function status = isSumWrong(handles)
    status = false;
    num1 = str2num(get(handles.numGroup1, 'String'));
    num2 = str2num(get(handles.numGroup2, 'String'));
    if(num1 + num2 > 8)
        status = true;
    end
    
function handleSumChanges(handles)
    if(isSumWrong(handles))
        set(handles.textError, 'Visible', 'on');
        set(handles.pushbuttonStart, 'Enable', 'off');
    else
        set(handles.textError, 'Visible', 'off');
        set(handles.pushbuttonStart, 'Enable', 'on');
    end
    

function period_Callback(hObject, eventdata, handles)
    currentValue = str2num(get(hObject, 'String'));
    if(currentValue > 28800)
        set(hObject, 'String', '28800');
    elseif(currentValue < 1)
        set(hObject, 'String', '1');
    end
    

% --- Executes during object creation, after setting all properties.
function numGroup1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function numGroup2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function period_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in pushbuttonDetailedResults.
function pushbuttonDetailedResults_Callback(hObject, eventdata, handles)
    allFiles = dir('results');
    [dx, dx] = sort([allFiles.datenum],'descend');
    newest = allFiles(dx(1)).name;
    winopen(['results\', newest]);

% --- Executes on button press in pushbuttonShowInputData.
function pushbuttonShowInputData_Callback(hObject, eventdata, handles)
    winopen(handles.fileName);

   
function initializeSimulation(hObject, handles)
    cla(handles.axesSimulation);
    clearvars sim simPrinter;   

    mine = CorridorStructure(handles.nodes, handles.adjMatrix);
    mine = mine.init();

    numOfVehPerGroup = getNumOfVehicles(handles);
    comFalloutsEnabled = get(handles.checkboxComFallouts,'Value');
    
    sim = Simulator();
    sim.initSimulation(mine, numOfVehPerGroup, comFalloutsEnabled, handles.fileName);
    simPrinter = SimulationPrinter(sim, handles.axesSimulation);
    
    axes(handles.axesLegend);
    simPrinter.printLegend();
    
    axes(handles.axesSimulation);
    simPrinter.init();
    
    handles.sim = sim;    
    handles.simPrinter = simPrinter;
    handles.periodValue = str2num(get(handles.period, 'String'));
    
    guidata(hObject, handles);
    
    
    updateGuiAfterInitialization(handles);

    
function updateGuiAfterInitialization(handles)
    set(handles.pushbuttonSimulateSingleStep, 'Enable', 'on');
    set(handles.pushbuttonSimulateTill, 'Enable', 'on');
    set(handles.editSteps, 'Enable', 'on');
    set(handles.editPauseTime, 'Enable', 'on');
    set(handles.pushbuttonReset, 'Enable', 'on');
    
    set(handles.numGroup1, 'Enable', 'off');
    set(handles.numGroup2, 'Enable', 'off');
    set(handles.period, 'Enable', 'off');
    set(handles.pushbuttonStart, 'Enable', 'off');
    set(handles.checkboxComFallouts, 'Enable', 'off');
    set(handles.radiobuttonSquare, 'Enable', 'off');
    set(handles.radiobuttonEight, 'Enable', 'off');
    
    set(handles.editSteps, 'String', num2str(handles.periodValue));
    
    set(handles.textSimulationStep, ...
        'String', [handles.simulationStepStr '0/', num2str(handles.periodValue)]);
    
    updateRangeStr(handles);
    
    
function str = updateRangeStr(handles)
    currentStep = handles.sim.step;
    str = '';
    if(currentStep < handles.periodValue)    
        maxRange = int2str(handles.periodValue - currentStep);
        str = ['[1..', maxRange, ']'];
    else
        str = '[0]';
    end
    set(handles.textRange, 'String', str);

function updateEditStepsValue(handles)
    maxRange = int2str(handles.periodValue - handles.sim.step);
    set(handles.editSteps, 'String', num2str(maxRange));
    
    
function data = getNumOfVehicles(handles)
    group1 = str2num(get(handles.numGroup1, 'String'));
    group2 = str2num(get(handles.numGroup2, 'String'));
    
    data = group1;
    if(group2 ~= 0)
        data = [group1, group2];
    end
    
function updateGuiWithResults(handles)
    dataResult = handles.sim.getResultData();
    set(handles.uitableResults,'data',dataResult);
    
    g = num2str(sum(handles.sim .g), '%.2f');
    g1 = num2str(handles.sim .g(1), '%.2f');
    g2 = num2str(handles.sim .g(2), '%.2f');
    g3 = num2str(handles.sim .g(3), '%.2f');
    set(handles.textResultG, 'String', ['G = ', g]);
    set(handles.textResultsGi, 'String', ['G1 = ', g1, ...
        ', G2 = ', g2, ...
        ', G3 = ', g3]);
    set(handles.pushbuttonDetailedResults, 'Enable', 'on');



function editPauseTime_Callback(hObject, eventdata, handles)

function editPauseTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSteps_Callback(hObject, eventdata, handles)
    currentValue = str2num(get(hObject, 'String'));
    period = str2num(get(handles.period, 'String'));
    currentStep = handles.sim.step;
    maxValue = period - currentStep;
    if(currentValue < 0)
        set(hObject, 'String', '0');
    elseif(currentValue > maxValue)
        set(hObject, 'String', num2str(maxValue));
    end

% --- Executes during object creation, after setting all properties.
function editSteps_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonReset.
function pushbuttonReset_Callback(hObject, eventdata, handles)
    updateGuiAfterReset(handles);

function updateGuiAfterReset(handles)
    set(handles.pushbuttonSimulateSingleStep, 'Enable', 'off');
    set(handles.pushbuttonSimulateTill, 'Enable', 'off');
    set(handles.editSteps, 'Enable', 'off');
    set(handles.editPauseTime, 'Enable', 'off');
    set(handles.pushbuttonReset, 'Enable', 'off');
    
    set(handles.numGroup1, 'Enable', 'on');
    set(handles.numGroup2, 'Enable', 'on');
    set(handles.period, 'Enable', 'on');
    set(handles.pushbuttonStart, 'Enable', 'on');
    set(handles.checkboxComFallouts, 'Enable', 'on');
    set(handles.radiobuttonSquare, 'Enable', 'on');
    set(handles.radiobuttonEight, 'Enable', 'on');
    
    set(handles.editSteps, 'String', '0');
    set(handles.editPauseTime, 'String', '0.02');
    set(handles.textRange, 'String', '[0]');
    set(handles.textResultG, 'String', 'G = 0');
    set(handles.textResultsGi, 'String', 'G1 = 0, G2 = 0, G3 = 0');
    set(handles.textSimulationStep, 'String', [handles.simulationStepStr '0/0']);
    
    set(handles.uitableResults, 'data', cell(size(get(handles.uitableResults,'data'))))
    
    cla;
    updateRangeStr(handles);



function editRange_Callback(hObject, eventdata, handles)
% hObject    handle to editRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRange as text
%        str2double(get(hObject,'String')) returns contents of editRange as a double


% --- Executes during object creation, after setting all properties.
function editRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbuttonStart_Callback(hObject, eventdata, handles)
    initializeSimulation(hObject, handles);
    
function status = isSimulationEnded(handles)
    status = false;
    period = str2num(get(handles.period, 'String'));
    if(handles.sim.step >= period)
        status = true;
    end
    
function handleEndOfSimulation(handles)
    set(handles.pushbuttonSimulateSingleStep, 'Enable', 'off');
    set(handles.pushbuttonSimulateTill, 'Enable', 'off');
    set(handles.editSteps, 'Enable', 'off');
    set(handles.editPauseTime, 'Enable', 'off');


function uipanelStructure_SelectionChangeFcn(hObject, eventdata, handles)
    switch get(eventdata.NewValue,'String')
        case 'Square'
            handles.nodes = handles.structures.square.nodes;
            handles.adjMatrix = handles.structures.square.adjMatrix;
            handles.fileName = 'dataSquare.xlsx';
        case 'Eight'
            handles.nodes = handles.structures.eight.nodes;
            handles.adjMatrix = handles.structures.eight.adjMatrix;
            handles.fileName = 'dataEight.xlsx';
    end
    guidata(hObject, handles);


% --- Executes on button press in checkboxComFallouts.
function checkboxComFallouts_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxComFallouts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxComFallouts

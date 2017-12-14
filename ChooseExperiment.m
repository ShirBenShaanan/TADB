function varargout = ChooseExperiment(varargin)
% CHOOSEEXPERIMENT MATLAB code for ChooseExperiment.fig
%      CHOOSEEXPERIMENT, by itself, creates a new CHOOSEEXPERIMENT or raises the existing
%      singleton*.
%
%      H = CHOOSEEXPERIMENT returns the handle to a new CHOOSEEXPERIMENT or the handle to
%      the existing singleton*.
%
%      CHOOSEEXPERIMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSEEXPERIMENT.M with the given input arguments.
%
%      CHOOSEEXPERIMENT('Property','Value',...) creates a new CHOOSEEXPERIMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChooseExperiment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChooseExperiment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChooseExperiment

% Last Modified by GUIDE v2.5 05-Aug-2017 18:01:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseExperiment_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseExperiment_OutputFcn, ...
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

% --- Executes just before ChooseExperiment is made visible.
function ChooseExperiment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChooseExperiment (see VARARGIN)

% Choose default command line output for ChooseExperiment
handles.output = hObject;

handles.experiment = -1;

fileNames = dir('experiments\*.mat');
fileNames = cellfun(@(x) x(1:end-4),{fileNames.name},'Un',0);
set(handles.experimentList, 'String', fileNames);

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes ChooseExperiment wait for user response (see UIRESUME)
% uiwait(handles.chooseExperimentFig);

% --- Outputs from this function are returned to the command line.
function varargout = ChooseExperiment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in chooseBtn.
function chooseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
files = get(handles.experimentList, 'String');
if isempty(files)
    warndlg('Please create a new experiment.');
    return;
end
selected = fullfile('experiments', files{get(handles.experimentList, 'value')});
selected = strcat(selected, '.mat');
load(selected);
handles.experiment = experiment;
guidata(hObject,handles);
close;

% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
experiment = createExperiment(handles);
correct = checkExperiment(experiment);
if correct
    name = get(handles.enterNameText, 'string');
    if isempty(name)
        warndlg('Please enter experiment name.');
    else
        handles = handleExperimentAddition(handles, name, experiment);
        guidata(hObject,handles);
        close;
    end
end

function experiment = createExperiment(handles)
experiment.fly.averageSpeed = handles.flyAveSpeed.Value;
experiment.fly.speed = handles.flySpeed.Value;
experiment.fly.location = handles.flyLocation.Value;
experiment.fly.walkSit = handles.flyWalkSit.Value;
experiment.fly.interactions = handles.flyInteractions.Value;
experiment.fly.distance = handles.flyDistance.Value;
experiment.arena.averageSpeed = handles.arenaAveSpeed.Value;
experiment.arena.speed = handles.arenaSpeed.Value;
experiment.arena.pi = handles.arenaPi.Value;
experiment.arena.interactions = handles.arenaInteractions.Value;
experiment.arena.distance = handles.arenaDistance.Value;
experiment.arena.walkSit = handles.arenaWalkSit.Value;
experiment.multiple.averageSpeed = handles.multipleAveSpeed.Value;
experiment.multiple.speed = handles.multipleSpeed.Value;
experiment.multiple.pi = handles.multiplePi.Value;
experiment.multiple.interactions = handles.multipleInteractions.Value;
experiment.multiple.distance = handles.multipleDistance.Value;
experiment.multiple.walkSit = handles.multipleWalkSit.Value;
experiment.returnedData.graphs = handles.returnGraphs.Value;
experiment.returnedData.excel = handles.returnExcel.Value;
experiment.returnedData.mat = handles.returnMat.Value;

function correct = checkExperiment(experiment)
returnedData = any(structfun(@(x) x, experiment.returnedData));
multiple = any(structfun(@(x) x, experiment.multiple));
arena = any(structfun(@(x) x, experiment.arena));
fly = any(structfun(@(x) x, experiment.fly));
if ~returnedData
    warndlg('Experiment must contain at least one type of returned data.');
    correct = false;
elseif ~(multiple || arena || fly)
    warndlg('Experiment must contain at least one type of analysis value.');
    correct = false;
else
    correct = true;
end

function handles = handleExperimentAddition(handles, name, experiment)
files = get(handles.experimentList, 'String');
fullFile = strcat('experiments\', name, '.mat');
if ismember(name, files)
    button = questdlg('Experiment already exists. Do you want to replace it?');
    if ~isequal(button, 'Yes')
        return;
    end
    delete(fullFile);
end
save(fullFile, 'experiment');
handles.experiment = experiment;


% --- Executes on button press in useBtn.
function useBtn_Callback(hObject, eventdata, handles)
% hObject    handle to useBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
experiment = createExperiment(handles);
correct = checkExperiment(experiment);
if correct
    handles.experiment = experiment;
    guidata(hObject,handles);
    close;
end

% --- Executes on button press in deleteBtn.
function deleteBtn_Callback(hObject, eventdata, handles)
% hObject    handle to deleteBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
files = get(handles.experimentList, 'String');
if isempty(files)
    return;
end
button = questdlg('Are you sure you want to delete this experiment?');
if ~isequal(button, 'Yes')
    return;
end
currentValue = get(handles.experimentList, 'Value');
selected = strcat('experiments\', files{currentValue}, '.mat');
delete(selected);
fileNames = dir('experiments\*.mat');
fileNames = cellfun(@(x) x(1:end-4),{fileNames.name},'Un',0);
set(handles.experimentList, 'Value', min(currentValue, length(fileNames)));
set(handles.experimentList, 'String', fileNames);
guidata(hObject,handles);

% --- Executes when user attempts to close chooseExperimentFig.
function chooseExperimentFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to chooseExperimentFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

setappdata(0, 'experiment', handles.experiment);
delete(hObject);





function enterNameText_Callback(hObject, eventdata, handles)
% hObject    handle to enterNameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enterNameText as text
%        str2double(get(hObject,'String')) returns contents of enterNameText as a double


% --- Executes during object creation, after setting all properties.
function enterNameText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enterNameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in returnMat.
function returnMat_Callback(hObject, eventdata, handles)
% hObject    handle to returnMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of returnMat


% --- Executes on button press in returnGraphs.
function returnGraphs_Callback(hObject, eventdata, handles)
% hObject    handle to returnGraphs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of returnGraphs


% --- Executes on button press in returnExcel.
function returnExcel_Callback(hObject, eventdata, handles)
% hObject    handle to returnExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of returnExcel


% --- Executes on button press in multipleAveSpeed.
function multipleAveSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to multipleAveSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multipleAveSpeed


% --- Executes on button press in multipleSpeed.
function multipleSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to multipleSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multipleSpeed


% --- Executes on button press in multipleInteractions.
function multipleInteractions_Callback(hObject, eventdata, handles)
% hObject    handle to multipleInteractions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multipleInteractions


% --- Executes on button press in multipleDistance.
function multipleDistance_Callback(hObject, eventdata, handles)
% hObject    handle to multipleDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multipleDistance


% --- Executes on button press in multiplePi.
function multiplePi_Callback(hObject, eventdata, handles)
% hObject    handle to multiplePi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multiplePi


% --- Executes on button press in arenaAveSpeed.
function arenaAveSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to arenaAveSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arenaAveSpeed


% --- Executes on button press in arenaSpeed.
function arenaSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to arenaSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arenaSpeed


% --- Executes on button press in arenaInteractions.
function arenaInteractions_Callback(hObject, eventdata, handles)
% hObject    handle to arenaInteractions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arenaInteractions


% --- Executes on button press in arenaDistance.
function arenaDistance_Callback(hObject, eventdata, handles)
% hObject    handle to arenaDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arenaDistance


% --- Executes on button press in arenaPi.
function arenaPi_Callback(hObject, eventdata, handles)
% hObject    handle to arenaPi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arenaPi


% --- Executes on button press in flyAveSpeed.
function flyAveSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to flyAveSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flyAveSpeed


% --- Executes on button press in flySpeed.
function flySpeed_Callback(hObject, eventdata, handles)
% hObject    handle to flySpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flySpeed


% --- Executes on button press in flyInteractions.
function flyInteractions_Callback(hObject, eventdata, handles)
% hObject    handle to flyInteractions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flyInteractions


% --- Executes on button press in flyDistance.
function flyDistance_Callback(hObject, eventdata, handles)
% hObject    handle to flyDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flyDistance


% --- Executes on button press in flyLocation.
function flyLocation_Callback(hObject, eventdata, handles)
% hObject    handle to flyLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flyLocation


% --- Executes on button press in flyWalkSit.
function flyWalkSit_Callback(hObject, eventdata, handles)
% hObject    handle to flyWalkSit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flyWalkSit


% --- Executes on selection change in experimentList.
function experimentList_Callback(hObject, eventdata, handles)
% hObject    handle to experimentList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns experimentList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from experimentList



% --- Executes during object creation, after setting all properties.
function experimentList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimentList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in multipleWalkSit.
function multipleWalkSit_Callback(hObject, eventdata, handles)
% hObject    handle to multipleWalkSit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multipleWalkSit


% --- Executes on button press in arenaWalkSit.
function arenaWalkSit_Callback(hObject, eventdata, handles)
% hObject    handle to arenaWalkSit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arenaWalkSit

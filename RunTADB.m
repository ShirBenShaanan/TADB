function varargout = RunTADB(varargin)
% RUNTADB MATLAB code for RunTADB.fig
%      RUNTADB, by itself, creates a new RUNTADB or raises the existing
%      singleton*.
%
%      H = RUNTADB returns the handle to a new RUNTADB or the handle to
%      the existing singleton*.
%
%      RUNTADB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNTADB.M with the given input arguments.
%
%      RUNTADB('Property','Value',...) creates a new RUNTADB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RunTADB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RunTADB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RunTADB

% Last Modified by GUIDE v2.5 17-Oct-2017 11:55:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RunTADB_OpeningFcn, ...
                   'gui_OutputFcn',  @RunTADB_OutputFcn, ...
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


% --- Executes just before RunTADB is made visible.
function RunTADB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RunTADB (see VARARGIN)

% Choose default command line output for RunTADB
handles.output = hObject;

handles.arenasNumber = 0;
handles.changesGraphs = {};
handles.movieName = -1;
handles.experiment = -1;
handles.curFilesNames = {};
handles.allFilesNames = {};
handles.allMovieNames = {};
handles.numberOfFrames = [];
handles.numberOfFlies = [];

set(handles.leftSlider,'Min', 0);
set(handles.leftSlider,'Max', 100);
set(handles.rightSlider,'Min', 0);
set(handles.rightSlider,'Max', 100);
set(handles.rightSlider,'Value',100);
set(handles.rightLim, 'Visible', 'off');
set(handles.leftLim, 'Visible', 'off');
set(handles.rightSlider, 'Visible', 'off');
set(handles.leftSlider, 'Visible', 'off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RunTADB wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RunTADB_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addMovieBtn.
function addMovieBtn_Callback(hObject, eventdata, handles)
% hObject    handle to addMovieBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(TrackingInfo);
if getappdata(0, 'arenasNumber') == length(getappdata(0, 'fixedFilesNames'))
    handles.arenasNumber = handles.arenasNumber + getappdata(0, 'arenasNumber');
    handles.movieName = getappdata(0, 'movieName');
    handles.allMovieNames = [handles.allFilesNames, getappdata(0, 'movieName')];
    handles.curFilesNames = getappdata(0, 'fixedFilesNames');
    handles.allFilesNames = [handles.allFilesNames, getappdata(0, 'fixedFilesNames')];
    handles.numberOfFrames = [handles.numberOfFrames, getappdata(0, 'numberOfFrames')];
    handles.numberOfFlies = [handles.numberOfFlies, getappdata(0, 'numberOfFlies')];
end
guidata(hObject, handles);



% --- Executes on button press in experimentBtn.
function experimentBtn_Callback(hObject, eventdata, handles)
% hObject    handle to experimentBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(ChooseExperiment);
handles.experiment = getappdata(0, 'experiment');
guidata(hObject, handles);


% --- Executes on button press in changesGraphsBtn.
function changesGraphsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to changesGraphsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i = 1:handles.arenasNumber
    load(handles.allFilesNames{i}, 'changesGraph');
    ax2 = scrollsubplot(4, 1, i); copyobj(changesGraph, ax2);
    axis([0 min(handles.numberOfFrames) 0 handles.numberOfFlies(i)]);
    xlabel('Frame Number');
    ylabel('Flies Changed');
    legend('Flies Added', 'Flies Deleted');
end
set(handles.rightSlider, 'Visible', 'on');
set(handles.leftSlider, 'Visible', 'on');


% --- Executes on button press in watchTrackingBtn.
function watchTrackingBtn_Callback(hObject, eventdata, handles)
% hObject    handle to watchTrackingBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.curFilesNames) && ~isequal(handles.movieName, -1)
    showTracking(handles.curFilesNames, handles.movieName);
else
    [fileName, pathName] = uigetfile('*.avi','Select movie to show');
    if ~isequal(fileName, 0)
        movieName = fullfile(pathName, fileName);
        [fileName, pathName] = uigetfile('*.mat', 'Select fixed tracking files to show', 'MultiSelect', 'on');
        if ~isequal(fileName, 0)
            allFilesNames = {};
            fileName = cellstr(fileName);
            for i = 1:length(fileName)
                allFilesNames = [allFilesNames, fullfile(pathName, fileName{i})];
            end
            showTracking(allFilesNames, movieName);
        end
    end
end



% --- Executes on button press in parametersBtn.
function parametersBtn_Callback(hObject, eventdata, handles)
% hObject    handle to parametersBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fliesBtn.
function fliesBtn_Callback(hObject, eventdata, handles)
% hObject    handle to fliesBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in analyzeBtn.
function analyzeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to analyzeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.experiment, -1)
    warndlg('Please select the output''s type');
else
    [file, path] = uiputfile('', 'Save output files');
    if ~isequal(file, 0)
        outputName = fullfile(path, file(1:end - 4));
        changeTrackingFilesLengths(handles);
        callOutputFunctions(handles.allFilesNames, handles.experiment, max(handles.numberOfFlies), outputName, handles.numberOfFlies, file(1:end - 4));
    end
end

function changeTrackingFilesLengths(handles)
framesPerStep = min(handles.numberOfFrames) / 106;
leftPos = get(handles.leftLim, 'Position');
rightPos = get(handles.rightLim, 'Position');
firstFrame = ((leftPos(3) - 1) * framesPerStep) + 1;
firstFrame = round(firstFrame);
if rightPos(3) == 1
    lastFrame = min(handles.numberOfFrames);
else
    lastFrame = min(handles.numberOfFrames) - ((rightPos(3) - 3) * framesPerStep);
end
lastFrame = round(lastFrame);
for i = 1:handles.arenasNumber
    load(handles.allFilesNames{i}, 'angle', 'identity', 'maj_ax', 'min_ax', 'x_pos', 'y_pos', 'ntargets');
    ntargets = ntargets(firstFrame:lastFrame);
    from = (firstFrame - 1) * ntargets(1) + 1;
    x_pos = x_pos(from:min(lastFrame * ntargets(1), length(x_pos)));
    y_pos = y_pos(from:min(lastFrame * ntargets(1), length(y_pos)));
    angle = angle(from:min(lastFrame * ntargets(1), length(angle)));
    maj_ax = maj_ax(from:min(lastFrame * ntargets(1), length(maj_ax)));
    min_ax = min_ax(from:min(lastFrame * ntargets(1), length(min_ax)));
    identity = identity(from:min(lastFrame * ntargets(1), length(identity)));
    save(handles.allFilesNames{i}, 'angle', 'identity', 'maj_ax', 'min_ax', 'x_pos', 'y_pos', 'ntargets', '-append')
end



function callOutputFunctions(allFilesNames, experiment, maxFliesNumber, outputName, numberOfFlies, expName)
if experiment.fly.location
    GenerateLocationOutput(allFilesNames, experiment, maxFliesNumber, outputName);
end
if experiment.fly.speed || experiment.arena.speed || experiment.multiple.speed || experiment.fly.averageSpeed || experiment.arena.averageSpeed || experiment.multiple.averageSpeed
    %GenerateSpeedOutput(allFilesNames, experiment);
end
if experiment.fly.walkSit || experiment.arena.walkSit || experiment.multiple.walkSit
    GenerateWalkSitOutput(allFilesNames, experiment, maxFliesNumber, outputName);
end
if experiment.arena.pi || experiment.multiple.pi
    GeneratePIOutput(allFilesNames, experiment, outputName, numberOfFlies, expName);
end
if experiment.fly.distance || experiment.arena.distance || experiment.multiple.distance
    %GenerateDistanceOutput(allFilesNames, experiment);
end
if experiment.fly.interactions || experiment.arena.interactions || experiment.multiple.interactions
    GenerateInteractionsOutput(allFilesNames, experiment);
end


% --- Executes on button press in restartBtn.
function restartBtn_Callback(hObject, eventdata, handles)
% hObject    handle to restartBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcbf)
RunTADB




% --- Executes on slider movement.
function leftSlider_Callback(hObject, eventdata, handles)
% hObject    handle to leftSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
leftPos = get(handles.leftLim, 'Position');
rightPos = get(handles.rightLim, 'Position');
if 1 + get(hObject,'Value') + rightPos(3) <= 80
    set(handles.leftLim, 'Position', [43.5, leftPos(2), 1 + get(hObject,'Value'), leftPos(4)]);
end
leftPos = get(handles.leftLim, 'Position');
if leftPos(3) == 1
    set(handles.leftLim, 'Visible', 'off');
else
    set(handles.leftLim, 'Visible', 'on');
end



% --- Executes during object creation, after setting all properties.
function leftSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function rightSlider_Callback(hObject, eventdata, handles)
% hObject    handle to rightSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
rightPos = get(handles.rightLim, 'Position');
leftPos = get(handles.leftLim, 'Position');
if 103 - get(hObject,'Value') + leftPos(3) <= 80
    set(handles.rightLim, 'Position', [51 + get(hObject,'Value'), rightPos(2), 103 - get(hObject,'Value'), rightPos(4)]);
end
rightPos = get(handles.rightLim, 'Position');
if rightPos(3) == 3
    set(handles.rightLim, 'Visible', 'off');
else
    set(handles.rightLim, 'Visible', 'on');
end



% --- Executes during object creation, after setting all properties.
function rightSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rightSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in arenasBtn.
function arenasBtn_Callback(hObject, eventdata, handles)
% hObject    handle to arenasBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in trainBtn.
function trainBtn_Callback(hObject, eventdata, handles)
% hObject    handle to trainBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in addFilesBtn.
function addFilesBtn_Callback(hObject, eventdata, handles)
% hObject    handle to addFilesBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, pathName] = uigetfile('*.mat', 'Select fixed tracking files to add', 'MultiSelect', 'on');
if ~isequal(fileName, 0)
    fileName = cellstr(fileName);
    for i = 1:length(fileName)
        curFileName = fullfile(pathName, fileName{i});
        load(curFileName, 'ntargets');
        handles.allFilesNames = [handles.allFilesNames, curFileName];
        handles.arenasNumber = handles.arenasNumber + 1;
        handles.numberOfFrames = [handles.numberOfFrames, length(ntargets)];
        handles.numberOfFlies = [handles.numberOfFlies, ntargets(1)];
    end
end
guidata(hObject, handles);

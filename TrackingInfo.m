function varargout = TrackingInfo(varargin)
% TRACKINGINFO MATLAB code for TrackingInfo.fig
%      TRACKINGINFO, by itself, creates a new TRACKINGINFO or raises the existing
%      singleton*.
%
%      H = TRACKINGINFO returns the handle to a new TRACKINGINFO or the handle to
%      the existing singleton*.
%
%      TRACKINGINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKINGINFO.M with the given input arguments.
%
%      TRACKINGINFO('Property','Value',...) creates a new TRACKINGINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrackingInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TrackingInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrackingInfo

% Last Modified by GUIDE v2.5 21-Jun-2017 20:54:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrackingInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @TrackingInfo_OutputFcn, ...
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

% --- Executes just before TrackingInfo is made visible.
function TrackingInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrackingInfo (see VARARGIN)

% Choose default command line output for TrackingInfo
handles.output = hObject;

handles.arenasNumber = -1;
handles.fliesNumber = -1;
handles.fileName = -1;
handles.lineDrawnLength = -1;
handles.lineLength = -1;
handles.fliesData = -1;
handles.arenasData = -1;
handles.mmPerPixel = -1;
handles.fixedFilesNames = {};
handles.numberOfFlies = [];
handles.numberOfFrames = [];

axes(handles.frameAxes);
imshow('images\Open image.jpg', 'Border', 'tight');
axis image;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes TrackingInfo wait for user response (see UIRESUME)
% uiwait(handles.trackingInfoFig);

% --- Outputs from this function are returned to the command line.
function varargout = TrackingInfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in selectMovieBtn.
function selectMovieBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selectMovieBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,pathName] = uigetfile('*.avi','Select movie for tracking');
if ~isequal(fileName, 0)
    axes(handles.frameAxes);
    handles.fileName = fullfile(pathName, fileName);
    obj = VideoReader(handles.fileName);
    video = readFrame(obj);
    [frameLength, frameWidth, ~] = size(video);
    handles.frameLength = frameLength;
    handles.frameWidth = frameWidth;
    imshow(video, 'Border', 'tight');
end
guidata(hObject,handles);

% --- Executes on enter text in arenasNumberText.
function arenasNumberText_Callback(hObject, eventdata, handles)
% hObject    handle to arenasNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of arenasNumberText as text
%        str2double(get(hObject,'String')) returns contents of arenasNumberText as a double
text = get(handles.arenasNumberText, 'string');
[arenasNumber, n] = sscanf(text, '%d');
if (n ~= 1) || contains(text, '.') || contains(text, ',') || contains(text, ';') || (arenasNumber < 1)
    warndlg('Number of arenas should be a whole positive number');
    handles.arenasNumber = -1;
else
    handles.arenasNumber = arenasNumber;
end
guidata(hObject,handles);

% --- Executes on enter text in fliesNumberText.
function fliesNumberText_Callback(hObject, eventdata, handles)
% hObject    handle to fliesNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fliesNumberText as text
%        str2double(get(hObject,'String')) returns contents of fliesNumberText as a double
text = get(handles.fliesNumberText, 'string');
[fliesNumber, n] = sscanf(text, '%d');
if (n ~= 1) || contains(text, '.') || contains(text, ',') || contains(text, ';') || (fliesNumber < 1)
    warndlg('Number of flies should be a whole positive number');
    handles.fliesNumber = -1;
else
    handles.fliesNumber = fliesNumber;
end
guidata(hObject,handles);

% --- Executes on button press in movieOkBtn.
function movieOkBtn_Callback(hObject, eventdata, handles)
% hObject    handle to movieOkBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.fileName, -1) && isequal(handles.arenasNumber, -1) && isequal(handles.fliesNumber, -1)
    warndlg('Please select file, number of arenas and number of flies');
elseif isequal(handles.fileName, -1)
    warndlg('Please select file');
elseif isequal(handles.arenasNumber, -1)
    warndlg('Please select number of arenas');
elseif isequal(handles.fliesNumber, -1)
    warndlg('Please select number of flies');
else
    set(handles.framePanel, 'Visible', 'on')
    set(handles.framePanel, 'Position', handles.moviePanel.Position)
    set(handles.markLineText, 'Visible', 'on')
    while (handles.lineDrawnLength <= 0)
        line = imline;
        setColor(line, [0.298, 0.702, 0.698]);
        lineDrawn = wait(line);
        handles.lineDrawnLength = sqrt(((lineDrawn(1, 1) - lineDrawn(2, 1))^2) + ((lineDrawn(1, 2) - lineDrawn(2, 2))^2));
        delete(line);
    end
    set(handles.markLineText, 'Visible', 'off')
    set(handles.enterLengthText, 'Visible', 'on')
    set(handles.lineLengthText, 'Visible', 'on')
    set(handles.lineDoneBtn, 'Visible', 'on')
end
guidata(hObject,handles);

% --- Executes on enter text in lineLengthText.
function lineLengthText_Callback(hObject, eventdata, handles)
% hObject    handle to lineLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of lineLengthText as text
%        str2double(get(hObject,'String')) returns contents of lineLengthText as a double
text = get(handles.lineLengthText, 'string');
[lineLength, n] = sscanf(text, '%f');
if (n ~= 1) || contains(text, ',') || contains(text, ';') || (lineLength < 1)
    warndlg('Length should be a positive number');
    handles.fliesNumber = -1;
else
    handles.lineLength = lineLength;
end
guidata(hObject,handles);


% --- Executes on button press in lineDoneBtn.
function lineDoneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to lineDoneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.lineLength, -1)
    warndlg('Please enter the line''s length in cm');
else
    set(handles.markLineText, 'Visible', 'off')
    set(handles.enterLengthText, 'Visible', 'off')
    set(handles.lineLengthText, 'Visible', 'off')
    set(handles.lineDoneBtn, 'Visible', 'off')
    set(handles.markFliesText, 'Visible', 'on')
    set(handles.fliesLeftText, 'Visible', 'on')
    set(handles.fliesDoneBtn, 'Visible', 'on')
    handles.mmPerPixel = (handles.lineLength * 10) / handles.lineDrawnLength;
    i = handles.fliesNumber;
    textLabel = sprintf('Flies left: %d', i);
    set(handles.fliesLeftText, 'String', textLabel);
    while (i > 0)
        point = impoint;
        setColor(point, [0.298, 0.702, 0.698]);
        i = i - 1;
        flies(handles.fliesNumber - i) = point;
        textLabel = sprintf('Flies left: %d', i);
        set(handles.fliesLeftText, 'String', textLabel);
    end
    handles.fliesData = flies;
end
guidata(hObject,handles);

% --- Executes on button press in fliesDoneBtn.
function fliesDoneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to fliesDoneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.fliesData, -1)
    warndlg('Please mark all flies');
else
    set(handles.markFliesText, 'Visible', 'off')
    set(handles.fliesLeftText, 'Visible', 'off')
    set(handles.fliesDoneBtn, 'Visible', 'off')
    set(handles.markArenasText, 'Visible', 'on')
    set(handles.arenasDoneBtn, 'Visible', 'on')
    i = handles.arenasNumber;
    while (i > 0)
        switch get(get(handles.arenasShapePanel,'SelectedObject'),'Tag')
            case 'circularBtn',  shape = imellipse;
            case 'rectangularBtn',  shape = imrect;
            otherwise, shape = impoly;
        end
        setColor(shape, [0.298, 0.702, 0.698]);
        if i > 1
            wait(shape);
        end
        i = i - 1;
        arenas(handles.arenasNumber - i) = shape;
    end
    handles.arenasData = arenas;
end
guidata(hObject,handles);

% --- Executes on button press in arenasDoneBtn.
function arenasDoneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to arenasDoneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.arenasData, -1)
    warndlg('Please mark all arenas');
else
    [correct, handles] = saveFliesAndArenasLocations(handles);
    if (correct)
        set(handles.instructionsPanel, 'Visible', 'on')
        set(handles.instructionsPanel, 'Position', handles.displayPanel.Position)
        set(handles.trackingPanel, 'Visible', 'on')
        set(handles.trackingPanel, 'Position', handles.moviePanel.Position)
        axes(handles.instructionsAxes);
        imshow('images\CTRAX instructions.jpg', 'Border', 'tight');
        axis image;
        set(handles.framePanel, 'Visible', 'off')
    end
end
guidata(hObject,handles);

function [correct, handles] = saveFliesAndArenasLocations(handles)
flyX = repmat(-1, handles.fliesNumber, 1);
flyY = repmat(-1, handles.fliesNumber, 1);
for i = 1:handles.fliesNumber
    flyPos = getPosition(handles.fliesData(i));
    flyX(i) = flyPos(1);
    flyY(i) = handles.frameLength - flyPos(2);
end
switch get(get(handles.arenasShapePanel,'SelectedObject'),'Tag')
    case 'circularBtn', [correct, handles] = checkCircular(handles, flyX, flyY);
    case 'rectangularBtn', [correct, handles] = checkRectangular(handles, flyX, flyY);
    otherwise, [correct, handles] = checkPolygonal(handles, flyX, flyY);
end

function [correct, handles] = checkCircular(handles, flyX, flyY)
for i = 1:handles.arenasNumber
    arenaPos = getPosition(handles.arenasData(i));
    handles.arenaX{i} = [arenaPos(1), arenaPos(1), arenaPos(1) + arenaPos(3), arenaPos(1) + arenaPos(3)].';
    handles.arenaY{i} = handles.frameLength - [arenaPos(2), arenaPos(2) + arenaPos(4), arenaPos(2) + arenaPos(4), arenaPos(2)].';
    in = inpolygon(flyX, flyY, handles.arenaX{i}, handles.arenaY{i});
    fliesData{i} = dataset(flyX(in), flyY(in), 'VarNames', {'x_pos', 'y_pos'});
    arenasData{i} = [min(handles.arenaX{i}), max(handles.arenaX{i}), max(handles.arenaY{i}), min(handles.arenaY{i})];
    flyX = flyX(~in);
    flyY = flyY(~in);
end
if ~isempty(flyX) || ~isempty(flyY)
    warndlg('Please move all flies'' marks inside an arena''s bounds.');
    correct = false;
else
    correct = true;
    handles.fliesData = fliesData;
    handles.arenasData = arenasData;
end

function [correct, handles] = checkRectangular(handles, flyX, flyY)
for i = 1:handles.arenasNumber
    arenaPos = getPosition(handles.arenasData(i));
    handles.arenaX{i} = [arenaPos(1), arenaPos(1), arenaPos(1) + arenaPos(3), arenaPos(1) + arenaPos(3)].';
    handles.arenaY{i} = handles.frameLength - [arenaPos(2), arenaPos(2) + arenaPos(4), arenaPos(2) + arenaPos(4), arenaPos(2)].';
    in = inpolygon(flyX, flyY, handles.arenaX{i}, handles.arenaY{i});
    fliesData{i} = dataset(flyX(in), flyY(in), 'VarNames', {'x_pos', 'y_pos'});
    arenasData{i} = [min(handles.arenaX{i}), max(handles.arenaX{i}), max(handles.arenaY{i}), min(handles.arenaY{i})];
    flyX = flyX(~in);
    flyY = flyY(~in);
end
if ~isempty(flyX) || ~isempty(flyY)
    warndlg('Please move all flies'' marks inside an arena''s bounds.');
    correct = false;
else
    correct = true;
    handles.fliesData = fliesData;
    handles.arenasData = arenasData;
end

function [correct, handles] = checkPolygonal(handles, flyX, flyY)
for i = 1:handles.arenasNumber
    arenaPos = getPosition(handles.arenasData(i));
    handles.arenaX{i} = arenaPos(:, 1);
    handles.arenaY{i} = handles.frameLength - arenaPos(:, 2);
    in = inpolygon(flyX, flyY, handles.arenaX{i}, handles.arenaY{i});
    fliesData{i} = dataset(flyX(in), flyY(in), 'VarNames', {'x_pos', 'y_pos'});
    arenasData{i} = [min(handles.arenaX{i}), max(handles.arenaX{i}), max(handles.arenaY{i}), min(handles.arenaY{i})];
    flyX = flyX(~in);
    flyY = flyY(~in);
end
if ~isempty(flyX) || ~isempty(flyY)
    warndlg('Please move all flies'' marks inside an arena''s bounds.');
    correct = false;
else
    correct = true;
    handles.fliesData = fliesData;
    handles.arenasData = arenasData;
end

% --- Executes on button press in separateBtn.
function separateBtn_Callback(hObject, eventdata, handles)
% hObject    handle to separateBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.arenasNumber == 1
    [handles, correct] = handleOneArena(handles);
else
    [handles, correct] = handleSeparateFiles(handles);
end
if correct
    guidata(hObject,handles);
    bar = handles.waitBar;
    close(bar);
    fig = handles.trackingInfoFig;
    close(fig);
end

function [handles, correct] = handleOneArena(handles)
correct = false;
[fileName,pathName] = uigetfile('*.mat','Select tracking file');
if ~isequal(fileName, 0)
    handles.waitBar = waitbar(0,'Fixing tracking data may take several minutes. Please wait');
    trackingFile = fullfile(pathName, fileName);
    userFliesData = handles.fliesData{1};
    [fixedFileName, numberOfFrames] = fixErrorsAlgorithm(userFliesData, trackingFile, handles.mmPerPixel, length(userFliesData), handles.arenaX{1}, handles.arenaY{1}, 'on');
    waitbar(1);
    handles.fixedFilesNames{1} = fixedFileName;
    handles.numberOfFlies(1) = length(userFliesData);
    handles.numberOfFrames(1) = numberOfFrames;
    correct = true;
end


function [handles, correct] = handleSeparateFiles(handles)
correct = false;
[fileName, pathName] = uigetfile('*.mat', 'Select tracking file', 'MultiSelect', 'on');
if isempty(fileName)
    return;
elseif length(fileName) ~= handles.arenasNumber
    warndlg('Wrong number of files. Please upload one file for each arena.');
else
    for flyNumber = 1:handles.fliesNumber
        allFiles = strings([handles.arenasNumber, 1]);
        for i = 1:handles.arenasNumber
            currentFile = fullfile(pathName, fileName{i});
            load(currentFile);
            for j = 1:handles.arenasNumber
                if inpolygon(x_pos(flyNumber), y_pos(flyNumber), handles.arenaX{j}, handles.arenaY{j})
                    allFiles(j) = currentFile;
                    break;
                end
            end
        end
        if all(allFiles ~= '')
            break;
        end
    end
    if any(allFiles == '')
        warndlg('Problem with files. Please upload one file for each arena.');
    else
        handles.waitBar = waitbar(0,'Fixing tracking data may take several minutes. Please wait');
        for i = 1:handles.arenasNumber
            trackingFile = char(allFiles(i));
            userFliesData = handles.fliesData{i};
            [fixedFileName, numberOfFrames] = fixErrorsAlgorithm(userFliesData, trackingFile, handles.mmPerPixel, length(userFliesData), handles.arenaX{i}, handles.arenaY{i}, 'off');
            waitbar(i / handles.arenasNumber);
            handles.fixedFilesNames{i} = fixedFileName;
            handles.numberOfFlies(i) = length(userFliesData);
            handles.numberOfFrames(i) = numberOfFrames;
        end
        correct = true;
    end
end



% --- Executes on button press in unifiedBtn.
function unifiedBtn_Callback(hObject, eventdata, handles)
% hObject    handle to unifiedBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.arenasNumber == 1
    [handles, correct] = handleOneArena(handles);
else
    [handles, correct] = handleUnifiedFile(handles);
end
if correct
    bar = handles.waitBar;
    close(bar);
    guidata(hObject,handles);
    fig = handles.trackingInfoFig;
    close(fig);
end

function [handles, correct] = handleUnifiedFile(handles)
correct = false;
[fileName,pathName] = uigetfile('*.mat','Select tracking file');
if ~isequal(fileName, 0)
    trackingFile = fullfile(pathName, fileName);
    handles.waitBar = waitbar(0,'Fixing tracking data may take several minutes. Please wait');
    for i = 1:handles.arenasNumber
        newFileName = strcat(trackingFile(1:end - 4), num2str(i), '.mat');
        SeparateTrackingFiles(trackingFile, handles.arenaX{i}, handles.arenaY{i}, newFileName)
        waitbar(((i * 2) - 1) / (handles.arenasNumber * 2));
        userFliesData = handles.fliesData{i};
        [fixedFileName, numberOfFrames] = fixErrorsAlgorithm(userFliesData, newFileName, handles.mmPerPixel, length(userFliesData), handles.arenaX{i}, handles.arenaY{i}, 'off');
        waitbar((i * 2) / (handles.arenasNumber * 2));
        handles.fixedFilesNames{i} = fixedFileName;
        handles.numberOfFlies(i) = length(userFliesData);
        handles.numberOfFrames(i) = numberOfFrames;
    end
    correct = true;
end

% --- Executes on button press in trackBtn.
function trackBtn_Callback(hObject, eventdata, handles)
% hObject    handle to trackBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname = 'for tracking_2017-03-27-123928-0000.avi.ann';
system('C:\"Program Files (x86)"\Ctrax-0.5\Ctrax.exe --Interactive=False --Input="C:\Users\shir\Documents\MATLAB\temp\for tracking_2017-03-27-123928-0000.avi" --SettingsFile="C:\Users\shir\Documents\MATLAB\temp\for tracking_2017-03-27-123928-0000.avi.ann" --Matfile=tracking.mat');


% --- Executes when user attempts to close trackingInfoFig.
function trackingInfoFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to trackingInfoFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

setappdata(0, 'movieName', handles.fileName);
setappdata(0, 'arenasNumber', handles.arenasNumber);
setappdata(0, 'fixedFilesNames', handles.fixedFilesNames);
setappdata(0, 'numberOfFlies', handles.numberOfFlies);
setappdata(0, 'numberOfFrames', handles.numberOfFrames);
delete(hObject);


% --- Executes during object creation, after setting all properties.
function framePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called










% --- Executes during object creation, after setting all properties.
function arenasNumberText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arenasNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function fliesNumberText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fliesNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in arenasShapePanel.
function arenasShape_Callback(hObject, eventdata, handles)
% hObject    handle to arenasShapePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns arenasShapePanel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from arenasShapePanel


% --- Executes during object creation, after setting all properties.
function arenasShapePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arenasShapePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function lineLengthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




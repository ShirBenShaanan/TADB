function varargout = CreateUnifiedAveragePiPlots(varargin)
% CREATEUNIFIEDAVERAGEPIPLOTS MATLAB code for CreateUnifiedAveragePiPlots.fig
%      CREATEUNIFIEDAVERAGEPIPLOTS, by itself, creates a new CREATEUNIFIEDAVERAGEPIPLOTS or raises the existing
%      singleton*.
%
%      H = CREATEUNIFIEDAVERAGEPIPLOTS returns the handle to a new CREATEUNIFIEDAVERAGEPIPLOTS or the handle to
%      the existing singleton*.
%
%      CREATEUNIFIEDAVERAGEPIPLOTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATEUNIFIEDAVERAGEPIPLOTS.M with the given input arguments.
%
%      CREATEUNIFIEDAVERAGEPIPLOTS('Property','Value',...) creates a new CREATEUNIFIEDAVERAGEPIPLOTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CreateUnifiedAveragePiPlots_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CreateUnifiedAveragePiPlots_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CreateUnifiedAveragePiPlots

% Last Modified by GUIDE v2.5 08-Nov-2017 13:30:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CreateUnifiedAveragePiPlots_OpeningFcn, ...
                   'gui_OutputFcn',  @CreateUnifiedAveragePiPlots_OutputFcn, ...
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


% --- Executes just before CreateUnifiedAveragePiPlots is made visible.
function CreateUnifiedAveragePiPlots_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CreateUnifiedAveragePiPlots (see VARARGIN)

% Choose default command line output for CreateUnifiedAveragePiPlots
handles.output = hObject;

handles.allFiles = {};
handles.genotypesNames = {};
handles.curFile = -1;
handles.colors = {};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CreateUnifiedAveragePiPlots wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CreateUnifiedAveragePiPlots_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in outputBtn.
function outputBtn_Callback(hObject, eventdata, handles)
% hObject    handle to outputBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, pathName] = uigetfile('*.mat', 'Select output files');
if ~isequal(fileName, 0)
    handles.curFile = fullfile(pathName, fileName);
end
guidata(hObject, handles);


% --- Executes on button press in addBtn.
function addBtn_Callback(hObject, eventdata, handles)
% hObject    handle to addBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(handles.curFile, -1)
    warndlg('Please select output file');
elseif isequal(get(handles.genotypeTxt, 'string'), '') || isempty(get(handles.genotypeTxt, 'string'))
    warndlg('Please enter genotype name');
else
    handles.allFiles = [handles.allFiles, handles.curFile];
    handles.genotypesNames = [handles.genotypesNames, get(handles.genotypeTxt, 'string')];
    color = getRgbValues(handles);
    handles.colors = [handles.colors, color];
    set(handles.genotypeTxt, 'string', '');
    set(handles.rTxt, 'string', '');
    set(handles.gTxt, 'string', '');
    set(handles.bTxt, 'string', '');
    handles.curFile = -1;
end
guidata(hObject, handles);

function [color] = getRgbValues(handles)
text = get(handles.rTxt, 'string');
[rValue, n] = sscanf(text, '%f');
if (n < 1)
    color = -1;
    return;
elseif (n > 1) || contains(text, ',') || contains(text, ';') || (rValue < 0) || (rValue > 255)
    warndlg('RGB values should be numbers between 0 and 1. Default color used.');
    color = -1;
    return;
end
text = get(handles.gTxt, 'string');
[gValue, n] = sscanf(text, '%f');
if (n < 1)
    color = -1;
    return;
elseif (n > 1) || contains(text, ',') || contains(text, ';') || (gValue < 0) || (gValue > 255)
    warndlg('RGB values should be numbers between 0 and 1. Default color used.');
    color = -1;
    return;
end
text = get(handles.bTxt, 'string');
[bValue, n] = sscanf(text, '%f');
if (n < 1)
    color = -1;
    return;
elseif (n > 1) || contains(text, ',') || contains(text, ';') || (bValue < 0) || (bValue > 1)
    warndlg('RGB values should be numbers between 0 and 1. Default color used.');
    color = -1;
    return;
end
color = [rValue, gValue, bValue];


% --- Executes on button press in doneBtn.
function doneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to doneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uiputfile('', 'Save output files');
if ~isequal(file, 0)
    outputName = fullfile(path, file(1:end - 4));
else
    return;
end
figure('Name','Unified Average PI','NumberTitle','off')
hold on
xMin = zeros(1, length(handles.allFiles));
for i = 1:length(handles.allFiles)
    all = cell2mat(struct2cell(load(handles.allFiles{i}, '-regexp', '^(?!overall_average_pi)\w')));
    average = cell2mat(struct2cell(load(handles.allFiles{i}, 'overall_average_pi')));
    xMin(i) = length(average);
    err = std(all)/sqrt(size(all, 1) - 1);
    if isequal(handles.colors{i}, -1)
        h = shadedErrorBar([], average, err, '-', 1);
    else
        h = shadedErrorBar([], average, err, {'Color', handles.colors{i}}, 1);
    end
    h.mainLine.DisplayName = handles.genotypesNames{i};
end
xlabel('frame');
ylabel('Average PI');
line(get(gca,'XLim'), [0 0],'Color', 'k');axis tight;
xlim ([0 min(xMin)]);
ylim ([-1 1]);
[~, hObj] = legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'));
hL = findobj(hObj, 'type', 'line');
set(hL, 'linewidth' ,2);
title('Average PI per frame');
set(gcf,'Position',[70 300 1100 300]);
outputName = strcat(outputName, '.jpg');
saveas(gcf ,outputName);


% --- Executes on button press in restartBtn.
function restartBtn_Callback(hObject, eventdata, handles)
% hObject    handle to restartBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcbf)
CreateUnifiedAveragePiPlots


function genotypeTxt_Callback(hObject, eventdata, handles)
% hObject    handle to genotypeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of genotypeTxt as text
%        str2double(get(hObject,'String')) returns contents of genotypeTxt as a double


% --- Executes during object creation, after setting all properties.
function genotypeTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genotypeTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rTxt_Callback(hObject, eventdata, handles)
% hObject    handle to rTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rTxt as text
%        str2double(get(hObject,'String')) returns contents of rTxt as a double


% --- Executes during object creation, after setting all properties.
function rTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gTxt_Callback(hObject, eventdata, handles)
% hObject    handle to gTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gTxt as text
%        str2double(get(hObject,'String')) returns contents of gTxt as a double


% --- Executes during object creation, after setting all properties.
function gTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bTxt_Callback(hObject, eventdata, handles)
% hObject    handle to bTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bTxt as text
%        str2double(get(hObject,'String')) returns contents of bTxt as a double


% --- Executes during object creation, after setting all properties.
function bTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

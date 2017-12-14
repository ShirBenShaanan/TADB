%% for tracking_2017-03-27-123928-0000

load('C:\Users\shir\Documents\MATLAB\TADB\runAllTemp\for tracking_2017-03-27-123928-0000-workspace.mat');

for i = 1:handles.arenasNumber
    trackingFile = char(allFiles(i));
    userFliesData = handles.fliesData{i};
    fixErrorsAlgorithm(userFliesData, trackingFile, handles.mmPerPixel, length(userFliesData), handles.arenaX{i}, handles.arenaY{i}, 'off');
end

showTracking(trackingFiles, movieName);

clear;

%% experiment males light  1_2017-06-14-103236-0000_2017-06-14-105831-0000

load('C:\Users\shir\Documents\MATLAB\TADB\runAllTemp\experiment males light  1_2017-06-14-103236-0000_2017-06-14-105831-0000-workspace.mat');

for i = 1:handles.arenasNumber
    trackingFile = char(allFiles(i));
    userFliesData = handles.fliesData{i};
    fixErrorsAlgorithm(userFliesData, trackingFile, handles.mmPerPixel, length(userFliesData), handles.arenaX{i}, handles.arenaY{i}, 'off');
end

showTracking(trackingFiles, movieName);

clear;

%% experiment males light 2_2017-06-14-115231-0000

load('C:\Users\shir\Documents\MATLAB\TADB\runAllTemp\experiment males light 2_2017-06-14-115231-0000-workspace.mat');

for i = 1:handles.arenasNumber
    trackingFile = char(allFiles(i));
    userFliesData = handles.fliesData{i};
    fixErrorsAlgorithm(userFliesData, trackingFile, handles.mmPerPixel, length(userFliesData), handles.arenaX{i}, handles.arenaY{i}, 'off');
end

showTracking(trackingFiles, movieName);

clear;

%% experiment males dark end 1_2017-06-14-103236-0000_2017-06-14-110723-0000

load('C:\Users\shir\Documents\MATLAB\TADB\runAllTemp\experiment males dark end 1_2017-06-14-103236-0000_2017-06-14-110723-0000-workspace.mat');

for i = 1:handles.arenasNumber
    trackingFile = char(allFiles(i));
    userFliesData = handles.fliesData{i};
    fixErrorsAlgorithm(userFliesData, trackingFile, handles.mmPerPixel, length(userFliesData), handles.arenaX{i}, handles.arenaY{i}, 'off');
end

showTracking(trackingFiles, movieName);

clear;

%% experiment males dark end 2_2017-06-14-114347-0000_2017-06-14-120205-0000

load('C:\Users\shir\Documents\MATLAB\TADB\runAllTemp\experiment males dark end 2_2017-06-14-114347-0000_2017-06-14-120205-0000-workspace.mat');

for i = 1:handles.arenasNumber
    trackingFile = char(allFiles(i));
    userFliesData = handles.fliesData{i};
    fixErrorsAlgorithm(userFliesData, trackingFile, handles.mmPerPixel, length(userFliesData), handles.arenaX{i}, handles.arenaY{i}, 'off');
end

showTracking(trackingFiles, movieName);

clear;

%% jjjjj


movieName = 'C:\Users\shir\Documents\MATLAB\Real\new females\Experiment light 2_2017-06-19-114110-0000.avi';

fileName1 = 'C:\Users\shir\Documents\MATLAB\Real\new females\Experiment light 2_2017-06-19-114110-0000-fixed';
fileName2 = 'C:\Users\shir\Documents\MATLAB\Real\new females\Experiment light 2_2017-06-19-114110-0001-fixed';
fileName3 = 'C:\Users\shir\Documents\MATLAB\Real\new females\Experiment light 2_2017-06-19-114110-0002-fixed';
fileName4 = 'C:\Users\shir\Documents\MATLAB\Real\new females\Experiment light 2_2017-06-19-114110-0003-fixed';
fileName5 = 'C:\Users\shir\Documents\MATLAB\Real\new females\Experiment light 2_2017-06-19-114110-0004-fixed';
fileName6 = 'C:\Users\shir\Documents\MATLAB\Real\new females\Experiment light 2_2017-06-19-114110-0005-fixed';


trackingFiles = {fileName1, fileName2, fileName3, fileName4, fileName5, fileName6};


showTracking(trackingFiles, movieName);


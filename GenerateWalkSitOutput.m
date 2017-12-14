function GenerateWalkSitOutput(allFilesNames, experiment, maxFliesNumber, outputName)
answer = inputdlg('Please enter minimum walking speed (in mm/sec)', 'Enter walking speed', 1, {'1.5'});
if isempty(answer)
    warndlg('Incorrect input. Default value is used.');
    threshold = 1.5; 
else
    [threshold, status] = str2num(answer{1});
    if ~status
        warndlg('Incorrect input. Default value is used.');
        threshold = 1.5;
    end
end
excelName = strcat(outputName, '-walking and sitting.xls');
matName = strcat(outputName, '-walking and sitting.mat');
fliesGraphName = strcat(outputName, '-walking and sitting-flies.jpg');
arenasGraphName = strcat(outputName, '-walking and sitting-arenas.jpg');
walkSitGraphs = figure('Name', 'Walking and Sitting Graphs', 'Visible', 'off', 'NumberTitle', 'off', 'Position', [60, 60, 1200, 570]);
averageWalking = repmat(-1, length(allFilesNames), 1);
averageSitting = repmat(-1, length(allFilesNames), 1);
for i = 1:length(allFilesNames)
    param = struct();
    load(allFilesNames{i}, 'mmPerPixel');
    param.mmPerPixel = mmPerPixel;
    [givenData, param, ~, ~] = createWorkingDatabase(allFilesNames{i}, param);
    walking = repmat(-1, max(givenData.identity) + 1, 1);
    sitting = repmat(-1, max(givenData.identity) + 1, 1);
    for j = 0:max(givenData.identity)
        x = givenData.x_pos(givenData.identity == j);
        y = givenData.y_pos(givenData.identity == j);
        speeds = getSpeed(x, y, param);
        walking(j + 1) = (length(find(speeds >= threshold)) / length(speeds)) * 100;
        sitting(j + 1) = 100 - walking(j + 1);
        graphTitle = strcat('Arena', {' '}, num2str(i), ', Fly', {' '}, num2str(j));
        if experiment.returnedData.graphs && experiment.fly.walkSit
            subplot(length(allFilesNames), maxFliesNumber, sub2ind([maxFliesNumber, length(allFilesNames)], j + 1, i));
            bar([walking(j + 1) sitting(j + 1)]);
            set(gca, 'xticklabel', {'walking', 'sitting'});
            ylabel('%');
            title(graphTitle);
        end
        if experiment.returnedData.excel && experiment.fly.walkSit
            data = num2cell([walking(j + 1) sitting(j + 1)]);
            header = {'Walking Percentage', 'Sitting Percentage'};
            xlswrite(excelName, [header; data], char(graphTitle))
        end
        if experiment.returnedData.mat && experiment.fly.walkSit
            walkName = strcat('arena_', num2str(i), '_fly_', num2str(j), '_walking');
            sitName = strcat('arena_', num2str(i), '_fly_', num2str(j), '_sitting');
            eval([walkName '= walking(j + 1)']);
            eval([sitName '= sitting(j + 1)']);
            if exist(matName, 'file') == 2
                save(matName, walkName, '-append');
            else
                save(matName, walkName);
            end
            save(matName, sitName, '-append');
        end
    end
    averageWalking(i) = mean(walking);
    averageSitting(i) = mean(sitting);
end
if experiment.returnedData.graphs && experiment.fly.walkSit
    set(walkSitGraphs, 'Visible', 'on');
    saveas(walkSitGraphs ,fliesGraphName);
end
addArenasAndMultiple(experiment, arenasGraphName, excelName, matName, averageWalking, averageSitting);
end

% Calculates the fly's speed.
function [speeds] = getSpeed(xVector, yVector, param)
speeds = repmat(-1, length(xVector) - 1, 1);
for i = 1:length(speeds)
    distance = sqrt(((xVector(i) - xVector(i + 1))^2) + ((yVector(i) - yVector(i + 1))^2)) * param.mmPerPixel;
    speeds(i) = distance / param.secPerFrame;
end
speeds(speeds == -1) = [];
end

function addArenasAndMultiple(experiment, arenasGraphName, excelName, matName, averageWalking, averageSitting)
walkSitGraphs = figure('Name', 'Walking and Sitting Graphs', 'Visible', 'off', 'NumberTitle', 'off', 'Position', [60, 60, 1200, 570]);
for i = 1:length(averageWalking)
    if experiment.returnedData.graphs && experiment.arena.walkSit
        subplot(length(allFilesNames), maxFliesNumber, i);
        bar([averageWalking(i) averageSitting(i)]);
        set(gca, 'xticklabel', {'walking', 'sitting'});
        ylabel('%');
        title(graphTitle);
    end
    if experiment.returnedData.excel && experiment.arena.walkSit
        title = strcat('Arena', {' '}, num2str(i));
        data = num2cell([averageWalking(i) averageSitting(i)]);
        header = {'Average Walking Percentage', 'Average Sitting Percentage'};
        xlswrite(excelName, [header; data], char(title))
    end
    if experiment.returnedData.mat && experiment.arena.walkSit
        walkName = strcat('arena_', num2str(i), '_walking_average');
        sitName = strcat('arena_', num2str(i), '_sitting_average');
        eval([walkName '= averageWalking(i)']);
        eval([sitName '= averageSitting(i)']);
        if exist(matName, 'file') == 2
            save(matName, walkName, '-append');
        else
            save(matName, walkName);
        end
        save(matName, sitName, '-append');
    end
end
if experiment.returnedData.graphs && experiment.multiple.walkSit
end
if experiment.returnedData.excel && experiment.multiple.walkSit
    data = num2cell([mean(averageWalking) mean(averageSitting)]);
    header = {'Average Walking Percentage', 'Average Sitting Percentage'};
    xlswrite(excelName, [header; data], 'Arenas Average')
end
if experiment.returnedData.mat && experiment.multiple.walkSit
    walkName = strcat('walking_average');
    sitName = strcat('sitting_average');
    eval([walkName '= mean(averageWalking)']);
    eval([sitName '= mean(averageSitting)']);
    if exist(matName, 'file') == 2
        save(matName, walkName, '-append');
    else
        save(matName, walkName);
    end
    save(matName, sitName, '-append');
end
if experiment.returnedData.graphs && (experiment.arena.walkSit || experiment.multiple.walkSit)
    set(walkSitGraphs, 'Visible', 'on');
    saveas(walkSitGraphs ,arenasGraphName);
end
end

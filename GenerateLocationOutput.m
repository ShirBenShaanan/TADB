function GenerateLocationOutput(allFilesNames, experiment, maxFliesNumber, outputName)
excelName = strcat(outputName, '-location.xls');
matName = strcat(outputName, '-location.mat');
graphName = strcat(outputName, '-location.jpg');
locationGraphs = figure('Name', 'Location Graphs', 'Visible', 'off', 'NumberTitle', 'off', 'Position', [60, 60, 1200, 570]);
for i = 1:length(allFilesNames)
    [givenData, ~, ~, ~] = createWorkingDatabase(allFilesNames{i}, struct());
    for j = 0:max(givenData.identity)
        subplot(length(allFilesNames), maxFliesNumber, sub2ind([maxFliesNumber, length(allFilesNames)], j + 1, i));
        x = givenData.x_pos(givenData.identity == j);
        y = givenData.y_pos(givenData.identity == j);
        plot(x, y);
        xlabel('x');
        ylabel('y');
        graphTitle = strcat('Arena', {' '}, num2str(i), ', Fly', {' '}, num2str(j));
        title(graphTitle);
        if experiment.returnedData.excel
            data = num2cell([x y]);
            header = {'X Position', 'Y Position'};
            xlswrite(excelName, [header; data], char(graphTitle))
        end
        if experiment.returnedData.mat
            xName = strcat('arena_', num2str(i), '_fly_', num2str(j), '_x_pos');
            yName = strcat('arena_', num2str(i), '_fly_', num2str(j), '_y_pos');
            eval([xName '= x']);
            eval([yName '= y']);
            if exist(matName, 'file') == 2
                save(matName, xName, '-append');
            else
                save(matName, xName);
            end
            save(matName, yName, '-append');
        end
    end
end
if experiment.returnedData.graphs
    set(locationGraphs, 'Visible', 'on');
    saveas(locationGraphs ,graphName);
end
end

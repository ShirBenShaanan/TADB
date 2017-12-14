function GenerateInteractionsOutput(allFilesNames, experiment)

for i = 1:length(allFilesNames)
    param = struct();
    load(allFilesNames{i}, 'mmPerPixel');
    param.mmPerPixel = mmPerPixel;
    [givenData, param, ~, ~] = createWorkingDatabase(allFilesNames{i}, param);
    for j = 0:max(givenData.identity)
        flyData = givenData(givenData.identity == j, :);
        flyLocation = [flyData.x_pos, flyData.y_pos];
        otherData = givenData(givenData.identity ~= j, :);
        for k = 1:max(givenData.identity)
            curData = otherData(otherData.identity == otherData.identity(k), :);
            distances = getCorrectDistanceData(flyData, flyLocation, curData, param);
            getCorrectDurationData();
        end
    end
end

end

function [distances] = getCorrectDistanceData(flyData, flyLocation, curData, param)
curLocation = [curData.x_pos, curData.y_pos];
distances = diag(pdist2(flyLocation, curLocation));
distances = [distances, flyData.frame];
index = distances(:, 1) <= (8 / param.mmPerPixel);
distances = distances(index, :);
end

function [] = getCorrectDurationData(frames)
firstFrame = frames(1);
for i = 2:length(frames)
    if frames(i) - frames(i - 1) > 1
        lastFrame = frames(i - 1);
        
        firstFrame = frames(i);
    end
end
end
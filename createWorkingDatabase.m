%% Read the CTRAX's tracking file.

% Gets all the information from the .mat file specified in "fileName".
% The .mat file contains the tracking information from CTRAX.
% Creates a data set with all the needed information.
function [givenData, param, timestamps, startframe] = createWorkingDatabase(fileName, param)
angle = {};
load(fileName);
param.numberOfFrames = length(ntargets);
param.secPerFrame = timestamps(2) - timestamps(1);
[frame, count] = getFrameAndCount(ntargets, 1, length(identity));
givenData = dataset(x_pos, y_pos, angle, maj_ax, min_ax, identity, frame, count);
end

% Creates "frame" and "count" vectors to add to the data set.
% The "frame" vector represent the frame of every line in the data set.
% The "count" vector counts the flies in each frame.
function [frame, count] = getFrameAndCount(ntargets, frameNumber, lengthOfVectors)
frame = ones(lengthOfVectors, 1);
count = ones(lengthOfVectors, 1);
countNumber = 0;
j = 1;
for i = 1:lengthOfVectors
    countNumber = countNumber + 1;
    count(i) = countNumber;
    frame(i) = frameNumber;
    if ntargets(j) == countNumber
        frameNumber = frameNumber + 1;
        countNumber = 0;
        j = j + 1;
    end
end
end
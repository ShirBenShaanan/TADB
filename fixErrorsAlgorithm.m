%% Run the fix error algotithm.

% Runs the fix errors algorithm.
% The algorithm receives CTRAX's tracking output, and removes\connects
% flies identities to generate a consistent tracking information.
% The tracking information is saved in a .mat file with the same format as
% the CTRAX's tracking output.
function [fixedFileName, numberOfFrames] = fixErrorsAlgorithm(userFliesData, fileName, mmPerPixel, numberOfFlies, arenaX, arenaY, showOptions)
param = getParameters(mmPerPixel, numberOfFlies, arenaX, arenaY);
[givenData, param, timestamps, startFrame] = createWorkingDatabase(fileName, param);
info = getWorkingInformation(givenData, userFliesData, param);
info = fixTrackingErrors(info, param);
[info, param] = handleEndAccuracy(info, param, showOptions);
changesGraph = generateChangesGraph(info, param);
fixedFileName = generateMatFile(info, param, timestamps, startFrame, fileName, changesGraph);
numberOfFrames = param.numberOfFrames;
end

%% Parameters values.

% Creates a struct with all the needed parameters.
function [param] = getParameters(mmPerPixel, numberOfFlies, arenaX, arenaY)
param = struct('mmPerPixel', mmPerPixel, 'numberOfFlies', numberOfFlies, 'arenaX', arenaX, 'arenaY', arenaY);
param.sameFlySpeed = 10;
param.flyMinWalkingSpeed = 1.5;
param.notWalkingPenalty = 1.2;
param.oneErrorThreshold = 10;
param.secBetweenCalculations = 1;
param.maxFlySpeed = 100;
param.flyMaxLength = 4;
param.framesPenalty = 10;
param.noOverlappingFrames = -1;
param.maxJumpFrames = 10;
param.currentSpeedLimit = param.sameFlySpeed;
param.currentTimeLimit = 20;
param.currentDistanceLimit = 10;
param.precisionRate = 0.8;
param.disappearSecThreshold = 50;
param.framesPercentToDelete = 0.1;
param.fliesPercentToDelete = 0.25;
param.maxTimeLimit = 300;
param.maxDistanceLimit = 80;
param.endTimeLimit = 2;
param.endDistanceLimit = 5;
end

%% Get the information needed to start fixing.

% Creates a struct with all the needed working information.
% The struct contains vectors with the number of flies removed and added in
% each frame that will be updated in the algorithm, and the tracking data 
% after matching the start identities with the given start identities which 
% were marked by the user.
function [info] = getWorkingInformation(givenData, userFliesData, param)
info = struct();
info.trackingData = givenData;
info.addedFliesPerFrame = zeros(param.numberOfFrames, 1);
info.deletedFliesPerFrame = zeros(param.numberOfFrames, 1);
info = fixStartIdentities(info, param, userFliesData);
[accuracy, ~] = calculateAccuracy(info, param);
info.startAccuracy = accuracy;
end

% Fixes the first frame's identities. Receives the location of all the 
% first frame's flies from the user and matches them to the tracking data.
% If the first frame has extra flies, they will be deleted from the data.
% If there are missing user's flies, they will be added to the first frame.
function [info] = fixStartIdentities(info, param, userFliesData)
maxIdentity = max(info.trackingData.identity);
addToIdentity = (info.trackingData.identity < param.numberOfFlies) * (maxIdentity + 1);
info.trackingData.identity = info.trackingData.identity + addToIdentity;
userFliesData.identity = (0:param.numberOfFlies - 1).';
firstFrameFlies = info.trackingData(info.trackingData.frame == info.trackingData.frame(1), :);
match = getMatchTable(userFliesData, firstFrameFlies, param);
info = matchFlies(info, match);
info = deleteExtraFlies(info, param);
info = addMissingFlies(info, userFliesData);
info.trackingData = sortrows(info.trackingData, [7 6]);
info = countFlies(info);
end

% Creates a table to match the user's flies with the tracking data.
% Flies with the smallest distance will be higher in the table so they will
% be matched. Flies with distance higher then 'flyMaxLength' will not be 
% added to the table.
function [match] = getMatchTable(userFliesData, firstFrameFlies, param)
userFly = repmat(-1, length(userFliesData) * length(firstFrameFlies), 1);
firstFrameFly = repmat(-1, length(userFliesData) * length(firstFrameFlies), 1);
distance = repmat(-1, length(userFliesData) * length(firstFrameFlies), 1);
match = dataset(userFly, firstFrameFly, distance);
for i = 1:length(userFliesData)
    for j = 1:length(firstFrameFlies)
        index = sub2ind([length(firstFrameFlies), length(userFliesData)], j, i);
        startX = userFliesData.x_pos(i);
        startY = userFliesData.y_pos(i);
        endX = firstFrameFlies.x_pos(j);
        endY = firstFrameFlies.y_pos(j);
        distance = sqrt(((startX - endX)^2) + ((startY - endY)^2)) * param.mmPerPixel;
        if distance <= param.flyMaxLength
            match.userFly(index) = userFliesData.identity(i);
            match.firstFrameFly(index) = firstFrameFlies.identity(j);
            match.distance(index) = distance;
        end
    end
end
match(match.userFly == -1, :) = [];
if ~isempty(match)
    match = sortrows(match, 3);
end
end

% Matches the flies according to the 'match' table.
% Changes the tracking data's fly's identity to the user's fly's identity.
function [info] = matchFlies(info, match)
while ~isempty(match)
    currentUserFly = match.userFly(1);
    currentFirstFrameFly = match.firstFrameFly(1);
    info.trackingData.identity(info.trackingData.identity == currentFirstFrameFly) = currentUserFly;
    match(match.firstFrameFly == currentFirstFrameFly, :) = [];
    match(match.userFly == currentUserFly, :) = [];
end
end

% Updates the changes done on each frame in the info's vectors.
% 'framesChanged' represents the frames that were changed, and the 'type'
% string represent the type of change: 'add' or 'remove'.
function [info] = updateChangesPerFrame(info, framesChanged, type)
if isempty(framesChanged)
    return;
end
framesChanged = tabulate(framesChanged);
FliesPerFrame = zeros(length(info.deletedFliesPerFrame), 1);
FliesPerFrame(framesChanged(:, 1)) = framesChanged(:, 2);
if strcmp(type, 'add')
    info.addedFliesPerFrame = info.addedFliesPerFrame + FliesPerFrame;
else
    info.deletedFliesPerFrame = info.deletedFliesPerFrame + FliesPerFrame;
end
end

% Deletes the first frame's flies that were not matched to the user's flies.
% Updates the changes vector with the number of flies deleted from each frame.
function [info] = deleteExtraFlies(info, param)
falseFlies = info.trackingData.identity(info.trackingData.frame == info.trackingData.frame(1) & info.trackingData.identity >= param.numberOfFlies);
framesChanged = info.trackingData.frame(ismember(info.trackingData.identity, falseFlies));
if ~isempty(framesChanged)
    info = updateChangesPerFrame(info, framesChanged, 'delete');
end
info.trackingData(ismember(info.trackingData.identity, falseFlies), :) = [];
end

% Adds the user's flies that were not matched to the first frame's flies.
% Updates the changes vector with the number of flies added to the frame.
function [info] = addMissingFlies(info, userFliesData)
missingFlies = userFliesData.identity(~ismember(userFliesData.identity, info.trackingData.identity));
if ~isempty(missingFlies)
    x_pos = userFliesData.x_pos(ismember(userFliesData.identity, missingFlies));
    y_pos = userFliesData.y_pos(ismember(userFliesData.identity, missingFlies));
    angle = zeros(length(x_pos), 1);
    maj_ax = zeros(length(x_pos), 1);
    min_ax = zeros(length(x_pos), 1);
    identity = missingFlies;
    frame = repmat(info.trackingData.frame(1), length(x_pos), 1);
    count = zeros(length(x_pos), 1);
    newData = dataset(x_pos, y_pos, angle, maj_ax, min_ax, identity, frame, count);
    info.trackingData = [info.trackingData ; newData];
    info = updateChangesPerFrame(info, frame, 'add');
end
end

% Counts the flies in the tracking data.
% The count is used to find error frames when there are more or less flies
% then the actual number of flies.
% The number of flies in each frame in the last value in the "count" column
% with the specific frame.
function [info] = countFlies(info)
count = ones(length(info.trackingData), 1);
frames = info.trackingData.frame;
countNumber = 1;
count(1) = 1;
for i = 2:length(info.trackingData)
    countNumber = countNumber + 1;
    if frames(i) > frames(i - 1)
        countNumber = 1;
    end
    count(i) = countNumber;
end
info.trackingData.count = count;
end

% Calculates the tracking data's accuracy percent.
% Identities larger than 'numberOfFlies' - 1 is deleted (only the start
% identities will be taken into account when calculating the accuracy percent).
% The accuracy is calculated according to the number of missing flies in each frame. 
function [accuracy, lastOccurrences] = calculateAccuracy(info, param)
info.trackingData(info.trackingData.identity >= param.numberOfFlies, :) = [];
[~,ia,~] = unique(info.trackingData.identity, 'last');
lastOccurrences = info.trackingData(ia, :);
errors = param.numberOfFrames * param.numberOfFlies - sum(lastOccurrences.frame);
accuracy = 100 - (errors * 100) / (param.numberOfFrames * param.numberOfFlies);
end

%% Fix all tracking errors

% Fixes all tracking errors. The algorithm do the following steps:
% Deletes observations where flies jumps outside the arena.
% Removes and connects given flies' tracks with a growing speed threshold.
% Connects the remaining flies' tracks.
function [info] = fixTrackingErrors(info, param)
info = fixJumpEvents(info, param);
param.currentSpeedLimit = param.sameFlySpeed;
while param.currentSpeedLimit <= param.maxFlySpeed 
    changed1 = true;
    changed2 = true;
    while changed1 || changed2
        [info, changed1] = handleTracks(info, param, 'remove');
        [info, changed2] = handleTracks(info, param, 'connect');
    end
    param.currentSpeedLimit = param.currentSpeedLimit * 2;
    param.currentTimeLimit = param.currentTimeLimit * 2;
    param.currentDistanceLimit = param.currentDistanceLimit * 2;
end
info = connectRemainingTracks(info, param);
end

% Fixes all flies' jump events.
% Deletes observations of flies that "jumps" out of the arena bounds or
% "jumps" too fast according to the 'maxFlySpeed' parameter.
% If the jump is at the middle of a fly's track, fills the frames before 
% and after the jump to connect the fly's track.
function [info] = fixJumpEvents(info, param)
for i = 0:max(info.trackingData.identity)
    info = fixSameIdentityFramesGap(info, i);
    info = deleteOutOfArenaJumps(info, param, i);
    info = deleteTooFastJumps(info, param, i);
end
end

% Fixes situations when there are missing frames in the middle of a certain
% identity's track. Disconnects the track to two different identities.
function [info] = fixSameIdentityFramesGap(info, flyIdentity)
flyFrames = info.trackingData.frame(info.trackingData.identity == flyIdentity);
if isempty(flyFrames)
    return;
end
allFrames = (flyFrames(1):flyFrames(end)).';
if ~isequal(flyFrames, allFrames)
    i = 2;
    while flyFrames(i) - flyFrames(i - 1) == 1
        i = i + 1;
    end
    info.trackingData.identity(info.trackingData.identity == flyIdentity & info.trackingData.frame >= flyFrames(i)) = max(info.trackingData.identity) + 1;
end
end

% Deletes observations of flies that "jumps" out of the arena bounds.
% If the jump is at the end of the fly's track, delete the jump's frames.
% If the jump is at the middle of the fly's track, fills the frames with the
% fly's approximate location according to its location before and after the jump.
function [info] = deleteOutOfArenaJumps(info, param, flyIdentity)
indexs = info.trackingData.identity == flyIdentity & ~inpolygon(info.trackingData.x_pos, info.trackingData.y_pos, param.arenaX, param.arenaY);
jumpsFrames = info.trackingData.frame(indexs);
if isempty(jumpsFrames)
    return;
end
firstJumpFrame = jumpsFrames(1);
for j = 2:length(jumpsFrames)
    if jumpsFrames(j) - jumpsFrames(j - 1) > 1
        lastJumpFrame = jumpsFrames(j - 1);
        info = handleJump(info, firstJumpFrame, lastJumpFrame, flyIdentity);
        firstJumpFrame = jumpsFrames(j);
    end
end
info = handleJump(info, firstJumpFrame, jumpsFrames(end), flyIdentity);
end

% Handles a certain fly's jump.
% Deletes the jump's frames and update the changes vector with the deleted frames.
% If the jump is at the middle of the fly's track, fills the frames before 
% and after the jump to connect the fly's track.
function [info] = handleJump(info, firstJumpFrame, lastJumpFrame, flyIdentity)
framesChanged = (firstJumpFrame:lastJumpFrame).';
info = updateChangesPerFrame(info, framesChanged, 'delete');
indexs = info.trackingData.frame >= firstJumpFrame & info.trackingData.frame <= lastJumpFrame & info.trackingData.identity == flyIdentity;
info.trackingData(indexs, :) = [];
flyDisappearData = info.trackingData(info.trackingData.identity == flyIdentity & info.trackingData.frame == firstJumpFrame - 1, :);
flyAppearData = info.trackingData(info.trackingData.identity == flyIdentity & info.trackingData.frame == lastJumpFrame + 1, :);
if ~isempty(flyDisappearData) && ~isempty(flyAppearData)
    info.trackingData(info.trackingData.identity == flyIdentity & (info.trackingData.frame == firstJumpFrame - 1 | info.trackingData.frame == lastJumpFrame + 1), :) = [];
    info = connectFliesPaths(info, flyDisappearData, flyAppearData);
end
end

% Receives the data of the fly's disappear and appear occurrences.
% Fills the missing frames with the fly's approximate location according 
% to its disappear and appear location.
function [info] = connectFliesPaths(info, flyDisappearData, flyAppearData)
length = flyAppearData.frame - flyDisappearData.frame + 1;
x_pos = linspace(flyDisappearData.x_pos, flyAppearData.x_pos, length).';
y_pos = linspace(flyDisappearData.y_pos, flyAppearData.y_pos, length).';
angle = linspace(flyDisappearData.angle, flyAppearData.angle, length).';
maj_ax = linspace(flyDisappearData.maj_ax, flyAppearData.maj_ax, length).';
min_ax = linspace(flyDisappearData.min_ax, flyAppearData.min_ax, length).';
identity = repmat(flyDisappearData.identity, length, 1);
frame = linspace(flyDisappearData.frame, flyAppearData.frame, length).';
count = zeros(length, 1);
newData = dataset(x_pos, y_pos, angle, maj_ax, min_ax, identity, frame, count);
info.trackingData = [info.trackingData ; newData];
info.trackingData = sortrows(info.trackingData, [7 6]);
info = updateChangesPerFrame(info, frame, 'add');
end

% Deletes observations of flies that fly faster than 'maxFlySpeed'.
% If the jump is at the end of the fly's track, delete the jump's frames.
% If the jump is at the middle of the fly's track, fills the frames with the
% fly's approximate location according to its location before and after the jump.
function [info] = deleteTooFastJumps(info, param, flyIdentity)
flyGivenData = info.trackingData(info.trackingData.identity == flyIdentity, :);
frames = flyGivenData.frame;
xVector = flyGivenData.x_pos;
yVector = flyGivenData.y_pos;
for i = 2:length(frames)
    speed = getApproximatedSpeed(xVector(i - 1), xVector(i), yVector(i - 1), yVector(i), param.secPerFrame, param);
    if speed > param.maxFlySpeed && i <= param.maxJumpFrames && frames(1) ~= 1
        info.trackingData(info.trackingData.frame <= frames(i - 1) & info.trackingData.identity == flyIdentity, :) = [];
        info.deletedFliesPerFrame(frames(i - 1)) = info.deletedFliesPerFrame(frames(i - 1)) + 1;
    elseif speed > param.maxFlySpeed && i >= length(frames) - param.maxJumpFrames
        info.trackingData(info.trackingData.frame >= frames(i) & info.trackingData.identity == flyIdentity, :) = [];
        info.deletedFliesPerFrame(frames(i)) = info.deletedFliesPerFrame(frames(i)) + 1;
    elseif speed > param.maxFlySpeed
        nextSpeed = getApproximatedSpeed(xVector(i), xVector(i + 1), yVector(i), yVector(i + 1), param.secPerFrame, param);
        if nextSpeed > param.maxFlySpeed
            info = handleJump(info, frames(i), frames(i), flyIdentity);
        end
    end
end
end

% Finds all errors for the specified action. Finds a block of frames
% representing the same error according to the threshold.
% Do the specified action on the block of frames. The function only fixes
% blocks that has a correct frame before and after them.
% If the data has changed, counts the flies ("count" column is not fixed
% after every error to save time).
function [info, changed] = handleTracks(info, param, action)
changed = false;
errorFrames = getErrors(info, param, action);
if isempty(errorFrames)
    return;
end
firstErrorFrame = errorFrames(1);
for i = 2:length(errorFrames)
    if errorFrames(i) - errorFrames(i - 1) > param.oneErrorThreshold
        lastErrorFrame = errorFrames(i - 1);
        [info, changed] = doGivenAction(info, firstErrorFrame, lastErrorFrame, param, action, changed);
        firstErrorFrame = errorFrames(i);
    end
end
if errorFrames(end) < param.numberOfFrames
    [info, changed] = doGivenAction(info, firstErrorFrame, errorFrames(end), param, action, changed);
end
if changed
    info = countFlies(info);
end
end

% Finds the frames with errors according to the given action.
% For action 'remove' finds the frames with more flies than 'numberOfFlies'.
% For action 'connect' uses 'getErrorFrames'.
function [errorFrames] = getErrors(info, param, action)
fliesPerFrame = findFliesPerFrame(info);
if strcmp(action, 'remove')
    errorFrames = find(fliesPerFrame > param.numberOfFlies, param.numberOfFrames);
else
    if abs(param.numberOfFlies - mean(fliesPerFrame)) > param.precisionRate
        errorFrames = getErrorFrames(param, fliesPerFrame);
    else
        errorFrames = find(fliesPerFrame > param.numberOfFlies | fliesPerFrame < param.numberOfFlies, param.numberOfFrames);
    end
end
end

% Finds the frames with the incorrect number of flies.
% The correct number of flies is define according to the most common number
% of flies in the nearby frames.
function [errorFrames] = getErrorFrames(param, fliesPerFrame)
errorFrames = repmat(-1, param.numberOfFrames, 1);
correctFliesNumber = find(fliesPerFrame == param.numberOfFlies, param.numberOfFrames);
currentFliesNumber = param.numberOfFlies;
i = 1;
while i <= param.numberOfFrames
    if i <= length(fliesPerFrame) && fliesPerFrame(i) == currentFliesNumber
        i = i + 1;
    else
        next = correctFliesNumber(find(correctFliesNumber > i, 1));
        if ~isempty(next) && ((next - i) * param.secPerFrame < param.disappearSecThreshold || all(fliesPerFrame(i:next) == fliesPerFrame(i)))
            errorFrames(i:next - 1) = 1;
            i = next + 1;
        else
            currentFliesNumber = fliesPerFrame(i);
            correctFliesNumber = find(fliesPerFrame == currentFliesNumber, param.numberOfFrames);
        end
    end
end
errorFrames = find(errorFrames ~= -1, param.numberOfFrames);
end

% Finds the number of flies in each frame according to the last "count"
% value for each frame in the data.
function [fliesPerFrame] = findFliesPerFrame(info)
%fliesPerFrame = info.trackingData.count([find(diff(info.trackingData.frame')) length(info.trackingData.frame)], :);
fliesPerFrame = splitapply(@length, info.trackingData.count, findgroups(info.trackingData.frame));
end

% Sends the 'info' struct to the correct function according to the 'action'
% value. The function will try to fix the errors between the given frames.
function [info, changed] = doGivenAction(info, firstErrorFrame, lastErrorFrame, param, action, changed)
if strcmp(action, 'remove')
    [info, isChanged] = handleFliesRemoval(info, firstErrorFrame, lastErrorFrame, param);
else
    [info, isChanged] = handleFliesConnection(info, firstErrorFrame, lastErrorFrame, param);
end
if isChanged
    changed = true;
end
end

% Receives the first and last frames with extra number of flies and decides
% which fly/ies to remove. 
% A fly will be removed only if the frames with the correct number of flies
% before and after the error's frames has the same flies' identities.
function [info, changed] = handleFliesRemoval(info, firstErrorFrame, lastErrorFrame, param)
changed = false;
fliesPerFrame = findFliesPerFrame(info);
if sameFlies(info, firstErrorFrame - 1, lastErrorFrame + 1) && fliesPerFrame(firstErrorFrame - 1) == param.numberOfFlies && fliesPerFrame(lastErrorFrame + 1) == param.numberOfFlies
    allFlies = unique(info.trackingData.identity(find(info.trackingData.frame >= firstErrorFrame & info.trackingData.frame <= lastErrorFrame, length(info.trackingData))));
    falseFlies = allFlies(~ismember(allFlies, info.trackingData.identity(info.trackingData.frame == firstErrorFrame - 1)));
    framesChanged = info.trackingData.frame(ismember(info.trackingData.identity, falseFlies));
    info = updateChangesPerFrame(info, framesChanged, 'delete');
    info.trackingData(ismember(info.trackingData.identity, falseFlies), :) = [];
    changed = true;
end
end

% Checks if the two given frames has the same flies' identities.
% Returns 'true' if the frames has the same flies, and 'false' otherwise.
function [bool] = sameFlies(info, firstFrame, lastFrame)
firstData = info.trackingData(info.trackingData.frame == firstFrame, :);
lastData = info.trackingData(info.trackingData.frame == lastFrame, :);
bool = all(ismember(firstData.identity, lastData.identity)) & length(firstData) == length(lastData);
end

% Receives the first and last frames with incorrect number of flies and 
% decides which flies to connect. 
% Flies will be connected according to their score in the scores table.
function [info, changed] = handleFliesConnection(info, firstErrorFrame, lastErrorFrame, param)
changed = false;
fliesAppear = getFliesInfo(info, firstErrorFrame, lastErrorFrame, param, 'appear');
fliesDisappear = getFliesInfo(info, firstErrorFrame, lastErrorFrame, param, 'disappear');
if isempty(fliesAppear) || isempty(fliesDisappear)
    return;
end
scores = getScoresTable(info, fliesAppear, fliesDisappear, lastErrorFrame - firstErrorFrame + 1, param);
if size(scores, 1) > 1
    %scores = a(info, scores, firstErrorFrame, lastErrorFrame);
end
[info, changed] = connectAccordingToScores(info, scores, fliesAppear, fliesDisappear, param);
end

% Returns the flies' information according to 'type'.
% For 'appear' flies returns the first observation of every fly.
% For 'disappear' flies returns the last observation of every fly.
% The information includes all the tracking information and the fly's speed.
function [fliesInfo] = getFliesInfo(info, firstErrorFrame, lastErrorFrame, param, type)
if strcmp(type, 'appear')
    [~,ia,~] = unique(info.trackingData.identity, 'first');
    firstOccurrences = info.trackingData(ia, :);
    fliesInfo = firstOccurrences(firstOccurrences.frame >= firstErrorFrame & firstOccurrences.frame <= (lastErrorFrame + 1), :);
else
    [~,ia,~] = unique(info.trackingData.identity, 'last');
    lastOccurrences = info.trackingData(ia, :);
    fliesInfo = lastOccurrences(lastOccurrences.frame >= (firstErrorFrame - 1) & lastOccurrences.frame <= lastErrorFrame, :);
end
fliesInfo.count = [];
fliesInfo.speed = ones(size(fliesInfo, 1), 1);
for i = 1:length(fliesInfo)
    fliesInfo.speed(i) = getAverageSpeed(info, fliesInfo.identity(i), param);
end
end

% Calculates the average fly's speed.
% The fly's speed is calculated every 'secBetweenCalculations' seconds 
% and not every frame to save running time.
function [speed] = getAverageSpeed(info, identity, param)
flyGivenData = info.trackingData(info.trackingData.identity == identity, :);
speeds = repmat(-1, length(flyGivenData) - 1, 1);
xVector = flyGivenData.x_pos;
yVector = flyGivenData.y_pos;
for i = 1:round(param.secBetweenCalculations / param.secPerFrame):length(speeds)
    speeds(i) = getApproximatedSpeed(xVector(i), xVector(i + 1), yVector(i), yVector(i + 1), param.secPerFrame, param);
end
speeds(speeds == -1) = [];
speed = mean(speeds);
end

% Calculates the approximated fly's speed between the start and end points.
function [speed] = getApproximatedSpeed(startX, endX, startY, endY, time, param)
distance = sqrt(((startX - endX)^2) + ((startY - endY)^2)) * param.mmPerPixel;
speed = distance / time;
end

% Creates a table to match the flies disappear with the flies appear.
% The table contains a score for each pair of flies which is calculated
% using the 'calculateFliesScore' function. Flies with the smallest scores 
% will be higher in the table so they will be matched. 
% Flies with speed higher then 'sameFlySpeed' will not be added to the table.
function [scores] = getScoresTable(info, fliesAppear, fliesDisappear, totalErrorFrames, param)
flyDisappear = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
flyAppear = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
speed = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
time = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
distance = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
score = repmat(-1, length(fliesAppear) * length(fliesDisappear), 1);
decisionInfo = cell(size(flyDisappear));
for i = 1:length(fliesDisappear)
    for j = 1:length(fliesAppear)
        [flyDisappearData, flyAppearData, OverlappingFrames] = getNonOverlappingData(info, fliesDisappear(i, :), fliesAppear(j, :), param);
        if OverlappingFrames == param.noOverlappingFrames
            continue;
        end
        curTime = (flyAppearData.frame - flyDisappearData.frame) * param.secPerFrame;
        curSpeed = getApproximatedSpeed(flyDisappearData.x_pos, flyAppearData.x_pos, flyDisappearData.y_pos, flyAppearData.y_pos, curTime, param);
        curDistance = curSpeed * curTime;
        if curSpeed < param.currentSpeedLimit && curTime < param.currentTimeLimit && curDistance < param.currentDistanceLimit
            index = sub2ind([length(fliesAppear), length(fliesDisappear)], j, i);
            flyDisappear(index) = flyDisappearData.identity;
            flyAppear(index) = flyAppearData.identity;
            speed(index) = curSpeed;
            score(index) = calculateFliesScore(curSpeed, flyDisappearData, flyAppearData, totalErrorFrames, OverlappingFrames, param);
            time(index) = curTime;
            distance(index) = curDistance;
            decisionInfo{index} = [abs(flyAppearData.frame - flyDisappearData.frame) - 1, totalErrorFrames, OverlappingFrames];
        end
    end
end
scores = dataset(flyDisappear, flyAppear, speed, score, time, distance, decisionInfo);
scores(scores.flyDisappear == -1, :) = [];
if ~isempty(scores)
    scores = sortrows(scores, [4 3]);
end
end

% Returns the flies' non Overlapping data.
% If the fly that appear and the fly that disappear has Overlapping frames,
% returns their data from the first and last frame they're not Overlapping.
% Overlapping frames are usually defective and reduces the algorithm performance.
function [flyDisappearData, flyAppearData, overlappingFrames] = getNonOverlappingData(info, flyDisappearData, flyAppearData, param)
overlappingFrames = 0;
disappearFrame = flyDisappearData.frame;
appearFrame = flyAppearData.frame;
if appearFrame <= disappearFrame
    overlappingFrames = disappearFrame - appearFrame + 1;
    disappearSpeed = flyDisappearData.speed;
    appearSpeed = flyAppearData.speed;
    flyDisappearData = info.trackingData(info.trackingData.frame == appearFrame - 1 & info.trackingData.identity == flyDisappearData.identity, :);
    flyAppearData = info.trackingData(info.trackingData.frame == disappearFrame + 1 & info.trackingData.identity == flyAppearData.identity, :);
    if isempty(flyDisappearData) || isempty(flyAppearData)
        overlappingFrames = param.noOverlappingFrames;
        return;
    end
    flyDisappearData.count = [];
    flyAppearData.count = [];
    flyDisappearData.speed = disappearSpeed;
    flyAppearData.speed = appearSpeed;
end
end

% Calculates a score for the given pair of flies.
% The score is calculated according to the approximated speed between the
% disappear frame and the appear frame, and the flies' known behavior.
% There are penalties for long disappearance time and frame's overlapping.
function [score] = calculateFliesScore(speed, flyDisappearData, ...
    flyAppearData, totalErrorFrames, OverlappingFrames, param)
score = speed;
% Adds a penalty if the disappear fly isn't moving in the video.
if flyDisappearData.speed < param.flyMinWalkingSpeed
   score = score * param.notWalkingPenalty;
end
% Adds a penalty if the appear fly isn't moving in the video.
if flyAppearData.speed < param.flyMinWalkingSpeed
   score = score * param.notWalkingPenalty;
end
% Adds a penalty according to the error's length.
framesBetweenFlies = abs(flyAppearData.frame - flyDisappearData.frame) - 1;
framesFraction = framesBetweenFlies / totalErrorFrames;
numberOfFramesPenalty = 1 + param.framesPenalty * framesFraction;
score = score * numberOfFramesPenalty;
% Adds a penalty according to the flies' overlapping frames' number.
OverlappingPenalty = 1 + (OverlappingFrames / param.oneErrorThreshold);
score = score * OverlappingPenalty;
end


function [scores] = a(info, scores, firstErrorFrame, lastErrorFrame)
currentMatch = getPairs(scores);
for i = 1:size(currentMatch, 1) 
    newScores = scores(scores.flyDisappear ~= currentMatch.flyDisappear(i) | scores.flyAppear ~= currentMatch.flyAppear(i), :);
    newMatch = getPairs(newScores);
    if size(newMatch, 1) >= size(currentMatch, 1)
        currentDiff = setdiff(currentMatch, newMatch);
        newDiff = setdiff(newMatch, currentMatch);
        if ~isempty(currentDiff) && ~isempty(newDiff)
            scores = b(info, scores, currentDiff, newDiff);
        end
    end
end
end

function [pairs] = getPairs(scores)
flyDisappear = repmat(-1, length(scores), 1);
flyAppear = repmat(-1, length(scores), 1);
speed = repmat(-1, length(scores), 1);
score = repmat(-1, length(scores), 1);
framesBetweenFlies = repmat(-1, length(scores), 1);
totalErrorFrames = repmat(-1, length(scores), 1);
overlappingFrames = repmat(-1, length(scores), 1);
i = 1;
while ~isempty(scores)
    flyDisappear(i) = scores.flyDisappear(1);
    flyAppear(i) = scores.flyAppear(1);
    speed(i) = scores.speed(1);
    score(i) = scores.score(1);
    decisionInfo = cell2mat(scores.decisionInfo(1));
    framesBetweenFlies(i) = decisionInfo(1);
    totalErrorFrames(i) = decisionInfo(2);
    overlappingFrames(i) = decisionInfo(3);
    scores(scores.flyDisappear == flyDisappear(i), :) = [];
    scores(scores.flyAppear == flyAppear(i), :) = [];
    scores.flyDisappear(scores.flyDisappear == flyAppear(i)) = flyDisappear(i);
    i = i + 1;
end
pairs = dataset(flyDisappear, flyAppear, speed, score, framesBetweenFlies, totalErrorFrames, overlappingFrames);
pairs(pairs.flyDisappear == -1, :) = [];
end

function [scores] = b(info, scores, currentDiff, newDiff)
a = size(newDiff, 1) - size(currentDiff, 1);
b = sum(newDiff.speed) - sum(currentDiff.speed);
c = sum(newDiff.score) - sum(currentDiff.score);
d = (sum(newDiff.framesBetweenFlies) - sum(currentDiff.framesBetweenFlies)) / currentDiff.totalErrorFrames(1);
e = sum(newDiff.overlappingFrames) - sum(currentDiff.overlappingFrames);
disp([a, b, c, d, e])
end


% Connects the flies disappear with the flies appear according to the
% scores table until the table is empty.
% The pair of flies that has the lowest score will be connected first.
function [info, changed] = connectAccordingToScores(info, scores, fliesAppear, fliesDisappear, param)
changed = false;
while ~isempty(scores)
    flyDisappearData = fliesDisappear(fliesDisappear.identity == scores.flyDisappear(1), :);
    flyAppearData = fliesAppear(fliesAppear.identity == scores.flyAppear(1), :);
    info = connectFlies(info, flyDisappearData, flyAppearData, param);
    scores(scores.flyDisappear == flyDisappearData.identity, :) = [];
    scores(scores.flyAppear == flyAppearData.identity, :) = [];
    scores.flyDisappear(scores.flyDisappear == flyAppearData.identity) = flyDisappearData.identity;
    changed = true;
end
end

% Connects the given flies. Deletes the overlapping frames, changes the  
% fly appear's identity to the fly disappear's identity, and fills the  
% missing frames with the fly's approximate location.
function [info] = connectFlies(info, flyDisappearData, flyAppearData, param)
[flyDisappearData, flyAppearData, ~] = getNonOverlappingData(info, flyDisappearData, flyAppearData, param);
indexs = (info.trackingData.frame <= flyAppearData.frame & info.trackingData.identity == flyAppearData.identity) | (info.trackingData.frame >= flyDisappearData.frame & info.trackingData.identity == flyDisappearData.identity);
framesChanged = info.trackingData.frame(indexs);
if ~isempty(framesChanged)
    info = updateChangesPerFrame(info, framesChanged, 'delete');
end
info.trackingData = info.trackingData(~indexs, :);
info.trackingData.identity(info.trackingData.identity == flyAppearData.identity) = flyDisappearData.identity;
info = connectFliesPaths(info, flyDisappearData, flyAppearData);
end

% Connects all the remaining flies. Sets the 'sameFlySpeed' to a high 
% threshold and connects all the flies that disappear in the tracking data 
% with all the flies that appear according to their scores.
% Deletes all the extra flies, the flies with identity higher than the
% number of flies - 1 (correct identities are 0 - numberOfFlies-1).
function [info] = connectRemainingTracks(info, param)
changed = true;
while param.endTimeLimit < param.maxTimeLimit && param.endDistanceLimit < param.maxDistanceLimit
    while changed
        [info, changed] = handleFliesConnection(info, info.trackingData.frame(1) + 1, param.numberOfFrames - 1, param);
    end
    changed = true;
    param.endTimeLimit = param.endTimeLimit * 2;
    param.endDistanceLimit = param.endDistanceLimit * 2;
end
framesChanged = info.trackingData.frame(info.trackingData.identity >= param.numberOfFlies);
if ~isempty(framesChanged)
    info = updateChangesPerFrame(info, framesChanged, 'delete');
end
info.trackingData(info.trackingData.identity >= param.numberOfFlies, :) = [];
end

%% Handle tracking accuracy after fixing.

% Calculates the tracking data's accuracy percent after fixing the errors.
% If the accuracy percent is lower than 100, display a list dialog with 
% options for the user to decide what to do with the incomplete data.
function [info, param] = handleEndAccuracy(info, param, showOptions)
[accuracy, lastOccurrences] = calculateAccuracy(info, param);
[info, param] = uniteGaps(info, param);
info.endAccuracy = accuracy;
message = strcat('Tracking is', {' '}, num2str(accuracy), '% complete.');
if accuracy < 100
    if strcmp(showOptions, 'on')
        [options, recommendedOption] = getOptions(param, lastOccurrences);
        message = strcat(message, ' Decide what to do:');
        [Selection, ~] = listdlg('SelectionMode', 'single', 'PromptString', message, 'ListString', options, 'ListSize', [300, 130], 'Name', 'Performances', 'CancelString', 'Do as recommended');
        if isempty(Selection)
            Selection(1) = recommendedOption;
        end
        if Selection(1) == 1
            info = deleteIncorrectFrames(info, min(lastOccurrences.frame));
        elseif Selection(1) == 2
            [info, param] = deleteFliesTracks(info, param, lastOccurrences);
        else
            info = addMissingFrames(info, param);
        end
    else
        info = addMissingFrames(info, param);
    end
end
end

function [info, param] = uniteGaps(info, param)
for flyIdentity = 0:max(info.trackingData.identity)
    flyFrames = info.trackingData.frame(info.trackingData.identity == flyIdentity);
    if isempty(flyFrames)
        return;
    end
    allFrames = (flyFrames(1):flyFrames(end)).';
    
    if ~isequal(flyFrames, allFrames)
        missingFrames = setdiff(allFrames, flyFrames);
        [info, param] = addGapFrames(info, param, missingFrames, flyIdentity);
    end
end
end

function [info, param] = addGapFrames(info, param, missingFrames, flyIdentity)
firstErrorFrame = missingFrames(1);
for i = 2:length(missingFrames)
    if missingFrames(i) - missingFrames(i - 1) > 1
        lastErrorFrame = missingFrames(i - 1);
        flyDisappearData = info.trackingData(info.trackingData.frame == firstErrorFrame - 1 & info.trackingData.identity == flyIdentity, :);
        flyAppearData = info.trackingData(info.trackingData.frame == lastErrorFrame + 1 & info.trackingData.identity == flyIdentity, :);
        info.trackingData(info.trackingData.identity == flyIdentity & (info.trackingData.frame == firstErrorFrame - 1 | info.trackingData.frame == lastErrorFrame + 1), :) = [];
        [info] = connectFliesPaths(info, flyDisappearData, flyAppearData);
        firstErrorFrame = missingFrames(i);
    end
end
if missingFrames(end) < param.numberOfFrames
    flyDisappearData = info.trackingData(info.trackingData.frame == firstErrorFrame - 1 & info.trackingData.identity == flyIdentity, :);
    flyAppearData = info.trackingData(info.trackingData.frame == missingFrames(end) + 1 & info.trackingData.identity == flyIdentity, :);
    info.trackingData(info.trackingData.identity == flyIdentity & (info.trackingData.frame == firstErrorFrame - 1 | info.trackingData.frame == missingFrames(end) + 1), :) = [];
    [info] = connectFliesPaths(info, flyDisappearData, flyAppearData);
end
info = countFlies(info);
end

% Returns the list of options for the list dialog.
% The options lets the user decide what to do with the incomplete data.
% A recommendation is calculated according to the characteristics of the
% remaining errors in the tracking data, and added to the options.
function [options, recommendedOption] = getOptions(param, lastOccurrences)
incorrectTime = (param.numberOfFrames - min(lastOccurrences.frame)) * param.secPerFrame;
units = 'second/s)';
if incorrectTime >= 60
    incorrectTime = incorrectTime / 60;
    units = 'minute/s)';
end
fliesDisappear = length(lastOccurrences(lastOccurrences.frame < param.numberOfFrames, :));
option1 = strjoin({'Delete incorrect frames (about', num2str(incorrectTime), units});
option2 = strjoin({'Delete incomplete tracks (delete', num2str(fliesDisappear), 'fly/ies)'});
option3 = 'Fill missing values with flies'' last known locations';
recommended = '- recommended';
if param.numberOfFrames - min(lastOccurrences.frame) <= param.numberOfFrames * param.framesPercentToDelete
    option1 = strjoin({option1, recommended});
    recommendedOption = 1;
elseif fliesDisappear <= param.numberOfFlies * param.fliesPercentToDelete
    option2 = strjoin({option2, recommended});
    recommendedOption = 2;
else
    option3 = strjoin({option3, recommended});
    recommendedOption = 3;
end
options = {option1, option2, option3};
end

% Deletes the frames with the incomplete tracking data.
% Updates the changes vector with the number of flies deleted from each frame.
function [info] = deleteIncorrectFrames(info, lastCorrectFrame)
framesChanged = info.trackingData.frame(info.trackingData.frame > lastCorrectFrame);
info = updateChangesPerFrame(info, framesChanged, 'delete');
info.trackingData(info.trackingData.frame > lastCorrectFrame, :) = [];
end

% Deletes the flies with the incomplete track.
% Updates the changes vector with the number of flies deleted from each frame.
function [info, param] = deleteFliesTracks(info, param, lastOccurrences)
fliesToDelete = lastOccurrences.identity(lastOccurrences.frame < param.numberOfFrames, :);
framesChanged = info.trackingData.frame(ismember(info.trackingData.identity, fliesToDelete));
info = updateChangesPerFrame(info, framesChanged, 'delete');
info.trackingData(ismember(info.trackingData.identity, fliesToDelete), :) = [];
param.numberOfFlies = param.numberOfFlies - length(fliesToDelete);
end

% Adds the missing frames to the tracking data.
% The missing frames will be filled with the flies' last known locations.
% Updates the changes vector with the number of flies added to each frame.
function [info] = addMissingFrames(info, param)
[~,ia,~] = unique(info.trackingData.identity, 'last');
lastOccurrences = info.trackingData(ia, :);
s = 1;
for i = 1:param.numberOfFlies
    flyData = lastOccurrences(i, :);
    length = param.numberOfFrames - flyData.frame;
    if length == 0
        continue;
    end
    s = s + 1;
    x_pos = repmat(flyData.x_pos, length, 1);
    y_pos = repmat(flyData.y_pos, length, 1);
    angle = repmat(flyData.angle, length, 1);
    maj_ax = repmat(flyData.maj_ax, length, 1);
    min_ax = repmat(flyData.min_ax, length, 1);
    identity = repmat(flyData.identity, length, 1);
    frame = ((flyData.frame + 1):param.numberOfFrames).';
    count = repmat(flyData.count, length, 1);
    newData = dataset(x_pos, y_pos, angle, maj_ax, min_ax, identity, frame, count);
    info.trackingData = [info.trackingData ; newData];
    info = updateChangesPerFrame(info, frame, 'add');
end
info.trackingData = sortrows(info.trackingData, [7 6]);
end

%% Create and display changes graph.

% Generates the graph with the number of flies added and deleted in each frame.
% The graph displays the number of flies with the approximate addition and 
% the number of extra flies as a function of frame number.
function [graph] = generateChangesGraph(info, param)
changesGraph = figure('Visible', 'off', 'Name', 'Changes Graph', 'Position', [60, 300, 1200, 300]);
graph = bar([info.deletedFliesPerFrame info.addedFliesPerFrame]);
set(graph(1), 'FaceColor',[0.667, 0.333, 0.345]);
set(graph(2), 'FaceColor',[0.3, 0.7, 0.7]);
axis([0 param.numberOfFrames 0 param.numberOfFlies]);
title('Number Of Flies Changed Per Frame');
xlabel('Frame Number');
ylabel('Flies Changed');
legend('Flies Deleted', 'Flies Added');
end

%% Save fixed tracking data.

% Generates a .mat file with the fixed tracking information.
% The .mat file format is the same as the the .mat file received from CTRAX.
function [fileName] = generateMatFile(info, param, timestamps, startframe, originalFileName, changesGraph)
ntargets = repmat(param.numberOfFlies, param.numberOfFrames, 1);
x_pos = info.trackingData.x_pos;
y_pos = info.trackingData.y_pos;
angle = info.trackingData.angle;
maj_ax = info.trackingData.maj_ax;
min_ax = info.trackingData.min_ax;
identity = info.trackingData.identity;
middleX = (max(param.arenaX) + min(param.arenaX)) / 2;
mmPerPixel = param.mmPerPixel;
fileName = strcat(originalFileName(1:end - 4), '-fixed.mat');
save(fileName, 'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'timestamps', 'startframe', 'ntargets', 'middleX', 'changesGraph', 'mmPerPixel');
end

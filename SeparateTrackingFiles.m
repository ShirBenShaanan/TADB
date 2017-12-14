function SeparateTrackingFiles(fileName, arenaX, arenaY, newFileName)
param = getParameters(arenaX, arenaY);
[givenData, param, timestamps, startFrame] = createWorkingDatabase(fileName, param);
info = struct();
info.trackingData = givenData;
for i = 0:max(info.trackingData.identity)
    info = deleteOutOfArenaFlies(info, param, i);
end
generateMatFile(info, timestamps, startFrame, newFileName);
end

function [param] = getParameters(arenaX, arenaY)
param = struct('arenaX', arenaX, 'arenaY', arenaY);
param.unifiedFileMaxJumpFrames = 100;
end

function [info] = deleteOutOfArenaFlies(info, param, flyIdentity)
indexs = info.trackingData.identity == flyIdentity & ~inpolygon(info.trackingData.x_pos, info.trackingData.y_pos, param.arenaX, param.arenaY);
jumpsFrames = info.trackingData.frame(indexs);
if isempty(jumpsFrames)
    return;
end
if isequal(jumpsFrames, info.trackingData.frame(info.trackingData.identity == flyIdentity))
    info.trackingData(info.trackingData.identity == flyIdentity, :) = [];
    return;
end
firstJumpFrame = jumpsFrames(1);
for j = 2:length(jumpsFrames)
    if jumpsFrames(j) - jumpsFrames(j - 1) > 1
        lastJumpFrame = jumpsFrames(j - 1);
        [info, changed] = handleJump(info, param, firstJumpFrame, lastJumpFrame, flyIdentity);
        if changed
            return;
        end
        firstJumpFrame = jumpsFrames(j);
    end
end
[info, ~] = handleJump(info,param, firstJumpFrame, jumpsFrames(end), flyIdentity);
end

function [info, changed] = handleJump(info, param, firstJumpFrame, lastJumpFrame, flyIdentity)
changed = false;
framesChanged = lastJumpFrame - firstJumpFrame + 1;
if framesChanged > param.unifiedFileMaxJumpFrames
    indexs = info.trackingData.frame >= firstJumpFrame & info.trackingData.frame <= lastJumpFrame & info.trackingData.identity == flyIdentity;
    info.trackingData(indexs, :) = [];
    flyDisappearData = info.trackingData(info.trackingData.identity == flyIdentity & info.trackingData.frame == firstJumpFrame - 1, :);
    flyAppearData = info.trackingData(info.trackingData.identity == flyIdentity & info.trackingData.frame == lastJumpFrame + 1, :);
    if ~isempty(flyDisappearData) && ~isempty(flyAppearData)
        info.trackingData.identity(info.trackingData.identity == flyAppearData.identity & info.trackingData.frame >= lastJumpFrame, :) = max(info.trackingData.identity) + 1;
        changed = true;
    end
end
end

function generateMatFile(info, timestamps, startframe, fileName)
ntargets = countFlies(info);
x_pos = info.trackingData.x_pos;
y_pos = info.trackingData.y_pos;
angle = info.trackingData.angle;
maj_ax = info.trackingData.maj_ax;
min_ax = info.trackingData.min_ax;
identity = info.trackingData.identity;
save(fileName, 'x_pos', 'y_pos', 'angle', 'maj_ax', 'min_ax', 'identity', 'timestamps', 'startframe', 'ntargets');
end

function [count] = countFlies(info)
count = repmat(-1, length(info.trackingData), 1);
frames = info.trackingData.frame;
countNumber = 1;
for i = 2:length(info.trackingData)
    if frames(i) > frames(i - 1)
        count(i) = countNumber;
        countNumber = 1;
    else
        countNumber = countNumber + 1;
    end
end
count(end) = countNumber;
count(count == -1) = [];
end
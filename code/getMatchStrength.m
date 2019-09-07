function [ matchStrength, initialStrength, totalShift ] = getMatchStrength( blob, target )
    blob_booleans = blob > 200;
    blobSize = sum(sum(uint8(blob_booleans)));
    target_booleans = target > 200;
    targetSize = sum(sum(uint8(target_booleans)));
    
    intersection = blob_booleans & target_booleans;
    intersectionSize = sum(sum(uint8(intersection)));
    normalizedIntersectionSize1 = intersectionSize / blobSize;
    normalizedIntersectionSize2 = intersectionSize / targetSize;
    initialStrength = min(normalizedIntersectionSize1, normalizedIntersectionSize2);
    
    % try shifting the image, doing gradient descent
    % wrt match strength
    shifted_blob_booleans = blob_booleans;
    prevImprovement = 1;
    prevStrength = 0;
    totalShift = [0, 0];
    dirs = {[-1, 0], [1, 0], [0, -1], [0, 1]};
    while(prevImprovement > 0)
        bestDir = dirs{1};
        bestStrength = prevStrength;
        bestImprovement = 0;
        for(i=1:length(dirs))
            dir = dirs{i};
            shift_try = matrixShift(shifted_blob_booleans, dir, 0);
            intersection = shift_try & target_booleans;
            intersectionSize = sum(sum(uint8(intersection)));
            normalizedIntersectionSize1 = intersectionSize / blobSize;
            normalizedIntersectionSize2 = intersectionSize / targetSize;
            tryStrength = min(normalizedIntersectionSize1, normalizedIntersectionSize2);
            tryImprovement = tryStrength - prevStrength;
            if(tryImprovement > bestImprovement)
                bestDir = dir;
                bestStrength = tryStrength;
                bestImprovement = tryImprovement;
            end
        end
        shifted_blob_booleans = matrixShift(shifted_blob_booleans, bestDir, 0);
        totalShift = totalShift + bestDir;
%         bestDir
%         bestImprovement
        prevStrength = bestStrength;
        prevImprovement = bestImprovement;
    end
    matchStrength = prevStrength;
end


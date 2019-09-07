function [ shifted ] = matrixShift( data, shift, defaultValue )
    % uses circular shift, then overwrites teleported pixels with the
    % default value
    shifted = circshift(data, shift);
    [maxRow, maxCol] = size(shifted);
    rowShift = shift(1);
    colShift = shift(2);
    if rowShift > 0
        shifted(1:rowShift, :) = defaultValue;
    elseif rowShift < 0
        shifted(maxRow+rowShift:maxRow, :) = defaultValue;
    end
    
    if colShift > 0
        shifted(:, 1:colShift) = defaultValue;
    elseif colShift < 0
        shifted(:, maxCol+colShift:maxCol) = defaultValue;
    end
end


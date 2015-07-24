function [ indexes ] = findPeaksAndTroughIndexes(data, scale)
    % Returns the indexes of the input data which represent peaks and
    % troughs. 
    %
    % The scale parameter represents how many datapoints around
    % each candidate turning point to search for maxima or minima. This
    % helps to avoid false turning points.
    
    % This works by doing two things
    %
    %  1. identify candidate turning points (peaks or troughs) by looking
    %     to see where the difference between consectutive points changes
    %     sign, i.e. shifts from positive to negative. This represents a
    %     change in the direction of the gradient and therefore indicates
    %     the location of a local peak or trough
    %
    %  2. we want to avoid very local peaks or troughs in cases where the
    %     data is noisy and only locate single peaks and troughs for individual
    %     flood and ebb tides. So we look around each candidate to make
    %     sure it is a maximum or minimum of the points around it. We don't
    %     want to look too far otherwise we might find another valid peak
    %     or trough, so we use the scale argument to determine how far to
    %     check around each candidate point. The appropriate size of the scale
    %     parameter will be related to the density of the observations.
    %
    
    % Get the differences between consecutive observations
    deltas = diff(data);
    indexes = [];
    
    % Iterate through the diff and check where the sign changes (i.e.
    % passing a peak or trough), then act accordingly.
    for i = 2:size(deltas,1)
       if sign(deltas(i)) ~= sign(deltas(i-1))

           % Determine the look ahead and look back distances. In most
           % cases these will simply be equal to the scale parameter,
           % except where we are near the beginning or end of the
           % iteration.
           look_ahead = min([scale, size(deltas,1) - i]);
           look_back  = min([scale, i-1]);
           
           % Get the local values around this point
           localSequence = data(i-look_back:i+look_ahead);

           if sign(deltas(i)) == -1 % leaving peak, we are at a local maximum
               
               % Find the value of the maximum value within the local
               % sequence. If our value is the max value, we might want to
               % use it. We want to make sure there aren't two or more
               % points which happen to equal this maximum value though so
               % we don't end up with  multiple points representing the
               % same slack water (peak or trough).
               
               localMax = max(localSequence); % maximum value
               localMaxIndexes = find(localSequence == localMax);
               
               % If more than one value in the local sequence is the
               % maximum then we only want to use it if it is the last one
               % (which is just an arbitrary choice). Skip if that is not
               % the case
               if size(localMaxIndexes,1) > 1 & any(localMaxIndexes > look_back +1)
                   continue
               end
               
               if data(i) == localMax
                   indexes(end+1,1) = i;
               end
           else % leaving trough, we are at a local minimum
               
               % Use same logic as above to avoid identifying multiple
               % maxima from local sequence
               
               localMin = min(localSequence);
               localMinIndexes = find(localSequence == localMin);
               
               if size(localMinIndexes,1) > 1 & any(localMinIndexes > look_back +1)
                   continue
               end
               
               if data(i) == localMin
                   indexes(end+1,1) = i;
               end
           end
       end
    end
end


%
% CROWDING.M
%
% NSGA-II density estimator
%
% distances = crowding(popData, ranking)
%
function distances = crowding(popData, ranking);

% Get dimensions.
[noSols, noObjs] = size(popData);
[rankRows, rankCols] = size(ranking);

% Error handling.
if (rankRows ~= noSols) | (rankCols ~= 1)
   error('Inconsistent input data.');
end

% Set up the output vector.
distances = zeros(noSols, 1);

% Get maximum rank.
maxRank = max(ranking);

% Get the bounds on the objectives.
minObj = min(popData);
maxObj = max(popData);

% Perform the density estimation in a rank-wise fashion.
for rank = 0:maxRank
   % Get indices to solutions of this rank.
   solIndices = find(ranking == rank);
   
   % Only do the estimation if we have some data.
   if ~isempty(solIndices)
      
      % Grab the subset of data.
      subsetPopData = popData(solIndices, :);

      % Get the bounds on the objectives.
      %minObj = min(subsetPopData);
      %maxObj = max(subsetPopData);

      % Do the NSGA-II crowding.
      distances(solIndices) = crowdingNSGA_II(subsetPopData, minObj, maxObj);
   end
end

%infIndices = find(distances == -1);
%if ~isempty(infIndices)
%   distances(infIndices) = Inf;
%end

% Deb's method biases in favour of boundary solutions at equilibrium - not correct.
maxDistance = max(distances);
infIndices = find(distances == -1);
if ~isempty(infIndices)
   distances(infIndices) = maxDistance;
end

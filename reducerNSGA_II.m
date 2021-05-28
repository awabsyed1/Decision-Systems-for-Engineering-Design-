%
% reducerNSGA_II.M
%
% newPop = reducerNSGA_II(unifiedPop, ranks, crowdings, noToSelect)
%
% NSGA II clustering procedure.
% Selects the new parent population from the unified population
% of previous parents and offspring.
%
% This is an M-File for MATLAB.
% Written by Robin Purshouse, 23-Oct-2002
%
% Inputs: unifiedPop - the combined parent and offspring populations
%         ranks      - ranking of the combined population
%         crowdings  - density estimates (large values = more remote)
%         noToSelect - size of newPop, defaults to 1/2 unifiedPop
%
% Output: selected   - indices for the new parent population
%
% Reference: Deb, K., 2001, 'Multi-Objective Optimization using
%            Evolutionary Algorithms', Chichester: Wiley, pp233-241.

function selected = reducerNSGA_II(unifiedPop, ranks, crowdings, noToSelect)

% Check for correct number of inputs.
if nargin < 3
  error('At least three inputs are required.');
end
  
% Gather input information, and check that it's OK.
popSize = size(unifiedPop, 1);
rankSize = size(ranks, 1);
crowdingSize = size(crowdings, 1);

if popSize ~= rankSize
  error('ranks vector is not of correct size');
end

if popSize ~= crowdingSize
  error('crowdings vector is not of correct size');
end

% Generate noToSelect if not provided.
if nargin < 4
  noToSelect = floor(popSize / 2);
end

% Handle quick returns.
selected = [];
if noToSelect >= popSize
  selected = [1:popSize]';
  return;
elseif noToSelect <= 0
  return;
end

% Go through the ranks and add to the new population until we spill over.
full = 0;
currentRank = -1;
noNewPop = 0;
while(~full)
  currentRank = currentRank + 1;
  thisRank = find(ranks == currentRank);
  noThisRank = size(thisRank, 1);
  if( (noNewPop + noThisRank) < noToSelect )
    selected = [selected; thisRank];
    noNewPop = noNewPop + noThisRank;
  else
    full = 1;
  end
end

% Shuffle the front that has spilled over, and put in as many as possible
% in terms of crowding distance.
thisRank = thisRank(randperm(noThisRank)');
[reRank, reRankI] = sort(-1*crowdings(thisRank));
selected = [selected; thisRank(reRankI(1:noToSelect-noNewPop))];
%
% FSHARE.M
%
% nicheCount = fshare(population, nicheSize, ranks, alpha);
%
% Goldberg and Richardson's fitness sharing.
% Distances are Euclidean.
% Sharing is performed on a rank-wise basis.
% The function does not perform normalisation of distances.
%
% Inputs: population - a matrix,
%                      each row is an individual,
%                      each column is an objective or phenotypic 
%                      decision variable
%
%         nicheSize  - Euclidean sharing distance
%
%         ranks      - the rank associated to each individual in the 
%                      population, must be a column vector
%
%         alpha      - the sharing function parameter
%                      (defaults to 1: triangular sharing)
%
% Output: nicheCount - the niche count for each individual, which can 
%                      subsequently be used to modify the individual 
%                      fitnesses
%

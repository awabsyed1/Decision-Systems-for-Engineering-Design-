%
% btwr.m
%
% Binary tournament selection with replacement.
%
% This is a MEX-file for MATLAB.
% 
% selectThese = btwr(fitnessValues, noToSelect)
%
% Inputs: fitnessValues - N columns of fitness values
%                         (in the case of a tie in the ith column,
%                         the i+1th column is considered, etc)
%         noToSelect    - number of solutions to include in mating pool
%                         (optional, defaults to number of fitness values)
%
% Output: selectThese   - the indices of solutions to include
%
%

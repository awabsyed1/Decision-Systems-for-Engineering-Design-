%
% sbx.c
%
% Simulated Binary Crossover operator
% for real number representations.
%
% This is a MEX-file for MATLAB.
% 
% offspring = sbx(parents, bounds, nc, option, prob, exchange, uniProb)
%
% Inputs: parents   - parent population (rows of individuals)
%         bounds    - decision variable bounds (lower; upper)
%         nc        - SBX parameter
%         option    - type of crossover
%                     (-1 = modify all, 0 = uniform, n = n-point)
%         prob      - probability of crossover between a pair
%         exchange  - flag to swap variables after SBX crossover
%                     with probability 0.5
%         uniProb   - probability of internal crossover in case of
%                     uniform crossover
%
% Output: offspring - offspring population
%
% Notes: (1) Crossover is performed on pairs of individuals, 
%            in the order provided.
%        (2) The last five inputs are optional en masse, but not
%            individually. (15, 1, 0.7, 0, 0.5)
%        (3) If resulting offspring are infeasible, they are set to
%            feasible bounds.
%        (4) Different random numbers are rolled for each decision
%            variable.
%        
%
% Reference: Deb, K. and Agrawal, S., 1995, 'Simulated binary crossover
%            for continuous search space', Complex Systems, 9(2),
%            pp 115-148.
%

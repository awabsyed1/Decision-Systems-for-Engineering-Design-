%
% polymut.m
%
% Polynomial mutation operator
% for real number representations.
%
% This is a MEX-file for MATLAB.
% 
% postMute = polymut(preMute, bounds, nm, prob)
%
% Inputs: preMute   - parent population (rows of individuals)
%         bounds    - decision variable bounds (lower; upper)
%         nm        - mutation parameter
%         prob      - probability of mutation of a single phenotype
%
% Output: postMute  - offspring population
%
% Notes: (1) The last two inputs are optional en masse, but not
%            individually. (20, 1 / nPhen)
%
% Reference: Deb, K. and Goyal, M., 1996, 'A combined genetic
%            adaptive search (GeneAS) for engineering design',
%            Computer Science and Informatics, 26(4), pp30-45.
%

%-------------------Lab B -------------------------------------------%
% Author : Awabullah Syed 
% Date : 28th May 2021
% DESCRIPTION: Identify a set of controller gains that will meet the
%   prefeerences of the Chief Engineer and consider trade-off in case the
%   preferences cannot be satisfied and resolve the design problem. 

%-------------Initialize the population---------------------------------%
clc; clear;
mex sbx.c %Since toolbox written in C and wrapped using MATLAB
mex -DVARIANT=4 Hypervolume_MEX.c hv.c avl.c

load ('Sobol_Sampling') % load sobol sampling (since optimal amongst other)
load ('Full_Sampling')
load('Latin_Sampling')
P = fac_sampl; 

Z = optimizeControlSystem(P);% Re-evaluate the design using post-processed

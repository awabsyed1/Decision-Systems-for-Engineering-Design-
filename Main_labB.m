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
mex rank_nds.c
mex crowdingNSGA_II.c 

load ('Sobol_Sampling') % load  sampling 
load ('Full_Sampling')
load('Latin_Sampling')
P = X_sobol; % Selected Sobol since optimal amongst others
Z = optimizeControlSystem(P);clc;% Re-evaluate the design - post-processed
%---------------------Calculating Fitness (NSGA-II)-----------------------%
% Non-dominated Sorting 
nond_rank = rank_nds(X_sobol);clc;
%Crowding Distance 
crowding_d = crowding(X_sobol,nond_rank); clc;

%---------------------------Selection-for-Variation----------------------%


%---------------------------Performing Variation--------------------------%


%---------------------------Monitoring Convergence------------------------%

%---------------------------Plots | Results-------------------------------%


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
mex btwr.c 

load ('Sobol_Sampling') % load  sampling 
load ('Full_Sampling')
load('Latin_Sampling')
P = X_sobol; % Selected Sobol since optimal amongst others
Z = optimizeControlSystem(P);% Re-evaluate the design - post-processed
%---------------------Calculating Fitness (NSGA-II)-----------------------%
% Non-dominated Sorting 
desired_goal = [1 -6 60 -30 2 10 10 8 20 1]; 
min_range = [0 -20 -30 0 0 0 0 0 1];
max_range = [1 -6 60 2 10 10 8 20 1];
% Goal Priorities 
Hard = 0.9; 
High = 0.8;
Moderate = 0.5;
Low = 0; 
priority = [Hard High High High Moderate Low Moderate Low Low Moderate];

metric = Hypervolume_MEX(P);

number_of_objectives = 10; % number of decision variables 

n = 100; %Number of iterations 
[J,distinct_d] = jd(X_sobol,2); %Euclidean p = 2
% for i = 1:n
%     
% end

nond_rank = rank_nds(Z);
%Crowding Distance 
crowding_d = crowding(Z,nond_rank); 

% for k = 1:10
%     min_range(k) = 0.05
%     max_range(k) = 
% end
%---------------------------Selection-for-Variation----------------------%
selection = btwr([fitness,crwoding_d]);

%---------------------------Performing Variation--------------------------%
bound = [zeros(1,2);ones(1,2

%---------------------------Monitoring Convergence------------------------%

%---------------------------Plots | Results-------------------------------%


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
mex rank_prf.c
mex crowdingNSGA_II.c 
mex btwr.c 
mex polymut.c 
%%
load ('Sobol_Sampling') % load  sampling 
load ('Sobol_Space_Sampling')  %load space2 variable from lab A 
load ('Morrison_Latin_Space_Sampling') % space4 variable, Morrison

% load ('Full_Sampling')
% load('Latin_Sampling')
% P = X_sobol; % Selected Sobol since optimal amongst others

 Z = optimizeControlSystem(space4);% Re-evaluate the design - post-processed

%---------------------Calculating Fitness (NSGA-II)-----------------------%
% Non-dominated Sorting 
% Goal = [1 0 0 0 -inf 0 0 -inf -inf 0]; % 5.2.1
Goal = [1 -6 -30 60 2 10 10 8 20 1]; 
% min_range = [0 -20 -30 0 0 0 0 0 1];
% max_range = [1 -6 60 2 10 10 8 20 1];
Level = [2 1 1 1 0.8 0.5 0.8 0.5 0.5 0.8]; % Step 1 

% Goal Priorities 
Hard = 2; 
High = 1;
Moderate = 0.8;
Low = 0.5; 
priority = [Hard High High High Moderate Low Moderate Low Low Moderate];
metric = Hypervolume_MEX(space4);

number_of_objectives = 10; % number of decision variables 
number_of_decision_variables = 100; 
pop = 100; % population size 
front = 1; % Initialize the front number to 1
F(front).f = [];
individual = [];
[N,m] = size(Z); % space2 or Z 
x = Z; % space2 or Z 
V = 100; % design/decision variables 

% [J,distinct_d] = jd(space2,2); %Euclidean p = 2
iteration = zeros(250,1); 
for i = 1:150 % [N,M] = size(space2)
    pool = round(pop/2); 
    nond_rank = rank_nds(Z); % non-dominated sorting 
    fitness = max(nond_rank)-nond_rank +1;
    %Crowding Distance 
    crowding_d = crowding(Z,nond_rank); 
    % Selection for variation 
    selectTourIndex = btwr([fitness,crowding_d]);
    selectTour = space4(selectTourIndex,:);
    % Z = optimizeControlSystem(parents);
    %----------------- performing variation-------------------%
    % Simulated binary crossover 
    bounds = [0.1 0.2 ; 0.8 0.5];
    %bounds = [min(selectTour(:,1)),min(selectTour(:,2));...
        % max(selectTour(:,1)),max(selectTour(:,2))];
    offspring_sim = sbx(selectTour,bounds); 
    % Polynomial mutation 
    offspring_poly = polymut(offspring_sim,bounds); %Poly
    
    %----------------selection for survival-----------------%
    Z_offspring = optimizeControlSystem(offspring_sim);
    % Z_offspring_poly = optimizeControlSystem(offspring_poly);
    
    new_pop = [space4;offspring_poly]; % Polynomial mutation population
    % Selection for variation 
[nond_rank_poly,fitness_poly,crowding_d_poly,Class] = evaluate(new_pop,Goal,Level);
    
    % Selection for Survival 
    survivor = reducerNSGA_II(new_pop,nond_rank_poly,crowding_d_poly);
        
    iteration(i) = i;
    % use the survivor (after elitism) as new population
    space4 = new_pop(survivor,:);
   %  new_pop_indix = reducerNSGA_II(new_pop_sim,nond_rank_sim,
end 

% Monitor 
HV = Hypervolume_MEX(space4); 

Z1 = optimizeControlSystem(space4); 
% Z2 = evaluateControlSystem(space4);
figure(1)
parallelcoords(Z1)
title('Parallel Coordinates Step 3: 150 iterations with Actual Goals')
xlabel('Performance Criteria ')
print('-clipboard','-dmeta')
% glyphplot(Z1,'glyph','face','features',[1:10]);

figure(2)
gplotmatrix(Z1)  % ,space4)
title('Scatter Step 3: 150 Iterations with Actual Goals')
ylabel('Performance criteria value')
xlabel('Performance criteria value')
print('-clipboard','-dmeta')

figure(3)
glyphplot(Z1,'glyph','face','features',[1:10]);
title('Chernoff Face Step 3 with Actual Goals ')
print('-clipboard','-dmeta')

%-------------------------------------End of Lab B-----------------------%
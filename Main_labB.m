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
% load ('Full_Sampling')
% load('Latin_Sampling')
% P = X_sobol; % Selected Sobol since optimal amongst others

Z = optimizeControlSystem(space2);% Re-evaluate the design - post-processed

%---------------------Calculating Fitness (NSGA-II)-----------------------%
% Non-dominated Sorting 
% Goal = [1 0 0 0 -inf 0 0 -inf -inf 0]; % 5.2.1
Goal = [1 -6 60 -30 2 -inf 10 inf inf 1]; 
% min_range = [0 -20 -30 0 0 0 0 0 1];
% max_range = [1 -6 60 2 10 10 8 20 1];
Level = [1 0 0 0 0 0 0 0 0 0]; % 5.2.1
% Goal Priorities 
Hard = 2; 
High = 1;
Moderate = 0.8;
Low = 0.5; 
priority = [Hard High High High Moderate Low Moderate Low Low Moderate];
metric = Hypervolume_MEX(space2);

n = 50; %Number of iterations / generations 
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
for i = 1:100 % [N,M] = size(space2)
    pool = round(pop/2); 
    nond_rank = rank_nds(Z); % non-dominated sorting 
    fitness = max(nond_rank)-nond_rank +1;
    %Crowding Distance 
    crowding_d = crowding(Z,nond_rank); 
    % Selection for variation 
    selectTourIndex = btwr([fitness,crowding_d]);
    selectTour = space2(selectTourIndex,:);
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
    
    new_pop = [space2;offspring_poly]; % Polynomial mutation population
    % Selection for variation 
[nond_rank_poly,fitness_poly,crowding_d_poly,Class] = evaluate(new_pop,Goal,Level);
    
    % Selection for Survival 
    survivor = reducerNSGA_II(new_pop,nond_rank_poly,crowding_d_poly);
        
    iteration(i) = i;
    % use the survivor (after elitism) as new population
    space2 = new_pop(survivor,:);
   %  new_pop_indix = reducerNSGA_II(new_pop_sim,nond_rank_sim,
end 

% Monitor 
HV = Hypervolume_MEX(space2); 

Z1 = optimizeControlSystem(space2); 
Z2 = evaluateControlSystem(space2);
figure(1)
parallelcoords(Z1)
title('Parallel Coordinates')
xlabel('criterias')

figure(2)
gplotmatrix(Z1,space2)
title('Scatter ')

figure(3)
glyphplot(Z1,space2)
title('Scatter ')

    % Extract_survivor = new_pop(survivor,:); 
%     Class = Class(survivor,:);
%%
% Different (updated)
for i = 1:25 %number of iterations 
    nond_rank = rank_nds(Z);
    fitness = max(nond_rank)-nond_rank;

    %Crowding Distance 
    crowding_d = crowding(space2,nond_rank); 
    %---------------------------Selection-for-Variation----------------------%
    selectTourIndex = btwr([fitness,crowding_d]);
    selectTour = space2(selectTourIndex,:);
    %---------------------------Performing Variation--------------------------%   
     % bound = [min(P(:,1)),min(P(:,2));max(P(:,1)),max(P(:,2))];
    %bound = [zeros(1,2);ones(1,2)];
    bound = [min(selectTour(:,1)),min(selectTour(:,2));...
        max(selectTour(:,1)),max(selectTour(:,2))];
    
    child_sbx = sbx(selectTour,bound);
    child_plymut = polymut(child_sbx,bound); 
    %--------------------------Selection-for-Survival---------------------%
    Z_child = optimizeControlSystem(child_sbx); 

    pop_unified = [space2;child_plymut];
    [ndrank_unified,~,unified_crowd] = selectVar(pop_unified);
%     ndrank_unified = rank_nds(pop_unified); 
%     unified_fitness = max(ndrank_unified)-ndrank_unified; 
%     unified_crowd = crowding(pop_unified,ndrank_unified);
   % pop = reducerNSGA_II(pop_unified, ndrank_unified, unified_crowd);
    %-----------------NSGA-II Selection for survivor---------------------%
   survivorindex = reducerNSGA_II(pop_unified,ndrank_unified,unified_crowd); 
   survivor = pop_unified(survivorindex);

   %  P = survivor; % New population 
end
HV = Hypervolume_MEX(space2); % Monitor 

Z = optimizeControlSystem(space2);
figure(1)
parallelcoords(Z)
title('Parallel Coordinates')
xlabel('criterias')
%%
for j = 1:100
    % create indices vector
    index = pop(j);
    % extract survivors
    Survivor(j,:) = pop_unified(index,:);    
end

for i = 1:250
    Z(100*(i-1)+1:100*i,:) = optimizeControlSystem(Survivor);
end
figure(1)
parallelcoords(Z)
title('Parallel Coordinates')
xlabel('criterias')
%% 
%%  Second Attempt 
load Sobol_Sampling
P = X_sobol;
% evaluate design choices
% Z = optimizeControlSystem(P);

% NSGA-II optimisor iteration

for i = 1:250
    % call function for optimizer
    Survivor = optimizer(space2);
    % use the survivor (after elitism) as new population
    space2 = Survivor;
end

% monitor convergence by Hypervolume_MEX
%HV = Hypervolume_MEX(P);

% %% visualise the trade-off among criteria
Z = optimizeControlSystem(P);
figure(1)
parallelcoords(Z)
title('Parallel Coordinates')
xlabel('criterias')
% %%
figure(2)
gplotmatrix(Z,P)
title('Sobol')



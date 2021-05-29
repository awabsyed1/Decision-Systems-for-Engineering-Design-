function Survivor = optimizer(P)
    % calculate fitness for NSGA-II optimiser
    [~,fitness,crowdingd] = selectVar(P);
    
    % Selection for variation (Tournament selection)
    selectTourIndex = btwr([fitness,crowdingd]);
    % extract corresponding variables by Tournament selection
    selectTour = P(selectTourIndex,:);

    % Variation 
    bound = [min(selectTour(:,1)),min(selectTour(:,2));...
        max(selectTour(:,1)),max(selectTour(:,2))];
    % Simulated binary crossover
    child_sbx = sbx(selectTour,bound);
    % polynomial mutation
    child_polymut = polymut(child_sbx,bound);

    % Selection-for-survival
    % Z_child = optimizeControlSystem(child_sbx);

    % check the rank and fitness of all designs
    P_unified = [P;child_polymut];
    [ndrank_unified,~,crowdingd_unified] = ...
        selectVar(P_unified);
    % NSGA-II Selection for survivor
    SurvivorIndex = reducerNSGA_II(P_unified, ndrank_unified,...
        crowdingd_unified);

    % extract the survivors by their indices
    Survivor = P_unified(SurvivorIndex,:);
end

% function for selection for variation
function [ndrank,fitness,crowdingd] = selectVar(P)
    % calculate fitness for NSGA-II optimiser
    % Non-dominance sorting
    ndrank = rank_nds(P);
    fitness = max(ndrank)-ndrank;
    % Crowding distance
    crowdingd = crowding(P,ndrank);
end
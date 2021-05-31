function [ndrank,fitness,crowding_d,ClassV] = evaluate(P,GoalV,PriorityV)
    % calculate fitness for NSGA-II optimiser
    % Non-dominance sorting of overall  population
   %  [ndrank] = rank_nds(P);
   Z = optimizeControlSystem(P);
   [ndrank,ClassV] = rank_prf(Z, GoalV, PriorityV);
    fitness = max(ndrank)-ndrank +1;
    % Crowding distance
    crowding_d = crowding(Z,ndrank);
end
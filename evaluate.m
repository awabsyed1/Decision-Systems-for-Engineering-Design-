function [ndrank,fitness,crowding_d] = evaluate(P)
    % calculate fitness for NSGA-II optimiser
    % Non-dominance sorting of overall  population
    [ndrank] = rank_nds(P);
    fitness = max(ndrank)-ndrank;
    % Crowding distance
    crowding_d = crowding(P,ndrank);
end
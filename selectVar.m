% function for selection for variation
function [ndrank,fitness,crowdingd] = selectVar(P)
    % calculate fitness for NSGA-II optimiser
    % Non-dominance sorting
    ndrank = rank_nds(P);
    fitness = max(ndrank)-ndrank;
    % Crowding distance
    crowdingd = crowding(P,ndrank);
end
%RANK_PRF       Rank points according to given preferences
%
%       Syntax:
%               [RankV, ClassV] = rank_prf(ObjV, GoalV, PriorityV);
%
%       This function ranks vectors (rows of ObjV) according to their
%       "utility", given a set of goals (GoalV) and the objectives'
%       priority (PriorityV), assuming a minimization problem. RankV is
%       a column vector containing the rank values (rank 0 is best).
%
%       Zero priority corresponds to a standard objective to be minimized. A
%       priority of 1 defines a hard constraint, which has to be met, but
%       not minimized once met. Higher prioritiy values define higher priority
%       hard constraints. ClassV is a column vector containing the highest
%       level of priority which the individual violates. Satisfying points
%       are classified -1 (meet all levels of priority).
%
%       GoalV is optional and defaults to [oo ... oo].
%       PriorityV is optional and defaults to [0 ... 0].

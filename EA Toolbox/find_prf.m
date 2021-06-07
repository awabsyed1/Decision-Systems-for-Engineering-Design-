%FIND_PRF       Find preferred points
%
%       Syntax:
%                      ix = find_prf(ObjV, GoalV, PriorityV);
%
%       The function returns a zero-one column vector (ix) which indexes the
%       preferred rows of ObjV, given a set of goals (GoalV) and the
%       objectives' priority (PriorityV), assuming a minimization problem.
%
%       Zero priority corresponds to a standard objective to be minimized. A
%       priority of 1 defines a hard constraint, which has to be met, but
%       not minimized once met. Higher prioritiy values define higher priority
%       hard constraints.
%
%       GoalV is optional and defaults to [oo ... oo].
%       PriorityV is optional and defaults to [0 ... 0].

% Author: Carlos Fonseca
% 	  Unversity of Sheffield
%	  10 March 1995

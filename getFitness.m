%RANKING        Generalized rank-based fitness assignment
%
%       Syntax:
%               FitnV = getFitness(CostV, RFun, ShareC)
%
%       This function ranks individuals represented by their associated
%       cost, to be *minimized*, and returns a column vector FitnV
%       containing the corresponding individual fintesses.
%
%       RFun is an optional vector containing the fitness to be
%       assigned to each rank. It should have the same length as CostV,
%       and will usually be monotonically increasing.  If RFun is a
%       scalar greater than 1, exponential ranking is assumed, and it
%       indicates selective pressure. If RFun is a scalar between
%	-1 and -2, linear ranking is assumed with selective pressure equal
%	to -RFun.  If RFun is missing or is an empty matrix, exponential
%	ranking and a selective pressure of e=exp(1) are assumed.
%
%       Individuals with exactly the same cost are assigned the average
%       of their original fitness. This average can then be affected by
%       supplying the optional column vector ShareC, in which case
%       fitness sharing is performed within each set of individuals
%       with the same cost.
%
%	NOTE: To avoid computing RFun at every call to ranking,
%	which my take some time for selective pressure close to unity,
%	the following calling sequence may be used:
%
%	RFun = (selective pressure);
%	for i=1:MAXGEN
%		...
%		[FitnV,RFun]=ranking(CostV,RFun);
%		...
%	end
%
%       However, selective pressures that close to unity are not very
%	useful...

% Author: Carlos Fonseca
% 	  Unversity of Sheffield
%	  10 March 1995

% Don't normalise wrt to sharing counts - RCP 22-May-2001

function [FitnV,RFun] = getFitness(CostV, RFun, ShareC);

[Nind,ncols] = size(CostV);

if ncols ~= 1,
	error('CostV must be a column vector');
end

if exist('RFun')~=1, RFun = []; end
if exist('ShareC')~=1, ShareC = []; end

% Check ranking function and use default values if necessary
if isempty(RFun),
        RFun = exp(1);
end
if prod(size(RFun)) == 1,
	if (RFun >= 1) & (RFun <= Nind),
		% This would take a long time for large Nind
		% rr = roots([RFun*ones(1,Nind-1) RFun-Nind]);
		% rr = rr(abs(rr)==rr);

		% A faster alternative is iteration
		rr0 = eps;
		rr = 1-RFun/Nind;
		while(abs(rr/rr0-1) >= eps); % Iterate till machine's precision
					     % is reached.
			rr0 = rr;
			rr = 1-RFun/Nind*(1-rr0^Nind);
		end
		RFun = RFun * rr.^(Nind-1:-1:0);
	elseif (RFun <= -1) & (RFun >= -2)
		RFun = 2+RFun - 2*(RFun+1)*[0:Nind-1]'/(Nind-1);
	else
                error('Invalid selective pressure');
	end
end;

if isempty(ShareC),
        ShareC = ones(Nind,1);
end

% Sort does not handle NaN values as required. So, find those...
NaNix = isnan(CostV);
Validix = find(~NaNix);
% ... and sort only numeric values (smaller is better).
[ans,ix] = sort(-CostV(Validix));

% Now build indexing vector assuming NaN are worse than numbers,
% (including Inf!)...
ix = [find(NaNix) ; Validix(ix)];
% ... and obtain a sorted version of CostV and the Weights to be
% used later.
SortedC = CostV(ix);
Weights = 1 ./ ShareC(ix);

% Assign fitness according to RFun.
i = 1;
FitnV = zeros(Nind,1);
for j = [find(SortedC(1:Nind-1) ~= SortedC(2:Nind)); Nind]',
  % For all solns of same cost (==rank), take mean fitness and apply sharing. (RCP)
  FitnV(i:j) = mean(RFun(i:j)) * Weights(i:j);
  % RCP FitnV(i:j) = sum(RFun(i:j)) .* Weights(i:j) ./ sum(Weights(i:j));
  i =j+1;
end

% Finally, return unsorted vector.
[ans,uix] = sort(ix);
FitnV = FitnV(uix);

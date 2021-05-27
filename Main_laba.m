%-------------------Lab A -------------------------------------------%
% Author : Awabullah Syed 
% Date : 21th May 2021
% Description : Explore the design space for the problem - revealing the
%   relationships that exist between design variables and performance
%   criteria and communicating these relathiships clearly through
%   visualisation methods
clc; clear; 
ts = 1; 
z = tf('z',ts);
% Gains 
Kp = [0.1 ]; 
Ki = [0.2 ];  
K = [Kp Ki];

for i = 1:100
    Z(i,:) = evaluateControlSystem(K);
end
%---------------------Sampling Plan------------------------------%
k = 2;  %No. of design variables 
n = 100; % No. of desired points 
% Full Factorial Sampling Plan
q = [2,50];
edge = 2; 
fac_sampl = fullfactorial(q,edge); % full factorial sampling plan 
% Latin Hypercube Design Sampling Plan
latin_hyper = rlh(n,k,edge); % Latin hypercube design 
% Sobol Sampling 
p = sobolset(k); 
p.Skip = 1; %Skip first row 
X_sobol = net(p,100); % Sobol Sampling 
%---------------------------------Phi Metric-----------------------%
phiq_fac = mmphi(fac_sampl,1,2); % Full factorial [Euclidean Distance]
phiq_latin = mmphi(latin_hyper,1,2); % Latin Hypercube design 
phiq_sobol = mmphi(X_sobol,1,2); % Sobol Sampling

disp(phiq_fac) 
disp(phiq_latin)
disp(phiq_sobol)
%------------------------------Plot--------------------------------------%
figure (1) % Scatter Plot with Latin Hypercube sampling plan
Z1 = evaluateControlSystem(latin_hyper);
gplotmatrix(Z1)
title('Scatter Plot: Latin Hypercube Sampling Plan') 
figure(2) % Scatter Plot with Full Factorial sampling plan
Z2 = evaluateControlSystem(fac_sampl);
gplotmatrix(Z2)
title('Scatter Plot: Full Factorial Sampling Plan')
figure (3) % Scatter Plot with Sobol Sampling Plan
Z3 = evaluateControlSystem(X_sobol);
gplotmatrix(Z3)
title('Scatter Plot: Sobol Sampling Plan')

figure(4) % with Initial system (Kp & Ki)
for i = 1:9
gplotmatrix(Z,[],Z(:,i))
end
title('Initial System [Without Sampling Plan]')

figure(5)
plot(1:100,clusterdata(Z1,1),'o') % Latin 
hold on
plot(1:100,clusterdata(Z2,1),'o') % full factorial 
hold on
plot(1:100,clusterdata(Z3,1),'o') % sobol
legend('Latin Hyper','Full !','Sobol')

figure (6) % Star Plot with different sampling plan
subplot(1,3,1)
glyphplot(Z1)
title('Star Plot: Latin Hypercube Sampling Plan')
subplot(1,3,2)
glyphplot(Z2)
title('Star Plot: Full Factorial Sampling Plan')
subplot(1,3,3)
glyphplot(Z3)
title('Star Plot: Sobol Sampling Plan')

figure (7) % x-axis = performance critera , y-axis = Kp(top) & Ki(bottom)
group = []; % Sobol Scatter Sobol Scatter 
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z3,X_sobol,group)
title('Scatter Plot with Sobol Sampling Plan')

figure (8) % Full Factorial Sampling Plan Scatter 
group = [];
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z2,fac_sampl,group)
title('Scatter Plot with Full Factorial Sampling Plan')

figure (9) % Latin Hyper Cube 
group = []; 
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z1,latin_hyper,group)
title('Scatter Plot with Latin Hypercube Sampling Plan')


% Try parallelcoords

% glyphplot(Z);
% glyphplot(fac_sampl(2,:),Z(1,:))
% gplotmatrix(fac_sampl(2,:),Z(1,:))

%---------------Knowledge Discovery-------------------------%
%%
labels = {'z1','z2','z3','z4','z5','z6','z7','z8','z9'};
for j = 1:100
    parallelcoords(Z(j,:))
end

% for j = 1:9 
%     for k = 1:100
%     parallelcoords(Z(j,:),'Group',Z1(:,k),'Labels',labels)
%     end
% end
figure (2) 
glyphplot(Z');

num = ((1-exp(-1))*(Kp + Ki)*z-Kp);
den = z^2*(z-exp(-1))*(z-1);
sys = num / den; 

%fimplicit 
% fsurf@ 






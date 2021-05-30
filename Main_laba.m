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
% Gains (compare with stable and unstable system - if deemed necessary) 
k = 2;  %No. of design variables 
n = 100; % No. of desired points 

% Kp = [0.1]; 
% Ki = [0.2]; 

KpMin = 0.1; KpMax = 0.9;
KiMin = 0.2; KiMax = 0.4; 

K = [Kp Ki];
for i = 1:100
    Z(i,:) = evaluateControlSystem(K);
end
% Sobol Sampling 
p = sobolset(k); 
p.Skip = 1; %Skip first row 
X_sobol = net(p,100); % Sobol Sampling 

design_space = fullfactorial ([2 50]); %Fulll Factorial [2 50]
design_space1 = rlh(n,k); % Latin 

space(:,1) = rescale(design_space(:,1),KpMin,KpMax); % Full Factorial
space(:,2) = rescale(design_space(:,2),KiMin,KiMax);

space1(:,1) = rescale(design_space1(:,1),KpMin,KpMax); % Latin 
space1(:,2) = rescale(design_space1(:,2),KiMin,KiMax); 

space2(:,1) = rescale(X_sobol(:,1),KpMin,KpMax);
space2(:,2) = rescale(X_sobol(:,2),KiMin,KiMax); % Sobol

phiq_fac = mmphi(space,1,2); % Full factorial [Euclidean Distance]
phiq_latin = mmphi(space1,1,2); % Latin Hypercube design 
phiq_sobol = mmphi(space2,1,2); % Sobol Sampling

disp(phiq_fac) 
disp(phiq_latin)
disp(phiq_sobol)

figure (1) % Scatter Plot with Latin Hypercube sampling plan
Z1 = evaluateControlSystem(space1);
gplotmatrix(Z1)
title('Scatter Plot: Latin Hypercube Sampling Plan') 
figure(2) % Scatter Plot with Full Factorial sampling plan
Z2 = evaluateControlSystem(space);
gplotmatrix(Z2)
title('Scatter Plot: Full Factorial Sampling Plan')
figure (3) % Scatter Plot with Sobol Sampling Plan
Z3 = evaluateControlSystem(space2);
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
gplotmatrix(Z3,space2,group)
title('Scatter Plot with Sobol Sampling Plan')

figure (8) % Full Factorial Sampling Plan Scatter 
group = [];
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z2,space,group)
title('Scatter Plot with Full Factorial Sampling Plan')

figure (9) % Latin Hyper Cube 
group = []; 
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z1,space1,group)
title('Scatter Plot with Latin Hypercube Sampling Plan')
%--------------------Space Filling Plots--------------------------------%
% Visually Compare Phi metric value
figure (10)
plot(space(:,1),space(:,2),'o')
title('Space Filling of Full Factorial')

figure(11)
plot(space1(:,1),space1(:,2),'o')
title('Space Filling of Latin Hypercube')

figure (12)
plot(space2(:,1),space2(:,2),'o')
title('Space Filling of Sobol Plan')
%-----------------------------Parallel Coordinates---------------------%
% Select the optimal sampling plan & then only used that to plot the
%   parallel coordinates plot 
figure (13) 
parallelcoords(Z1)
xlabel ('Performance Criteria') 
title('Latin Hypercube sampling')

save Sobol_Space_Sampling.mat space2 % To be used in lab B 
save Latin_Space_Sampling.mat space1 % To be used in Lab B 
save Full_Space_Sampling.mat space % % To be used in Lab B
%%
% Previous 
%---------------------Sampling Plan------------------------------%
% Full Factorial Sampling Plan
q = [2,50];
edge = 2; 
fac_sampl = fullfactorial(q,edge); % full factorial sampling plan
% Latin Hypercube Design Sampling Plan
latin_hyper = rlh(n,k,edge); % Latin hypercube design 
%---------------------------------Phi Metric-----------------------%
phiq_fac = mmphi(fac_sampl,1,2); % Full factorial [Euclidean Distance]
phiq_latin = mmphi(latin_hyper,1,2); % Latin Hypercube design 
phiq_sobol = mmphi(X_sobol,1,2); % Sobol Sampling

disp(phiq_fac) 
disp(phiq_latin)
disp(phiq_sobol)
%%
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
%--------------------Space Filling Plots--------------------------------%
% Visually Compare Phi metric value
figure (10)
plot(fac_sampl(:,1),fac_sampl(:,2),'o')
title('Space Filling of Full Factorial')

figure(11)
plot(latin_hyper(:,1),latin_hyper(:,2),'o')
title('Space Filling of Latin Hypercube')

figure (12)
plot(X_sobol(:,1),X_sobol(:,2),'o')
title('Space Filling of Sobol Plan')
%-----------------------------Parallel Coordinates---------------------%
% Select the optimal sampling plan & then only used that to plot the
%   parallel coordinates plot 
figure (13) 
parallelcoords(Z1)
xlabel ('Performance Criteria') 
title('Latin Hypercube sampling')

save Sobol_Sampling.mat X_sobol % To be used in lab B 
save Latin_Sampling.mat latin_hyper % To be used in Lab B 
save Full_Sampling.mat fac_sampl % % To be used in Lab B






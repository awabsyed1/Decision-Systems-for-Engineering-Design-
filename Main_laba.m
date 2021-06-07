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

Kp = [0.1]; 
Ki = [0.2]; 

KpMin = 0.01; KpMax = 0.9; %0.9
KiMin = 0.02; KiMax = 0.4;  % 0.4

K = [Kp Ki];
for i = 1:100
    Z(i,:) = evaluateControlSystem(K);
end
num = ((1-exp(-1))*(Kp + Ki)*z - Kp);
den = z^2*(z-exp(-1))*(z-1);
sys = num / den;
% Sobol Sampling 
p = sobolset(k); 
p.Skip = 1; %Skip first row 
X_sobol = net(p,100); % Sobol Sampling 

design_space = fullfactorial ([10 10],1); %Fulll Factorial [2 50]
design_space1 = rlh(n,k); % Latin 

pert_fac = perturb(design_space,25); % Pertubed full fac by 25 numbers 
% best_latin = bestlh(n,k, 100, 250); [save Morrison_Sampling.mat]
load Morrison_Sampling.mat % To avoid running everytime 

space(:,1) = rescale(design_space(:,1),KpMin,KpMax); % Full Factorial
space(:,2) = rescale(design_space(:,2),KiMin,KiMax);

space1(:,1) = rescale(design_space1(:,1),KpMin,KpMax); % Latin 
space1(:,2) = rescale(design_space1(:,2),KiMin,KiMax); 

space2(:,1) = rescale(X_sobol(:,1),KpMin,KpMax);
space2(:,2) = rescale(X_sobol(:,2),KiMin,KiMax); % Sobol

space3(:,1) = rescale(pert_fac(:,1),KpMin,KpMax);
space3(:,2) = rescale(pert_fac(:,2),KiMin,KiMax); 

space4(:,1) = rescale(best_latin(:,1),KpMin,KpMax);
space4(:,2) = rescale(best_latin(:,2),KiMin,KiMax); 

phiq_fac = mmphi(space,1,2); % Full factorial [Euclidean Distance]
phiq_latin = mmphi(space1,1,2); % Latin Hypercube design 
phiq_sobol = mmphi(space2,1,2); % Sobol Sampling
phiq_pert = mmphi(space3,1,2); % Full Fac Perturbed 
phiq_opt = mmphi(space4,1,2); % Best Optimal latin 

disp(phiq_fac) 
disp(phiq_latin)
disp(phiq_sobol)
disp(phiq_pert)
disp(phiq_opt); 


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

figure (4) % Morrison Hypercube 
Z4 = evaluateControlSystem(space2);
gplotmatrix(Z4)
title('Scatter Plot: Morris Latin Hypercube')
print('-clipboard','-dmeta')
 
figure(5) % with Initial system (Kp & Ki)
for i = 1:9
gplotmatrix(Z,[],Z(:,i))
end
title('Initial System [Without Sampling Plan]')

figure(6)
plot(1:100,clusterdata(Z4,1),'o') % Latin 
hold on
plot(1:100,clusterdata(Z2,1),'o') % full factorial 
hold on
plot(1:100,clusterdata(Z3,1),'o') % sobol
legend('Latin Hyper','Full !','Sobol')

figure (7) % Star Plot with different sampling plan
glyphplot(Z4,'glyph','face','features',[1:9]);
title('Chernoff Face Plot of 100 Candidate Design')
print('-clipboard','-dmeta')

% subplot(1,3,1)
% glyphplot(Z4,'glyph','face','features',[1:9],'standardize','PCA')
% glyphplot(Z1)
% title('Star Plot: Latin Hypercube Sampling Plan')
% subplot(1,3,2)
% glyphplot(Z2)
% title('Star Plot: Full Factorial Sampling Plan')
% subplot(1,3,3)
% glyphplot(Z3)
% title('Star Plot: Sobol Sampling Plan')

figure (8) % x-axis = performance critera , y-axis = Kp(top) & Ki(bottom)
group = []; % Sobol Scatter Sobol Scatter 
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z3,space2,group)
title('Scatter Plot with Sobol Sampling Plan')

figure (9) % Full Factorial Sampling Plan Scatter 
group = [];
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z2,space,group)
title('Scatter Plot with Full Factorial Sampling Plan')

figure (10)  
group = []; 
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z4,space4,group)
title('Scatter Plot Morrison Latin Hypercube')
print('-clipboard','-dmeta')
%--------------------Space Filling Plots--------------------------------%
% Visually Compare Phi metric value
figure (11)
plot(space(:,1),space(:,2),'o')
title('Space Filling of Full Factorial')
xlabel('Design Variable, x_1 (K_p)')
ylabel('Deisgn Variable, x_2 (K_i)')

figure (12)
plot(space3(:,1),space3(:,2),'o')
title('Space Filling of Perturbed Full Factorial')
xlabel('Design Variable, x_1 (K_p)')
ylabel('Deisgn Variable, x_2 (K_i)')

figure(13)
plot(space1(:,1),space1(:,2),'o')
title('Space Filling of Random Latin Hypercube')
xlabel('Design Variable, x_1 (K_p)')
ylabel('Deisgn Variable, x_2 (K_i)')

figure (14) % Optimal Latin Hyper 
plot(space4(:,1),space4(:,2),'o')
title('Space Filling of Morris-Mitchell optimum plan q =50')
xlabel('Design Variable, x_1 (K_p)')
ylabel('Deisgn Variable, x_2 (K_i)')

figure (15)
plot(space2(:,1),space2(:,2),'o')
title('Space Filling of Sobol Plan')
xlabel('Design Variable, x_1 (K_p)')
ylabel('Deisgn Variable, x_2 (K_i)')
%-----------------------------Parallel Coordinates---------------------%
% Select the optimal sampling plan & then only used that to plot the
%   parallel coordinates plot 
figure (16) 
parallelcoords(Z4)
xlabel ('Performance Criteria') 
title('Correlation between Designs and Performance Criteria')
print('-clipboard','-dmeta')

save Sobol_Space_Sampling.mat space2 % To be used in lab B 
save Latin_Space_Sampling.mat space1 % To be used in Lab B 
save Full_Space_Sampling.mat space % % To be used in Lab B
save Morrison_Latin_Space_Sampling.mat space4
% csvwrite('Z.csv',space4) % to be used for d3JS

%-------------------------------------End of Lab A----------------------%
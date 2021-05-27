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

Kp = [0.1 ]; % 0.1
Ki = [0.2 ];  % 0.2
K = [Kp Ki];

for i = 1:100
    Z(i,:) = evaluateControlSystem(K);
end

%---------------------Sampling Plan------------------------------%
q = [2,50];
edge = 2; 
fac_sampl = fullfactorial(q,edge); % full factorial sampling plan 
k = 2;  %No. of design variables 
n = 100; % No. of desired points 
latin_hyper = rlh(n,k,edge); % Latin hypercube design 
p = sobolset(k); % Sobol Sampling 
p.Skip = 1;
X_sobol = net(p,100); 

%---------------------------------Phi Metric-----------------------%
phiq_fac = mmphi(fac_sampl,1,2); % Full factorial [Euclidean Distance]
phiq_latin = mmphi(latin_hyper,1,2); % Latin Hypercube design 
phiq_sobol = mmphi(X_sobol,1,2); % Sobol Sampling

disp(phiq_fac) 
disp(phiq_latin)
disp(phiq_sobol)

figure (1)
Z1 = evaluateControlSystem(latin_hyper);
gplotmatrix(Z1)
figure(2)
Z2 = evaluateControlSystem(fac_sampl);
gplotmatrix(Z2)
figure (3)
Z3 = evaluateControlSystem(X_sobol);
gplotmatrix(Z3)

figure(4) % with Initial system (Kp & Ki)
for i = 1:9
gplotmatrix(Z,[],Z(:,i))
end
figure(5)
plot(1:100,clusterdata(Z1,1),'r') % Latin 
hold on
plot(1:100,clusterdata(Z2,1),'b') % full factorial 
hold on
plot(1:100,clusterdata(Z3,1),'g') % sobol
legend('Latin Hyper','Full !','Sobol')
figure (6) 
glyphplot(Z3)
title('Sobol')

figure (7) % x-axis = performance critera , y-axis = Kp(top) & Ki(bottom)
group = [];
for i = 1:100
    group(i,:) = [1, 2];
end
gplotmatrix(Z3,X_sobol,group)
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






# Decision-Systems-for-Engineering-Design-
Sampling Plans | Knowledge Discovery | Optimization | NSGA-II Genetic Algorithm | Decision Support

This report aims to explore the optimal tuning parameter for a PI Controller via a Multi-Objective Optimization approach amalgamated with the deduced optimal sampling plan and the NSGA-II Genetic algorithm as a decision-making tool for the engineering design problem. The problem was Initialized via Matlab to deduce a [0.9 0.4] and [0.01 0.02] as the maximum and minimum range of decision variable, K_p and K_I, respectively. The procedure involved progressively incorporating goals and priority of the performance criteria provided by the Chief of Engineer. The candidate designs obtained from the 250 iterations (generation) of the NSGA-II algorithm were extensively analyzed to determine the trade-off and harmonious relationship between performance criteria. Several potential designs were extracted (Table 3), none of the candidate designs met the desired Rise Time and Gain Margin criteria. The Chief of Engineering will require to reconsider the Rise Time while taking the trade-off between the performance criteria into considerations as well as potentially considering Gain Margin as a Hard constraint. Design 1 with the [K_p  K_I ] gain of [0.2148 0.2384] was selected as an optimal candidate based upon it effectively meeting all performance criteria except those explained above. Design 4, [0.1106 0.2128] was considered as the second-best option. The approach used to deduce the tuning parameter of the PI controller can also be extended to examine the suitable controller for the propulsion engine via considering the Simulink model as a ‘black-box’ system. Lastly, several examples are also provided where the Multi-objective optimization technique is implemented as a decision-making tool in the automotive industry for vehicle design along with potential decision systems tool that could potentially be utilized for vehicle design problem though, this greatly depends on the type of problem at hand. 

## [Multi-Objective Optimization for Engineering Design] 

In this section, optimal tuning parameter of the controller for the propulsion engine was deduced to ensure optimal performance of the system with respect to set/desired specification. 

The classical approach where the decision is based on expert opinion incorporated with the *Trial and Error* method along with prototyping to run multiple simulations hinders the selection of the optimal design while also being costly (Not to mention - it is also quite venerable to human error). Hence, from business and decision-making acumen, it is indisputable to move away from the classical approach and towards the modern approach of imlemting *Multi-Objective Optimization method*, an offline decision-making procedure implemented via a cheap-to-evaluate *surrogate* model that emulates the response and considers the complex engineering systems as a *black-box*. 

### [NSGA II - Developing an electric vehicle with two main goals and three adjustable parameters] 

![image](https://user-images.githubusercontent.com/42310216/146129278-0234c652-8aea-4a93-9f6c-286d20518e7e.png)


#### [Battery Consideration]

![image](https://user-images.githubusercontent.com/42310216/146129329-be3dd62c-250b-436c-89b8-89e2a776a4ff.png)


### [Sampling Plan] 
Various sampling plans were considered to construct the design space, ranging from random to *Sobol* to *Perturbed Full Factorial*. 
Each sampling plans were compared and the optimal that took full advantage of design space was carried forward. 

## [Knowledge Discovery] 
### [Chernoff Face Plot]
Several types of plots were considered, the Chernoff Face Plot shown below displays 100 candidate design solutions with facial features depicting the relevant performance critera. 
![image](https://user-images.githubusercontent.com/42310216/146129679-4b5fc677-05da-4518-9caa-91a53c08b8bb.png)

![image](https://user-images.githubusercontent.com/42310216/146129712-5e0cde41-4f53-41cb-9f69-4e97e17218d0.png)

### [Parallel Coordinate Plot]
Parallel Coordinate plot was also considered to gain an insight into the relationship between the pair of design variable and the performance criteria. This is further explained/analyzed in the report. 

![image](https://user-images.githubusercontent.com/42310216/146130011-6ed80f53-81f8-46ed-812d-fcb87d025346.png)


### [Morrison Latin Hypercube]
Scatter plot of the candidate designs with the Morrison Latin Hypercube design space was plotted with each column representing the performance criteria. 
The plot is divided into two horizontal sections, the upper horizontal shows the stability region of the design variable, Kp, while the lower section represents, Ki. 

![image](https://user-images.githubusercontent.com/42310216/146130190-09da84a4-0825-41b6-8f13-29b1f07a18f3.png)

## [Implementing MSGA-II for Optimization] 
To construct a *Multi-Objective Problem*, a bio-inspired population-based optimizer genetic algorithm, NSGA-II [an improved NSGA which is criticized for its computational complexity] was implemented which implies *Darwin's* survival of the fittest principle to deduce the *fittest* solution. 

![image](https://user-images.githubusercontent.com/42310216/146130741-932d0729-221d-475f-932c-42e73efe07a9.png)


![image](https://user-images.githubusercontent.com/42310216/146130771-6d25d749-905b-4cff-80fd-81184e2f3b91.png)


### [Parallel Plot & Chernoff Face Plot with NSGA-II Implemented]

![image](https://user-images.githubusercontent.com/42310216/146130847-c0e2e3fe-f93b-4d3d-9893-7858fbf9fcb2.png)

![image](https://user-images.githubusercontent.com/42310216/146130869-1d7b49c8-5d65-4a20-93c9-180a2430051d.png)


### [Potential Candidate Solutions]

![image](https://user-images.githubusercontent.com/42310216/146130915-bb5e08de-0804-4184-8982-17b298f82bd7.png)


## [Trade-off / Conflicting Performance Criteria] 

![image](https://user-images.githubusercontent.com/42310216/146131017-eeb9218e-8b64-4d16-afa4-a32d44bbb11f.png)






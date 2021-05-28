/*
 * Author: Carlos Fonseca
 * 	   Unversity of Sheffield
 *	   10 March 1995
 */


#include <math.h>
#include "mex.h"

#define max(x,y) ( ((x)>(y)) ? (x) : (y) )


/* First input argument: Objective Vectors              */
#define NIND mxGetM(prhs[0])         /* integer              */
#define NOBJ mxGetN(prhs[0])         /* integer              */
#define OBJV mxGetPr(prhs[0])      /* double(NIND,NOBJ)    */

/* Second input argument: Goal Vector (optional)        */
#define GOAL_IN prhs[1]
#define GOALROWS mxGetM(goalp)       /* integer == 1         */
#define NGOALS mxGetN(goalp)         /* integer == NOBJ      */
#define GOAL mxGetPr(goalp)        /* double(1,NOBJ)       */

/* Third input argument: Priority vector (optional)     */
/*      0 - Objective to be minimized                   */
/*      1 - Constraint to be met                        */
/*      2 - Higher priority constraint to be met        */
/*      3 - ...                                         */
#define PRIOR_IN prhs[2]
#define PRIORROWS mxGetM(priorp)     /* integer == 1         */
#define NPRIORS mxGetN(priorp)       /* integer == NOBJ      */
#define PRIOR mxGetPr(priorp)      /* double(1,NOBJ)       */


/* First output argument: individual rank               */
#define RANK_OUT plhs[0]
#define RANK mxGetPr(plhs[0])      /* double(NIND,1)       */

/* Second output argument: individual class (optional)  */
#define CLASS_OUT classp
#define CLASS mxGetPr(classp)      /* double(NIND,1)       */


/* Function: paired comparison                          */

int
AcompareB(iA, iB, Obj, Goal, Prior, Class, Nobj)
        int             iA, iB;
        int    Nobj;
        double         *Obj[], Goal[], Prior[], Class[];

{
        int             AequalB, BequalA, AbetterB, BbetterA;
        int             Cl, k;

        if (Class[iA] < Class[iB])      /* iA is better than iB */
                return 1;
        else if (Class[iA] > Class[iB]) /* iB is better than iA */
                return -1;

        else {
                for (Cl = Class[iA]; Cl >= 0; Cl--) {
                        AbetterB = AequalB = BbetterA = BequalA = 1;
                        for (k = 0; k < Nobj; k++) {
                                if (Prior[k] != Cl)
                                    continue;
                                if (Obj[k][iA] > Goal[k]) {
                                    AbetterB *= (Obj[k][iA] <= Obj[k][iB]);
                                    AequalB *= (Obj[k][iA] == Obj[k][iB]);
                                }
                                if (Obj[k][iB] > Goal[k]) {
                                    BbetterA *= (Obj[k][iB] <= Obj[k][iA]);
                                    BequalA *= (Obj[k][iB] == Obj[k][iA]);
                                }
                        }

                        if (AequalB && BequalA)
                                continue;

                        if ((AbetterB && !AequalB) || (AequalB && !BequalA))
                                return 1;

                        if ((BbetterA && !BequalA) || (BequalA && !AequalB))
                                return -1;

                        return 0;
                }

                /* this point is only reached in case the decision is  *
                 * based on those objectives which satisfy their goals */

                AbetterB = AequalB = BbetterA = 1;
                for (k = 0; k < Nobj; k++) {
                        if (Prior[k] != 0)
                                continue;
                        AbetterB *= (Obj[k][iA] <= Obj[k][iB]);
                        AequalB *= (Obj[k][iA] == Obj[k][iB]);
                        BbetterA *= (Obj[k][iB] <= Obj[k][iA]);
                }
                if (AbetterB && !AequalB)
                        return 1;
                if (BbetterA && !AequalB)
                        return -1;
                return 0;
        }
}



/* MATLAB gateway routine                               */

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
        mxArray         *goalp, *priorp, *classp;
        int             i, j;
        double        **Obj;


        /* Validate inputs */
        if (nrhs > 3)
                nrhs = 3;       /* Maximum 3 inputs. Ignore any other   */

        switch (nrhs) {
        case 3:
                priorp = PRIOR_IN;
                if (PRIORROWS != 1)
                    mexErrMsgTxt("The priority vector must be a row vector.");
                if (NPRIORS != NOBJ)
                    mexErrMsgTxt("Number of priorities must agree.");
        case 2:
                goalp = GOAL_IN;
                if (GOALROWS != 1)
                    mexErrMsgTxt("The goal vector must be a row vector.");
                if (NGOALS != NOBJ)
                    mexErrMsgTxt("Number of goals must agree.");
        case 1:
                Obj = (double**)mxCalloc(NOBJ,sizeof(double*));
                for (i = 0; i < NOBJ; i++)
                    Obj[i] = OBJV + i * NIND;
                break;
        default:
                mexErrMsgTxt("Not enough input arguments.");
        }

        switch (nrhs) {
        case 1:
                goalp = mxCreateDoubleMatrix(1, NOBJ, mxREAL);
                for (i = 0; i < NGOALS; i++)
                        GOAL[i] = 10e10;
        case 2:
                priorp = mxCreateDoubleMatrix(1, NOBJ, mxREAL);
        }


        /* Validate number of output arguments */
        if (nlhs > 2)				
                mexErrMsgTxt("Too many output arguments.");

        /* Create Matrices to return results in */
        RANK_OUT = mxCreateDoubleMatrix(NIND, 1, mxREAL);
        CLASS_OUT = mxCreateDoubleMatrix(NIND, 1, mxREAL);

        /* Initialize vector CLASS */
        for (i = 0; i < NIND; i++)
                CLASS[i] = -1;


        /* Classify individuals:
                -1 - meets all constraints and goals
                 0 - meets all constraints but not all goals
                 1 - does not meet all priority 1 constraints
        */
        for (i = 0; i < NIND; i++)
                for (j = 0; j < NOBJ; j++)
                        if (Obj[j][i] > GOAL[j])
                                CLASS[i] = max(CLASS[i],PRIOR[j]);


        for (i = 1; i < NIND; i++)
                for (j = 0; j < i; j++)
                        switch(AcompareB(i,j,Obj,GOAL,PRIOR,CLASS,NOBJ)) {
                        case -1:
                                ++(RANK[i]);
                                break;
                        case  1:
                                ++(RANK[j]); 
                        }


        if (nlhs == 2)
                plhs[1] = classp;
}


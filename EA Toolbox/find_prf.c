/*
 * Author: Carlos Fonseca
 *         Unversity of Sheffield
 *         10 March 1995
 */

#include <math.h>
#include "mex.h"

#define max(x,y) ( ((x)>(y)) ? (x) : (y) )

/* First input argument: Objective Vectors              */

#define NIND mxGetM(prhs[0])         /* integer              */
#define NOBJ mxGetN(prhs[0])         /* integer              */
#define OBJV mxGetPr(prhs[0])      /* double[NIND,NOBJ]    */

/* Second input argument: Goal Vector                   */

#define GOAL_IN prhs[1]
#define GOALROWS mxGetM(goalp)       /* integer == 1         */
#define NGOALS mxGetN(goalp)         /* integer == NOBJ      */
#define GOAL mxGetPr(goalp)        /* double[1,NOBJ]       */

/* Third input argument: Priority vector                */
/*      0 - Objective to be minimized                   */
/*      1 - Constraint to be met                        */
/*      2 - Higher priority constraint to be met        */
/*      3 - ...                                         */

#define PRIOR_IN prhs[2]
#define PRIORROWS mxGetM(priorp)     /* integer == 1         */
#define NPRIORS mxGetN(priorp)       /* integer == NOBJ      */
#define PRIOR mxGetPr(priorp)      /* double[1,NOBJ]       */

/* Output argument:
	zero-one vector indexing efficient solutions    */

#define IX_OUT plhs[0]
#define IX mxGetPr(plhs[0])


int
AcompareB(iA, iB, Obj, Goal, Prior, Class, Nobj)
	int             iA, iB, Class[];
    int    Nobj;
	double         *Obj[], Goal[], Prior[];
{
	int             AequalB, BequalA, AbetterB, BbetterA;
	int             Cl, k;

	if (Class[iA] < Class[iB])      /* iA is better than iB */
		return 1;

	else if (Class[iA] > Class[iB]) /* iB is better than iA */
		return -1;

	else {
		for (Cl = Class[iA]; Cl >= 0; Cl--) {
		/*      mex_printf("Class %i\n",Cl); */
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
			/*      mex_printf("Prior %g\n",Prior[k]); */
			}
			if (AequalB && BequalA)
				continue;
			if ((AbetterB && !AequalB) || (AequalB && !BequalA))
				return 1;
			if ((BbetterA && !BequalA) || (BequalA && !AequalB))
				return -1;
			return 0;
		}

		/*
		 * this point is only reached in case the decision is based
		 * on those objectives which satisfy their goals
		 */

		AbetterB = AequalB = BbetterA = BequalA = 1;
		for (k = 0; k < Nobj; k++) {
			if (Prior[k] != 0)
				continue;
			AbetterB *= (Obj[k][iA] <= Obj[k][iB]);
			AequalB *= (Obj[k][iA] == Obj[k][iB]);
			BbetterA *= (Obj[k][iB] <= Obj[k][iA]);
			BequalA *= (Obj[k][iB] == Obj[k][iA]);
		}
		if ((AbetterB && !AequalB) || (AequalB && !BequalA))
			return 1;
		if ((BbetterA && !BequalA) || (BequalA && !AequalB))
			return -1;
		return 0;
	}
}


/* MATLAB interface routine                             */
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
	const mxArray         *goalp, *priorp;
	int             i, j;
	double        **Obj;
	int            *Class;

	/* Validate input arguments */
	if (nrhs > 3)
		nrhs = 3;
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
		break;
	case 1:
		goalp = mxCreateDoubleMatrix(1, NOBJ, mxREAL);
		for (i = 0; i < NGOALS; i++)
			GOAL[i] = HUGE_VAL;
		break;
	default:
		mexErrMsgTxt("Not enough input arguments.");
	}

	/* Create missing input matrices */
	switch (nrhs) {
	case 1:
	case 2:
		priorp = mxCreateDoubleMatrix(1, NOBJ, mxREAL);
	default:
		;
	}

	/* Validate number of output arguments */
	if (nlhs > 1)
		mexErrMsgTxt("Too many output arguments.");

	/* Create Matrix to return result in */
	IX_OUT = mxCreateDoubleMatrix(NIND, 1, mxREAL);

	/* Create auxiliar matrix */
	Class = (int*)mxCalloc(NIND,sizeof(int));

	/* Initialize matrices */
	for (i = 0; i < NIND; i++) {
		IX[i] = 1;
		Class[i] = -1;
	}

	/* Create an array of pointers to OBJV... */
	Obj = (double**)mxCalloc(NOBJ,sizeof(double*));

	/* ... and initialize it */
	for (i = 0; i < NOBJ; i++)
		Obj[i] = OBJV + i * NIND;

	/* Classify individuals:
		-1 - meets all constraints and goals
		 0 - meets all constraints but not all goals
		 1 - does not meet all constraints
	*/

	for (i = 0; i < NIND; i++)
		for (j = 0; j < NOBJ; j++)
			if (Obj[j][i] > GOAL[j])
				Class[i] = max(Class[i],PRIOR[j]);

	/* Perform calculations */
	for (i = 0; i < NIND-1; i++) {
		for (j = i+1; j < NIND; j++) {
			if (IX[i] == 0) break;
			if (IX[j] == 0) continue;
			switch(AcompareB(i,j,Obj,GOAL,PRIOR,Class,NOBJ)) {
			case -1:
				--(IX[i]);
				break;
			case  1:
				--(IX[j]); 
			}


		}
	}

}
  
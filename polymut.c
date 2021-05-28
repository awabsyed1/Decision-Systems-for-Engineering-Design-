#include <mex.h>
#include <math.h>
#include <stdlib.h>

/*
 * polymut.c
 *
 * Polynomial mutation operator
 * for real number representations.
 *
 * This is a MEX-file for MATLAB.
 * Robin Purshouse, 19-Oct-2001
 * Changed random number generator 24-Apr-2019
 *
 */


/*
 * void polymut( ... see below ... ); 
 *
 * Inputs: preMute  - individuals arranged in rows
 *         bounds   - information on decision variable bounds
 *         nm       - mutation parameter, describing extent of search power
 *         mutProb  - element-wise probability of mutation
 *         noVar    - number of decision variables per candidate solution
 *         noSols   - number of candidates
 *
 * Output: postMute - the results of mutation
 *
 */
void polymut(double* preMute, double* bounds, double nm, double mutProb, int noVar, int noSols, double* postMute)
{
  /* Variable declarations: */
  int individual = 0;
  int var = 0;
  double r = 0.0;
  double oldVal = 0.0;
  double lBound = 0.0;
  double uBound = 0.0;
  double delta = 0.0;
  mxArray* rhs[1] = {NULL};
  mxArray* lhs[1] = {NULL};
  double* randFromMATLAB = NULL;
  double* setToOne = NULL;

  /* Initialise output: */
  for(individual = 0; individual < noSols; individual++)
  {
    for(var = 0; var < noVar; var++)
    {
      *(postMute + noSols * var + individual) = *(preMute + noSols * var + individual);
    }
  }

  /* Only do stuff if mutation probability is greater than zero. */
  if( mutProb > 0 )
  {

    /* *** INITIALISE RANDOM NUMBER GENERATOR *** */

    /* Get a random number from MATLAB to seed the C random number generator. */
    /* (NB: System clock doesn't update fast enough for it to be used reliably.) */
    rhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    /* Get a pointer to the argument to rand() and set the corresponding value to 1. */
    setToOne = mxGetPr(rhs[0]);
    *setToOne = 1.0;
    
    /* Execute MATLAB rand() command. */
    mexCallMATLAB(1, lhs, 1, rhs, "rand");
    
    /* Get a pointer to the return value. */
    randFromMATLAB = mxGetPr(lhs[0]);
    
    /* Ensure truncation to type long won't give us zero. */
    *randFromMATLAB *= 1000.0;
    
    /* Initialise random number generator. */
    srand( (int)(*randFromMATLAB) );
    
    /* *** */
    
    /* Algorithm. */
    /* Loop round every element of preMute and test for mutation. */
    for(individual = 0; individual < noSols; individual++)
    {
      for(var = 0; var < noVar; var++)
      {
	r = (double)rand() / (double)RAND_MAX;
	if( r <= mutProb )
	{
	  /* *** APPLY MUTATION *** */
	  
	  /* Obtain the necessary variables. */
	  r = (double)rand() / (double)RAND_MAX;
	  oldVal = *(preMute + noSols * var + individual);
	  lBound = *(bounds + 2 * var);
	  uBound = *(bounds + 2 * var + 1);
	  
	  /* Do the mutation, ensuring that variable bounds are not breached. */
	  if(r < 0.5)
	  {
	    delta = pow(2.0 * r, 1.0 / (nm + 1.0)) - 1.0;
	    *(postMute + noSols * var + individual) = oldVal + (oldVal - lBound) * delta;
	  }
	  else
	  {
	    delta = 1 - pow(2.0 * (1.0 - r), 1.0 / (nm + 1.0));
	    *(postMute + noSols * var + individual) = oldVal + (uBound - oldVal) * delta;
	  }
	}
      }
    }
  }
}

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[],
		 int nrhs, const mxArray* prhs[])
{
  double* preMute = NULL;
  double* bounds = NULL;
  double* nm = NULL;
  double* mutProb = NULL;
  double* postMute = NULL;
  int noVar = 0;
  int noSols = 0;
  int noVarBounds = 0;
  int noBounds = 0;

  /* Check for correct number of inputs: */
  if(nrhs < 2)
  {
    mexErrMsgTxt("At least two inputs are required.");
  }
  else if(nrhs == 3)
  {
    mexErrMsgTxt("All optional arguments are required.");
  } 

  /* Check for correct number of outputs: */
  if(nlhs > 1)
  {
    mexErrMsgTxt("A single output is required.");
  }

  /* We could add more checks, such as non-complex, numeric, etc. */

  /* Get pointers to the input matrices. */
  preMute = mxGetPr(prhs[0]);
  bounds = mxGetPr(prhs[1]);
  
  /* Get the necessary size information. */
  noSols = mxGetM(prhs[0]);
  noVar = mxGetN(prhs[0]);

  /* Determine if the user has provided optional terms. */
  if(nrhs == 4)
  {
    nm = mxGetPr(prhs[2]);
    mutProb = mxGetPr(prhs[3]);

    /* Error checking on inputs. */
    if( (*mutProb < 0.0) || (*mutProb > 1.0) )
    {
      mexErrMsgTxt("Erroneous probability of mutation.");
    }
  }
  else
  {
    /* Set the default values: */
    nm = malloc(sizeof(double));
    *nm = 20;

    mutProb = malloc(sizeof(double));
    *mutProb = 1.0 / (double)noVar;
  }

  /* Check that we've got consistent input data: */
  noBounds = mxGetM(prhs[1]);
  noVarBounds = mxGetN(prhs[1]);
  if( (noBounds != 2) || (noVarBounds != noVar) )
  {
    mexErrMsgTxt("Input data is inconsistent.");
  }

  /* Set the output pointer to the output matrix. */
  plhs[0] = mxCreateDoubleMatrix(noSols, noVar, mxREAL);

  /* Create a (C) pointer to the output matix: */
  postMute = mxGetPr(plhs[0]);

  /* Call the subroutine. */
  polymut(preMute, bounds, *nm, *mutProb, noVar, noSols, postMute);

  /* If we allocated some memory, free it. */
  if(nrhs != 4)
  {
    free(nm);
    free(mutProb);
  }
} 

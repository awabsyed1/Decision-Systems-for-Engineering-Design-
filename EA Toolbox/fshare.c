#include "mex.h"
#include "math.h"

/*
 * fshare.c
 *
 * Goldberg and Richardson's fitness sharing,
 * using L2-norm as the distance metric.
 *
 * This is a MEX-file for MATLAB.
 * Robin Purshouse, 31-May-2001
 *
 * Inputs: pop   - individuals arranged in rows
 *         share - niche size ("sigma-share")
 *         rank  - the rank associated with each individual
 *         n     - dimensions
 *         N     - size of population
 *         alpha - sharing function parameter 
 *
 * Output: count - the share count for each individual
 *
 */

void fshare(double* pop, double* share, double* rank, int n, int N, double alpha, 
	    double* count)
{
  /* Variable declarations: */
  int individual = 0;
  int at = 0;
  int compareThis = 0;
  double distance = 0.0;
  int dimension = 0;
  double dimD = 0.0;
  double sh = 0.0;
  
  /* Initialise output: */
  for(individual = 0; individual < N; individual++)
  {
    /* Individuals add to their own count, unless sigma-share = 0. */
    if(*share == 0)
    {
      *(count + individual) = 0;
    }
    else
    {
      *(count + individual) = 1;
    }
  }

  /* If sigma-share = 0, we can return without further ado. */
  if(*share == 0)
  {
    return;
  }

  /* For each individual, perform the share count: */
  for(individual = 0; individual < (N - 1); individual++)
  {
    /* Avoid unnecessary computations: */
    at++;
    for(compareThis = at; compareThis < N; compareThis++)
    {
      /* Only apply sharing if ranks are identical. */
      if( *(rank + individual) == *(rank + compareThis) )
      {
	/* Compute the Euclidean distance: */
	distance = 0.0;
	for(dimension = 0; dimension < n; dimension++)
	{
	  /* Compute the distance for that dimension. */
	  dimD = *(pop + N * dimension + individual) - 
	    *(pop + N * dimension + compareThis);

	  /* Square it. */
	  dimD *= dimD;

	  /* And add to the running total. */
	  distance += dimD;
	}

	/* Take the square root to get the L2 distance. */
	distance = sqrt(distance);

	/* Compute the sharing function. */
	sh = 0.0;
	if(distance < *share)
	{
	  sh = 1 - pow(distance / *share, alpha);
	}

	/* Add to the counts. */
	*(count + individual) += sh;
	*(count + compareThis) += sh;
      }
    }
  }
}

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[],
		 int nrhs, const mxArray* prhs[])
{
  double* pop = NULL;
  double* share = NULL;
  double* rank = NULL;
  double* count = NULL;
  double* alpha = NULL;
  int dimSize = 0;
  int popSize = 0;
  int rankN = 0;
  int rankM = 0;

  /* Check for correct number of inputs: */
  if(nrhs < 3)
  {
    mexErrMsgTxt("At least three inputs are required.");
  }

  /* Check for correct number of outputs: */
  if(nlhs > 1)
  {
    mexErrMsgTxt("A single output is required.");
  }

  /* We could add more checks, such as non-complex, numeric, etc. */

  /* Get pointers to the input matrices. */
  pop = mxGetPr(prhs[0]);
  share = mxGetPr(prhs[1]);
  rank = mxGetPr(prhs[2]);
  
  /* Determine if the user has provided an alpha. */
  if(nrhs == 4)
  {
    alpha = mxGetPr(prhs[3]);
  }
  else
  {
    /* Set the default value: */
    alpha = malloc(sizeof(double));
    *alpha = 1.0;
  }
  
  /* Get the necessary size information. */
  popSize = mxGetM(prhs[0]);
  dimSize = mxGetN(prhs[0]);

  /* Check that we've got consistent input data: */
  rankM = mxGetM(prhs[2]);
  rankN = mxGetN(prhs[2]);
  if( (rankM != popSize) || (rankN != 1) )
  {
    mexErrMsgTxt("Input data is inconsistent.");
  }
  /* Note that we could be flexible and allow a row vector for rank. */

  /* Set the output pointer to the output matrix. */
  plhs[0] = mxCreateDoubleMatrix(popSize, 1, mxREAL);

  /* Create a (C) pointer to the output matix: */
  count = mxGetPr(plhs[0]);

  /* Call the subroutine. */
  fshare(pop, share, rank, dimSize, popSize, *alpha, count);

  /* If we allocated some memory, free it. */
  if(nrhs != 4)
  {
    free(alpha);
  }
} 

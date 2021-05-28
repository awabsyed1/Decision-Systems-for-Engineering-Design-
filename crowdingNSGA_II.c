#include "mex.h"
#include "math.h"

/*
 * crowding.c
 *
 * NSGA-II density estimator.
 *
 * This is a MEX-file for MATLAB.
 * Robin Purshouse, 11-Oct-2001
 * Divide-by-zero fix 9-Apr-2019
 *
 * Inputs: popData   - population data
 *
 * Output: distances - NSGA-II crowding distances 
 *
 */

void crowdingNSGA_II(double* popData, int noObjs, int noSols, double* minObj, double* maxObj, double* distances)
{
  /* Variable declarations: */
  int candidate = 0;
  int objective = 0;
  int compareThis = 0;
  double d = 0.0;
  double dMore = 0.0;
  double dLess = 0.0;
  double fCandidate = 0.0;
  double fCompare = 0.0;
  double fDistance = 0.0;
  double dObjective = 0.0;
  
  /* Initialise output: */
  for(candidate = 0; candidate < noSols; candidate++)
  {
    /* -1 is to be interpreted as 'Inf' */
    *(distances + candidate) = -1.0;
  }

  /* Algorithm: */
  /* For each individual ... */
  for(candidate = 0; candidate < noSols; candidate++)
  {
    /* Reset 'd'. */
    d = 0.0;
    
    /* Determine 'd' for each objective. */
    for(objective = 0; objective < noObjs; objective++)
    {

      if(*(maxObj + objective) - *(minObj + objective) != 0)
	{

      /* Extract the objective value for the candidate solution. */
      fCandidate = *(popData + (noSols * objective) + candidate);
      
      /* Reset local d's. */
      dMore = -1.0;
      dLess = -1.0;
      dObjective = -1.0;

      /* Go through all other individuals to find minimum distance either side. */
      for(compareThis = 0; compareThis < noSols; compareThis++)
      {
	/* Don't include distance to self. */
	if(candidate != compareThis)
	{
	  /* Extract objective value. */
	  fCompare = *(popData + (noSols * objective) + compareThis);

	  /* Find the difference between the two values. */
	  fDistance = fCandidate - fCompare;

	  /* Find out whether or not this is the closest distance up or down. */
	  if( (fDistance < 0.0) && ( (-fDistance < dMore) || (dMore == -1.0) ) )
	  {
	    dMore = -fDistance;
	  }
	  else if( (fDistance > 0.0) && ( (fDistance < dLess) || (dLess == -1.0) ) )
	  {
	    dLess = fDistance;
	  }
	  else if(fDistance == 0.0)
	  {
	    dMore = 0.0;
	    dLess = 0.0;
	  }
	}
      }

      /* Compute dObjective. */
      if( (dMore != -1.0) && (dLess != -1.0) )
      {
	dObjective = (dMore + dLess) / ( *(maxObj + objective) - *(minObj + objective) );
      }
      else
      {
	dObjective = -1.0;
      }
      
      /* Add to d. */
      if(d != -1.0)
      {
	if(dObjective != -1.0)
	{
	  d += dObjective;
	}
	else
	{
	  d = -1.0;
	}
      }
	}
      }
      
    
    /* Store the 'd' value for the candidate. */
    *(distances + candidate) = d;
  }
}

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[],
		 int nrhs, const mxArray* prhs[])
{
  double* popData = NULL;
  double* distances = NULL;
  double* minObj = NULL;
  double* maxObj = NULL;
  int noObjs = 0;
  int noSols = 0;
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
  popData = mxGetPr(prhs[0]);
  minObj = mxGetPr(prhs[1]);
  maxObj = mxGetPr(prhs[2]);  

  /* Get the necessary size information. */
  noSols = mxGetM(prhs[0]);
  noObjs = mxGetN(prhs[0]);

  /* Set the output pointer to the output matrix. */
  plhs[0] = mxCreateDoubleMatrix(noSols, 1, mxREAL);

  /* Create a (C) pointer to the output matix: */
  distances = mxGetPr(plhs[0]);

  /* Call the subroutine. */
  crowdingNSGA_II(popData, noObjs, noSols, minObj, maxObj, distances);

} 

#include "mex.h"
#include "math.h"

/*
 * rank_nds.c
 *
 * Assigns rank using the non-dominated sorting principle.
 *
 * This is a MEX-file for MATLAB.
 * Robin Purshouse, 11-Oct-2001
 *
 * Input:  popData   - population data
 *                     rows - individuals; columns - criteria
 *
 * Output: ranking   - ranking of candidate solutions
 *
 */

void rank_nds(double* popData, int noObjs, int noSols, double* ranking)
{
  /* Variable declarations: */
  int candidate = 0;
  int noRanked = 0;
  int compareWith = 0;
  int dominated = 0;
  int currentRank = 0;
  int obj = 0;
  int lessThanCounter = 0;
  int lessThanEqualToCounter = 0;
  double* tempRanking = NULL;
  double candidateCriterion = 0.0;
  double compareCriterion = 0.0;

  /* Set aside memory for temporary ranking matrix. */
  tempRanking = malloc(sizeof(double) * noSols);

  /* Initialise output: */
  for(candidate = 0; candidate < noSols; candidate++)
  {
    *(ranking + candidate) = -1;
    *(tempRanking + candidate) = -1;
  }

  /* Algorithm: */
  /* For each no-dominated set: */
  while(noRanked < noSols)
  {
    /* printf("ranked: %d\n", noRanked); */
    /* For each individual: */
    for(candidate = 0; candidate < noSols; candidate++)
    {
      /* Only try and rank it if it hasn't been ranked already. */
      if( *(ranking + candidate) == -1 )
      {
	/* Reset inner loop variables. */
	compareWith = 0;
	dominated = 0;
	/* Compare with all other solutions. */
	while( (compareWith < noSols) && (dominated == 0) )
	{
	  /* Don't compare with self, and don't compare if other solution has
	     alread been ranked. */
	  if( ( *(ranking + compareWith) == -1 ) && (candidate != compareWith) )
	  {
	    /* Reset domination indicator. */
	    lessThanCounter = 0;
	    lessThanEqualToCounter = 0;
	    /* Compare performance in each objective in turn. */
	    for(obj = 0; obj < noObjs; obj++)
	    {
	      /* printf("Objective: %d\n", obj); */
	      /* Get the performance data for the current objective. */
	      candidateCriterion = *(popData + (obj * noSols) + candidate);
	      compareCriterion = *(popData + (obj * noSols) + compareWith);
	      /* printf("Candidate: %f\n", candidateCriterion);
		 printf("Compare: %f\n", compareCriterion); */
	      if( compareCriterion <= candidateCriterion )
	      {
		if( compareCriterion < candidateCriterion )
		{
		  lessThanCounter++;
		  lessThanEqualToCounter++;
		}
		else
		{
		  lessThanEqualToCounter++;
		}
	      }
	    }
	    /* printf("Less than: %d\n", lessThanCounter);
	       printf("Less than or equal: %d\n", lessThanEqualToCounter); */
	    /* Check if the candidate solution is dominated. */
	    if( (lessThanCounter > 0) && (lessThanEqualToCounter == noObjs) )
	    {
	      /* We can end the non-domination check here. */
	      dominated = 1;
	    }
	  }
	  /* Compare with the next yet-to-be-ranked solution. */
	  compareWith++;
	}
	
	/* If we've checked all solutions, and the individual is still non-dominated,
	   then it belongs to the current rank. */
	if(dominated == 0)
	{
	  /* Set the rank for this individual. */
	  *(tempRanking + candidate) = currentRank;
	      
	  /* Increment the number ranked. */
	  noRanked++;
	}
      }
    }
    
    /* Copy the latest rank information to the actual ranking matrix. */
    for(candidate = 0; candidate < noSols; candidate++)
    {
      *(ranking + candidate) = *(tempRanking + candidate);
    }
    
    /* Increment the current non-dominated front counter. */
    currentRank++;
  }

  /* Free dynamically allocated memory. */
  free(tempRanking);
}


/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[],
		 int nrhs, const mxArray* prhs[])
{
  double* popData = NULL;
  double* ranking = NULL;
  int noObjs = 0;
  int noSols = 0;

  /* Check for correct number of inputs: */
  if(nrhs != 1)
  {
    mexErrMsgTxt("A single input is required.");
  }

  /* Check for correct number of outputs: */
  if(nlhs > 1)
  {
    mexErrMsgTxt("A single output is required.");
  }

  /* We could add more checks, such as non-complex, numeric, etc. */

  /* Get pointers to the input matrices. */
  popData = mxGetPr(prhs[0]);
  
  /* Get the necessary size information. */
  noSols = mxGetM(prhs[0]);
  noObjs = mxGetN(prhs[0]);

  /* Set the output pointer to the output matrix. */
  plhs[0] = mxCreateDoubleMatrix(noSols, 1, mxREAL);

  /* Create a (C) pointer to the output matix: */
  ranking = mxGetPr(plhs[0]);

  /* Call the subroutine. */
  rank_nds(popData, noObjs, noSols, ranking);

} 

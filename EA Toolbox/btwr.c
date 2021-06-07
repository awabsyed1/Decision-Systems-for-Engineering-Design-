#include <mex.h>
#include <math.h>
#include <stdlib.h>

/*
 * btwr.c
 *
 * N-step Binary tournament selection with replacement.
 *
 * This is a MEX-file for MATLAB.
 * Robin Purshouse, 10-May-2002
 * N-Step variant:  16-Oct-2002
 * Random number change: 24-Apr-2019
 *
 */


/*
 * void btwr( ... see below ... );
 *
 * Inputs: fitnessValues - N columns of fitness values
 *                         (in the case of a tie in the ith column,
 *                         the i+1th column is considered, etc)
 *         noSols        - number of candidate solutions
 *         dimF          - number of fitness measures (prioritised)
 *         noToSelect    - number of solutions to include in mating pool
 *
 * Output: selectThese   - the indices of solutions to include
 *
 */
void btwr(double* fitnessValues, int noSols, int dimF, double noToSelect, double* selectThese)
{
  /* Variable declarations: */
  int mater = 0;
  int solOne = 0;
  int solTwo = 0;
  int fitLevel = 0;
  int selectedFlag = 0;
  double fitnessOne = 0.0;
  double fitnessTwo = 0.0;
  mxArray* rhs[1] = {NULL};
  mxArray* lhs[1] = {NULL};
  double* randFromMATLAB = NULL;
  double* setToOne = NULL;
  double r = 0.0;

  /* Initialise output: */
  for(mater = 0; mater < noToSelect; mater++)
  {
    *(selectThese + mater) = 1;
  }

  /* Return if we've only got one solution to choose from! */
  if(noSols == 1)
  {
    return;
  }

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
  /* Loop until we've selected enough solutions for the mating pool. */
  for(mater = 0; mater < noToSelect; mater++)
  {
    /* Select two solutions at random. */
    r = (double)rand() / (double)RAND_MAX;
    solOne = (int)(noSols * r);
    
    /* Don't allow to select the same solution twice */
    solTwo = solOne;

    while(solTwo == solOne)
    {
      r = (double)rand() / (double)RAND_MAX;
      solTwo = (int)(noSols * r);
    }

    /* Set the fitness level to consider. */
    fitLevel = 0;
    selectedFlag = 0;

    /* Go through the levels of fitness until a winner is found. */
    while(selectedFlag == 0)
    {
      /* Extract the fitness data. */
      fitnessOne = *(fitnessValues + noSols*fitLevel + solOne);
      fitnessTwo = *(fitnessValues + noSols*fitLevel + solTwo);

      /* Choose the bigger.
       * If they're equal then go to the next level if available,
       * else choose randomly.
       */
      if(fitnessOne > fitnessTwo)
      {
	/* We need to add 1 because Matlab indexes from 1. */
	*(selectThese + mater) = solOne + 1;

	/* Raise selected flag. */
	selectedFlag = 1;
      }
      else if(fitnessOne < fitnessTwo)
      {
	*(selectThese + mater) = solTwo + 1;

	/* Raise selected flag. */
	selectedFlag = 1;
      }
      else
      {
	if(fitLevel < (dimF - 1))
	{
	  /* Try the next fitness level. */
	  fitLevel++;
	}
	else
	{
	  /* Raise selected flag. */
	  selectedFlag = 1;
	  
	  /* Choose randomly. */
	  r = (double)rand() / (double)RAND_MAX;
	  if( r < 0.5 )
	  {
	    *(selectThese + mater) = solOne + 1;
	  }
	  else
	  {
	    *(selectThese + mater) = solTwo + 1;
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
  double* fitnessValues = NULL;
  int dimF = 0;
  int noSols = 0;
  double* noToSelect = NULL;
  double* selectThese = NULL;

  /* Check for correct number of inputs: */
  if(nrhs < 1 )
  {
    mexErrMsgTxt("At least one input is required.");
  }
   
  /* Check for correct number of outputs: */
  if(nlhs > 1)
  {
    mexErrMsgTxt("A single output is required.");
  }

  /* We could add more checks, such as non-complex, numeric, etc. */

  /* Get pointers to the input matrices. */
  fitnessValues = mxGetPr(prhs[0]);
  
  /* Get the necessary size information. */
  noSols = mxGetM(prhs[0]);
  dimF = mxGetN(prhs[0]);

  /* Determine if the user has provided optional terms. */
  if(nrhs == 2)
  {
    noToSelect = mxGetPr(prhs[1]);
    *noToSelect = floor(*noToSelect);

    /* Error checking on inputs. */
    if( *noToSelect <= 0.0 )
    {
      mexErrMsgTxt("Bad number to select.");
    }
  }
  else
  {
    /* Set the default values: */
    noToSelect = malloc(sizeof(int));
    *noToSelect = noSols;
  }

  /* Set the output pointer to the output matrix. */
  plhs[0] = mxCreateDoubleMatrix(*noToSelect, 1, mxREAL);

  /* Create a (C) pointer to the output matix: */
  selectThese = mxGetPr(plhs[0]);

  /* Call the subroutine. */
  btwr(fitnessValues, noSols, dimF, *noToSelect, selectThese);

  /* If we allocated some memory, free it. */
  if(nrhs != 2)
  {
    free(noToSelect);
  }
}


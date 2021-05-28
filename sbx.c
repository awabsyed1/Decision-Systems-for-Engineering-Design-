#include <mex.h>
#include <math.h>
#include <stdlib.h>

/*
 * sbx.c
 *
 * Simulated Binary Crossover operator
 * for real number representations.
 *
 * This is a MEX-file for MATLAB.
 * Robin Purshouse, 22-Oct-2001
 * Random number generator modifed 22-Apr-2019
 *
 */


/*
 * void sbx( ... see below ... ); 
 *
 * Inputs: parents  - individuals arranged in rows
 *         bounds   - information on decision variable bounds
 *         nc       - crossover parameter, describing extent of search power
 *         option   - type of crossover, e.g. single-point
 *         xovProb  - probability of binary crossover
 *         exchange - exchange offspring variables after SBX crossover
 *         uniProb  - probability of crossing over a particular element
 *         noVar    - number of decision variables per candidate solution
 *         noSols   - number of parents
 *
 * Output: offspring - the offspring resulting from the recombination
 *
 */
void sbx(double* parents, double* bounds, double nc, double option, double xovProb, double exchange, double uniProb, int noVar, int noSols, double* offspring)
{
  /* Variable declarations: */
  int parentSol = 0;
  int offspringSol = 0;
  int var = 0;
  int crossoverPoint = 0;
  double parent1 = 0.0;
  double parent2 = 0.0;
  double xovParam = 0.0;
  double randNo = 0.0;
  double uBound = 0.0;
  double lBound = 0.0;
  double offspring1 = 0.0;
  double offspring2 = 0.0;
  double copyChild = 0.0;
  mxArray* rhs[1] = {NULL};
  mxArray* lhs[1] = {NULL};
  double* randFromMATLAB = NULL;
  double* setToOne = NULL;
  int* variablesToCross = NULL;
  
  /* Initialise output: */
  for(offspringSol = 0; offspringSol < noSols; offspringSol++)
  {
    for(var = 0; var < noVar; var++)
    {
      *(offspring + noSols * var + offspringSol) = *(parents + noSols * var + offspringSol);
    }
  }

  /* Only perform crossover if probabilities are greater than zero. */
  if( ( (xovProb != 0) && (option != 0) ) || ( (xovProb != 0) && (option == 0) && (uniProb != 0) ) )
  {

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
    
    /* Ensure truncation to type int won't give us zero. */
    *randFromMATLAB *= 1000.0;
    
    /* Initialise random number generator. */
    srand( (int)(*randFromMATLAB) );
    
    /* Algorithm. */
  
    /* Depending on chosen option, set up a cross - don't cross array. */
    variablesToCross = malloc(sizeof(int)*noVar);
    
    
    if( (option == -1.0) || (option == 0.0) || (option == 1.0) )
    {
      while(parentSol < noSols)
      {
	/* If there is only one parent in the pair, return unchanged. */
	if(parentSol == noSols - 1)
	{
	  /* No action required, because offspring are initialised to parents. */
	}
	/* Otherwise begin crossover procedure. */
	else
	{
	  /* Roll a random number to see if crossover should occur. */
	  randNo = (double)rand() / (double)RAND_MAX;
	  if( randNo <= xovProb )
	  {
	    if(option == 1)
	    {
	      /* Single point crossover. */
	      
	      /* Determine crossover point. */
	      randNo = (double)rand() / (double)RAND_MAX;
	      crossoverPoint = ceil( randNo * noVar ) - 1;
	      
	      /* Set up array. */
	      for(var = 0; var < crossoverPoint; var++)
	      {
		*(variablesToCross + var) = 0;
	      }
	      for(var = crossoverPoint; var < noVar; var++)
	      {
		*(variablesToCross + var) = 1;
	      }
	    }
	    else if(option == 0)
	    {
	      /* Uniform crossover. */
	      
	      /* Set up array. */
	      for(var = 0; var < noVar; var++)
	      {
		randNo = (double)rand() / (double)RAND_MAX;
		if( randNo <= uniProb )
		{
		  *(variablesToCross + var) = 1;
		}
		else
		{
		  *(variablesToCross + var) = 0;
		}
	      }
	    }
	    else if(option == -1)
	    {
	      /* Cross everything. */
	      
	      /* Set up array. */
	      for(var = 0; var < noVar; var++)
	      {
		*(variablesToCross + var) = 1;
	      }
	    }
	
	    /* Do the crossover. */
	    for(var = 0; var < noVar; var++)
	    {
	      /* If this is a crossover site, perform crossover. */
	      if( *(variablesToCross + var) == 1)
	      {
		/* Extract current parent values. */
		parent1 = *(parents + noSols * var + parentSol);
		parent2 = *(parents + noSols * var + parentSol + 1);
		
		/* Extract variable bounds. */
		uBound = *(bounds + 2 * var + 1);
		lBound = *(bounds + 2 * var);
		
		/* Compute parameter from distribution. */
		randNo = (double)rand() / (double)RAND_MAX;
		if( randNo <= 0.5 )
		{
		  xovParam = pow(2.0 * randNo, 1.0 / (nc + 1.0) );
		}
		else
		{
		  xovParam = pow(1.0 / (2 * (1.0 - randNo) ), 1.0 / (nc + 1.0) );
		}
		
		/* Compute offspring values. */
		offspring1 = 0.5 * ( (1.0 + xovParam) * parent1 + (1.0 - xovParam) * parent2 );
		offspring2 = 0.5 * ( (1.0 - xovParam) * parent1 + (1.0 + xovParam) * parent2 );
		
		/* If offspring are infeasible then set to boundary parameters. */
		if(offspring1 > uBound) offspring1 = uBound;
		if(offspring1 < lBound) offspring1 = lBound;
		if(offspring2 > uBound) offspring2 = uBound;
		if(offspring2 < lBound) offspring2 = lBound;
		
		/* If the exchange option is activated, then perform the exchange with
		   probability 0.5. */
		randNo = (double)rand() / (double)RAND_MAX;
		if( (exchange == 1.0) && (randNo <= 0.5) )
		{
		  copyChild = offspring1;
		  offspring1 = offspring2;
		  offspring2 = copyChild;
		}
		
		/* Store the results. */
		*(offspring + noSols * var + parentSol) = offspring1;
		*(offspring + noSols * var + parentSol + 1) = offspring2;
	      }
	    }
	  }
	  else
	  {
	    /* No crossover occurred, so return unchanged. */
	  }
	}
	/* Go to the next pair of parents. */
	parentSol += 2;
      }
    }
    else
    {
      /* Unsupported crossover type. */ 
      printf("\nWarning from SBX: Unsupported crossover option. Offspring equal parents.\n");
    }

    /* Free the memory associated with the cross/don't cross array. */
    free(variablesToCross);
  }
}

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[],
		 int nrhs, const mxArray* prhs[])
{
  double* parents = NULL;
  double* bounds = NULL;
  double* nc = NULL;
  double* option = NULL;
  double* xovProb = NULL;
  double* exchange = NULL;
  double* offspring = NULL;
  double* uniProb = NULL;
  int noVar = 0;
  int noSols = 0;
  int noVarBounds = 0;
  int noBounds = 0;

  /* Check for correct number of inputs: */
  if(nrhs < 2)
  {
    mexErrMsgTxt("At least two inputs are required.");
  }
  else if( (nrhs == 3) || (nrhs == 4) || (nrhs == 5) || (nrhs == 6) )
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
  parents = mxGetPr(prhs[0]);
  bounds = mxGetPr(prhs[1]);
  
  /* Determine if the user has provided optional terms. */
  if(nrhs == 7)
  {
    nc = mxGetPr(prhs[2]);
    option = mxGetPr(prhs[3]);
    xovProb = mxGetPr(prhs[4]);
    exchange = mxGetPr(prhs[5]);
    uniProb = mxGetPr(prhs[6]);

    /* Error checking on inputs. */
    if( (*xovProb < 0.0) || (*xovProb > 1.0) )
    {
      mexErrMsgTxt("Erroneous probability of crossover.");
    }

    if( (*uniProb < 0.0) || (*uniProb > 1.0) )
    {
      mexErrMsgTxt("Erroneous probability of internal crossover.");
    }
  }
  else
  {
    /* Set the default values: */
    nc = malloc(sizeof(double));
    *nc = 15.0;

    option = malloc(sizeof(double));
    *option = 1.0;

    xovProb = malloc(sizeof(double));
    *xovProb = 0.7;

    exchange = malloc(sizeof(double));
    *exchange = 0.0;

    uniProb = malloc(sizeof(double));
    *uniProb = 0.5;
  }
  
  /* Get the necessary size information. */
  noSols = mxGetM(prhs[0]);
  noVar = mxGetN(prhs[0]);

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
  offspring = mxGetPr(plhs[0]);

  /* Call the subroutine. */
  sbx(parents, bounds, *nc, *option, *xovProb, *exchange, *uniProb, noVar, noSols, offspring);

  /* If we allocated some memory, free it. */
  if(nrhs != 7)
  {
    free(nc);
    free(option);
    free(xovProb);
    free(exchange);
  }
} 

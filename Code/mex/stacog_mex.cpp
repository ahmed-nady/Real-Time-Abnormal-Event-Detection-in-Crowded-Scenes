/*=================================================================
 *
 * STACOG feature extraction
 *
 * feat = stacog_mex(Grad, rvecs, ztol, nxybin, ntbin, reflect)
 *
 * Input
 *  Grad    - Gradient data [height x width x 3(dx,dy,dz) x depth]
 *  rvecs   - Displacement (rx,ry,rz) [nr x 3]
 *  ztol    - Tolerance for zero gradients [scalar] 
 *  nxybin  - Number of orientation bins in x-y plane  [scalar]
 *  ntbin   - Number of orientation bin-layers along t [scalar]
 *  reflect - 1 for calculating direction in half-region (0~180) [1|0]
 *            0 for whole-region (0~360)
 *
 * Output
 *  feat - Feature vector  [nbin+nr*nbin^2) x 1]
 *          nbin = nxybin*(2*ntbin+1) + 2 for reflect = 1
 *               = nxybin*(2*ntbin+1) + 1 for reflect = 0
 *
 *=================================================================*/
#include "mex.h"
#include "stacog.hpp"

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
{ 
    if (nrhs != 6)     mexErrMsgTxt("stacog_mex: Wrong number of inputs."); 
    else if (nlhs > 2) mexErrMsgTxt("stacog_mex: Wrong number of outputs."); 
    
    /*-- Check the dimensions --*/ 
	int ndim = (int)mxGetNumberOfDimensions(prhs[0]);
    if (!mxIsDouble(prhs[0])) mexErrMsgTxt("stacog_mex: wrong data type of gradient matrix."); 
    if (ndim < 3 || ndim > 4) mexErrMsgTxt("stacog_mex: wrong size of gradient matrix.");
	const mwSize* dim = mxGetDimensions(prhs[0]);
    int height = (int)dim[0];
    int width  = (int)dim[1];
	int ngrad  = (int)dim[2];
	int depth  = 1;
    if (ngrad != 3) mexErrMsgTxt("stacog_mex: wrong size of gradient matrix");
	if (ndim == 4)  depth = (int)dim[3];
	
	/*-- Gradient --*/
    double *grad;
    grad = (double*) mxGetPr(prhs[0]);

	/*-- Parameters --*/
	/*-Displacement vectors-*/
	int nr = (int)mxGetM(prhs[1]);
	if(!mxIsDouble(prhs[1])) mexErrMsgTxt("stacog_mex: wrong data type of displacement vectors."); 
	if(mxGetNumberOfDimensions(prhs[1]) != 2 || mxGetNumberOfElements(prhs[1]) != nr*3) 
		mexErrMsgTxt("stacog_mex: wrong size of displacement vectors.");
	double* rvecs_= (double*)mxGetPr(prhs[1]);
	int*    rvecs = (int*)mxCalloc(3*nr, sizeof(int));
	for(int i = 0; i < 3*nr; i++) rvecs[i] = (int)rvecs_[i];
	int tpmax = 0, tnmax = 0;
	for(int i = 0; i < nr; i++){
		int dt = rvecs[i+2*nr];
		if( dt > 0  && tpmax < dt) tpmax = dt;
		else if( dt < 0 && tnmax < -dt) tnmax = -dt;
	}

	/*-Zero tolerance-*/
	double ztol = mxGetScalar(prhs[2]);

	/*-Orientation bin-*/
	int nbin   = (int)mxGetScalar(prhs[3]);
	int nlayer = (int)mxGetScalar(prhs[4]);

	/*-Orientation reflect-*/
	int reflect = (int)mxGetScalar(prhs[5]);

	/*-- Orientation coding --*/
	double *codes = (double*)mxCalloc(width*height*10*depth,sizeof(double));
	int nallbin;
	for(int i = 0; i < depth; i++) 
		nallbin = storientation_code(&codes[width*height*10*i], &grad[width*height*3*i], width*height, nbin, nlayer, ztol, reflect);

	/*- Feature extraction -*/
	int fdim = nallbin + nr*nallbin*nallbin;
	plhs[0]  = mxCreateDoubleMatrix(fdim, 1, mxREAL);
	double *feat = (double*)mxGetPr(plhs[0]);
	for(int i = tnmax; i < depth - tpmax; i++)
		calc_stacog(feat, &codes[width*height*10*i], height, width, nallbin, rvecs, nr);

	/*- Number of all bins -*/
	if(nlhs == 2) plhs[1] = mxCreateDoubleScalar(nallbin);

	mxFree(rvecs);
	mxFree(codes);

	return;
}

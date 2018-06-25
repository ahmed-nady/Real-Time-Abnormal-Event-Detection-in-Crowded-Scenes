#ifndef STACOG_HPP
#define STACOG_HPP

#include <math.h>

#define MIN(a,b) ((a)>(b) ? (b):(a))

#ifndef M_PI
#define M_PI 3.141592
#endif

/*---------------------------------------------------------------*
 *  Orientation coding
 *    e.g., in case of nbin = 8, nlayer = 2
 *           5 6 7                  5  4 3      ^ t
 *            \|/                   | //        |       sig=1
 *          4-- --0    +--->x        --- 2      +--->x
 *            /|\      |            | \\                sig=-1
 *           3 2 1     v            6  0 1     
 *                     y               layer
 *
 * Input 
 *  num  - Number of pixels
 *  grad - Gradient vectors [num x 3 (dx, dy, dz)]
 *  nbin - Number of orientation bins in x-y plane
 *  nlayer - Number of orientation bin-layers along t-axis
 *  ztol - Tolerance for zero gradient
 *	reflect - 1 for calculating direction in half-region (0~180)
 *            0 for whole-region (0~360)
 *
 * Output
 * 	output - Orientation code data [num x 10]
 * 		0: norm
 *		1: first direction index
 *      2: first weight to the index
 *      :
 *      7: 4th weight to the index  
 *      8: 4th weight to the index  
 *      9: termination index (-1)
 *
 *	returned value - Number of all bins on (hemi)sphere
 *---------------------------------------------------------------*/
int storientation_code(double* output, double* grad, int num, int nbin, int nlayer, double ztol, int reflect)
{
	int nbin_ = nbin;

	/*- In case of 'reflect', spatial angles are temporarily calculated in 0~360 degree by doubled bins -*/
	if (reflect > 0 ) nbin_ = nbin*2;
	double radian2bin = nbin_/(2*M_PI);

	/*- Layers along temporal axis -*/
	double LAYER[256];
	for(int i = 0; i <= nlayer; i++) LAYER[i] = (0.5*M_PI)*i/(nlayer+1);
	int nall_layer = nlayer*2 + 1;  //num. of all layers without zenith
	int add_spole  = 1;             //if 1, the north and the south poles are distinguished
	if( reflect > 0 ) add_spole = 0;

	double *xgrad = &grad[0];
	double *ygrad = &grad[num];
	double *zgrad = &grad[2*num];
	for(int i = 0; i < num; i++){
		double x = xgrad[i];
		double y = ygrad[i];
		double z = zgrad[i];

		/*- Magnitude -*/
		double *mag = &output[10*i];
		*mag = sqrt(x*x+y*y+z*z); //for asin

		double *indwei = &output[10*i+1];
		/*- Ignore tiny gradients -*/
		if(*mag < ztol){
			*mag      = 0;
			indwei[0] = -1;
			continue;
		}

		/*- Spatial Angles (0~360 degrees) -*/
		double theta  = atan2(y,x);
		if(theta < 0) theta += 2*M_PI;
		double dindex = theta * radian2bin;
		int     index = (int)floor(dindex);
		double weiL   = 1 + index - dindex;
		if(index == nbin_){ index = 0; weiL  = 1; }
		double weiR   = 1 - weiL;
		int indL = index%nbin;
		int indR = (index+1)%nbin;

		/*- Temporal Angles -*/
		int sigL = 1, sigR = 1;     //sign +1 for t > 0, -1 for t < 0 along t-axis, and sigL for left, sigR for right bins
		int sigS = 0;               //whether the zenith is the south pole or not
		double phi = asin(z / (*mag));

		if ( phi < 0 ) {phi*=-1; sigL=-1; sigR=-1; sigS=1;}

		/*- In case of 'reflect', opposite vectors are regarded as identical ones -*/
		if( reflect > 0 ){
			if(index+1 == nbin_) sigL *= -1;
			else if(index >= nbin) {sigL *= -1; sigR *= -1;}
			else if(index+1 >= nbin) sigR *= -1;
			sigS = 0;
		}

		if( phi >= LAYER[nlayer] ){
			/*- around zenith (pole) -*/
			double weiU = (phi - LAYER[nlayer])/(0.5*M_PI - LAYER[nlayer]);
			double weiD = 1 - weiU;
			indwei[0] = nall_layer * nbin + sigS; //to zenith (north/south)
			indwei[1] = weiU;
			indwei[2] = (nlayer * sigL + nlayer) * nbin + indL;
			indwei[3] = weiD * weiL;
			indwei[4] = (nlayer * sigR + nlayer) * nbin + indR;
			indwei[5] = weiD * weiR;
			indwei[6] = -1;  //termination
		}else{
			/*- between l-th and (l+1)-th layers -*/
			int l;
			for(l = nlayer - 1; l >= 0 ;l--)
				if( phi >= LAYER[l] ) break;
			double weiU = (phi-LAYER[l]) / (LAYER[l+1]-LAYER[l]);
			double weiD = 1 - weiU;
			indwei[0] = (sigL * (l+1) + nlayer) * nbin + indL;
			indwei[1] = weiU * weiL;
			indwei[2] = (sigR * (l+1) + nlayer) * nbin + indR;
			indwei[3] = weiU * weiR;
			indwei[4] = (sigL *  l    + nlayer) * nbin + indL;
			indwei[5] = weiD * weiL;
			indwei[6] = (sigR *  l    + nlayer) * nbin + indR;
			indwei[7] = weiD * weiR;
			indwei[8] = -1;  //termination
		}
	}
	return nall_layer*nbin + 1 + add_spole;
}

/*---------------------------------------------------------------*
 *   Spatio-Temporal Auto-Correlation Of Gradient (STACOG)
 * Input
 * 	 idata - Orientation code data [height x width x 10]
 *   nbin  - Number of all orientation bins   [scalar]
 *   rvecs  - Displacement intervals (rx,ry,rz) [nr x 3]
 *
 * Output
 *   ofeat - Feature vector  [nbin + nr*nbin^2 x 1]
 *---------------------------------------------------------------*/
void calc_stacog(double *ofeat, double* idata, int height, int width, int nbin, int* rvecs, int nr)
{
	double *feat0th = &ofeat[0];
	double *feat1st = &ofeat[nbin];

 	for(int x = 0; x < width; x++){
	   for(int y = 0; y < height; y++){
		   int i = y+x*height;
		   double *dat_c = &idata[i*10];

		   /*- Gradient Magnitude -*/
		   double mag1 = dat_c[0];
		   if( mag1 <= 0) continue;

		   for(int index_c = 1; index_c < 8, dat_c[index_c] >= 0; index_c+=2){
			   /*- Orientation index -*/
			   int    ind1 = (int)dat_c[index_c];
			   double wei1 =      dat_c[index_c+1];
			   feat0th[ind1] += mag1 * wei1;

			   for(int l = 0; l < nr; l++){
				   int dx = x+rvecs[l];
				   int dy = y+rvecs[l+nr];
				   int dz =   rvecs[l+2*nr];
				   
				   if( dy >= 0 && dy < height && dx >= 0 && dx < width ){
					   int j = dy + dx*height + dz*width*height;
					   double *dat_r = &idata[j*10];
					   
					   /*- Gradient Magnitude -*/
					   double mag2 = dat_r[0];
					   if( mag2 <= 0) continue;
					   
					   /*- Weight for the pair -*/
					   double mag = MIN(mag1, mag2);

					   double* feat1st_ = &feat1st[l*nbin*nbin];
					   for(int index_r = 1; index_r < 8, dat_r[index_r] >= 0; index_r+=2){
						   /*- Orientation index -*/
						   int    ind2 = (int)dat_r[index_r];
						   double wei2 =      dat_r[index_r+1];

						   /*- Voting -*/
						   feat1st_[ind1 + ind2*nbin] += mag * wei1 * wei2;
					   }
				   }
			   }
		   }
	   }
   }
}
#endif

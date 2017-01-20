//------------------------------------------------------------------------
// guotai wang
// guotai.wang.14@ucl.ac.uk
// 9 Dec, 2014
// interactive graphcut
//------------------------------------------------------------------------

#include "mex.h"
#include "maxflow-v3.0/graph.h"
#include <iostream>
#include <cmath>
#define   FOREGROUND_LABEL 127
#define   BACKGROUND_LABEL 255
using namespace std;

// [flow label]=interactive_graphcut(I,Seeds,foregroundProb,backgroundProb, lambda,sigma);
// I              --input graylevel or rgb image. type: double
// Seeds          -- 2D image storing scribbles. type: unsigned char. 127--foreground, 255--background
// foregroundProb -- Probability of being foreground. type: double
// foregroundProb -- Probability of being background. type: double
// lambda         --CRF parameter, weight of pairwise potential. (1.0, 20.0)
// sigma          --CRF parameter, control the significance of itensity difference (5.0, 20.0)
void mexFunction(int			nlhs, 		/* number of expected outputs */
				 mxArray		*plhs[],	/* mxArray output pointer array */
				 int			nrhs, 		/* number of inputs */
				 const mxArray	*prhs[]		/* mxArray input pointer array */)
{
	// input checks
	if (nrhs != 6 )
	{
		mexErrMsgTxt ("USAGE: [flow label]=interactive_graphcut(I,Seeds,foregroundProb,backgroundProb,lambda,sigma);");
	}
	const mxArray *I = prhs[0];
	const mxArray *Seed = prhs[1];
    const mxArray *FProb = prhs[2];
    const mxArray *BProb = prhs[3];
    double lamda=* mxGetPr(prhs[4]);
    double sigma= * mxGetPr(prhs[5]);
    
    double * IPr=(double *)mxGetPr(I);
    unsigned char * SeedPr=(unsigned char *)mxGetPr(Seed);
    double * FProbPr = mxGetPr(FProb);
    double * BProbPr = mxGetPr(BProb);
    
    int D = mxGetNumberOfDimensions(I);
    const mwSize * Ishape = mxGetDimensions(I);
    int channel = (D==2)?1:Ishape[2];
    
	// size of image
	mwSize m = Ishape[0];//mxGetM(I);//height, number of rows
	mwSize n = Ishape[1];//mxGetN(I);//width, number of columns

    //construct graph
    typedef Graph<float,float,float> GraphType;
    GraphType *g = new GraphType(/*estimated # of nodes*/ m*n, /*estimated # of edges*/ 2*m*n);
    g->add_node(m*n);
    float maxWeight=-1e20;
    for(int x=0;x<n;x++)
    {
        for(int y=0;y<m;y++)
        {
            //n-link
            double * pValue= IPr + x*m + y;
            //int label=seed.at<uchar>(y,x);
            int uperPointx=x;
            int uperPointy=y-1;
            int LeftPointx=x-1;
            int LeftPointy=y;
            float n_weight=0;
            if(uperPointy>=0 && uperPointy<m)
            {
                double * qValue= IPr + uperPointx*m + uperPointy;
                float square_differ = 0;
                for(int c = 0; c<channel; c++)
                {
                    float differ = float (*(pValue + c*m*n) - *(qValue + c*m*n));
                    square_differ += differ*differ;
                }
                n_weight=lamda*exp(-square_differ/(2*sigma*sigma));
                int pIndex=x*m+y;
                int qIndex=uperPointx*m+uperPointy;

                g->add_edge(qIndex,pIndex,n_weight,n_weight);
            }
            if(LeftPointx>=0 && LeftPointx<n)
            {
                double * qValue= IPr + LeftPointx*m + LeftPointy;
                float square_differ = 0;
                for(int c = 0; c<channel; c++)
                {
                    float differ = float (*(pValue + c*m*n) - *(qValue + c*m*n));
                    square_differ += differ*differ;
                }               
                n_weight=lamda*exp(-square_differ/(2*sigma*sigma));
                int pIndex=x*m+y;
                int qIndex=LeftPointx*m+LeftPointy;
                g->add_edge(qIndex,pIndex,n_weight,n_weight);
            }
            if(n_weight>maxWeight)
            {
                maxWeight=n_weight;
            }
        }
    }
    maxWeight=1e10;

    for(int x=0;x<n;x++)
    {
        for(int y=0;y<m;y++)
        {
            //t-link
            unsigned char label=*(SeedPr+x*m+y);
            float s_weight=0;
            float t_weight=0;
            if(label==FOREGROUND_LABEL)
            {
                s_weight=maxWeight;
            }
            else if(label==BACKGROUND_LABEL )
            {
                t_weight=maxWeight;
            }
            else
            {
                float forePosibility=(float) *(FProbPr+x*m+y);
                float backPosibility=(float) *(BProbPr+x*m+y);

                s_weight=-log(backPosibility);
                t_weight=-log(forePosibility);
            }
            int pIndex=x*m+y;
            g->add_tweights(pIndex,s_weight,t_weight);
        }
    }
    // return the results
	plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	double* flow = mxGetPr(plhs[0]);
	*flow = g->maxflow();
    printf("max flow: %f\n",*flow);
    
	// figure out segmentation
	plhs[1] = mxCreateNumericMatrix(m, n, mxUINT8_CLASS, mxREAL);
	unsigned char * labels = (unsigned char*)mxGetData(plhs[1]);
	for (int x = 0; x < n; x++)
	{
        for (int y=0;y<m;y++)
        {
            int Index=x*m+y;
            labels[Index] = g->what_segment(Index);
        }
	}
	// cleanup
	delete g;
}


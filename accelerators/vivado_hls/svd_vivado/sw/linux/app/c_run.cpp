#include "c_run.h"
#include "eigen/Eigen/Dense"
#include "eigen/Eigen/SVD"
#include <time.h>
#include <bits/stdc++.h>
#include <stdio.h>
#include <iostream>

using namespace Eigen;
using namespace std;

extern "C" {

    Matrix3f R;

    void c_run_svd(float inputP, float* inputX, float* inputY, float* inputT)
    {
        //Variables
        float inputQ[229*177];
        int p = 229, q = 177;
        for(int j = 0; j < p*q; j++) //Q
            inputQ[j] = (float) 1/(p * q);

        Matrix3f A;
        //float Q[229*177];
        MatrixXf Q = Map<Matrix<float, 177, 229> >(inputQ);
        MatrixXf C;
        MatrixXf X = Map<Matrix<float, 3, 229> >(inputX);
        MatrixXf Y = Map<Matrix<float, 3, 177> >(inputY);
        Matrix3f T = Map<Matrix<float, 3, 3> >(inputT);

        //Measure time
        //struct timespec startn, endn;
        //unsigned long long sw_ns;

        //gettime(&startn);

        //Run svd software - get R, X*R and Y.T
        A = Y*Q*X.transpose()*2*inputP+T;
        JacobiSVD<Matrix3f> svd(A, ComputeFullU | ComputeFullV);
        Matrix3f U = svd.matrixU();
        Matrix3f Vh = svd.matrixV().transpose();
        R = U * Vh;
        MatrixXf X_res = X.transpose()*R;
        MatrixXf Y_res = Y;

        //gettime(&endn);

        //sw_ns = ts_subtract(&startn, &endn);
        //printf("  > Software test time: %llu ns\n", sw_ns);
        //printf("    + CP_sum: %f\n", sum);

    }

    void printR()
    {
        cout <<"\n+ Software matrix R is:\n" << R << endl;
    }

} /* extern "C" */

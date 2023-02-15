#include "c_run.h"
#include "eigen/Eigen/Dense"
#include "eigen/Eigen/SVD"
#include <time.h>
#include <bits/stdc++.h>
#include <stdio.h>
#include <iostream>
#include "total.h"

using namespace Eigen;
using namespace std;

extern "C" {

    MatrixXf P, K3, K3_t, b2, a2, C3;
    ArrayXXf C2, K2, CP;
    VectorXf a3, b3;
    Matrix3f R;

    float c_run_hiwa(unsigned p, unsigned q, float* X, float* Y,
                     float gamma, unsigned maxiter, float outputX[],
                     float outputY[], float C[], float K[], float a[], float b[])
    {

        unsigned m = 3;

        for(unsigned i = 0; i < m; i++)
            for(unsigned j = 0 ; j < p; j++)
            {
                outputX[j] += pow(X[i * p + j], 2);
            }


        for(unsigned i = 0; i < m; i++)
            for(unsigned j = 0 ; j < q; j++)
            {
                outputY[j] += pow(Y[i * q + j], 2);
            }


        reshape_to_C_mat_with_R2(outputY, outputX, Y, X, q, p, C);

        C2 = Map<Array<float, 177, 229> >(C);
        K2 = C2 / (-1 * gamma);
        K2 = K2.exp();
        K3 = K2.matrix();
        K3_t = K3.transpose();

        //Initializing b
        for(unsigned i = 0; i < q; i++)
        {
            b[i] = 1.0 / (float)q;
        }

        b2 = Map<Array<float, 1, 177> >(b);
        MatrixXf b2_prev;
        float norm = 0.0;
        //MatrixXf a2;

        for(unsigned i = 0; i < maxiter; i++)
        {
            b2_prev = b2;

            a2 = (1.0 / (p * b2 * K3).array()).matrix();

            b2 = (1.0 / (q * a2 * K3_t).array()).matrix();

            norm = (b2 - b2_prev).norm();
            if(norm < 0.00001)
                break;
        }

        a3 =  Map<VectorXf>(a2.data(), a2.cols()*a2.rows());
        b3 =  Map<VectorXf>(b2.data(), b2.cols()*b2.rows());
        DiagonalMatrix<float, Dynamic> P2 = a3.asDiagonal();
        DiagonalMatrix<float, Dynamic> P3 = b3.asDiagonal();

        P = P3 * K3 * P2;

        C3 = (C2.matrix()).transpose();
        //ArrayXXf CP;
        CP = P.array() * C2.array();
        float sum_CP = CP.sum();

        return sum_CP;
    }

void reshape_to_C_mat_with_R2(float* y, float* x, float* Y, float* X, unsigned q, unsigned p, float* C)
{
	//Takes two arrays with different dimensions
	//Array x has n elements, array y has m elements
	//Arrange x times m rows in X and y times n columns in Y
	//Add X+Y

	for(unsigned i = 0; i < p; i++)
		for(unsigned j = 0 ; j < q; j++)
		{
			//C[i * q + j] = 0;
			for(unsigned k = 0; k < 3; k++)
			{
				C[i * q + j] += X[k * p + i] * Y[k * q + j];
			}

			C[i * q + j] = y[j] + x[i] - 2 * C[i * q + j];
		}

}

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

    void reshape_to_C_mat_with_RK(float* y, float* x, float* Y, float* X,
                                        unsigned q, unsigned p, float* C, float* K, float gamma)
    {
        //Takes two arrays with different dimensions
        //Array x has n elements, array y has m elements
        //Arrange x times m rows in X and y times n columns in Y
        //Add X+Y

        for(unsigned i = 0; i < p; i++)
            for(unsigned j = 0 ; j < q; j++)
            {
                C[i * q + j] = 0;
                for(unsigned k = 0; k < 3; k++)
                {
                    C[i * q + j] += X[k * p + i] * Y[k * q + j];
                }

                C[i * q + j] = y[j] + x[i] - 2 * C[i * q + j];
                K[i * q + j] = exp(-C[i * q + j] / gamma);
            }
    }

    float sinkhorn_kernel_clean(unsigned iter, unsigned p, unsigned q,
                                       float* a, float* b, float* b_prev,
                                       float* K, float* C, float* P)
    {
        //Implementation of the inner loop in sinkhorn algorithm

        float norm = 0.0;

        //Initializing b
        for(unsigned i = 0; i < q; i++)
        {
            b[i] = 1.0 / (float)q;
        }

        //Main loop
        for(unsigned i = 0; i < iter; i++)
        {

            for(unsigned j = 0; j < q; j++)
                b_prev[j] = b[j];

            //printf("%u ", i);
            sink_kernel_operation(a, p, q, K, b, false);

            sink_kernel_operation(b, p, q, K, a, true);

            norm = 0;
            for(unsigned j = 0; j < q; j++)
                norm += pow(b[j]-b_prev[j],2);

            norm = sqrt(norm);
            if(norm < 0.00001)
                break;

        }

        mult_diag_mat_diag(a, K, b, P, p, q);

        float sum = 0;
        sum = mult_sum_mats_elementwise(C, P, p, q);
        return sum;

    }

    void sink_kernel_operation(float* a, unsigned p, unsigned q, float* K, float* b, bool transpose)
    {
        if(!transpose)//Regular multiplication
        {
            for(unsigned i = 0; i < p; i++)
            {
                a[i] = 0;
                for(unsigned k = 0; k < q; k++)
                {
                    a[i] += K[i * q + k] * b[k];
                }
                a[i] = 1.0/((float)p * a[i]);
            }
        }
        else//Transpose multiplication
        {
            float* a_alt = (float*)malloc(q * sizeof(float));
            if (a_alt == NULL) {
                printf("Memory not allocated.\n");
                exit(0);
            };

            for(unsigned i = 0; i < p; i++)
            {
                //a_alt[i] = 0;
                for(unsigned k = 0; k < q; k++)
                {
                    if(i == 0)
                        a_alt[k] = 0;
                    //a[i] += K[k * q + i] * b[k];
                    a_alt[k] += K[i * q + k] * b[i];
                    if(i == p-1)
                    {
                        a[k] = 1.0/((float)q * a_alt[k]);
                    }
                }
                //a[i] = 1.0/((float)q * a[i]);
            }
        }
    }

    void mult_diag_mat_diag(float* diag_vec_1, float* K, float* diag_vec_2, float* R, unsigned m, unsigned n)
    {
        //Multiply 2 diagonal matrices with another matrix K in the middle
        //Save result in R
        //m is rows in K and n is columns

        for(unsigned i = 0; i < m; i++)
            for(unsigned j = 0; j < n; j++)
            {
                R[i*n + j] = diag_vec_1[i] * K[i*n + j] * diag_vec_2[j];
            }

    }

    float mult_sum_mats_elementwise(float* C, float* P, unsigned rows, unsigned cols)
    {
        //Calculate the sum of element-wise multiplication of 2 matrices
        float sum = 0;
        for(unsigned j = 0; j < cols*rows; j++)
        {
            sum += C[j] * P[j];
        }
        return sum;
    }

    float total_sinkhorn_clean(unsigned p, unsigned q, float* X, float* Y, float* P,
                               float gamma, unsigned maxiter, float outputX[],
                               float outputY[], float C[],float K[], float a[], float b[], float b_prev[])
    {
        float sum = 0;

        unsigned m = 3;


        for(unsigned i = 0; i < m; i++)
            for(unsigned j = 0 ; j < p; j++)
            {
                if(i == 0)
                    outputX[j] = 0;
                outputX[j] += pow(X[i * p + j], 2);
            }


        for(unsigned i = 0; i < m; i++)
            for(unsigned j = 0 ; j < q; j++)
            {
                if(i == 0)
                    outputY[j] = 0;
                outputY[j] += pow(Y[i * q + j], 2);
            }

        //float C[229*177] = {0};
        reshape_to_C_mat_with_RK(outputY, outputX, Y, X, q, p, C, K, gamma);

        //exp_gamma_mat(C, gamma, p, q, K);

        sum = sinkhorn_kernel_clean(maxiter, p, q, a, b, b_prev, K, C, P);

        return sum;
    }


    void* c_hiwa_tot(void* pq)
    {

        int i = *((int*)pq)/4;
        int j = *((int*)pq)%4;

        int p = p_tot[i];
        int q = q_tot[j];
        float* X_i = X_tot[i];
        float* Y_j = Y_tot[j];

        float* outputX3;
        outputX3 = (float*)malloc(p * sizeof(float));
        if (outputX3 == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }
        for(int i = 0; i < p; i++) outputX3[i] = 0;

        float* outputY3;
        outputY3 = (float*)malloc(q * sizeof(float));
        if (outputY3 == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }
        for(int i = 0; i < q; i++) outputY3[i] = 0;

        float* X_sink = (float*)malloc(p*3 * sizeof(float));
        if (X_sink == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }

        float* Y_sink = (float*)malloc(q*3 * sizeof(float));
        if (Y_sink == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }

        float* P_sink = (float*)malloc(q*p * sizeof(float));
        if (P_sink == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }

        float* C_sink = (float*)malloc(q*p * sizeof(float));
        if (C_sink == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }

        float* K_sink = (float*)malloc(q*p * sizeof(float));
        if (K_sink == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }

        float* a = (float*)malloc(p * sizeof(float));
        if (a == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }

        float* b = (float*)malloc(q * sizeof(float));
        if (b == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }

        float* b_prev = (float*)malloc(q * sizeof(float));
        if (b_prev == NULL) {
            printf("Memory not allocated.\n");
            exit(0);
        }

        ArrayXXf C3(p, q);
        unsigned iter = 150;
        float sum = 0;
        float gamma = 1.6;

        Matrix3f A, A2;
        MatrixXf Q = MatrixXf::Ones(q,p);
        Q = Q *((float) 1/(p*q));

        MatrixXf C;
        MatrixXf X = Map<MatrixXf>(X_i, 3, p);
        MatrixXf Y = Map<MatrixXf>(Y_j, 3, q);
        Matrix3f T = Map<Matrix<float, 3, 3> >(T_total);
        Matrix3f U, Vh, res, prev_res;
        MatrixXf X_res, Y_res;

        res = Matrix3f::Identity();
        float norm = 0;

        for(int i = 0; i < 100; i++)
        {
            prev_res = res;

            //SVD
            A = Y*Q*X.transpose()*2*P_total+T;

            JacobiSVD<Matrix3f> svd(A, ComputeFullU | ComputeFullV);

            U = svd.matrixU();
            Vh = svd.matrixV().transpose();
            res = U * Vh;
            X_res = res*X;
            Y_res = Y;

            for(int k = 0; k < 3; k++)
                for(int j = 0; j < p; j++)
                    X_sink[k*p+j] = X_res(k, j);

            for(int k = 0; k < 3; k++)
                for(int j = 0; j < q; j++)
                    Y_sink[k*q+j] = Y_res(k, j);

            //Sinkhorn
            sum = total_sinkhorn_clean(p, q, X_sink, Y_sink, P_sink,
                                       gamma, iter, outputX3, outputY3, C_sink,
                                       K_sink, a, b, b_prev);

            for(int k = 0; k < q; k++)
                for(int j = 0; j < p; j++)
                    Q(k, j) = P_sink[j*q+k];

            norm = (res-prev_res).norm();
            if(norm < 0.0141){
                //printf("norm is: %f. CP_sum: %f\n", norm, sum);
                break;
            }
        }

        free(outputX3);
        free(outputY3);

        CP_res[*((int*)pq)] = sum;

        return pq;
    }

} /* extern "C" */

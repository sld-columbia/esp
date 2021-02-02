// == mojo ====================================================================
//
//    Copyright (c) gnawice@gnawice.com. All rights reserved.
//	  See LICENSE in root folder
//
//    Permission is hereby granted, free of charge, to any person obtaining a
//    copy of this software and associated documentation files(the "Software"),
//    to deal in the Software without restriction, including without
//    limitation the rights to use, copy, modify, merge, publish, distribute,
//    sublicense, and/or sell copies of the Software, and to permit persons to
//    whom the Software is furnished to do so, subject to the following
//    conditions :
//
//    The above copyright notice and this permission notice shall be included
//    in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//    OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
//    THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// ============================================================================
//    core_math.h: defines matrix class and math functions
// ==================================================================== mojo ==


#ifndef _MATRIX_H_
#define _MATRIX_H_

#include <math.h>
#include <string.h>
#include <string>
#include <cstdlib>
#include <algorithm>


namespace mojo
{

// matrix class ---------------------------------------------------
// should use opencv if available
//

	class matrix
	{
		int _size;
		int _capacity;
		float *_x_mem;
		void delete_x()
			{
				delete[] _x_mem;
				x = NULL;
				_x_mem = NULL;
			}

		float *new_x(const int size)
			{
				_x_mem = new float[size];
				x = _x_mem;
				return x;
			}
	public:
		std::string _name;
		int cols, rows, chans;
		int chan_stride;
		float *x;

		virtual int calc_chan_stride(int w, int h)
			{
				return w * h;
			}


		matrix( )
			: _size(0),
			  _capacity(0),
			  cols(0),
			  rows(0),
			  chans(0),
			  chan_stride(0),
			  x(NULL)
			{}

		matrix( int _w, int _h, int _c = 1, const float *data = NULL)
			: cols(_w),
			  rows(_h),
			  chans(_c)
			{
				chan_stride = calc_chan_stride(cols, rows);
				_size = chan_stride * chans;
				_capacity =_size;
				x = new_x(_size);
				if(data != NULL) memcpy(x, data, _size * sizeof(float));
			}

		virtual ~matrix()
			{
				if (x)
					delete_x();
			}

		matrix get_chans(int start_channel, int num_chans=1) const
			{
				return matrix(cols,rows,num_chans,&x[start_channel*chan_stride]);
			}


		matrix pad(int dx, int dy) const
			{
				int half_dx = dx / 2;
				int half_dy = dy / 2;
				matrix v(cols + dx, rows + dy, chans);
				v.fill(0);

				for(int k = 0; k < chans; k++)
				{
					const int v_chan_offset= k * v.chan_stride;
					const int chan_offset= k * chan_stride;
					for(int j = 0; j < rows; j++)
						memcpy(&v.x[half_dx + (j + half_dy) * v.cols + v_chan_offset], &x[j * cols + chan_offset], sizeof(float) * cols);
				}

				return v;
			}

		matrix crop(int dx, int dy, int w, int h) const
			{
				matrix v(w, h, chans);

				for(int k = 0; k < chans; k++)
					for(int j = 0; j < h; j++)
						memcpy(&v.x[j * w + k * v.chan_stride], &x[dx + (j + dy) * cols + k * chan_stride], sizeof(float) * w);
				return v;
			}

		matrix flip_cols()
			{
				mojo::matrix v(cols,rows,chans);
				for(int k=0; k<chans; k++)
					for(int j=0; j<rows; j++)
						for(int i=0; i<cols; i++)
							v.x[i+j*cols+k*chan_stride]=x[(cols-i-1)+j*cols+k*chan_stride];

				return v;
			}
		matrix flip_rows()
			{
				mojo::matrix v(cols, rows, chans);

				for (int k = 0; k<chans; k++)
					for (int j = 0; j<rows; j++)
						memcpy(&v.x[(rows-1-j)*cols + k*chan_stride],&x[j*cols + k*chan_stride], cols*sizeof(float));

				return v;
			}

		void clip(float min, float max)
			{
				int s = chan_stride*chans;
				for (int i = 0; i < s; i++)
				{
					if (x[i] < min) x[i] = min;
					if (x[i] > max) x[i]=max;
				}
			}


		void min_max(float *min, float *max, int *min_i=NULL, int *max_i=NULL)
			{
				int s = rows*cols;
				int mini = 0;
				int maxi = 0;
				for (int c = 0; c < chans; c++)
				{
					const int t = chan_stride*c;
					for (int i = t; i < t+s; i++)
					{
						if (x[i] < x[mini]) mini = i;
						if (x[i] > x[maxi]) maxi = i;
					}
				}
				*min = x[mini];
				*max = x[maxi];
				if (min_i) *min_i = mini;
				if (max_i) *max_i = maxi;
			}

		float mean()
			{
				const int s = rows*cols;
				float average = 0;
				for (int c = 0; c < chans; c++)
				{
					const int t = chan_stride*c;
					for (int i = 0; i < s; i++)
						average += x[i + t];
				}
				average = average / (float)(s*chans);
				return average;
			}
		float remove_mean(int channel)
			{
				int s = rows*cols;
				int offset = channel*chan_stride;
				float average=0;
				for(int i=0; i<s; i++) average+=x[i+offset];
				average= average/(float)s;
				for(int i=0; i<s; i++) x[i+offset]-=average;
				return average;
			}

		float remove_mean()
			{
				float m=mean();
				int s = chan_stride*chans;
				for(int i=0; i<s; i++) x[i]-=m;
				return m;
			}
		void fill(float val)
			{
				for(int i = 0; i < _size; i++)
					x[i] = val;
			}

		// deep copy
		inline matrix& operator =(const matrix &m)
			{
				resize(m.cols, m.rows, m.chans);
				memcpy(x, m.x, sizeof(float) * _size);
				return *this;
			}

		int  size() const {return _size;}

		void resize(int _w, int _h, int _c) {
			int new_stride = calc_chan_stride(_w, _h);
			int s = new_stride*_c;
			if(s>_capacity)
			{
				if(_capacity>0)
					delete_x();
				_size = s;
				_capacity=_size;
				x = new_x(_size);
			}
			cols = _w; rows = _h; chans = _c; _size = s; chan_stride = new_stride;
		}

		// +=
		inline matrix& operator+=(const matrix &m2){
			for(int i = 0; i < _size; i++) x[i] += m2.x[i];
			return *this;
		}
		// -=
		inline matrix& operator-=(const matrix &m2) {
			for (int i = 0; i < _size; i++) x[i] -= m2.x[i];
			return *this;
		}
		// *= float
		inline matrix operator *=(const float v) {
			for (int i = 0; i < _size; i++) x[i] = x[i] * v;
			return *this;
		}
		// *= matrix
		inline matrix operator *=(const matrix &v) {
			for (int i = 0; i < _size; i++) x[i] = x[i] * v.x[i];
			return *this;
		}
		inline matrix operator *(const matrix &v) {
			matrix T(cols, rows, chans);
			for (int i = 0; i < _size; i++) T.x[i] = x[i] * v.x[i];
			return T;
		}
		// * float
		inline matrix operator *(const float v) {
			matrix T(cols, rows, chans);
			for (int i = 0; i < _size; i++) T.x[i] = x[i] * v;
			return T;
		}

		// + float
		inline matrix operator +(const float v) {
			matrix T(cols, rows, chans);
			for (int i = 0; i < _size; i++) T.x[i] = x[i] + v;
			return T;
		}

		// +
		inline matrix operator +(matrix m2)
			{
				matrix T(cols,rows,chans);
				for(int i = 0; i < _size; i++) T.x[i] = x[i] + m2.x[i];
				return T;
			}
	};

}// namespace

#endif // _MATRIX_H_

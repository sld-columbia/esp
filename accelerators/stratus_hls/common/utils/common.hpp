// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __COMMON_HPP__
#define __COMMON_HPP__

inline int min(int a, int b){
    if (a < b)
	return a;
    else
	return b;
}

inline int max(int a, int b){
    if (a > b)
	return a;
    else
	return b;
}

#endif /* __COMMON_HPP__ */

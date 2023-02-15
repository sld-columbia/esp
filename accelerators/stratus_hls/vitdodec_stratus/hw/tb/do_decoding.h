// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef INCLUDED_VITERBI_GENERIC_H
#define INCLUDED_VITERBI_GENERIC_H

/*
 * Copyright (C) 2016 Bastian Bloessl <bloessl@ccs-labs.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#undef VERBOSE_OUTPUT 

#ifdef VERBOSE_OUTPUT
 #define VERBOSE(_x_) _x_;
#else
 #define VERBOSE(_x_) ;
#endif

extern void do_decoding(int in_n_data_bits, int in_cbps, int in_ntraceback, unsigned char *inMemory, unsigned char *l_decoded);

#endif

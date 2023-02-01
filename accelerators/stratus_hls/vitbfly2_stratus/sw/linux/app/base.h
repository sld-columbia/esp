// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
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

#ifndef INCLUDED_BASE_H
#define INCLUDED_BASE_H

#include "utils.h"
// Maximum number of traceback bytes
#define TRACEBACK_MAX 24

/* This Viterbi decoder was taken from the gr-dvbt module of
 * GNU Radio. It is a version of the Viterbi Decoder
 * created by Phil Karn. For more info see: gr-dvbt/lib/d_viterbi.h
 */

void reset();
uint8_t* depuncture(uint8_t *in);

#endif

/************************************************************************/
/*   This file is a part of the mkprom3 boot-prom utility               */
/*   Copyright (C) 2004 Cobham Gaisler AB                               */
/*                                                                      */
/*   This library is free software; you can redistribute it and/or      */
/*   modify it under the terms of the GNU General Public                */
/*   License as published by the Free Software Foundation; either       */
/*   version 2 of the License, or (at your option) any later version.   */
/*                                                                      */
/*   See the file COPYING.GPL for the full details of the license.      */
/************************************************************************/


#define MAGIC_NUMBER '\xaa'
#define PH_SIZE 12
#define EOP '\x55'

typedef struct
{
    char MAGIC;
    unsigned char PARAMS;
    unsigned char CHECKSUM;
    unsigned char dummy;
    unsigned char ENCODED_SIZE[4];
    unsigned char DECODED_SIZE[4];
} packet_header;


unsigned char
Decode (unsigned char *in_buffer, unsigned char *out_buffer)
{
    int i, j, k, r, c, in_ctr, out_ctr;
    unsigned int flags;
    unsigned char checksum = 0xff, CHECKSUM;
    packet_header *PH;
    unsigned long LHS, WS, ES;
    unsigned char THRESH;
    char ring_buffer[4096];

    PH = (packet_header *) in_buffer;

    if (PH->MAGIC != MAGIC_NUMBER)
	return 1;

    WS = (PH->PARAMS & 0xf0) << 6;
    LHS = (1 << ((PH->PARAMS & 0x0c) >> 2)) * 9;

    THRESH = (PH->PARAMS & 0x03) + 1;
    CHECKSUM = PH->CHECKSUM;

    ES = (PH->ENCODED_SIZE[0] << 24) |
	(PH->ENCODED_SIZE[1] << 16) |
	(PH->ENCODED_SIZE[2] << 8) |
	PH->ENCODED_SIZE[3];

    in_buffer += PH_SIZE;

    in_ctr = out_ctr = 0;

    for (i = 0; i < WS - LHS; i++)
	ring_buffer[i] = ' ';
    r = WS - LHS;
    flags = 0;

    for (;;)
      {
	  if (((flags >>= 1) & 256) == 0)
	    {
		if (in_ctr == ES)
		    break;
		c = in_buffer[in_ctr++];
		flags = c | 0xff00;
	    }
	  if (flags & 1)
	    {
		if (in_ctr == ES)
		    break;
		c = in_buffer[in_ctr++];
		out_buffer[out_ctr++] = c;
		checksum ^= c;
		ring_buffer[r++] = c;
		r &= (WS - 1);
	    }
	  else
	    {
		if (in_ctr == ES)
		    break;
		i = in_buffer[in_ctr++];
		if (in_ctr == ES)
		    break;
		j = in_buffer[in_ctr++];
		i |= ((j & 0xf0) << 4);
		j = (j & 0x0f) + THRESH;
		for (k = 0; k <= j; k++)
		  {
		      c = ring_buffer[(i + k) & (WS - 1)];
		      out_buffer[out_ctr++] = c;
		      checksum ^= c;
		      ring_buffer[r++] = c;
		      r &= (WS - 1);
		  }
	    }
      }

    if (checksum != CHECKSUM)
	return 2;
    if (in_buffer[in_ctr++] != EOP)
	return 3;
    in_buffer += in_ctr;
    out_buffer += out_ctr;
    return 0;
}

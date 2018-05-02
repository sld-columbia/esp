#include "wami_debayer.h"

#define PIXEL_MAX 65535

static uint16_t compute_and_clamp_pixel(uint16_t pos, uint16_t neg)
{
	if (pos < neg) {
		return 0;
	} else {
		const uint16_t pixel = (pos - neg) >> 3;
		if (pixel > PIXEL_MAX) { return PIXEL_MAX; }
		else { return pixel; }
	}
}

/*
 * This version handles masks with fractional negative values. In those
 * cases truncating before subtraction does not generally yield the
 * same result as truncating after subtraction.  The negative value
 * is using weights in units of 1/16ths so that the one-half portions
 * are retained.
 */
static uint16_t compute_and_clamp_pixel_fractional_neg(uint16_t pos, uint16_t neg)
{
	/*
	 * The positive portion is converted to u32 prior to doubling because
	 * otherwise some of the weights could yield overflow. At that point,
	 * all weights are effectively 16x their actual value, so combining
	 * the positive and negative portions and then shifting by four bits
	 * yields the equivalent of a floor() applied to the result of the
	 * full precision convolution.
	 */
	const uint32_t pos_u32 = ((uint32_t) pos) << 1;
	const uint32_t neg_u32 = (uint32_t) neg;
	if (pos_u32 < neg_u32) {
		return 0;
	} else {
		const uint16_t pixel = (uint16_t) ((pos_u32 - neg_u32) >> 4);
		if (pixel > PIXEL_MAX)
			return PIXEL_MAX;
		else
			return pixel;
	}
}

static uint16_t interp_G_at_RRR_or_G_at_BBB(int cols, uint16_t (* const bayer)[cols], int row, int col)
{
	/*
	 * The mask to interpolate G at R or B is:
	 *
	 * [0  0 -1  0  0
	 *  0  0  2  0  0
	 * -1  2  4  2 -1
	 *  0  0  2  0  0
	 *  0  0 -1  0  0]/8
	 */
	const uint16_t pos =
		2 * bayer[row-1][col] +
		2 * bayer[row][col-1] +
		4 * bayer[row][col] +
		2 * bayer[row][col+1] +
		2 * bayer[row+1][col];
	const uint16_t neg =
		bayer[row][col+2] +
		bayer[row-2][col] +
		bayer[row][col-2] +
		bayer[row+2][col];

	return compute_and_clamp_pixel(pos, neg);
}

static uint16_t interp_R_at_GRB_or_B_at_GBR(int cols, uint16_t (* const bayer)[cols], int row, int col)
{
	/*
	 * [0  0 0.5 0  0
	 *  0 -1  0 -1  0
	 * -1  4  5  4 -1
	 *  0 -1  0 -1  0
	 *  0  0 0.5 0  0]/8;
	 */
	const uint16_t pos =
		((bayer[row-2][col] + bayer[row+2][col]) >> 1) +
		4 * bayer[row][col-1] +
		5 * bayer[row][col] +
		4 * bayer[row][col+1];
	const uint16_t neg =
		bayer[row-1][col-1] +
		bayer[row-1][col+1] +
		bayer[row][col-2] +
		bayer[row][col+2] +
		bayer[row+1][col-1] +
		bayer[row+1][col+1];

	return compute_and_clamp_pixel(pos, neg);
}

static uint16_t interp_R_at_GBR_or_B_at_GRB(int cols, uint16_t (* const bayer)[cols], int row, int col)
{
	/*
	 * [0  0 -1  0  0
	 *  0 -1  4 -1  0
	 * 0.5 0  5  0 0.5
	 *  0 -1  4 -1  0
	 *  0  0 -1 0  0]/8;
	 */
	const uint16_t pos =
		4 * bayer[row-1][col] +
		((bayer[row][col-2] + bayer[row][col+2]) >> 1) +
		5 * bayer[row][col] +
		4 * bayer[row+1][col];
	const uint16_t neg =
		bayer[row-2][col] +
		bayer[row-1][col-1] +
		bayer[row-1][col+1] +
		bayer[row+1][col-1] +
		bayer[row+1][col+1] +
		bayer[row+2][col];

	return compute_and_clamp_pixel(pos, neg);
}

static uint16_t interp_R_at_BBB_or_B_at_RRR(int cols, uint16_t (* const bayer)[cols], int row, int col)
{
	/*
	 * [0  0 -1.5 0  0
	 *  0  2  0  2  0
	 * -1.5 0  6  0 -1.5
	 *  0  2  0  2  0
	 *  0  0 -1.5 0  0]/8;
	 */
	const uint16_t pos =
		2 * bayer[row-1][col-1] +
		2 * bayer[row-1][col+1] +
		6 * bayer[row][col] +
		2 * bayer[row+1][col-1] +
		2 * bayer[row+1][col+1];
	const uint16_t neg =
		(3 * bayer[row-2][col] +
			3 * bayer[row][col-2] +
			3 * bayer[row][col+2] +
			3 * bayer[row+2][col]);

	return compute_and_clamp_pixel_fractional_neg(pos, neg);
}

void wami_debayer(int rows, int cols, rgb_pixel debayered[rows- 2 * PAD][cols - 2 * PAD], uint16_t (* const bayer)[cols])
{
	int row, col;

	/*
	 * Demosaic the following Bayer pattern:
	 * R G ...
	 * G B ...
	 * ... ...
	 */

	/* Copy red pixels through directly */
	for (row = PAD; row < rows-PAD; row += 2) {
		for (col = PAD; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].r = bayer[row][col];
	}

	/* Copy top-right green pixels through directly */
	for (row = PAD; row < rows-PAD; row += 2) {
		for (col = PAD+1; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].g = bayer[row][col];
	}

	/* Copy bottom-left green pixels through directly */
	for (row = PAD+1; row < rows-PAD; row += 2) {
		for (col = PAD; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].g = bayer[row][col];
	}

	/* Copy blue pixels through directly */
	for (row = PAD+1; row < rows-PAD; row += 2) {
		for (col = PAD+1; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].b = bayer[row][col];
	}

	/* Interpolate green pixels at red pixels */
	for (row = PAD; row < rows-PAD; row += 2) {
		for (col = PAD; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].g = interp_G_at_RRR_or_G_at_BBB(cols, bayer, row, col);
	}

	/* Interpolate green pixels at blue pixels */
	for (row = PAD+1; row < rows-PAD; row += 2) {
		for (col = PAD+1; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].g = interp_G_at_RRR_or_G_at_BBB(cols, bayer, row, col);
	}

	/* Interpolate red pixels at green pixels, red row, blue column */
	for (row = PAD; row < rows-PAD; row += 2) {
		for (col = PAD+1; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].r = interp_R_at_GRB_or_B_at_GBR(cols, bayer, row, col);
	}

	/* Interpolate blue pixels at green pixels, blue row, red column */
	for (row = PAD+1; row < rows-PAD; row += 2) {
		for (col = PAD; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].b = interp_R_at_GRB_or_B_at_GBR(cols, bayer, row, col);
	}

	/* Interpolate red pixels at green pixels, blue row, red column */
	for (row = PAD+1; row < rows-PAD; row += 2) {
		for (col = PAD; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].r = interp_R_at_GBR_or_B_at_GRB(cols, bayer, row, col);
	}

	/* Interpolate blue pixels at green pixels, red row, blue column */
	for (row = PAD; row < rows-PAD; row += 2) {
		for (col = PAD+1; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].b = interp_R_at_GBR_or_B_at_GRB(cols, bayer, row, col);
	}

	/* Interpolate red pixels at blue pixels, blue row, blue column */
	for (row = PAD+1; row < rows-PAD; row += 2) {
		for (col = PAD+1; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].r = interp_R_at_BBB_or_B_at_RRR(cols, bayer, row, col);
	}

	/* Interpolate blue pixels at red pixels, red row, red column */
	for (row = PAD; row < rows-PAD; row += 2) {
		for (col = PAD; col < cols-PAD; col += 2)
			debayered[row-PAD][col-PAD].b = interp_R_at_BBB_or_B_at_RRR(cols, bayer, row, col);
	}
}

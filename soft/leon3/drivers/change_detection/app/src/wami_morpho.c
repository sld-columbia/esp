/*
 * Morphological image operations. These are currently used only for
 * correctness evaluation and are not part of the PERFECT suite proper.
 */

#include "wami_morpho.h"

void wami_morpho_erode(int rows, int cols,
    uint8_t eroded[rows][cols],
    uint8_t frame[rows][cols])
{
    int row, col;
    for (row = 0; row < rows; ++row)
    {
        for (col = 0; col < cols; ++col)
        {
            const int row_m_1 = (row > 0) ? row-1 : 0;
            const int col_m_1 = (col > 0) ? col-1 : 0;
            const int row_p_1 = (row < rows-1) ? row+1 :
                rows-1;
            const int col_p_1 = (col < cols-1) ? col+1 :
                cols-1;
            if (frame[row][col] == 0 ||
                frame[row_m_1][col_m_1] == 0 ||
                frame[row_m_1][col] == 0 ||
                frame[row_m_1][col_p_1] == 0 ||
                frame[row][col_m_1] == 0 ||
                frame[row][col] == 0 ||
                frame[row][col_p_1] == 0 ||
                frame[row_p_1][col_m_1] == 0 ||
                frame[row_p_1][col] == 0 ||
                frame[row_p_1][col_p_1] == 0)
            {
                eroded[row][col] = 0;
            }
            else
            {
                eroded[row][col] = 1;
            }
        }
    }
}

/* Copyright 2018 Columbia University, SLD Group */

#ifndef __VALIDATION_HPP__
#define __VALIDATION_HPP__

// REPORT_THRESHOLD: the maximum number of errors to report
#define REPORT_THRESHOLD 10

// MAX_ERROR_ACCEPTED: the maximum number of accepted errors
#define MAX_ERROR_ACCEPTED 10

// MAX_ERROR_THRESHOLD: the maximum relative error (percentage)
#define MAX_ERROR_THRESHOLD 0.001

// MIN: macro to find the minimum of two values
#define MIN(x, y) (((x) < (y)) ? (x) : (y))

// MAX: macro to find the maximum of two values
#define MAX(x, y) (((x) < (y)) ? (y) : (x))

int round_down(int num_to_round, int multiple)
{
    if (multiple == 0)
        return num_to_round;

    int remainder = num_to_round % multiple;
    if (remainder == 0)
        return num_to_round;

    return MAX(num_to_round - multiple - remainder, 0);
}

int round_up(int num_to_round, int multiple, int max)
{
    if (multiple == 0)
        return num_to_round;

    int remainder = num_to_round % multiple;
    if (remainder == 0)
        return num_to_round;

    return MIN(num_to_round + multiple - remainder, max);
}

bool check_error_threshold(double out, double gold, double &error)
{
    assert(!isinf(gold) && !isnan(gold));

    // return an error if out is Infinite or NaN
    if (isinf(out) || isnan(out)) { return true; }

    if (fabs(gold) > 0.00001)
        error = fabs((gold - out) / gold);
    else if (fabs(out) > 0.00001)
        error = fabs((out - gold) / out);
    else // it is almost zero..
        error = fabs(out - gold);

    return (error > MAX_ERROR_THRESHOLD);
}

#endif // __VALIDATION_HPP__

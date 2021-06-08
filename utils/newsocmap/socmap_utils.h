#ifndef SOCMAP_UTILS_H
#define SOCMAP_UTILS_H

#include <dirent.h>
#include <string>
#include <iostream>
#include <sstream>
#include <stdlib.h>
#include <stdio.h>

#include <QColor>
#include <QWidget>

#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
#define EVAL_AGAIN(x) x
#define EVAL(x) EVAL_AGAIN(x)

#ifndef CPU_ARCH
#error CPU_ARCH not defined
#endif

namespace socmap
{
#define ECPUCOUNT(__N) TOSTRING(There must be __N processor tile(s))
#define EMEMDBGCOUNT(__N) TOSTRING(There must be __N memory and debug tile(s))
#define EMISCCOUNT(__N) TOSTRING(There must be __N miscellaneous tile(s))
#define EAXICOUNT(__N) TOSTRING(There must be __N AXI interface tile(s))
#define EACCCOUNT(__N) TOSTRING(There must be at least __N accelerator tile(s))
#define EACCNOIMPL TOSTRING(Implementation must be selected for accelerator tile)
#define ECLKDOMAINS                                                                      \
    TOSTRING(Clock domain IDs must be contiguous and each clock domain must have one and \
                 only one PLL)

#define __round_mask(x, y) ((__typeof__(x))((y) - 1))
#define round_up(x, y) ((((x) - 1) | __round_mask(x, y)) + 1)
#define round_down(x, y) ((x) & ~__round_mask(x, y))

void die(std::string msg);

void set_background_color(QWidget *w, const QColor col);

template <typename T> std::string to_string(const T &n)
{
    std::ostringstream stm;
    stm << n;
    return stm.str();
}

static const QColor color_error("#FF7A7A");
static const QColor color_ok("#88CC88");
static const QColor color_empty("#e6e6e6");
static const QColor color_acc("#8dd3c7");
static const QColor color_axi("#bebada");
static const QColor color_cpu("#fb8072");
static const QColor color_mem("#80b1d3");
static const QColor color_misc("#fdb462");

typedef enum tile_enum
{
    TILE_EMPTY = 0,
    TILE_ACC,
    TILE_CPU,
    TILE_MEM,
    TILE_MEMDBG,
    TILE_MISC,
    TILE_AXI
} tile_t;
std::string tile_t_to_string(tile_t type);

void get_subdirs(const std::string path, std::vector<std::string> &list);
void get_files(const std::string path, std::vector<std::string> &list);
void parse_implementations(std::vector<std::string> &inlist,
                           std::vector<std::string> &outlist);

const int lsb_64_table[64] = { 63, 30, 3,  32, 59, 14, 11, 33, 60, 24, 50, 9,  55,
                               19, 21, 34, 61, 29, 2,  53, 51, 23, 41, 18, 56, 28,
                               1,  43, 46, 27, 0,  35, 62, 31, 58, 4,  5,  49, 54,
                               6,  15, 52, 12, 40, 7,  42, 45, 16, 25, 57, 48, 13,
                               10, 39, 8,  44, 20, 47, 38, 22, 17, 37, 36, 26 };

const int msb_64_table[64] = { 0,  47, 1,  56, 48, 27, 2,  60, 57, 49, 41, 37, 28,
                               16, 3,  61, 54, 58, 35, 52, 50, 42, 21, 44, 38, 32,
                               29, 23, 17, 11, 4,  62, 46, 55, 26, 59, 40, 36, 15,
                               53, 34, 51, 20, 43, 31, 22, 10, 45, 25, 39, 14, 33,
                               19, 30, 9,  24, 13, 18, 8,  12, 7,  6,  5,  63 };

unsigned msb64(unsigned long long bb);
unsigned lsb64(unsigned long long bb);
}

#endif // SOCMAP_UTILS_H

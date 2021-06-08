#include "socmap_utils.h"

namespace socmap
{

void die(std::string msg)
{
    std::cout << "    ERROR: " << msg << std::endl;
    exit(EXIT_FAILURE);
}

std::string tile_t_to_string(tile_t type)
{
    switch (type)
    {
    case TILE_ACC:
        return "Accelerator";
        break;
    case TILE_AXI:
        return "AXI Interface";
        break;
    case TILE_CPU:
        return "Processor";
        break;
    case TILE_EMPTY:
        return "Empty";
        break;
    case TILE_MEM:
        return "Memory";
        break;
    case TILE_MEMDBG:
        return "Memory & Debug";
        break;
    case TILE_MISC:
        return "Miscellaneous";
        break;
    default:
        // This should never occur...
        break;
    }
    die("Illegal tile type!");
    return "";
}

void set_background_color(QWidget *w, const QColor col)
{
    QPalette pal;
    pal.setColor(QPalette::Background, col);
    w->setAutoFillBackground(true);
    w->setPalette(pal);
    w->show();
}

void get_subdirs(const std::string path, std::vector<std::string> &list)
{
    DIR *dirp;
    struct dirent *directory;
    dirp = opendir(path.c_str());
    if (dirp)
    {
        while ((directory = readdir(dirp)) != NULL)
            if (directory->d_type == DT_DIR)
                if (strcmp(directory->d_name, ".") && strcmp(directory->d_name, ".."))
                {
                    std::string s(directory->d_name);
                    list.push_back(s);
                }
    }
    closedir(dirp);
}

void get_files(const std::string path, std::vector<std::string> &list)
{
    DIR *dirp;
    struct dirent *directory;
    dirp = opendir(path.c_str());
    if (dirp)
    {
        while ((directory = readdir(dirp)) != NULL)
            if (directory->d_type == DT_REG)
            {
                std::string s(directory->d_name);
                list.push_back(s);
            }
    }
    closedir(dirp);
}

void parse_implementations(std::vector<std::string> &inlist,
                           std::vector<std::string> &outlist)
{
    for (unsigned i = 0; i < inlist.size(); i++)
    {
        std::ostringstream stm;
        size_t len = strlen(inlist[i].c_str());
        char *tmp = new char[len];
        strcpy(tmp, inlist[i].c_str());
        char *pch;
        unsigned width;

        // IP name (discard)
        pch = strtok(tmp, "_");
        if (pch == NULL)
            // Invalid implementation name
            return;

        // Start implementation name parse
        pch = strtok(NULL, "_");

        while (pch != NULL)
        {
            stm << pch;
            if (sscanf(pch, "dma%d", &width) == 1)
            {
                if (width == DMA_WIDTH)
                {
                    outlist.push_back(stm.str());
                    break;
                }
            }
            stm << "_";
            pch = strtok(NULL, "_");
        }
        delete tmp;
    }
}

/**
 * bitScanReverse
 * @authors Kim Walisch, Mark Dickinson
 * @param bb bitboard to scan
 * @precondition bb != 0
 * @return index (0..63) of most significant one bit
 */
unsigned msb64(unsigned long long bb)
{
    const unsigned long long debruijn64 = 0x03f79d71b4cb0a89;
    bb |= bb >> 1;
    bb |= bb >> 2;
    bb |= bb >> 4;
    bb |= bb >> 8;
    bb |= bb >> 16;
    bb |= bb >> 32;
    return (unsigned)msb_64_table[(bb * debruijn64) >> 58];
}

/**
 * bitScanForward
 * @author Matt Taylor (2003)
 * @param bb bitboard to scan
 * @precondition bb != 0
 * @return index (0..63) of least significant one bit
 */
unsigned lsb64(unsigned long long bb)
{
    unsigned int folded;
    bb ^= bb - 1;
    folded = (int)bb ^ (bb >> 32);
    return (unsigned)lsb_64_table[folded * 0x78291ACF >> 26];
}
}

#include "espcreator.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    if (argc != 4)
    {
        printf("usage: ./main <NOC_WIDTH> <TECH_LIB> <MAC_ADDRESS>\n");
        return 1;
    }

    espcreator w(NULL, argv[1], argv[2], argv[3]);

    w.show();

    return a.exec();
}

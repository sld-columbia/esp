#include "espmonmain.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    EspMonMain w;
    w.show();

    return a.exec();
}

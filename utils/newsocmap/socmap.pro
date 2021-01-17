#-------------------------------------------------
#
# Project created by QtCreator 2017-07-05T15:07:37
#
#-------------------------------------------------

QT       += core gui concurrent

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = newsocmap
TEMPLATE = app


SOURCES += socmap_utils.cpp \
           tile.cpp \
           espcreator.cpp \
           main.cpp \
           address_map.cpp \
           power_info.cpp



HEADERS  += socmap_utils.h \
            tile.h \
            espcreator.h \
            address_map.h \
            power_info.h

FORMS    += espcreator.ui


# Command-line defines
INCLUDEPATH += $$(DESIGN_PATH)

DEFINES += TECH_PATH=$$(TECH_PATH)
DEFINES += DESIGN_PATH=$$(DESIGN_PATH)
DEFINES += TECH=$$(TECH)
DEFINES += CPU_ARCH=$$(CPU_ARCH)
DEFINES += DMA_WIDTH=$$(DMA_WIDTH)
DEFINES += BOARD=$$(BOARD)

DISTFILES +=

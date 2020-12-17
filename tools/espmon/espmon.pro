#-------------------------------------------------
#
# Project created by QtCreator 2015-12-07T17:03:15
#
#-------------------------------------------------

QT       += core gui concurrent

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = espmon
TEMPLATE = app

SOURCES += main.cpp\
        espmonmain.cpp \
    mmi64_mon.cpp

HEADERS  += espmonmain.h \
    mmi64_mon.h

FORMS    += espmonmain.ui

INCLUDEPATH += $(PROFPGA)/include
INCLUDEPATH += $(DESIGN_DIR)
INCLUDEPATH += $(ESP_CFG_DIR)
DEPENDPATH += $(PROFPGA)/include

unix:!macx: QMAKE_CXXFLAGS += -Wno-narrowing

unix:!macx: LIBS += -fpic -rdynamic
unix:!macx: LIBS += $(PROFPGA)/lib/linux_x86_64/libprofpga.a
unix:!macx: LIBS += ${PROFPGA}/lib/linux_x86_64/libmmi64.a
unix:!macx: LIBS += ${PROFPGA}/lib/linux_x86_64/libconfig.a -Wl,--no-whole-archive -lpthread
unix:!macx: LIBS += -lrt -ldl

unix:!macx: PRE_TARGETDEPS += $(PROFPGA)/lib/linux_x86_64/libprofpga.a
unix:!macx: PRE_TARGETDEPS += $(PROFPGA)/lib/linux_x86_64/libmmi64.a
unix:!macx: PRE_TARGETDEPS += $(PROFPGA)/lib/linux_x86_64/libconfig.a

QMAKE_CXXFLAGS += -Wno-write-strings

#ifndef POWER_INFO_H
#define POWER_INFO_H

#include <string>
#include <stdio.h>
#include <math.h>
#include <iomanip>

#include <iostream>
#include <ostream>
#include <vector>
#include <map>
#include <string>
#include <iterator>

#include <QFrame>
#include <QLabel>
#include <QLayout>
#include <QPushButton>
#include <QPalette>
#include <QColor>
#include <QComboBox>
#include <QSpinBox>
#include <QCheckBox>
#include <QLineEdit>
#include <QSpacerItem>
#include <QFont>
#include <QFontDatabase>

#include "socmap_utils.h"
#include "esp_constants.h"

using namespace socmap;

class op_point_t
{
  public:
    op_point_t(float V, float ps, float mW)
    {
        this->ps = ps;
        this->V = V;
        this->mW = mW;
    }

    inline friend std::ostream &operator<<(std::ostream &os, op_point_t const &x)
    {
        os << x.ps << " ps - " << x.V << " V - " << x.mW << " mW";
        return os;
    }

    float ps;
    float V;
    float mW;
};

typedef std::vector<op_point_t> vector_op_point_t;
typedef std::map<std::string, std::vector<op_point_t> > op_point_info_t;
typedef std::map<std::string, op_point_info_t> power_info_db_t;

class OperatingPoint
{
  public:
    OperatingPoint(int i, float f, float v, float p, QWidget *parent)
        : id(i), MHz(new QLineEdit(to_string(f).c_str(), parent)),
          MHz_l(new QLabel("MHz", parent)),
          V(new QLineEdit(to_string(v).c_str(), parent)), V_l(new QLabel("V", parent)),
          mW(new QLineEdit(to_string(p).c_str(), parent)), mW_l(new QLabel("mW", parent)),
          hsp(new QSpacerItem(20, 20, QSizePolicy::Minimum, QSizePolicy::Expanding))
    {
        MHz->setAlignment(Qt::AlignRight);
        V->setAlignment(Qt::AlignRight);
        mW->setAlignment(Qt::AlignRight);
        MHz->setEnabled(false);
        V->setEnabled(false);
        mW->setEnabled(false);
    }

    ~OperatingPoint()
    {
        delete mW;
        delete mW_l;
        delete V;
        delete V_l;
        delete MHz;
        delete MHz_l;
        delete hsp;
    }

    float f(void) const
    {
        return MHz->text().toFloat();
    }

    float v(void) const
    {
        return V->text().toFloat();
    }

    float p(void) const
    {
        return mW->text().toFloat();
    }

    unsigned id;
    QLineEdit *MHz;
    QLabel *MHz_l;
    QLineEdit *V;
    QLabel *V_l;
    QLineEdit *mW;
    QLabel *mW_l;
    QSpacerItem *hsp;
};

class Power : public QWidget
{
    Q_OBJECT

  public:
    Power(QWidget *parent,
          QGridLayout *parent_layout,
          unsigned power_line_number,
          unsigned tile_id,
          std::string ip,
          std::string impl,
          power_info_db_t &db);

    ~Power();

  public:
    unsigned tile_id;
    std::string ip;
    std::string impl;
    std::vector<OperatingPoint *> info;
    power_info_db_t db;

  private:
    QLabel *name;
    QLayout *parent_layout;
};

#endif // POWER_INFO_H

#ifndef ADDRESS_H
#define ADDRESS_H

#include <string>
#include <stdio.h>
#include <math.h>

#include <iomanip>

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

class Address : public QWidget
{
    Q_OBJECT

  public:
    Address(QGridLayout *parent_layout,
            unsigned address_line_number,
            unsigned cpu_arch_bits,
            unsigned tile_id,
            std::string ip,
            unsigned long long base,
            unsigned long long mask);

    ~Address();

  public:
    unsigned cpu_arch_bits;
    unsigned tile_id;
    std::string ip;
    unsigned lsb;
    unsigned msb;
    unsigned long long range;
    unsigned long long base;
    unsigned long long end;
    unsigned long long mask;
    unsigned long long size;
    unsigned shift;

    void set_conflicting(bool set);

signals:
    void addressMapChanged();

  private
slots:
    void on_address_size_currentIndexChanged(int arg1);
    void on_address_base_addressChanged();

  private:
    QLabel *name;
    QFrame *address_base_f;
    QHBoxLayout *address_base_lay;
    QLabel *address_base_head_l;
    std::vector<QLineEdit *> address_base;

    QFrame *address_size_f;
    QHBoxLayout *address_size_lay;
    QComboBox *address_size;

    QFrame *address_end_f;
    QHBoxLayout *address_end_lay;
    QLabel *address_end;

    QFrame *address_mask_f;
    QHBoxLayout *address_mask_lay;
    QLabel *address_mask;

    unsigned long long get_digit(unsigned long long x, unsigned i);
    void read_current_address();
    void update_address_base();
    void update_address_info();
};

#endif // ADDRESS_H

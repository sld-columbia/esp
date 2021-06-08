#ifndef ESPCREATOR_H
#define ESPCREATOR_H

#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>

#include <stdio.h>
#include <sys/sendfile.h> // sendfile
#include <fcntl.h>        // open
#include <unistd.h>       // close
#include <sys/stat.h>     // fstat
#include <sys/types.h>    // fstat
#include <ctime>

#include <QMainWindow>
#include <QFrame>

#include <tile.h>
#include <address_map.h>
#include <power_info.h>
#include "esp_constants.h"

using namespace socmap;

namespace Ui
{
class espcreator;
}

#define FOREACH_TILE(_y, _x)                                                             \
    for (int _y = 0; _y < (int)frame_tile.size(); _y++)                                  \
        for (int _x = 0; _x < (int)frame_tile[_y].size(); _x++)

#define FOREACH_ADDRESS(_i) for (int _i = 0; _i < (int)frame_address.size(); _i++)

#define REV_FOREACH_ADDRESS(_i)                                                          \
    for (int _i = (int)frame_address.size() - 1; _i >= 0; _i--)

#define FOREACH_ADDRESS_PAIR(_i, _j)                                                     \
    for (int _i = 0; _i < (int)frame_address.size(); _i++)                               \
        for (int _j = _i + 1; _j < (int)frame_address.size(); _j++)

#define REV_FOREACH_POW(_i) for (int _i = (int)frame_power.size() - 1; _i >= 0; _i--)

class espcreator : public QMainWindow
{
    Q_OBJECT

  public:
    espcreator(QWidget *parent,
               std::string noc_width,
               std::string tech_library,
               std::string mac_address);
    ~espcreator();

  private
slots:
    void on_pushButton_noc_clicked();
    void on_spinBox_nocy_valueChanged(int arg1);
    void on_spinBox_nocx_valueChanged(int arg1);
    // void on_pushButton_cfg_clicked();

    void on_checkBox_caches_toggled(bool arg1);

    void on_combo_arch_currentIndexChanged(const QString &arg1);

    void on_pushButton_addr_reset_clicked();

    void on_pushButton_addr_validate_clicked();

    void on_pushButton_addr_confirm_clicked();

    void on_pushButton_gen_clicked();

    void addressMapChanged();

    void on_pushButton_pow_confirm_clicked();

  private:
    Ui::espcreator *ui;
    unsigned int NOCX;
    unsigned int NOCY;
    std::string cpu_arch;

    std::vector<std::vector<Tile *> > frame_tile;
    std::vector<Address *> frame_address;
    std::vector<Power *> frame_power;
    power_info_db_t power_info_db;

    std::string get_ESP_MAC();
    std::string get_ESP_IP();
    std::string get_MAC_Addr(std::string mac);

    QString get_ok_bullet();
    QString get_err_bullet();
    void check_enable_noc_update();
    bool check_present(tile_t type);
    bool check_present(tile_t type, unsigned max_count);
    bool check_clock_domains();
    void update_address_map();
    void update_power_info();
};

#endif // ESPCREATOR_H

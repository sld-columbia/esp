// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef ESPMONMAIN_H
#define ESPMONMAIN_H

#include <QMainWindow>
#include <QMessageBox>
#include <QPushButton>
#include <QProgressBar>
#include <QGridLayout>
#include <QFont>
#include <QColor>
#include <Qt>
#include <QColorDialog>
#include <QtConcurrentRun>
#include <QHBoxLayout>
#include <QFile>
#include <QTextStream>

#include "mmi64_mon.h"
#include "power.h"

namespace Ui {
	class EspMonMain;
}

class EspMonMain;

class MmiWorker : public QObject {
	Q_OBJECT

		public:
	MmiWorker(EspMonMain *mon) {
		this->mon = mon;
	}

	//~MmiWorker();

	public slots:
	void process();

signals:
	void finished();
	void update();
	void error(QString err);

private:
	EspMonMain *mon;
};

class EspMonMain : public QMainWindow
{
	Q_OBJECT

public:
	explicit EspMonMain(QWidget *parent = 0);
	~EspMonMain();

	void ErrorMessage(const char * c_str);

	void enable_mmi_panel();
	void disable_mmi_panel();
	void enable_mmi_auto();

	void show_soc();
	void show_dvfs();
	void show_acc();
	void show_heatmap();

	void update_heatmap(int noc, float max, uint32_t (&probes_queue)[NOCS_NUM][TILES_NUM][DIRECTIONS]);

	void set_window(uint32_t win);
	void start_probes();
	bool read_probes();
	void get_statistics();
	void print_statistics(const char * file_name);

private slots:
	void on_btn_mmi_open_clicked();

	void on_dial_mmi_win_sliderMoved(int position);

	void on_btn_mmi_start_pressed();

	void on_btn_mmi_stop_clicked();

	void update_probes();

	void errorString(QString);

	void on_check_mmi_acc_toggled(bool checked);

	void on_check_mmi_dvfs_toggled(bool checked);

    void on_check_mmi_auto_toggled(bool checked);

    void on_btn_stat_ave_clicked();

    void on_btn_stat_max_clicked();

public:
	Ui::EspMonMain *ui;
	std::vector<QPushButton *> btn_tiles;
	std::vector<QProgressBar *> pbar_dvfs;
	std::vector<QProgressBar *> pbar_acc;
	QGridLayout *layout_heat;
	std::vector<QWidget *> wid_map[NOCS_NUM];
	std::vector<QWidget *> wid_map1[NOCS_NUM];

	unsigned long long router_is_active[NOCS_NUM][TILES_NUM];

	// MMI
	mmi64_mon *mmi;
	bool mmi_is_open;
	bool mmi_is_running;
	unsigned long long current_time;
	unsigned long long new_time;
	bool first_sample;
	bool ave_not_max;
	float power_tot[TILES_NUM];
	float power_max[TILES_NUM];
	float power_ave[TILES_NUM];
	double mem_compute_tot[ACCS_NUM];
	float mem_compute_max[ACCS_NUM];
	float mem_compute_ave[ACCS_NUM];
	double exec_compute_tot[ACCS_NUM];
	float exec_compute_max[ACCS_NUM];
	float exec_compute_ave[ACCS_NUM];

};

#endif // ESPMONMAIN_H

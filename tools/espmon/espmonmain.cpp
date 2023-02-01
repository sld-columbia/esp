// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "espmonmain.h"
#include "ui_espmonmain.h"

#include <string>
#include <sstream>
#include <ostream>
#include <fstream>
#include <iomanip>
#include <cassert>

template < typename T > std::string to_string( const T& n )
{
        std::ostringstream stm ;
        stm << n ;
        return stm.str() ;
}


EspMonMain::EspMonMain(QWidget *parent) :
	QMainWindow(parent),
	ui(new Ui::EspMonMain),
	mmi(new mmi64_mon)
{
	ui->setupUi(this);

	// MMI
	mmi_is_open = false;
	mmi_is_running = false;
	ave_not_max = true;

	// Build panels
	show_soc();
	show_dvfs();
	show_acc();
	show_heatmap();
}

EspMonMain::~EspMonMain()
{
	// Close MMI to avoid deadlock on next open
	profpga_error_t status __attribute__((unused));
	if (mmi_is_open)
		status = mmi->close_system();

	delete ui;
}

void EspMonMain::ErrorMessage(const char * c_str)
{
	std::ostringstream stm;
	stm << "Error: " << c_str;
	QMessageBox messageBox;
	messageBox.critical(0,"Error", stm.str().c_str());
	messageBox.setFixedSize(500,200);
}

void EspMonMain::errorString(QString str)
{
	QMessageBox messageBox;
	messageBox.critical(0,"Error", str);
	messageBox.setFixedSize(500,200);
}

void EspMonMain::show_soc()
{
	for (int i = 0; i < TILES_NUM; i++) {
		const struct tile_info *t = &tiles[i];
		QPushButton *btn = new QPushButton();
		std::ostringstream stm;
		stm << i << ". " << t->name;
		btn->setText(stm.str().c_str());
		QFont f("Arial", 13, -1, false);
		btn->setFont(f);
                std::string color_html;
		if (t->type == (int) cpu_tile) {
			color_html="#fd8276";
		} else if (t->type == (int) accelerator_tile) {
			color_html="#8ad0c5";
		} else if (t->type == (int) empty_tile) {
			color_html="#e5e5e5";
		} else {
			color_html="#84bcf2";
		}
		QColor col(color_html.c_str());
		QString qss = QString("background-color: %1").arg(col.name());
		btn->setStyleSheet(qss);
		btn->setMinimumHeight(50);

		btn_tiles.push_back(btn);
		ui->layout_soc->addWidget(btn, t->position.y, t->position.x, 1, 1);
	}
}

// Less contrast
// static const QColor heat_no("#00BF9B");
// static const QColor heat_00("#00C264");
// static const QColor heat_10("#00C62B");
// static const QColor heat_20("#10CA00");
// static const QColor heat_30("#4FCE00");
// static const QColor heat_40("#8FD200");
// static const QColor heat_50("#D2D500");
// static const QColor heat_60("#D99B00");
// static const QColor heat_70("#DD5C00");
// static const QColor heat_80("#E11A00");
// static const QColor heat_90("#E50029");

// More constrast
//static const QColor heat_no("#007CBF");
static const QColor heat_no("#dfdfdf");
static const QColor heat_00("#00C2C2");
static const QColor heat_10("#00C67F");
static const QColor heat_20("#00CA3A");
static const QColor heat_30("#0CCE00");
static const QColor heat_40("#57D200");
static const QColor heat_50("#A4D500");
static const QColor heat_60("#D9BE00");
static const QColor heat_70("#DD7300");
static const QColor heat_80("#E12600");
static const QColor heat_90("#E50029");

static const QColor heat_250("#0CCE00");
static const QColor heat_375("#57D200");
static const QColor heat_500("#A4D500");
static const QColor heat_625("#D9BE00");
static const QColor heat_750("#DD7300");
static const QColor heat_875("#E12600");
static const QColor heat_1000("#E50029");

// Even more contrast
// static const QColor heat_no("#000BBF");
// static const QColor heat_00("#008BBF");
// static const QColor heat_10("#00C3AD");
// static const QColor heat_20("#00C765");
// static const QColor heat_30("#00CB19");
// static const QColor heat_40("#35CF00");
// static const QColor heat_50("#87D400");
// static const QColor heat_60("#D8D400");
// static const QColor heat_70("#DC8300");
// static const QColor heat_80("#E03000");
// static const QColor heat_90("#E50025");

// white to red
// static const QColor heat_no("#ffffff");
// static const QColor heat_00("#fffcec");
// static const QColor heat_10("#fff00c");
// static const QColor heat_20("#fee8c8");
// static const QColor heat_30("#fdd49e");
// static const QColor heat_40("#fdbb84");
// static const QColor heat_50("#fc8d59");
// static const QColor heat_60("#ef6548");
// static const QColor heat_70("#d7301f");
// static const QColor heat_80("#b30000");
// static const QColor heat_90("#7f0000");

void EspMonMain::show_heatmap()
{
	layout_heat = new QGridLayout();
	layout_heat->setSpacing(1);

	ui->layout_frame_heat->addLayout(layout_heat);

	for (int y = 0; y < YLEN * 6; y++)
		for (int x = 0; x < XLEN * 6; x++)
			for (int h = 0; h < NOCS_NUM; h++) {
				QPalette Pal(palette());
				Pal.setColor(QPalette::Background, heat_no);
				QWidget *w = new QWidget();
				w->setAutoFillBackground(true);
				w->setPalette(Pal);

				QSizePolicy sizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
				sizePolicy.setHorizontalStretch(0);
				sizePolicy.setVerticalStretch(0);
				sizePolicy.setHeightForWidth(w->sizePolicy().hasHeightForWidth());
				w->setSizePolicy(sizePolicy);
				w->setMinimumSize(QSize(9, 9));

				int y0 = (y * NOCS_NUM) + h;
				int x0 = (x * NOCS_NUM) + h;
				wid_map[h].push_back(w);
				layout_heat->addWidget(w, y0, x0, 1, 1);

				QPalette Pal1(palette());
				Pal1.setColor(QPalette::Background, heat_no);
				QWidget *w1 = new QWidget();
				w1->setAutoFillBackground(true);
				w1->setPalette(Pal);

				QSizePolicy sizePolicy1(QSizePolicy::Fixed, QSizePolicy::Fixed);
				sizePolicy1.setHorizontalStretch(0);
				sizePolicy1.setVerticalStretch(0);
				sizePolicy1.setHeightForWidth(w->sizePolicy().hasHeightForWidth());
				w1->setSizePolicy(sizePolicy1);
				w1->setMinimumSize(QSize(9, 9));

				if ((x0 % (6 * NOCS_NUM)) < (2 * NOCS_NUM)) {
					if ((y0 % 2) == 0)
						layout_heat->addWidget(w1, y0, x0 + 1, 1, 1);
					else
						layout_heat->addWidget(w1, y0, x0 - 1, 1, 1);
				} else if ((x0 % (6 * NOCS_NUM)) < (4 * NOCS_NUM)) {
					if ((y0 % 2) == 0)
						layout_heat->addWidget(w1, y0 + 1, x0, 1, 1);
					else
						layout_heat->addWidget(w1, y0 - 1, x0, 1, 1);

				} else {
					if ((y0 % 2) == 0)
						layout_heat->addWidget(w1, y0, x0 + 1, 1, 1);
					else
						layout_heat->addWidget(w1, y0, x0 - 1, 1, 1);
				}
				wid_map1[h].push_back(w1);

			}

	for (int i = 0; i < TILES_NUM; i++)
		for (int h = 0; h < NOCS_NUM; h++)
			router_is_active[h][i] = 0;
}

void EspMonMain::show_dvfs()
{
	for (int i = 0; i < TILES_NUM; i++) {
		QProgressBar *pb = new QProgressBar();
		pb->setOrientation(Qt::Vertical);

#ifndef DVFS_offset
		pb->setEnabled(false);
#endif
		pbar_dvfs.push_back(pb);
		const struct tile_info *t = &tiles[i];
		if (t->type == accelerator_tile)
			// Do not show other tiles for now
			ui->layout_power->addWidget(pb);
	}

	for (int i = 0; i < TILES_NUM; i++) {
		const struct tile_info *t = &tiles[i];
		if (t->type != accelerator_tile)
			continue;

		QLabel *label_power = new QLabel(ui->frame_4);
		std::ostringstream stm;
		stm << i;
		label_power->setObjectName(stm.str().c_str());
		label_power->setText(stm.str().c_str());
		ui->layout_power_label->addWidget(label_power);
	}

}

void EspMonMain::show_acc()
{
	for (int i = 0; i < ACCS_NUM; i++) {
		QProgressBar *pb = new QProgressBar();
		pb->setOrientation(Qt::Vertical);

#ifndef ACC_offset
		pb->setEnabled(false);
#endif
		pbar_acc.push_back(pb);
		ui->layout_acc->addWidget(pb);
	}

	for (int i = 0; i < TILES_NUM; i++) {
		const struct tile_info *t = &tiles[i];
		if (t->type != accelerator_tile)
			continue;

		QLabel *label_acc = new QLabel(ui->frame_5);
		std::ostringstream stm;
		stm << i;
		label_acc->setObjectName(stm.str().c_str());
		label_acc->setText(stm.str().c_str());
		ui->layout_acc_label->addWidget(label_acc);
	}

}

void EspMonMain::enable_mmi_panel()
{
	ui->check_mmi_ddr->setEnabled(true);
#ifdef NOC_QUEUES_offset
	ui->check_mmi_traffic->setEnabled(true);
#endif
#ifdef ACC_offset
	ui->check_mmi_acc->setEnabled(true);
#endif
#ifdef DVFS_offset
	ui->check_mmi_dvfs->setEnabled(true);
#endif
	if (ui->check_mmi_acc->isChecked() ||
	    ui->check_mmi_dvfs->isChecked())
		ui->check_mmi_auto->setEnabled(true);

	if (!ui->check_mmi_auto->isChecked()) {
		ui->btn_mmi_start->setEnabled(true);
		ui->dial_mmi_win->setEnabled(true);
	}

	ui->label_mmi_win->setEnabled(true);
	ui->label_mmi_win_fixed->setEnabled(true);
	ui->feedback->setEnabled(true);
}

void EspMonMain::disable_mmi_panel()
{
	ui->check_mmi_ddr->setEnabled(false);
	ui->check_mmi_traffic->setEnabled(false);
	ui->check_mmi_acc->setEnabled(false);
	ui->check_mmi_dvfs->setEnabled(false);
	ui->check_mmi_auto->setEnabled(false);
	ui->btn_mmi_start->setEnabled(false);
	ui->dial_mmi_win->setEnabled(false);
	ui->label_mmi_win->setEnabled(false);
	ui->label_mmi_win_fixed->setEnabled(false);
	ui->feedback->setEnabled(false);

	ui->btn_stat_ave->setEnabled(false);
	ui->btn_stat_max->setEnabled(false);
}

void EspMonMain::on_btn_mmi_open_clicked()
{
	profpga_error_t status;
	if (mmi_is_open)
		status = mmi->close_system();
	else
		status = mmi->open_system();

	if (status == E_PROFPGA_OK) {
		if (mmi_is_open) {
			mmi_is_open = false;
			ui->btn_mmi_open->setText("Connect");
			disable_mmi_panel();
		} else {
			mmi64_error_t mmi_status;
			mmi_status = mmi->get_user_module();
			if (mmi_status == E_MMI64_OK) {
				mmi_is_open = true;
				ui->btn_mmi_open->setText("Disconnect");
				enable_mmi_panel();
				uint32_t win = 1 << ui->dial_mmi_win->value();
				set_window(win);
			} else {
				status = mmi->close_system();
				std::ostringstream stm;
				stm << "Failed to find MMI user module (" << mmi64_strerror(mmi_status) << ")";
				const char *err = stm.str().c_str();
				ErrorMessage(err);
			}
		}
	} else {
		std::ostringstream stm;
		stm << "Failed connect to PROFPGA system (" << profpga_strerror(status) << ")";
		const char *err = stm.str().c_str();
		ErrorMessage(err);
	}
}

void EspMonMain::set_window(uint32_t win)
{
	mmi64_error_t status = mmi->set_window(win);
	if (status != E_MMI64_OK) {
		std::ostringstream stm;
		stm << "Failed to write window size (" << mmi64_strerror(status) << ")";
		const char *err = stm.str().c_str();
		ErrorMessage(err);
	}
}

void EspMonMain::on_dial_mmi_win_sliderMoved(int position)
{
	ui->dial_mmi_win->setValue(position);
	ui->label_mmi_win->setText(to_string<int>(position).c_str());
	uint32_t win = 1 << position;
	set_window(win);
}

bool EspMonMain::read_probes()
{
	mmi64_error_t status;
	status = mmi->read_timestamp();
	if (status != E_MMI64_OK)
		ErrorMessage(mmi64_strerror(status));

	if (current_time == mmi->current_time)
		return false;
	new_time = mmi->current_time;

#ifdef NOC_QUEUES_offset
	if (ui->check_mmi_traffic->isChecked()) {
		status = mmi->read_queues();
		if (status != E_MMI64_OK)
			ErrorMessage(mmi64_strerror(status));
	}
#endif

#ifdef DVFS_offset
	if (ui->check_mmi_dvfs->isChecked()) {
		status = mmi->read_dvfs();
		if (status != E_MMI64_OK)
			ErrorMessage(mmi64_strerror(status));
	}
#endif

#ifdef ACC_offset
	if (ui->check_mmi_acc->isChecked()) {
		status = mmi->read_accs();
		if (status != E_MMI64_OK)
			ErrorMessage(mmi64_strerror(status));
	}
#endif
	return true;
}

static QColor get_color_heatmap(unsigned long long probe, float max)
{
	float rate = 100 * probe / max;
#ifdef SIGNATURE_offset
	if (rate >= 100)
		return heat_1000;
	if (rate > 87.5)
		return heat_875;
	if (rate > 75)
		return heat_750;
	if (rate > 62.5)
		return heat_625;
	if (rate > 50)
		return heat_500;
	if (rate > 37.5)
		return heat_375;
	if (rate > 25)
		return heat_250;
	if (rate > 0)
		return heat_00;
	return heat_no;
#else
	if (rate > 90)
		return heat_90;
	if (rate > 80)
		return heat_80;
	if (rate > 70)
		return heat_70;
	if (rate > 60)
		return heat_60;
	if (rate > 50)
		return heat_50;
	if (rate > 40)
		return heat_40;
	if (rate > 30)
		return heat_30;
	if (rate > 20)
		return heat_20;
	if (rate > 10)
		return heat_10;
	if (rate > 0)
		return heat_00;
	return heat_no;
#endif
}

#ifdef NOC_QUEUES_offset
void EspMonMain::update_heatmap(int noc, float max, uint32_t (&probes_queue)[NOCS_NUM][TILES_NUM][DIRECTIONS])
{
	const int N = 6;
	for (int i = 0; i < TILES_NUM; i++)
		router_is_active[noc][i] = 0;

	for (int i = 0; i < TILES_NUM; i++) {
		const struct tile_info *t = &tiles[i];
		// Notrth out
		int y0 = N * t->position.y + 2;
		int x0 = N * t->position.x + 2;
		if (t->position.y != 0) {
			QColor col = get_color_heatmap(probes_queue[noc][i][0], max);
			router_is_active[noc][(t->position.y) * XLEN + t->position.x] += probes_queue[noc][i][0];
			for (int y = 1; y < N-1; y++) {
				QPalette Pal(palette());
				Pal.setColor(QPalette::Background, col);
				wid_map[noc][(y0 - y) * N * XLEN + x0]->setPalette(Pal);
				wid_map1[noc][(y0 - y) * N * XLEN + x0]->setPalette(Pal);
			}
		}

		// South out
		y0 = N * t->position.y + 3;
		x0 = N * t->position.x + 3;
		if (t->position.y != YLEN - 1) {
			QColor col = get_color_heatmap(probes_queue[noc][i][1], max);
			router_is_active[noc][(t->position.y) * XLEN + t->position.x] += probes_queue[noc][i][1];
			for (int y = 1; y < N-1; y++) {
				QPalette Pal(palette());
				Pal.setColor(QPalette::Background, col);
				wid_map[noc][(y0 + y) * N * XLEN + x0]->setPalette(Pal);
				wid_map1[noc][(y0 + y) * N * XLEN + x0]->setPalette(Pal);
			}
		}

		// West out
		y0 = N * t->position.y + 3;
		x0 = N * t->position.x + 2;
		if (t->position.x != 0) {
			QColor col = get_color_heatmap(probes_queue[noc][i][2], max);
			router_is_active[noc][t->position.y * XLEN + t->position.x] += probes_queue[noc][i][2];
			for (int x = 1; x < N-1; x++) {
				QPalette Pal(palette());
				Pal.setColor(QPalette::Background, col);
				wid_map[noc][y0 * N * XLEN + x0 - x]->setPalette(Pal);
				wid_map1[noc][y0 * N * XLEN + x0 - x]->setPalette(Pal);
			}
		}

		// East out
		y0 = N * t->position.y + 2;
		x0 = N * t->position.x + 3;
		if (t->position.x != XLEN - 1) {
			QColor col = get_color_heatmap(probes_queue[noc][i][3], max);
			router_is_active[noc][t->position.y * XLEN + t->position.x] += probes_queue[noc][i][3];
			for (int x = 1; x < N-1; x++) {
				QPalette Pal(palette());
				Pal.setColor(QPalette::Background, col);
				wid_map[noc][y0 * N * XLEN + x0 + x]->setPalette(Pal);
				wid_map1[noc][y0 * N * XLEN + x0 + x]->setPalette(Pal);
			}
		}
	}

	// Routers
	for (int i = 0; i < TILES_NUM; i++) {
		const struct tile_info *t = &tiles[i];
		// Notrth out
		int y0 = N * t->position.y + 2;
		int y1 = N * t->position.y + 3;
		int x0 = N * t->position.x + 2;
		int x1 = N * t->position.x + 3;
		QPalette Pal0(palette());
		QPalette Pal1(palette());
		QPalette Pal2(palette());
		QPalette Pal3(palette());
		//QColor col = get_color_heatmap(router_is_active[noc][i], max);
		QColor col;
		if (noc % NOCS_NUM == 0)
			col = QColor("#bfbfbf");
		else
			col = QColor("#7f7f7f");

		Pal0.setColor(QPalette::Background, col);
		Pal1.setColor(QPalette::Background, col);
		Pal2.setColor(QPalette::Background, col);
		Pal3.setColor(QPalette::Background, col);
		wid_map[noc][y0 * N * XLEN + x0]->setPalette(Pal0);
		wid_map[noc][y0 * N * XLEN + x1]->setPalette(Pal1);
		wid_map[noc][y1 * N * XLEN + x0]->setPalette(Pal2);
		wid_map[noc][y1 * N * XLEN + x1]->setPalette(Pal3);
	}
}
#endif


void EspMonMain::update_probes()
{
	const float max = 0.8 * (1<<ui->dial_mmi_win->value());

	if (first_sample) {
		first_sample = false;
		mmi->probes_statistics_reset();
		for (int k = 0; k < TILES_NUM; k++) {
			power_tot[k] = 0.0;
			power_max[k] = 0.0;
		}
		for (int k = 0; k < ACCS_NUM; k++) {
			mem_compute_tot[k] = 0.0;
			mem_compute_max[k] = 0.0;
			exec_compute_tot[k] = 0.0;
			exec_compute_max[k] = 0.0;
		}
		ui->label_mmi_warn->setText("");
	} else {
		if (new_time > current_time + 1)
			ui->label_mmi_warn->setText("Data loss!");
	}
	current_time = new_time;
	std::ostringstream stm;
	stm << current_time;
	ui->feedback->setText(stm.str().c_str());

#ifdef NOC_QUEUES_offset
	if (ui->check_mmi_traffic->isChecked())
		for (int h = 0; h < NOCS_NUM; h++) {
#ifdef SIGNATURE_offset
			const float max_noc_queues = (1<<ui->dial_mmi_win->value());
#else
			const float max_noc_queues = max;
#endif
			update_heatmap(h, max_noc_queues, mmi->probes_queue);
		}
#endif
#ifdef DVFS_offset
	if (ui->check_mmi_dvfs->isChecked()) {
		for (int k = 0; k < TILES_NUM; k++) {
			float pow = 0;
			const struct tile_info *t = &tiles[k];
			if (t->type != accelerator_tile)
				continue;
			// computing pJ / ns -> mW
			assert(period[k][VF_OP_POINTS - 1] != 0);
			const float pow_max = energy_weight[k][VF_OP_POINTS - 1] / period[k][VF_OP_POINTS - 1];
			for (int i = 0; i < VF_OP_POINTS; i++) {
				assert(period[k][i] != 0);
				assert(pow_max != 0);
				float weight = (100.0 * (energy_weight[k][i] / period[k][i])) / pow_max;
				pow += mmi->probes_dvfs[k][i] * weight;
			}

			// Record power max and ave for later
			power_tot[k] += pow;
			assert(mmi->current_time - mmi->sample_start != 0);
			power_ave[k] = power_tot[k] / (mmi->current_time - mmi->sample_start);
			if (pow > power_max[k])
				power_max[k] = pow;

			assert(max != 0);
			float bar_value = pow / max;
			if (bar_value != 0 && bar_value < 1)
				bar_value = 1.0;
			pbar_dvfs[k]->setValue(bar_value);
		}
	}
#endif

#ifdef ACC_offset
	if (ui->check_mmi_acc->isChecked()) {
		for (int k = 0; k < ACCS_NUM; k++) {
			float mem = 0.0;
			float tot = 0.0;
			float mem_compute = 0.0;
			float exec_compute = 0.0;
			mem += mmi->probes_acc[k][0]; // TLB
			mem += mmi->probes_acc[k][1]; // DMA
			tot += mmi->probes_acc[k][2]; // TOT
			if (tot == 0.0) {
                                pbar_acc[k]->setValue(mem_compute);
				continue;
                        }
			mem_compute = (100.0 * mem) / tot;
			exec_compute = (100.0 * tot) / max;

			// Record memory over computation ratio for later
			mem_compute_tot[k] += mem_compute;
			mem_compute_ave[k] = mem_compute_tot[k] / (mmi->current_time - mmi->sample_start);
			exec_compute_tot[k] += exec_compute;
			exec_compute_ave[k] = exec_compute_tot[k] / (mmi->current_time - mmi->sample_start);
			if (mem_compute > mem_compute_max[k])
				mem_compute_max[k] = mem_compute;
			if (exec_compute > exec_compute_max[k])
				exec_compute_max[k] = exec_compute;

			pbar_acc[k]->setValue(mem_compute);
		}
	}
#endif
}


void MmiWorker::process()
{
	bool relevant_sample = false;
	bool auto_start = mon->ui->check_mmi_auto->isChecked();
        unsigned no_activity_counter = 4;
	while(mon->mmi_is_running) {
		if(mon->read_probes()) {
			if (mon->mmi->relevant_sample() || !auto_start) {
				relevant_sample = true;
				emit update();
                                no_activity_counter = 4;
			} else {
				if (relevant_sample) {
					emit update();
                                        no_activity_counter--;

                                        if (no_activity_counter == 0)
                                            break;
				}
			}
		}
	}
	emit finished();
	usleep(1000);
	mon->ui->feedback->setText("Not Sampling");
	mon->ui->check_mmi_auto->setChecked(false);
}

void EspMonMain::start_probes()
{
	ui->btn_mmi_open->setEnabled(false);
	disable_mmi_panel();

	mmi_is_running = true;
	first_sample = true;

	// Create and connect MmiWorker
	MmiWorker *mwk = new MmiWorker(this);
	QThread *mth = new QThread();
	mwk->moveToThread(mth);
	connect(mwk, SIGNAL(error(QString)), this, SLOT(errorString(QString)));
	connect(mth, SIGNAL(started()), mwk, SLOT(process()));
	connect(mwk, SIGNAL(finished()), mth, SLOT(quit()));
	connect(mwk, SIGNAL(finished()), mwk, SLOT(deleteLater()));
	connect(mth, SIGNAL(finished()), mth, SLOT(deleteLater()));
	connect(mwk, SIGNAL(update()), this, SLOT(update_probes()));

	mth->start();
}

void EspMonMain::on_btn_mmi_start_pressed()
{
	ui->btn_mmi_stop->setEnabled(true);
	start_probes();
}

void EspMonMain::on_btn_mmi_stop_clicked()
{
	mmi_is_running = false;
	if (ui->check_mmi_auto->isChecked()) {
		ui->check_mmi_auto->setChecked(false);
	} else {
		ui->btn_mmi_stop->setEnabled(false);
		get_statistics();
		enable_mmi_panel();
		ui->btn_mmi_open->setEnabled(true);
	}
}

void EspMonMain::enable_mmi_auto()
{
	if (ui->check_mmi_acc->isChecked() ||
	    ui->check_mmi_dvfs->isChecked()) {
		ui->check_mmi_auto->setEnabled(true);
	} else {
		ui->check_mmi_auto->setChecked(false);
		ui->check_mmi_auto->setEnabled(false);
	}
}

void EspMonMain::on_check_mmi_acc_toggled(bool checked __attribute__((unused)))
{
	enable_mmi_auto();
}

void EspMonMain::on_check_mmi_dvfs_toggled(bool checked __attribute__((unused)))
{
	enable_mmi_auto();
}

void EspMonMain::on_check_mmi_auto_toggled(bool checked)
{
	if (checked) {
		ui->btn_mmi_stop->setEnabled(true);
		start_probes();
	} else {
		mmi_is_running = false;
		ui->btn_mmi_stop->setEnabled(false);
		get_statistics();
		enable_mmi_panel();
		ui->btn_mmi_open->setEnabled(true);
	}
}

void EspMonMain::get_statistics()
{
	// Open report file using time stamp from mmi
        std::ostringstream file_name_max;
        std::ostringstream file_name_ave;
	file_name_max << "espmon_max" << mmi->current_time << ".rpt";
	file_name_ave << "espmon_ave" << mmi->current_time << ".rpt";
	std::ofstream rpt_max;
	std::ofstream rpt_ave;
	rpt_max.open(file_name_max.str().c_str());
	rpt_ave.open(file_name_ave.str().c_str());

	// Enable statistics toggle push buttons
	ui->btn_stat_ave->setEnabled(true);
	ui->btn_stat_max->setEnabled(true);

	// Note that these are the number of cycles in a window.
	// The 0.8 factor is needed to account for the scaling between
	// 100 MHz (mmi_clk) and 80 MHz (clkm)
	const float max = 0.8 * (1<<ui->dial_mmi_win->value());


#ifdef DVFS_offset
	if (ui->check_mmi_dvfs->isChecked()) {
		float total_energy = 0.0;
		rpt_max << "=== Maximum Power (mW) ===" << std::endl;
		rpt_ave << "=== Average Power (mW) and Total Energy ===" << std::endl;
		for (int k = 0; k < TILES_NUM; k++) {
			float pow = 0;
			const struct tile_info *t = &tiles[k];
			if (t->type != accelerator_tile)
				continue;
			const float pow_max = energy_weight[k][VF_OP_POINTS - 1] / period[k][VF_OP_POINTS - 1];
			if (ave_not_max)
				pow = power_ave[k];
			else
				pow = power_max[k];

			float bar_value = pow / max;
			if (bar_value != 0 && bar_value < 1)
				bar_value = 1.0;
			pbar_dvfs[k]->setValue(bar_value);

			// TODO: if we change sample window before printing the log, we'll print it wrong!
			// Execution time in ns (no need to scale because target fastest clock cycle is 1ns)
			float exec_time = (mmi->current_time - mmi->sample_start) * (1<<ui->dial_mmi_win->value());
			rpt_max << k << ". " << t->name << ": ";
			rpt_ave << k << ". " << t->name << ": ";
			rpt_max << std::setprecision(5) << "  " << (power_max[k] / max) * pow_max / 100.0 << "mW" << std::endl;
			rpt_ave << std::setprecision(5) << "  " << (power_ave[k] / max) * pow_max / 100.0 << "mW, ";
			float en = exec_time * (power_ave[k] / max) * pow_max / 100.0;
			rpt_ave << std::setprecision(5) << "  " << en << "pJ" << std::endl;
			total_energy += en;
		}
		rpt_ave << " ** Total Energy: " << std::setprecision(5) << "  " << total_energy << "pj **"  << std::endl;
	}

	rpt_max << std::endl;
	rpt_ave << std::endl;

#endif

#ifdef NOC_QUEUES_offset
	/*
	 * N = 0
	 * S = 1
	 * W = 2
	 * E = 3
	 * L = 4
	 */
	float global_ave_bandwidth = 0.0;
	if (ui->check_mmi_traffic->isChecked()) {
		for (int h = 0; h < NOCS_NUM; h++) {
			if (ave_not_max)
				update_heatmap(h, max, mmi->probes_queue_ave);
			else
				update_heatmap(h, max, mmi->probes_queue_max);
			if (h == 0) {
				rpt_max << "=== DMA Mem-to-Dev ===" << std::endl;
				rpt_ave << "=== DMA Mem-to-Dev ===" << std::endl;
			} else {
				rpt_max << "=== DMA Dev-to-Mem ===" << std::endl;
				rpt_ave << "=== DMA Dev-to-Mem ===" << std::endl;
			}
			rpt_max << "  Maximum Link Activity % (N, S, W, E, L) ===" << std::endl;
			rpt_ave << "  Average Link Activity % (N, S, W, E, L) ===" << std::endl;
			for (int k = 0; k < TILES_NUM; k++) {
				const struct tile_info *t = &tiles[k];
				rpt_max << k << ". " << t->name << ": ";
				rpt_ave << k << ". " << t->name << ": ";
				for (int i = 0; i < DIRECTIONS; i++) {
					rpt_max << std::setprecision(5) << (100.0 * mmi->probes_queue_max[h][k][i]) / max << "%, ";
					rpt_ave << std::setprecision(5) << (100.0 * mmi->probes_queue_ave[h][k][i]) / max << "%, ";
					global_ave_bandwidth += (100 * mmi->probes_queue_ave[h][k][i]) / max;
				}
				rpt_max << std::endl;
				rpt_ave << std::endl;
			}
			rpt_max << std::endl;
			rpt_ave << std::endl;
		}
		global_ave_bandwidth /= ((NOCS_NUM * TILES_NUM * DIRECTIONS) - (2 * (XLEN + YLEN) * NOCS_NUM));
		rpt_ave << " ** Average Bandwidth: " << std::setprecision(5) << "  " << global_ave_bandwidth << "% **"  << std::endl;
	}
	rpt_max << std::endl;
	rpt_ave << std::endl;
#endif

#ifdef ACC_offset
	if (ui->check_mmi_acc->isChecked()) {
		rpt_max << "=== Maximum Communication over Execution Time ratio (%) ===" << std::endl;
		rpt_ave << "=== Average Communication over Execution Time ratio (%) ===" << std::endl;
		int accelerator = 0;
		for (int k = 0; k < TILES_NUM; k++) {
			const struct tile_info *t = &tiles[k];
			if (t->type != accelerator_tile)
				continue;

			if (ave_not_max)
				pbar_acc[accelerator]->setValue(mem_compute_ave[accelerator]);
			else
				pbar_acc[accelerator]->setValue(mem_compute_max[accelerator]);

			rpt_max << k << ". " << t->name << ": ";
			rpt_ave << k << ". " << t->name << ": ";
			rpt_max << std::setprecision(5) << mem_compute_max[accelerator] << "%" << std::endl;
			rpt_ave << std::setprecision(5) << mem_compute_ave[accelerator] << "%" << std::endl;
			accelerator++;
		}
		rpt_max << "=== Maximum Total Execution Time ratio (%) ===" << std::endl;
		rpt_ave << "=== Average Total Execution Time ratio (%) ===" << std::endl;
		accelerator = 0;
		for (int k = 0; k < TILES_NUM; k++) {
			const struct tile_info *t = &tiles[k];
			if (t->type != accelerator_tile)
				continue;

			rpt_max << k << ". " << t->name << ": ";
			rpt_ave << k << ". " << t->name << ": ";
			rpt_max << std::setprecision(5) << exec_compute_max[accelerator] << "%" << std::endl;
			rpt_ave << std::setprecision(5) << exec_compute_ave[accelerator] << "%" << std::endl;
			accelerator++;
		}

		rpt_max << std::endl << "=== Samping time ===" << (mmi->current_time - mmi->sample_start) * (1<<ui->dial_mmi_win->value()) * 10 << " ns" << std::endl;
		rpt_ave << std::endl << "=== Samping time ===" << (mmi->current_time - mmi->sample_start) * (1<<ui->dial_mmi_win->value()) * 10 << " ns" << std::endl;
	}
#endif

	rpt_max.close();
	rpt_ave.close();

	if (ave_not_max)
		print_statistics(file_name_ave.str().c_str());
	else
		print_statistics(file_name_max.str().c_str());

}

void EspMonMain::print_statistics(const char *file_name)
{
	QFile file(file_name);
	file.open(QIODevice::ReadOnly);
	QTextStream in(&file);
	ui->textBrowser->setText(in.readAll());
}

void EspMonMain::on_btn_stat_ave_clicked()
{
	ave_not_max = true;
	get_statistics();
}

void EspMonMain::on_btn_stat_max_clicked()
{
	ave_not_max = false;
	get_statistics();
}

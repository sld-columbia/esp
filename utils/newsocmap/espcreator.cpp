#include "espcreator.h"
#include "ui_espcreator.h"


//
// Constructor
//


espcreator::espcreator(QWidget *parent, std::string noc_width,
        std::string tech_library, std::string mac_address) :
    QMainWindow(parent),
	ui(new Ui::espcreator)
{
	NOCX = 0;
	NOCY = 0;
    cpu_arch = TOSTRING(CPU_ARCH);
    std::string mac_addr = get_MAC_Addr(mac_address);

    ui->setupUi(this);
    ui->lineEdit_mac->setText(mac_addr.c_str());
	ui->lineEdit_tech->setText(tech_library.c_str());
	ui->lineEdit_board->setText(TOSTRING(BOARD));
    ui->combo_arch->addItem("leon3");
    ui->combo_arch->addItem("ariane");
    ui->combo_arch->setEditable(true);
    ui->combo_arch->lineEdit()->setReadOnly(true);
    ui->combo_arch->lineEdit()->setAlignment(Qt::AlignCenter);
    /* ui->lineEdit_arch->setText("leon3"); */
    ui->lineEdit_nocw->setText("32");
    // ui->lineEdit_nocw->setText("64");
    ui->lineEdit_espmac->setText(get_ESP_MAC().c_str());
    ui->lineEdit_espip->setText(get_ESP_IP().c_str());

    ui->combo_l2_ways->addItem("2 ways");
    ui->combo_l2_ways->addItem("4 ways");
    ui->combo_l2_ways->addItem("8 ways");
    ui->combo_l2_ways->setCurrentIndex(1);
    ui->combo_l2_ways->setEnabled(false);

    ui->combo_l2_sets->addItem("32 sets");
    ui->combo_l2_sets->addItem("64 sets");
    ui->combo_l2_sets->addItem("128 sets");
    ui->combo_l2_sets->addItem("256 sets");
    ui->combo_l2_sets->addItem("512 sets");
    ui->combo_l2_sets->addItem("1024 sets");
    ui->combo_l2_sets->addItem("2048 sets");
    ui->combo_l2_sets->addItem("4096 sets");
    ui->combo_l2_sets->setCurrentIndex(4);
    ui->combo_l2_sets->setEnabled(false);

    ui->combo_llc_ways->addItem("4 ways");
    ui->combo_llc_ways->addItem("8 ways");
    ui->combo_llc_ways->addItem("16 ways");
    ui->combo_llc_ways->setCurrentIndex(2);
    ui->combo_llc_ways->setEnabled(false);

    ui->combo_llc_sets->addItem("32 sets");
    ui->combo_llc_sets->addItem("64 sets");
    ui->combo_llc_sets->addItem("128 sets");
    ui->combo_llc_sets->addItem("256 sets");
    ui->combo_llc_sets->addItem("512 sets");
    ui->combo_llc_sets->addItem("1024 sets");
    ui->combo_llc_sets->addItem("2048 sets");
    ui->combo_llc_sets->addItem("4096 sets");
    ui->combo_llc_sets->setCurrentIndex(5);
    ui->combo_llc_sets->setEnabled(false);

    ui->combo_al2_ways->addItem("2 ways");
    ui->combo_al2_ways->addItem("4 ways");
    ui->combo_al2_ways->addItem("8 ways");
    ui->combo_al2_ways->setCurrentIndex(1);
    ui->combo_al2_ways->setEnabled(false);

    ui->combo_al2_sets->addItem("32 sets");
    ui->combo_al2_sets->addItem("64 sets");
    ui->combo_al2_sets->addItem("128 sets");
    ui->combo_al2_sets->addItem("256 sets");
    ui->combo_al2_sets->addItem("512 sets");
    ui->combo_al2_sets->addItem("1024 sets");
    ui->combo_al2_sets->addItem("2048 sets");
    ui->combo_al2_sets->addItem("4096 sets");
    ui->combo_al2_sets->setCurrentIndex(4);
    ui->combo_al2_sets->setEnabled(false);

    ui->combo_implem->addItem("SystemVerilog");
    ui->combo_implem->addItem("SystemC (HLS)");
    ui->combo_implem->setEnabled(false);

	ui->pushButton_gen->setEnabled(true);
}

void espcreator::on_checkBox_caches_toggled(bool arg1)
{
    if (arg1 == false)
    {
        ui->combo_l2_ways->setEnabled(false);
        ui->combo_l2_sets->setEnabled(false);
        ui->combo_llc_ways->setEnabled(false);
        ui->combo_llc_sets->setEnabled(false);
        ui->combo_al2_ways->setEnabled(false);
        ui->combo_al2_sets->setEnabled(false);
        ui->combo_implem->setEnabled(false);
    }
    else
    {
        ui->combo_l2_ways->setEnabled(true);
        ui->combo_l2_sets->setEnabled(true);
        ui->combo_llc_ways->setEnabled(true);
        ui->combo_llc_sets->setEnabled(true);
        ui->combo_al2_ways->setEnabled(true);
        ui->combo_al2_sets->setEnabled(true);
        ui->combo_implem->setEnabled(true);
    }
}


//
// Destructor
//

espcreator::~espcreator()
{
	delete ui;
}

//
//
//

std::string espcreator::get_ESP_IP()
{
    std::string str, ethipm, ethipl;
    std::ifstream ifs("grlib_config.vhd");
    while (std::getline(ifs, str))
    {
        if (str.find("CFG_ETH_IPM") != std::string::npos)
        {
            ethipm = str.substr(str.find("16#") + 3, 4);
            /* printf("ethipm: %s\n", ethipm.c_str()); */
        }

        if (str.find("CFG_ETH_IPL") != std::string::npos)
        {
            ethipl = str.substr(str.find("16#") + 3, 4);
            /* printf("ethipl: %s\n", ethipl.c_str()); */
        }
    }

    char buf[20];
    str = ethipm + ethipl;
    int part1 = strtol(str.substr(0, 2).c_str(), NULL, 16);
    int part2 = strtol(str.substr(2, 2).c_str(), NULL, 16);
    int part3 = strtol(str.substr(4, 2).c_str(), NULL, 16);
    int part4 = strtol(str.substr(6, 2).c_str(), NULL, 16);
    sprintf(buf, "%d.%d.%d.%d", part1, part2, part3, part4);
    /* printf("ethipm: %s\n", buf); */
    return std::string(buf);
}

std::string espcreator::get_ESP_MAC()
{
    std::string str, ethipm, ethipl;
    std::ifstream ifs("grlib_config.vhd");
    while (std::getline(ifs, str))
    {
        if (str.find("CFG_ETH_ENM") != std::string::npos)
        {
            ethipm = str.substr(str.find("16#") + 3, 6);
            /* printf("ethipm: %s\n", ethipm.c_str()); */
        }

        if (str.find("CFG_ETH_ENL") != std::string::npos)
        {
            ethipl = str.substr(str.find("16#") + 3, 6);
            /* printf("ethipl: %s\n", ethipl.c_str()); */
        }
    }
    str = ethipm + ethipl;
    int length = str.length() + 3;
    for (int i = 2; i < length; i += 3)
         str.insert(i, ":");
    std::transform(str.begin(), str.end(),str.begin(), ::toupper);
    /* printf("ethipm: %s\n", str.c_str()); */
    return str;
}

std::string espcreator::get_MAC_Addr(std::string mac)
{
    int length = mac.length() + 3;
    for (int i = 2; i < length; i += 3)
        mac.insert(i, ":");
    std::transform(mac.begin(), mac.end(),mac.begin(), ::toupper);
    return mac;
}

//
// NoC Frame
//
void espcreator::on_pushButton_noc_clicked()
{
	unsigned new_nocy = ui->spinBox_nocy->value();
	unsigned new_nocx = ui->spinBox_nocx->value();

	// Delete rows
	if (new_nocy < NOCY) {
		for (int y = frame_tile.size() - 1; y >= (int) new_nocy; y--) {
			for (int x = frame_tile[y].size() - 1; x >= 0; x--) {
				delete frame_tile[y][x];
				frame_tile[y].pop_back();
			}
			frame_tile.pop_back();
		}
	}
	// Delete columns
	if (new_nocx < NOCX) {
		for (int y = 0; y < (int) frame_tile.size(); y++)
			for (int x = frame_tile[y].size() - 1; x >= (int) new_nocx; x--) {
				delete frame_tile[y][x];
				frame_tile[y].pop_back();
			}
	}
	// Add columns
	if (new_nocx > NOCX)
		for (int y = 0; y < (int) frame_tile.size(); y++)
			for (int x = frame_tile[y].size(); x < (int) new_nocx; x++)
				frame_tile[y].push_back(new Tile(ui->frame_noc, ui->layout_noc, y, x, cpu_arch));

	// Add rows
	if (new_nocy > NOCY)
		for (int y = frame_tile.size(); y < (int) new_nocy; y++) {
			frame_tile.push_back(std::vector<Tile *>());
			for (int x = 0; x < (int) new_nocx; x++)
				frame_tile[y].push_back(new Tile(ui->frame_noc,
                            ui->layout_noc, y, x, cpu_arch));
		}

	for (int y = 0; y < (int) frame_tile.size(); y++)
		for (int x = 0; x < (int) frame_tile[y].size(); x++)
			frame_tile[y][x]->set_id(y * new_nocx + x);

	/* ui->pushButton_cfg->setEnabled(true); */

	NOCX = new_nocx;
	NOCY = new_nocy;
}

void espcreator::check_enable_noc_update()
{
	if (ui->spinBox_nocx->value() > 0 && ui->spinBox_nocy->value() > 0)
		ui->pushButton_noc->setEnabled(true);
	else
		ui->pushButton_noc->setEnabled(false);
}

void espcreator::on_spinBox_nocy_valueChanged(int arg1 __attribute__((unused)))
{
	check_enable_noc_update();
}

void espcreator::on_spinBox_nocx_valueChanged(int arg1 __attribute__((unused)))
{
	check_enable_noc_update();
}

//
// Configuration checks
//
bool espcreator::check_present(tile_t type)
{
	FOREACH_TILE(y, x)
		if (frame_tile[y][x]->type == type)
			return true;
	return false;
}

bool espcreator::check_present(tile_t type, unsigned max_count)
{
	unsigned count = 0;
	for (int y = 0; y < (int) frame_tile.size(); y++)
		for (int x = 0; x < (int) frame_tile[y].size(); x++)
			if (frame_tile[y][x]->type == type)
				count++;
	if (count > 0 && count <= max_count)
		return true;
	else
		return false;
}

bool espcreator::check_clock_domains()
{
	std::map<int, int> domain;
	unsigned domain_count = 0;

	FOREACH_TILE(y, x) {
		int inc = frame_tile[y][x]->has_pll ? 1 : 0;
		if (frame_tile[y][x]->domain != 0) {
			if (domain.insert(std::make_pair(frame_tile[y][x]->domain, inc)).second == false)
				domain[frame_tile[y][x]->domain] = domain[frame_tile[y][x]->domain] + inc;
			else
				domain_count++;
			if (domain[frame_tile[y][x]->domain] > 1)
				return false;
		}
	}

	FOREACH_TILE(y, x) {
		if (frame_tile[y][x]->domain != 0 && domain[frame_tile[y][x]->domain] != 1)
			return false;
		if (frame_tile[y][x]->domain > domain_count)
			return false;
	}

	return true;
}


//
// Confiugration updates
//
void espcreator::update_power_info()
{
	REV_FOREACH_POW(i) {
		delete frame_power[i];
		frame_power.pop_back();
	}


	// Look for power domains different from zero
    FOREACH_TILE(y, x) {
        Power *pa = new Power(ui->frame_pow,
                              ui->layout_pow,
                              frame_power.size() + 1,
                              frame_tile[y][x]->id,
                              frame_tile[y][x]->ip,
                              frame_tile[y][x]->impl,
                            power_info_db);
        frame_power.push_back(pa);
	}
}


void espcreator::update_address_map()
{
	REV_FOREACH_ADDRESS(i) {
		ui->layout_addr->removeWidget(frame_address[i]);
		delete frame_address[i];
		frame_address.pop_back();
	}

	// Set accelerators starting address
	unsigned cpu_arch_bits = 32;
	unsigned long long accelerators_addr = 0;
	unsigned long long accelerators_mask = 0;

	if (cpu_arch == "leon3") {
		accelerators_addr = CFG_LEON3_AHB_APB_ADDR + CFG_LEON3_APB_ESP_ACCELERATORS_ADDR;
		accelerators_mask = CFG_LEON3_APB_ESP_ACCELERATORS_MASK;
		cpu_arch_bits = 32;
	}/* else if (cpu_arch == "zynq") {
	    accelerators_addr = CFG_ZYNQ_PL_ADDR + CFG_ESP_ACCELERATOR_ADDR;
	    cpu_arch_bits = 32;
	    }*/

	// Count memory tiles
	unsigned mem_split = 1;
	FOREACH_TILE(y, x)
		if (frame_tile[y][x]->type == TILE_MEMDBG || frame_tile[y][x]->type == TILE_MEM)
			mem_split++;

	// Create address space
	FOREACH_TILE(y, x) {
		if (frame_tile[y][x]->type == TILE_ACC) {
			Address *fa = new Address(ui->layout_addr,
						  frame_address.size() + 1,
						  cpu_arch_bits,
						  frame_tile[y][x]->id,
						  frame_tile[y][x]->ip,
						  accelerators_addr,
						  accelerators_mask);
			frame_address.push_back(fa);
			accelerators_addr += frame_address.back()->size;
			connect(fa, SIGNAL(addressMapChanged()), this, SLOT(addressMapChanged()));
		}
		if (frame_tile[y][x]->type == TILE_MEMDBG) {
			Address *fa;
			fa = new Address(ui->layout_addr,
					 frame_address.size() + 1,
					 cpu_arch_bits,
					 frame_tile[y][x]->id,
					 to_string("L3 Debug Unit"),
					 CFG_LEON3_AHB_DSU3_ADDR,
					 CFG_LEON3_AHB_DSU3_MASK);
			frame_address.push_back(fa);
			connect(fa, SIGNAL(addressMapChanged()), this, SLOT(addressMapChanged()));
			fa = new Address(ui->layout_addr,
					 frame_address.size() + 1,
					 cpu_arch_bits,
					 frame_tile[y][x]->id,
					 to_string("GR Ethernet"),
					 CFG_LEON3_AHB_APB_ADDR + CFG_LEON3_APB_GRETH_ADDR,
					 CFG_LEON3_APB_GRETH_MASK);
			frame_address.push_back(fa);
			connect(fa, SIGNAL(addressMapChanged()), this, SLOT(addressMapChanged()));
			fa = new Address(ui->layout_addr,
					 frame_address.size() + 1,
					 cpu_arch_bits,
					 frame_tile[y][x]->id,
					 to_string("SGMII Adapter"),
					 CFG_LEON3_AHB_APB_ADDR + CFG_LEON3_APB_SGMII_ADDR,
					 CFG_LEON3_APB_SGMII_MASK);
			frame_address.push_back(fa);
			connect(fa, SIGNAL(addressMapChanged()), this, SLOT(addressMapChanged()));
		}
	}
	addressMapChanged();
}

QString espcreator::get_ok_bullet()
{
	QString ok_bullet="<span style=\" color:#0000ff;\" > ";
	ok_bullet.append("<b># </b>");
	ok_bullet.append("</span>");
	ok_bullet.append("<span style=\" color:#000000;\" > ");
	return ok_bullet;
}

QString espcreator::get_err_bullet()
{
	QString err_bullet="<span style=\" color:#ff0c32;\" > ";
	err_bullet.append("<b># </b>");
	err_bullet.append("</span>");
	err_bullet.append("<span style=\" color:#000000;\" > ");
	return err_bullet;
}

void espcreator::on_combo_arch_currentIndexChanged(const QString &arg1)
{
    if (arg1.toStdString() == "leon3")
    {
        ui->lineEdit_nocw->setText("32");
    }
    else if (arg1.toStdString() == "ariane")
    {
        ui->lineEdit_nocw->setText("64");
    }
}

void espcreator::addressMapChanged()
{
	std::vector<QString> error_msg;
	QString err_bullet = get_err_bullet();
	QString error = err_bullet;
	error.append("Review and validate address map </span><br>");
	error_msg.push_back(error);
	ui->textBrowser_addr->setHtml(error);

	ui->pushButton_addr_confirm->setEnabled(false);
	ui->pushButton_gen->setEnabled(true);
	/* ui->pushButton_gen->setEnabled(true); */
	ui->pushButton_pow_confirm->setEnabled(false);
}

void espcreator::on_pushButton_cfg_clicked()
{
	std::vector<QString> error_msg;
	QString ok_bullet = get_ok_bullet();
	QString err_bullet = get_err_bullet();

	if (cpu_arch == "leon3") {
		if (!check_present(TILE_CPU, CFG_LEON3_NCPU_MAX)) {
			QString error = err_bullet;
			error.append(ECPUCOUNT(1)"</span><br>");
			error_msg.push_back(error);
		}
		if (!check_present(TILE_MEMDBG, 1)) {
			QString error = err_bullet;
			error.append(EMEMDBGCOUNT(1)"</span><br>");
			error_msg.push_back(error);
		}
		if (!check_present(TILE_MISC, 1)) {
			QString error = err_bullet;
			error.append(EMISCCOUNT(1)"</span><br>");
			error_msg.push_back(error);
		}
	}

	if (!check_clock_domains()) {
		QString error = err_bullet;
		error.append(ECLKDOMAINS"</span><br>");
		error_msg.push_back(error);
	}

	FOREACH_TILE(y, x)
		if (frame_tile[y][x]->type == TILE_ACC && frame_tile[y][x]->impl == "") {
			QString error = err_bullet;
			std::string s = EACCNOIMPL + (" " + to_string(frame_tile[y][x]->id)) + "</span><br>";
			error.append(s.c_str());
			error_msg.push_back(error);
		}

	if (error_msg.size() == 0) {
		ok_bullet.append("SoC configuration is valid.</span><br>");
		/* ui->textBrowser_msg->setHtml(ok_bullet); */
		/* ui->pushButton_gen->setEnabled(false); */
        ui->pushButton_gen->setEnabled(true);
		ui->pushButton_pow_confirm->setEnabled(false);
		ui->tab_addr->setEnabled(true);
		ui->pushButton_addr_reset->setEnabled(true);
		ui->pushButton_addr_validate->setEnabled(true);
		update_address_map();
		ui->tab_pow->setEnabled(true);
		update_power_info();
		ui->tabWidget->setCurrentIndex(ui->tabWidget->indexOf(ui->tab_addr));
		ui->tabWidget->setCurrentWidget(ui->tab_addr);
	} else {
		QString err = "";
		for (int i = 0; i < (int) error_msg.size(); i++)
			err.append(error_msg[i]);
		/* ui->textBrowser_msg->setHtml(err); */
		ui->pushButton_gen->setEnabled(true);
		/* ui->pushButton_gen->setEnabled(true); */
		ui->pushButton_pow_confirm->setEnabled(false);
		ui->tab_addr->setEnabled(false);
		ui->tab_pow->setEnabled(false);
	}
}

void espcreator::on_pushButton_addr_reset_clicked()
{
	update_address_map();
}

void espcreator::on_pushButton_addr_validate_clicked()
{
	bool address_map_is_valid = true;
	FOREACH_ADDRESS(i)
		frame_address[i]->set_conflicting(false);
	FOREACH_ADDRESS_PAIR(i, j) {
		if (frame_address[i]->base > frame_address[j]->end ||
		    frame_address[i]->end < frame_address[j]->base) {
			continue;
		} else {
			address_map_is_valid = false;
			frame_address[i]->set_conflicting(true);
			frame_address[j]->set_conflicting(true);
		}
	}
	if (address_map_is_valid) {
		QString ok_bullet = get_ok_bullet();
		QString ok = ok_bullet;
		ok.append("Address map is valid </span><br>");
		ui->textBrowser_addr->setHtml(ok);
		ui->pushButton_addr_confirm->setEnabled(true);
	}
}

void espcreator::on_pushButton_addr_confirm_clicked()
{
	ui->pushButton_pow_confirm->setEnabled(true);
	ui->tabWidget->setCurrentIndex(ui->tabWidget->indexOf(ui->tab_pow));
	ui->tabWidget->setCurrentWidget(ui->tab_pow);
}

void espcreator::on_pushButton_pow_confirm_clicked()
{
    ui->pushButton_gen->setEnabled(true);
	ui->tabWidget->setCurrentIndex(ui->tabWidget->indexOf(ui->tab_soc));
	ui->tabWidget->setCurrentWidget(ui->tab_soc);
}

void espcreator::on_pushButton_gen_clicked()
{
	// Determine backup configuration file name.
	int i = 1;
	std::string cfg_file_name = ".esp_config";
	while (true) {
		std::string bkp_file_name = cfg_file_name + ".bak." + to_string(i);
		std::ifstream bkp(bkp_file_name.c_str());
		if (!bkp.good())
			break;
		i++;
	}
	std::string bkp_file_name = cfg_file_name + ".bak." + to_string(i);

	// If configuration file exists, then backup
	int source = open(cfg_file_name.c_str(), O_RDONLY, 0);
	if (source) {
		int dest = open(bkp_file_name.c_str(), O_WRONLY | O_CREAT, 0644);
		struct stat stat_source;
		fstat(source, &stat_source);
		sendfile(dest, source, 0, stat_source.st_size);
		::close(source);
		::close(dest);
	}

	// Write new configuration
	std::ofstream cfg(cfg_file_name.c_str());

}

#include "tile.h"
#include "socmap_utils.h"

//
// Destructor
//
Tile::~Tile()
{
    ip_list.clear();
    impl_list.clear();
    delete id_l;
    delete type_sel;
    delete ip_sel_l;
    delete ip_sel;
    delete impl_sel_l;
    delete impl_sel;
    /* delete domain_sel_l; */
    /* delete domain_sel; */
    /* delete has_pll_sel; */
    /* delete extra_buf_sel; */
    delete layout;
}

//
// Constructor
//
Tile::Tile(QWidget *parent,
           QGridLayout *parent_layout,
           unsigned y,
           unsigned x, std::string cpu_arch)
    : QFrame(parent)
{
    // Set known variables
    nocy = y;
    nocx = x;

    // Create object name
    std::string name("tile_" + to_string(y) + "_" + to_string(x));
    this->setObjectName(QString::fromUtf8(name.c_str()));

    // Set size policy
    QSizePolicy sizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
    sizePolicy.setHorizontalStretch(0);
    sizePolicy.setVerticalStretch(0);

    /* sizePolicy.setHeightForWidth(this->sizePolicy().hasHeightForWidth()); */
    this->setMaximumWidth(292);
    this->setSizePolicy(sizePolicy);



    // Set appearance
    this->setFrameShape(QFrame::StyledPanel);
    this->setFrameShadow(QFrame::Raised);

    // Prepare grid for configuration objects
    layout = new QGridLayout(this);
    layout->setSpacing(8);
    layout->setContentsMargins(11, 11, 11, 11);

    // Tile ID
    id_l = new QLabel("Tile ");
    layout->addWidget(id_l, 0, 0, 1, 1);

    // Type selector
    type_sel = new QComboBox(this);
    type_sel->setObjectName(QString::fromUtf8("type_sel"));
    type_sel->clear();
    type_sel->addItem(tile_t_to_string(TILE_EMPTY).c_str());
    type_sel->setItemData(0, tile_t_to_string(TILE_EMPTY).c_str(), Qt::ToolTipRole);
    type_sel->addItem(tile_t_to_string(TILE_ACC).c_str());
    type_sel->setItemData(1, tile_t_to_string(TILE_ACC).c_str(), Qt::ToolTipRole);

    this->cpu_arch = cpu_arch;
    /* if (cpu_arch == "arm-zynq") { */
        /* type_sel->addItem(tile_t_to_string(TILE_AXI).c_str()); */
        /* type_sel->setItemData(2, tile_t_to_string(TILE_AXI).c_str(), Qt::ToolTipRole); */
    if (cpu_arch == "leon3") {
        type_sel->addItem(tile_t_to_string(TILE_CPU).c_str());
        type_sel->setItemData(2, tile_t_to_string(TILE_CPU).c_str(), Qt::ToolTipRole);
        /* type_sel->addItem(tile_t_to_string(TILE_MEMDBG).c_str()); */
        /* type_sel->setItemData(3, tile_t_to_string(TILE_MEMDBG).c_str(), Qt::ToolTipRole); */
        type_sel->addItem(tile_t_to_string(TILE_MEM).c_str());
        type_sel->setItemData(3, tile_t_to_string(TILE_MEM).c_str(), Qt::ToolTipRole);
        type_sel->addItem(tile_t_to_string(TILE_MISC).c_str());
        type_sel->setItemData(4, tile_t_to_string(TILE_MISC).c_str(), Qt::ToolTipRole);
    } else if (cpu_arch == "ariane") {
        type_sel->addItem(tile_t_to_string(TILE_CPU).c_str());
        type_sel->setItemData(2, tile_t_to_string(TILE_CPU).c_str(), Qt::ToolTipRole);
        /* type_sel->addItem(tile_t_to_string(TILE_MEMDBG).c_str()); */
        /* type_sel->setItemData(3, tile_t_to_string(TILE_MEMDBG).c_str(), Qt::ToolTipRole); */
        type_sel->addItem(tile_t_to_string(TILE_MEM).c_str());
        type_sel->setItemData(3, tile_t_to_string(TILE_MEM).c_str(), Qt::ToolTipRole);
        type_sel->addItem(tile_t_to_string(TILE_MISC).c_str());
        type_sel->setItemData(4, tile_t_to_string(TILE_MISC).c_str(), Qt::ToolTipRole);
    } else {
        std::string msg("Unsupported processor architecture (" + cpu_arch + ")");
        die(msg);
    }
    type_sel->setToolTip(type_sel->currentText());
    type = TILE_EMPTY;
    layout->addWidget(type_sel, 0, 1, 1, 5);

    // IP selector
    ip_sel_l = new QLabel("IP: ", this);
    ip_sel_l->setAlignment(Qt::AlignRight);
    QSizePolicy ip_sel_l_sizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
    ip_sel_l_sizePolicy.setHorizontalStretch(0);
    ip_sel_l_sizePolicy.setVerticalStretch(0);
    ip_sel_l_sizePolicy.setHeightForWidth(this->sizePolicy().hasHeightForWidth());
    ip_sel_l->setSizePolicy(ip_sel_l_sizePolicy);
    layout->addWidget(ip_sel_l, 1, 0, 1, 1);
    ip_sel = new QComboBox(this);
    ip_sel->setObjectName(QString::fromUtf8("ip_sel"));
    ip_sel->clear();
    ip_sel->addItem("");
    ip_sel->setToolTip(ip_sel->currentText());
    ip_sel->setMinimumWidth(90);
    ip_sel->addItem("aes");
    ip_sel->addItem("rsa");
    ip_sel->addItem("sha1");
    ip_sel->addItem("sha2");
    /* ip_sel->addItem("obfuscator"); */
    /* std::string tech_path(TOSTRING(TECH_PATH)); */
    /* std::string ip_path(tech_path + "/acc"); */
    /* get_subdirs(ip_path, ip_list); */
    /* for (unsigned i = 0; i < ip_list.size(); i++) { */
        /* ip_sel->addItem(ip_list[i].c_str()); */
        /* ip_sel->setItemData(i + 1, ip_list[i].c_str(), Qt::ToolTipRole); */
    /* } */
    ip_sel->setEnabled(false);
    ip = "empty";
    layout->addWidget(ip_sel, 1, 1, 1, 2);

    // IP implementation selector
    impl_sel_l = new QLabel("  Impl.: ", this);
    impl_sel_l->setAlignment(Qt::AlignRight);
    QSizePolicy impl_sel_l_sizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
    impl_sel_l_sizePolicy.setHorizontalStretch(0);
    impl_sel_l_sizePolicy.setVerticalStretch(0);
    impl_sel_l_sizePolicy.setHeightForWidth(this->sizePolicy().hasHeightForWidth());
    impl_sel_l->setSizePolicy(impl_sel_l_sizePolicy);
    layout->addWidget(impl_sel_l, 1, 3, 1, 1);
    impl_sel = new QComboBox(this);
    impl_sel->setObjectName(QString::fromUtf8("ip_sel"));
    impl_sel->clear();
    impl_sel->addItem("");
    /* impl_sel->addItem("dma32"); */
    impl_sel->addItem("dma64");
    impl_sel->setToolTip(impl_sel->currentText());
    impl_sel->setEnabled(false);
    impl = "none";
    layout->addWidget(impl_sel, 1, 4, 1, 2);

    // Security feature selector
    /* security_l = new QLabel("Security:"); */
    /* layout->addWidget(security_l, 2, 0, 1, 1); */

    /* has_dift_sel = new QCheckBox("DIFT"); */
    /* has_dift_sel->setEnabled(false); */
    /* layout->addWidget(has_dift_sel, 2, 2, 1, 1); */

    /* has_prop_sel = new QCheckBox("Properties Enforc."); */
    /* has_prop_sel->setEnabled(false); */
    /* layout->addWidget(has_prop_sel, 2, 1, 1, 1); */

    /* has_encl_sel = new QCheckBox("Enclaves Supp."); */
    /* has_encl_sel->setEnabled(false); */
    /* layout->addWidget(has_encl_sel, 2, 3, 1, 1); */

    security_l1 = new QLabel("DIFT Support:");
    /* security_l->setAlignment(Qt::AlignLeft); */
    layout->addWidget(security_l1, 2, 0, 1, 2);
    dift_combo1 = new QComboBox(this);
    dift_combo1->addItem("");
    dift_combo1->addItem("Enable tags");
    dift_combo1->addItem("Disable tags");
    layout->addWidget(dift_combo1, 2, 2, 1, 4);

    security_l2 = new QLabel("Properties:");
    /* security_l->setAlignment(Qt::AlignLeft); */
    layout->addWidget(security_l2, 3, 0, 1, 2);
    dift_combo2 = new QComboBox(this);
    dift_combo2->addItem("");
    dift_combo2->addItem("Enable HW checks");
    dift_combo2->addItem("Disable HW checks");
    layout->addWidget(dift_combo2, 3, 2, 1, 4);

    security_l3 = new QLabel("Enclaves:");
    /* security_l->setAlignment(Qt::AlignLeft); */
    layout->addWidget(security_l3, 4, 0, 1, 2);
    dift_combo3 = new QComboBox(this);
    dift_combo3->addItem("");
    dift_combo3->addItem("Callable inside enclaves");
    dift_combo3->addItem("Callable by all processes");
    dift_combo3->addItem("Not callable inside enclaves");
    layout->addWidget(dift_combo3, 4, 2, 1, 4);

    acc_caches = new QLabel("Enable ACC L2 Caches: ", this);
    layout->addWidget(acc_caches, 5, 0, 1, 4);
    has_caches = new QCheckBox();
    layout->addWidget(has_caches, 5, 5, 1, 1);

    ip_sel_l->setStyleSheet("color: rgba(184, 184, 184, 1);");
    impl_sel_l->setStyleSheet("color: rgba(184, 184, 184, 1);");
    security_l1->setStyleSheet("color: rgba(184, 184, 184, 1);");
    security_l2->setStyleSheet("color: rgba(184, 184, 184, 1);");
    security_l3->setStyleSheet("color: rgba(184, 184, 184, 1);");
    acc_caches->setStyleSheet("color: rgba(184, 184, 184, 1);");
    has_caches->setEnabled(false);
    dift_combo1->setEnabled(false);
    dift_combo2->setEnabled(false);
    dift_combo3->setEnabled(false);


    // Domain selector
    /* domain_sel_l = new QLabel("Clock domain: ", this); */
    /* domain_sel_l->setAlignment(Qt::AlignRight); */
    /* QSizePolicy domain_sel_l_sizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed); */
    /* domain_sel_l_sizePolicy.setHorizontalStretch(0); */
    /* domain_sel_l_sizePolicy.setVerticalStretch(0); */
    /* domain_sel_l_sizePolicy.setHeightForWidth(this->sizePolicy().hasHeightForWidth()); */
    /* domain_sel_l->setSizePolicy(domain_sel_l_sizePolicy); */
    /* layout->addWidget(domain_sel_l, 5, 0, 1, 3); */
    /* domain_sel = new QSpinBox(this); */
    /* domain_sel->setMinimum(0); */
    /* domain_sel->setObjectName(QString::fromUtf8("domain_sel")); */
    /* domain_sel->setEnabled(false); */
    /* domain = 0; */
    /* layout->addWidget(domain_sel, 5, 3, 1, 1); */

    // Has PLL
    /* has_pll_sel = new QCheckBox("PLL", this); */
    /* has_pll_sel->setChecked(false); */
    /* has_pll_sel->setObjectName(QString::fromUtf8("has_pll_sel")); */
    /* has_pll_sel->setToolTip("Has PLL"); */
    /* has_pll_sel->setEnabled(false); */
    /* has_pll = false; */
    /* layout->addWidget(has_pll_sel, 4, 0, 1, 2); */

    // Extra clock buffer
    /* extra_buf_sel = new QCheckBox("Clock buf.", this); */
    /* extra_buf_sel->setChecked(false); */
    /* extra_buf_sel->setObjectName(QString::fromUtf8("extra_buf_sel")); */
    /* extra_buf_sel->setToolTip("Add extra clock buffer"); */
    /* extra_buf_sel->setEnabled(false); */
    /* extra_buf = false; */
    /* layout->addWidget(extra_buf_sel, 4, 2, 1, 2); */


    // Background color
    socmap::set_background_color(this, color_empty);

    // Connect signals to slot
    connect(this->type_sel, SIGNAL(currentIndexChanged(const QString&)), this, SLOT(on_type_sel_currentIndexChanged(const QString&)));
    connect(this->ip_sel, SIGNAL(currentIndexChanged(const QString&)), this, SLOT(on_ip_sel_currentIndexChanged(const QString&)));
    connect(this->impl_sel, SIGNAL(currentIndexChanged(const QString&)), this, SLOT(on_impl_sel_currentIndexChanged(const QString&)));
    /* connect(this->domain_sel, SIGNAL(valueChanged(int)), this, SLOT(on_domain_sel_valueChanged(int))); */
    /* connect(this->has_pll_sel, SIGNAL(toggled(bool)), this, SLOT(on_has_pll_sel_toggled(bool))); */
    /* connect(this->extra_buf_sel, SIGNAL(toggled(bool)), this, SLOT(on_extra_buf_sel_toggled(bool))); */

    // Add tile frame to parent frame
    parent_layout->addWidget(this, y, x, 1, 1);
}

void Tile::set_id(unsigned id)
{
    std::string s("Tile " + to_string(id) + ":");
    id_l->setText(s.c_str());
    this->id = id;
}



void Tile::impl_reset()
{
    /* impl_sel->clear(); */
    /* impl_sel->addItem(""); */
    /* impl_sel->setCurrentIndex(0); */
    /* impl_sel->setEnabled(false); */
    /* impl_sel->setToolTip(impl_sel->currentText()); */
    /* impl_list.clear(); */
    /* impl = ""; */
}

void Tile::clocking_reset()
{
    /* has_pll_sel->setChecked(false); */
    has_pll = false;
    /* extra_buf_sel->setChecked(false); */
    extra_buf = false;
}

void Tile::domain_reset()
{
    /* domain_sel->setValue(0); */
    domain = 0;
    clocking_reset();
}

void Tile::tile_reset()
{
    type_sel->setToolTip(type_sel->currentText());
    ip_sel->setCurrentIndex(0);
    ip_sel->setEnabled(false);
    ip = "";
    ip_sel->setToolTip(ip_sel->currentText());
    impl_reset();
    domain_reset();
}

void Tile::clocking_setEnabled(bool en)
{
    /* has_pll_sel->setEnabled(en); */
    /* extra_buf_sel->setEnabled(en); */
}

void Tile::domain_setEnabled(bool en)
{
    /* domain_sel->setEnabled(en); */
    if (!en)
        clocking_setEnabled(en);
}

void Tile::on_type_sel_currentIndexChanged(const QString &arg1)
{
    tile_reset();
    domain_setEnabled(false);

    if (arg1 != tile_t_to_string(TILE_ACC).c_str()) {

        ip_sel_l->setStyleSheet("color: rgba(184, 184, 184, 1);");
        impl_sel_l->setStyleSheet("color: rgba(184, 184, 184, 1);");
        security_l1->setStyleSheet("color: rgba(184, 184, 184, 1);");
        security_l2->setStyleSheet("color: rgba(184, 184, 184, 1);");
        security_l3->setStyleSheet("color: rgba(184, 184, 184, 1);");
        acc_caches->setStyleSheet("color: rgba(184, 184, 184, 1);");
        has_caches->setEnabled(false);
    } else {
        dift_combo1->setCurrentIndex(2);
        dift_combo2->setCurrentIndex(2);
        dift_combo3->setCurrentIndex(2);
        ip_sel_l->setStyleSheet("color: rgba(0, 0, 0, 1);");
        impl_sel_l->setStyleSheet("color: rgba(0, 0, 0, 1);");
        security_l1->setStyleSheet("color: rgba(0, 0, 0, 1);");
        security_l2->setStyleSheet("color: rgba(0, 0, 0, 1);");
        security_l3->setStyleSheet("color: rgba(0, 0, 0, 1);");
        acc_caches->setStyleSheet("color: rgba(0, 0, 0, 1);");
        has_caches->setEnabled(true);
    }

    if (arg1 == tile_t_to_string(TILE_EMPTY).c_str()) {
        type = TILE_EMPTY;
        ip = "empty";
        impl = "none";
        set_background_color(this, color_empty);
    } else if (arg1 == tile_t_to_string(TILE_ACC).c_str()) {
        type = TILE_ACC;
        set_background_color(this, color_acc);
        ip_sel->setEnabled(true);
        domain_setEnabled(true);
        dift_combo1->setEnabled(true);
        dift_combo2->setEnabled(true);
        dift_combo3->setEnabled(true);
        has_caches->setEnabled(true);
    } else if (arg1 == tile_t_to_string(TILE_AXI).c_str()) {
        type = TILE_AXI;
        ip = "axi";
        impl = "default";
        set_background_color(this, color_axi);
    } else if (arg1 == tile_t_to_string(TILE_CPU).c_str()) {
        type = TILE_CPU;
        ip = cpu_arch;
        impl = "rtl";
        socmap::set_background_color(this, color_cpu);
        domain_setEnabled(true);
        dift_combo1->setEnabled(false);
        dift_combo2->setEnabled(false);
        dift_combo3->setEnabled(false);
        has_caches->setEnabled(false);
    /* } else if (arg1 == tile_t_to_string(TILE_MEMDBG).c_str()) { */
        /* type = TILE_MEMDBG; */
        /* ip = "memdbg"; */
        /* impl = "rtl"; */
        /* set_background_color(this, color_mem); */
        /* dift_combo1->setEnabled(false); */
        /* dift_combo2->setEnabled(false); */
        /* dift_combo3->setEnabled(false); */
        /* has_caches->setEnabled(false); */
        /* has_dift_sel->setEnabled(false); */
        /* has_prop_sel->setEnabled(false); */
        /* has_encl_sel->setEnabled(false); */
    } else if (arg1 == tile_t_to_string(TILE_MEM).c_str()) {
        type = TILE_MEM;
        ip = "mem";
        impl = "rtl";
        set_background_color(this, color_mem);
        dift_combo1->setEnabled(false);
        dift_combo2->setEnabled(false);
        dift_combo3->setEnabled(false);
        has_caches->setEnabled(false);
        /* has_dift_sel->setEnabled(false); */
        /* has_prop_sel->setEnabled(false); */
        /* has_encl_sel->setEnabled(false); */
    } else if (arg1 == tile_t_to_string(TILE_MISC).c_str()) {
        type = TILE_MISC;
        ip = "misc";
        impl = "rtl";
        set_background_color(this, color_misc);
        dift_combo1->setEnabled(false);
        dift_combo2->setEnabled(false);
        dift_combo3->setEnabled(false);
        has_caches->setEnabled(false);
        /* has_dift_sel->setEnabled(false); */
        /* has_prop_sel->setEnabled(false); */
        /* has_encl_sel->setEnabled(false); */
    }
}

void Tile::on_ip_sel_currentIndexChanged(const QString &arg1)
{
    impl_reset();

    if (arg1 != "") {
        std::string tech_path(TOSTRING(TECH_PATH));
        std::string ip_path(tech_path + "/acc/" + arg1.toStdString());
        std::vector<std::string> impl_dir_list;
        get_subdirs(ip_path, impl_dir_list);
        parse_implementations(impl_dir_list, impl_list);
        for (unsigned i = 0; i < impl_list.size(); i++) {
            /* impl_sel->addItem(impl_list[i].c_str()); */
            impl_sel->setItemData(i + 1, impl_list[i].c_str(), Qt::ToolTipRole);
        }

        impl_sel->setEnabled(true);
    }
    ip = ip_sel->currentText().toStdString();
    ip_sel->setToolTip(ip_sel->currentText());
    impl_sel->setToolTip(impl_sel->currentText());
}

void Tile::on_impl_sel_currentIndexChanged(const QString &arg1 __attribute__((unused)))
{
    impl = impl_sel->currentText().toStdString();
    impl_sel->setToolTip(impl_sel->currentText());
}

void Tile::on_domain_sel_valueChanged(int arg1)
{
    domain = arg1;
    if (arg1 == 0) {
        clocking_reset();
        clocking_setEnabled(false);
    } else {
        clocking_setEnabled(true);
    }
}

void Tile::on_has_pll_sel_toggled(bool arg1)
{
    if (!arg1)
        clocking_reset();
    else
        has_pll = true;
}

void Tile::on_extra_buf_sel_toggled(bool arg1)
{
    extra_buf = arg1;
}

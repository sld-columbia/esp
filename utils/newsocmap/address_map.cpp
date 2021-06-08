#include "address_map.h"

//
// Destructor
//
Address::~Address()
{
    delete name;

    delete address_base_head_l;

    for (int i = (int)address_base.size() - 1; i >= 0; i--)
    {
        delete address_base[i];
        address_base.pop_back();
    }
    delete address_base_lay;
    delete address_base_f;

    delete address_size;
    delete address_size_lay;
    delete address_size_f;

    delete address_end;
    delete address_end_lay;
    delete address_end_f;

    delete address_mask;
    delete address_mask_lay;
    delete address_mask_f;
}

unsigned long long Address::get_digit(unsigned long long x, unsigned i)
{
    const unsigned long long digit_mask = 0xf;
    unsigned shift = 4 * i;
    unsigned long long y = x >> shift;
    return y & digit_mask;
}

//
// Constructor
//
Address::Address(QGridLayout *parent_layout,
                 unsigned address_line_number,
                 unsigned cpu_arch_bits,
                 unsigned tile_id,
                 std::string ip,
                 unsigned long long base,
                 unsigned long long mask)
{
    this->lsb = lsb64(mask);
    this->msb = msb64(mask);
    this->range = ~((-1 << msb) | mask);

    this->cpu_arch_bits = cpu_arch_bits;
    this->tile_id = tile_id;
    this->ip = ip;
    this->base = base;
    this->mask = mask;
    this->end = base + range;
    this->size = range + 1;
    this->shift = lsb;

    QFont fixedFont("Monospace");
    fixedFont.setStyleHint(QFont::TypeWriter);

    // Create object name
    std::string obj_name("Tile " + to_string(tile_id) + " - " + ip);
    this->setObjectName(QString::fromUtf8(obj_name.c_str()));

    // Name
    name = new QLabel(obj_name.c_str(), this);
    name->setFont(fixedFont);
    parent_layout->addWidget(name, address_line_number, 0, 1, 1, Qt::AlignLeft);

    std::stringstream stm;
    unsigned addr_range_size_log_min = lsb;
    unsigned addr_range_size_log_max = msb;

    // Base
    address_base_f = new QFrame(this);
    address_base_lay = new QHBoxLayout(address_base_f);
    stm.str("");
    address_base_head_l = new QLabel("0x", address_base_f);
    address_base_head_l->setFont(fixedFont);
    address_base_lay->addWidget(address_base_head_l);
    for (int i = cpu_arch_bits / 4 - 1; i >= 0; i--)
    {
        QLineEdit *le = new QLineEdit(address_base_f);
        le->setMaxLength(1);
        le->setMaximumWidth(20);
        stm.str("");
        stm << std::hex << std::uppercase << std::setw(1) << std::setfill('0')
            << get_digit(this->base, (unsigned)i);
        le->setText(stm.str().c_str());
        le->setAlignment(Qt::AlignRight);
        le->setTextMargins(0, 0, 0, 0);
        if ((unsigned)i >= ((msb + 1) / 4) || (unsigned)i < (lsb / 4))
            le->setEnabled(false);
        else
            le->setEnabled(true);
        address_base.push_back(le);
        le->setFont(fixedFont);
        address_base_lay->addWidget(le);
    }
    address_base_lay->setSpacing(0);
    address_base_lay->setMargin(0);

    parent_layout->addWidget(
        address_base_f, address_line_number, 1, 1, 1, Qt::AlignRight);

    // size
    address_size_f = new QFrame(this);
    address_size_lay = new QHBoxLayout(address_size_f);
    address_size = new QComboBox(address_size_f);
    for (unsigned i = addr_range_size_log_min; i <= addr_range_size_log_max; i++)
    {
        unsigned div_factor;
        std::string unit;
        if (i < 10)
        {
            div_factor = 0;
            unit = " B";
        }
        else if (i < 20)
        {
            div_factor = 10;
            unit = " KB";
        }
        else if (i < 30)
        {
            div_factor = 20;
            unit = " MB";
        }
        else
        {
            div_factor = 30;
            unit = " GB";
        }

        unsigned next_size = 1 << i;
        unsigned next_size_scaled = 1 << (i - div_factor);
        std::string item(to_string(next_size_scaled) + unit);
        address_size->addItem(item.c_str(), next_size);
    }
    address_size_lay->addWidget(address_size);
    address_size->setFont(fixedFont);
    parent_layout->addWidget(
        address_size_f, address_line_number, 2, 1, 1, Qt::AlignRight);

    // end
    stm.str("");
    stm << "0x" << std::hex << std::uppercase << std::setw(cpu_arch_bits / 4)
        << std::setfill('0') << this->end;
    address_end_f = new QFrame(this);
    address_end_lay = new QHBoxLayout(address_end_f);
    address_end = new QLabel(address_end_f);
    address_end->setText(stm.str().c_str());
    address_end->setAlignment(Qt::AlignRight);
    address_end_lay->addWidget(address_end);
    address_end->setFont(fixedFont);
    parent_layout->addWidget(address_end_f, address_line_number, 3, 1, 1, Qt::AlignRight);

    // mask
    stm.str("");
    stm << "0x" << std::hex << std::uppercase << std::setw(cpu_arch_bits / 4)
        << std::setfill('0') << this->mask;
    address_mask_f = new QFrame(this);
    address_mask_lay = new QHBoxLayout(address_mask_f);
    address_mask = new QLabel(address_mask_f);
    address_mask->setText(stm.str().c_str());
    address_mask->setAlignment(Qt::AlignRight);
    address_mask_lay->addWidget(address_mask);
    address_mask->setFont(fixedFont);
    parent_layout->addWidget(
        address_mask_f, address_line_number, 4, 1, 1, Qt::AlignRight);

    // Connect signals to slot
    connect(this->address_size,
            SIGNAL(currentIndexChanged(int)),
            this,
            SLOT(on_address_size_currentIndexChanged(int)));
    for (int i = 0; i < (int)cpu_arch_bits / 4; i++)
    {
        connect(this->address_base[i],
                SIGNAL(textChanged(QString)),
                this,
                SLOT(on_address_base_addressChanged()));
    }
}

void Address::set_conflicting(bool set)
{
    QPalette valid;
    QPalette non_valid;
    valid.setColor(QPalette::Base, color_ok);
    non_valid.setColor(QPalette::Base, color_error);
    for (int i = 0; i < (int)cpu_arch_bits / 4; i++)
    {
        QLineEdit *le = this->address_base[i];
        if (le->isEnabled())
        {
            if (set)
                le->setPalette(non_valid);
            else
                le->setPalette(valid);
        }
    }
}

void Address::read_current_address()
{
    this->base = 0;
    for (int i = 0; i < (int)cpu_arch_bits / 4; i++)
    {
        QLineEdit *le = this->address_base[i];
        unsigned digit = (unsigned)cpu_arch_bits / 4 - i - 1;
        this->base |= le->text().toUInt(0, 16) << (digit << 2);
    };
}

void Address::update_address_base()
{
    std::stringstream stm;

    for (int i = 0; i < (int)cpu_arch_bits / 4; i++)
    {
        QLineEdit *le = this->address_base[i];
        unsigned digit = (unsigned)cpu_arch_bits / 4 - i - 1;
        stm.str("");
        stm << std::hex << std::uppercase << std::setw(1) << std::setfill('0')
            << get_digit(this->base, digit);
        le->setText(stm.str().c_str());
        if ((unsigned)digit * 4 >= round_up(this->msb, 4) ||
            (unsigned)digit * 4 < round_down(this->lsb, 4))
            le->setEnabled(false);
        else
            le->setEnabled(true);
    }
}

void Address::update_address_info()
{
    this->range = this->size - 1;
    this->lsb = msb64(this->range) + 1;
    this->mask = ~((0xffffffffffffffffULL << (this->msb + 1)) |
                   (0xffffffffffffffffULL >> (64 - this->lsb)));

    // Check base address alignment and fix it if necessary
    this->base = this->base & ((0xffffffffffffffffULL << (this->msb + 1)) | this->mask);
    update_address_base();

    this->end = this->base + range;

    // Update end address label
    std::stringstream stm;
    stm.str("");
    stm << "0x" << std::hex << std::uppercase << std::setw(cpu_arch_bits / 4)
        << std::setfill('0') << this->end;
    this->address_end->setText(stm.str().c_str());

    // Update mask label
    stm.str("");
    stm << "0x" << std::hex << std::uppercase << std::setw(cpu_arch_bits / 4)
        << std::setfill('0') << this->mask;
    this->address_mask->setText(stm.str().c_str());

    // Emit addressChanged
    emit this->addressMapChanged();
}

void Address::on_address_size_currentIndexChanged(int arg1)
{
    this->size = address_size->itemData(arg1).toLongLong();
    update_address_info();
}

void Address::on_address_base_addressChanged()
{
    read_current_address();
    update_address_info();
}

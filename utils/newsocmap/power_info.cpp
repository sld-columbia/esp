#include "power_info.h"

//
// Destructor
//
Power::~Power()
{
    delete name;
    for (int i = (int)info.size() - 1; i >= 0; i--)
    {
        parent_layout->removeWidget(info[i]->mW);
        parent_layout->removeWidget(info[i]->mW_l);
        parent_layout->removeWidget(info[i]->V);
        parent_layout->removeWidget(info[i]->V_l);
        parent_layout->removeWidget(info[i]->MHz);
        parent_layout->removeWidget(info[i]->MHz_l);
        parent_layout->removeItem(info[i]->hsp);
        delete info[i];
        info.pop_back();
    }
}

//
// Constructor
//
Power::Power(QWidget *parent,
             QGridLayout *parent_layout,
             unsigned power_line_number,
             unsigned tile_id,
             std::string ip,
             std::string impl,
             power_info_db_t &db)
{
    this->parent_layout = parent_layout;
    this->tile_id = tile_id;
    this->ip = ip;
    this->impl = impl;
    this->db = db;

    QFont fixedFont("Monospace");
    fixedFont.setStyleHint(QFont::TypeWriter);

    // Create object name
    std::string obj_name("Tile " + to_string(tile_id) + " - " + ip + "_" + impl);

    // Name
    name = new QLabel(obj_name.c_str(), parent);
    name->setFont(fixedFont);
    parent_layout->addWidget(name, power_line_number, 0, 1, 1, Qt::AlignLeft);

    // std::stringstream stm;
    // stm.str("");

    // Power Info
    bool missing_info = true;
    if (db.find(ip.c_str()) != db.end())
    {
        op_point_info_t acc_info = db[ip.c_str()];
        if (acc_info.find(impl.c_str()) != acc_info.end())
        {
            vector_op_point_t impl_info = acc_info[impl.c_str()];
            for (unsigned i = 0; i < impl_info.size(); i++)
            {
                float f = 1000000.0 / impl_info[i].ps;
                float v = impl_info[i].V;
                float p = impl_info[i].mW;
                OperatingPoint *op = new OperatingPoint(i, f, v, p, parent);
                info.push_back(op);
            }
            missing_info = false;
        }
    }

    if (missing_info)
    {
        for (int i = 0; i < 4; i++)
        {
            OperatingPoint *op = new OperatingPoint(i, 0.0, 0.0, 0.0, parent);
            info.push_back(op);
        }
    }

    for (unsigned i = 0; i < info.size(); i++)
    {
        OperatingPoint *op = info[i];
        parent_layout->addItem(
            op->hsp, power_line_number, 7 * i + 1, 1, 1, Qt::AlignRight);
        parent_layout->addWidget(
            op->MHz, power_line_number, 7 * i + 2, 1, 1, Qt::AlignRight);
        parent_layout->addWidget(
            op->MHz_l, power_line_number, 7 * i + 3, 1, 1, Qt::AlignLeft);
        parent_layout->addWidget(
            op->V, power_line_number, 7 * i + 4, 1, 1, Qt::AlignRight);
        parent_layout->addWidget(
            op->V_l, power_line_number, 7 * i + 5, 1, 1, Qt::AlignLeft);
        parent_layout->addWidget(
            op->mW, power_line_number, 7 * i + 6, 1, 1, Qt::AlignRight);
        parent_layout->addWidget(
            op->mW_l, power_line_number, 7 * i + 7, 1, 1, Qt::AlignLeft);
    }
}

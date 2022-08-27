// System headers
#include <iostream>
#include <algorithm>
#include <fstream>
#include <sstream>
#include <ctime>
#include <iterator>
// --------------

#include "csv_data_manipulator.hpp"

// --- CONSTANTS --- //
const char *CSVData::VERSION = "v0.2a"; // XXX: Update version here
const char CSVData::CSV_DELIMITER = ',';
const char CSVData::C_STRING_DELIMITER = '"';
const char *CSVData::S_STRING_DELIMITER = "\"";
const char *CSVData::TMP_DELIM_REPLACEMENT = "#|#";
const char CSVData::DECIMAL_DELIMITER = '.';

const int CSVData::ASC = 1;
const int CSVData::DESC = 2;
// ----------------- //

// ---  MACROS   --- //
#define DEBUG_MODE 0
// ----------------- //

using namespace std;

// ==========================================================================================================|

bool os_safe_getline(istream &is, string &s)
{
    s.clear();

    char c;

    while (is.get(c)) {
        if (is.eof()) {
            return false;
        } else if (c == '\n') {
            return true;
        } else if (c == '\r') {
            is.get(c);
            if (c != '\n') is.putback(c);
            return true;
        } else {
            s += c;
        }
    }

    return false;
}

// ==========================================================================================================|

CSVData::CSVData() : m_is_modified(false), m_is_unified(true), m_rows(0), m_cols(0)
{
}

// ----------------------------------------------------------------------------------------------------------|

CSVData::CSVData(CSVData &rhs) :
    m_is_modified(rhs.is_modified()), m_is_unified(rhs.is_unified()),
    m_rows(rhs.m_rows), m_cols(rhs.m_cols)
{
}

// ----------------------------------------------------------------------------------------------------------|

CSVData::CSVData(const string &filename) :
    m_is_modified(false), m_is_unified(true), m_rows(0), m_cols(0)
{
    read_file(filename);
    m_is_modified = false;
}

// ----------------------------------------------------------------------------------------------------------|

const string CSVData::get_value(int row, int col)
{
     if (row >= m_rows || col >= m_cols || row < 0 || col < 0) return "";
     return const_cast<string&>(m_data.at(row).at(col));
}

// ----------------------------------------------------------------------------------------------------------|

const vector<string> CSVData::get_row(int row)
{
     if (row >= m_rows || row < 0) return vector<string>();
     return const_cast<vector<string>&>(m_data.at(row));
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::set_value(int row, int col, string value)
{
     if (row >= m_rows || col >= m_cols || row < 0 || col < 0) return;

     m_data.at(row).at(col) = value;
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::add_row(vector<string> row_data)
{
     size_t new_row_size = row_data.size();
     if (new_row_size != m_cols && m_is_unified) m_is_unified = false;
     m_data.push_back(row_data);
     m_rows++;
     if (m_cols < new_row_size) m_cols = new_row_size;
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::add_row(vector<string> row_data, int pos)
{
     if (pos < 0 || pos >= m_data.size()) return;

     vector< vector<string> >::iterator it = m_data.begin() + pos;

     size_t new_row_size = row_data.size();
     if (new_row_size != m_cols && m_is_unified) m_is_unified = false;

     m_data.insert(it, row_data);
     m_rows++;
     if (m_cols < new_row_size) m_cols = new_row_size;
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::delete_row(int row)
{
	if (row >= m_rows || row < 0) return;
	m_data.erase(m_data.begin() + row);
	m_rows--;
	m_is_modified = true;
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::delete_row_if(function<bool(int, const std::vector< std::string > &, void *cbData)> cbFun,
        void *cbData)
{
    vector<int> rows_to_delete;

    for (int row = 0; row < m_data.size(); ++row) {
        if ( cbFun(row, m_data.at(row), cbData) ) {
            rows_to_delete.push_back(row);
        }
    }

    if (rows_to_delete.size() > 0) {
        sort(rows_to_delete.begin(), rows_to_delete.end(), std::greater<int>());
        for (int row = 0; row < rows_to_delete.size(); ++row) delete_row(rows_to_delete.at(row));
    }
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::delete_row_if(function<bool(int, int, const std::string&, void *cbData)> cbFun, void *cbData)
{
    vector<int> rows_to_delete;

    for (int row = 0; row < m_data.size(); ++row) {
        for (int col = 0; col < m_data.at(row).size(); ++col) {
            if ( cbFun(row, col, m_data.at(row).at(col), cbData) ) {
                rows_to_delete.push_back(row);
                break;
            }
        }
    }

    if (rows_to_delete.size() > 0) {
        sort(rows_to_delete.begin(), rows_to_delete.end(), std::greater<int>());
        for (int row = 0; row < rows_to_delete.size(); ++row) delete_row(rows_to_delete.at(row));
    }
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::delete_row_if(function<bool(int, int, const std::string&)> cbFun)
{
    function<bool(int, int, const std::string&, void *cbData)> simple_delete_row_if =
        [=](int row, int col, const std::string& val, void *cbData) {
            return cbFun(row, col, val);
        };

    delete_row_if(simple_delete_row_if, nullptr);
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::delete_col(int col)
{
	if (col >= m_cols || col < 0) return;
	for (int i = 0; i < m_data.size(); ++i) {
		if (col < m_data.at(i).size()) {
			m_data.at(i).erase(m_data.at(i).begin() + col);
			m_is_modified = true;
		}
	}
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::delete_item(int row, int col)
{
	if (row >= m_rows || row < 0) return;
	if (col >= m_data.at(row).size() || col < 0) return;

	m_data.at(row).erase(m_data.at(row).begin() + col);
	m_is_modified = true;
	m_is_unified = false;
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::_append_data(std::vector< std::vector<std::string> > &data)
{
    if (data.empty()) return;

    if (m_data.empty()) {
        m_data = move(data);
    } else {
        m_data.reserve(m_data.size() + data.size());
        move(data.begin(), data.end(), back_inserter(m_data));
        data.clear();
    }
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::_read_file(const std::string &filename, std::vector< std::vector<std::string> > &target, int &cols)
{
    ifstream input_file(filename.c_str());

    if (!input_file.is_open()) {
        cerr << "Unable to open file '" << filename << "'. Check if file exists and if you have the right permissions." << endl;
        return;
    }

    string line;
    int current_line = 0;

    while (os_safe_getline(input_file, line)) {
        int contains_strings = 0;
        current_line++;
        if ( (contains_strings = count(line.begin(), line.end(), C_STRING_DELIMITER)) > 0 ) {
            size_t left = line.find(C_STRING_DELIMITER, 0);
            size_t right = line.find(C_STRING_DELIMITER, left + 1);

            while (left != string::npos && right != string::npos) {
                size_t found = left;
                while (true) {
                    found = line.find(C_STRING_DELIMITER, found);
                    if (found == string::npos) break;

                    line.replace(found, 1, TMP_DELIM_REPLACEMENT);
                    found += 3;
                }

                left = line.find(C_STRING_DELIMITER, right);
                right = line.find(C_STRING_DELIMITER, left + 1);
            }
        }

        stringstream ss(line);
        string tok, i_row;
        vector<string> row;

        while (getline(ss, tok, CSV_DELIMITER)) {
            if (tok.find(TMP_DELIM_REPLACEMENT) != string::npos) {
                i_row = tok;

                size_t found = 0;
                while (true) {
                    found = i_row.find(TMP_DELIM_REPLACEMENT, found);
                    if (found == string::npos) break;

                    i_row.replace(found, 3, string(S_STRING_DELIMITER));
                    found++;
                }
            } else {
                i_row = tok;
            }
            row.push_back(i_row);
        }

        if (cols != 0 && cols != row.size()) m_is_unified = false;

        int rsz = row.size();
        cols = max(cols, rsz);

        if (row.size() > 0) {
            target.push_back(row);
        } else {
            if (DEBUG_MODE) cout << "Line " << current_line << ": empty line" << endl;
        }

    }

    input_file.close();
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::read_file(const string &filename)
{
    m_data.clear();

    _read_file(filename, m_data, m_cols);

    m_is_modified = true;
    m_rows = m_data.size();
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::append_file(const string &filename)
{
    std::vector< std::vector<std::string> > new_data;

    _read_file(filename, new_data, m_cols);
    _append_data(new_data);

    m_is_modified = true;
    m_rows = m_data.size();
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::write_data(const string &filename)
{
    ofstream output_file(filename.c_str(), ofstream::out);

    if (!output_file.is_open()) {
        cerr << "Unable to open file '" << filename << "'. Check if you have the right permissions." << endl;
        return;
    }

    for (int row = 0; row < m_data.size(); ++row) {
        string new_line;

        vector<string> row_data = m_data.at(row);
        for (int i = 0; i < row_data.size(); i++) {
            new_line.append(row_data.at(i));
            new_line.append(string(1, CSV_DELIMITER));
        }

        size_t last_comma = new_line.find_last_of(",");
        new_line.replace(last_comma, 1, "\n");

        output_file << new_line;
    }

    output_file.close();

    m_is_modified = false;
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::convert_date_format(const std::string &old_format, const std::string &new_format, int column)
{
    for (int row = 0; row < m_data.size(); ++row) convert_date_format(old_format, new_format, row, column);
}

// ----------------------------------------------------------------------------------------------------------|

void CSVData::convert_date_format(const std::string &old_format, const std::string &new_format, int row, int column)
{
    if (column < 0 || column >= m_cols) {
        cerr << "Invalid column number: " << column << endl;
        return;
    }

    if (row < 0 || row >= m_rows) {
        cerr << "Invalid row number: " << row << endl;
        return;
    }

    vector<string> row_data = m_data.at(row);

    string old_date = row_data.at(column);
    std::tm od;
    strptime(old_date.c_str(), old_format.c_str(), &od);

    char buffer[256];
    strftime(buffer, sizeof(buffer), new_format.c_str(), &od);

    string new_date(buffer);

    m_data.at(row).at(column) = new_date;

    m_is_modified = true;
}

// ==========================================================================================================|

static bool is_digits(const string &str)
{
    return std::all_of(str.begin(), str.end(), ::isdigit);
}

// ==========================================================================================================|

void CSVData::sort_by_col(int col, int order)
{
    auto acs_compare_fun = [&](const vector< string > &row1, const vector< string > &row2) {
        bool ret_val;

        if (is_digits(row1[col]) && is_digits(row2[col])) {
            auto a = (row1[col].find(DECIMAL_DELIMITER) != string::npos) ? stod(row1[col]) : stol(row1[col]);
            auto b = (row2[col].find(DECIMAL_DELIMITER) != string::npos) ? stod(row2[col]) : stol(row2[col]);
            ret_val = a < b;
        } else {
             ret_val = row1[col] < row2[col];
        }

        return ret_val;
    };

    auto desc_compare_fun = [&](const vector< string > &row1, const vector< string > &row2) {
        bool ret_val;

        if (is_digits(row1[col]) && is_digits(row2[col])) {
            auto a = (row1[col].find(DECIMAL_DELIMITER) != string::npos) ? stod(row1[col]) : stol(row1[col]);
            auto b = (row2[col].find(DECIMAL_DELIMITER) != string::npos) ? stod(row2[col]) : stol(row2[col]);
            ret_val = a > b;
        } else {
             ret_val = row1[col] > row2[col];
        }

        return ret_val;
    };

    switch (order) {
        case DESC:
            sort(m_data.begin(), m_data.end(), desc_compare_fun);
            break;
        case ASC:
        default:
            sort(m_data.begin(), m_data.end(), acs_compare_fun);
            break;
    }

    m_is_modified = true;
}

// ==========================================================================================================|

void CSVData::make_data_unique()
{
    if (!m_is_unified) {
        cout << "Data are not unified. Cannot check all the data." << endl;
        return;
    }

    for (int col = 0; col < m_cols; col++) {
        sort_by_col(col, ASC);
        m_data.erase(unique(m_data.begin(), m_data.end()), m_data.end());
    }
}

// ==========================================================================================================|

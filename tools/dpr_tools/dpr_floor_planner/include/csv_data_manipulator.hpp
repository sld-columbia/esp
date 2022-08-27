#ifndef CSV_DATA_MANIPULATOR
#define CSV_DATA_MANIPULATOR

#include <vector>
#include <functional>

class CSVData {
    public:
        CSVData();
        CSVData(CSVData &rhs);
        CSVData(const std::string &filename);
        ~CSVData() {  }

        bool is_modified() { return m_is_modified; }
        bool is_unified() { return m_is_unified; }
        int  columns() { return m_cols; }
        int  rows() { return m_rows; }

        const std::string get_value(int row, int col);
        const std::vector<std::string> get_row(int row);
        void set_value(int row, int col, std::string value);

        void add_row(std::vector<std::string> row_data);
        void add_row(std::vector<std::string> row_data, int pos);
        void delete_row(int row);
        void delete_col(int col);
        void delete_item(int row, int col);
        void delete_row_if(std::function<bool(int, int, const std::string&)> cbFun);
        void delete_row_if(std::function<bool(int, int, const std::string&, void *cbData)> cbFun, void *cbData);
        void delete_row_if(std::function<bool(int, const std::vector< std::string > &, void *cbData)> cbFun, void *cbData);

        void read_file(const std::string &filename);
        void append_file(const std::string &filename);
        void write_data(const std::string &filename);

        void convert_date_format(const std::string &old_format, const std::string &new_format, int column);
        void convert_date_format(const std::string &old_format, const std::string &new_format, int row, int column);

        const char* get_version() { return VERSION; }

        void sort_by_col(int col, int order);
        void make_data_unique();

        // --- PUBLIC CONSTANTS --- //
        static const int ASC;
        static const int DESC;

    private:
        std::vector< std::vector<std::string> > m_data;

        bool m_is_modified;
        bool m_is_unified;
        int m_rows;
        int m_cols;

        // --- CONSTANTS --- //
        static const char *VERSION;
        static const char CSV_DELIMITER;
        static const char C_STRING_DELIMITER;
        static const char *S_STRING_DELIMITER;
        static const char *TMP_DELIM_REPLACEMENT;
        static const char DECIMAL_DELIMITER;

        // --- private functions --- //
        void _read_file(const std::string &filename, std::vector< std::vector<std::string> > &target, int &cols);
        void _append_data(std::vector< std::vector<std::string> > &data);

}; // CSVData

#endif /* CSV_DATA_MANIPULATOR */

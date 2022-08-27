#include "flora.h"

int main(int argc, char* argv[])
{

std::string fplan_xdc_file= "pblocks.xdc";

// start doing usefull stuff ...
    input_to_flora in_flora;
    in_flora.num_rm_partitions = atol(argv[1]);
    in_flora.path_to_input = argv[2];
    in_flora.path_to_output = argv[3];

    flora fl(&in_flora);
    fl.clear_vectors();
    fl.prep_input();
    fl.start_optimizer();
    fl.generate_xdc(fplan_xdc_file);
    return 0;
}

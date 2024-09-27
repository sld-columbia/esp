#!/usr/bin/env python
# coding: utf-8

import os
import sys
import math

def data_struct(pad_list):

    for row in pad_list:
        if str(row[0]) == "in":
            pad_dict["in"].append({"macro_name": str(row[1]),
                                   "type": str(row[2])})
        if str(row[0]) == "out":
            pad_dict["out"].append({"macro_name": str(row[1]),
                                    "type": str(row[2])})
        if str(row[0]) == "io":
            pad_dict["io"].append({"macro_name": str(row[1]),
                                   "type": str(row[2])})
            
    return pad_dict
        
def print_wrap_pad(file1, module1, macro_name, pad_dir, pad_type):

    if os.path.exists(file1):
        None
    else:
        out_file = open(file1, "w")
        out_file.write("`timescale 1 ps / 1ps \n")
        out_file.write("\n")
        if pad_dir == "IN":
            out_file.write("module %s (PAD, Y); \n" %module1)
            out_file.write("\n")
            out_file.write("  input           PAD;\n")
            out_file.write("  output            Y;\n")
            out_file.write("\n")
            out_file.write("  %s inpad \n" %macro_name)
        elif pad_dir == "OUT":
            out_file.write("module %s (PAD, A, CFG); \n" %module1)
            out_file.write("\n")
            out_file.write("  output           PAD;\n")
            out_file.write("  input              A;\n")
            out_file.write("  input [2 : 0]    CFG;\n")
            out_file.write("\n")
            out_file.write("  %s outpad \n" %macro_name)
        else:
            out_file.write("module %s (PAD, Y, A, OE, CFG); \n" %module1)
            out_file.write("\n")
            out_file.write("  inout           PAD;\n")
            out_file.write("  output            Y;\n")
            out_file.write("  input             A;\n")
            out_file.write("  input            OE;\n")
            out_file.write("  input [2 : 0]   CFG;\n")
            out_file.write("\n")
            out_file.write("  %s iopad \n" %macro_name)
        out_file.write("  ( \n")
        out_file.write("// map the pad interface with the wrapper \n")
        out_file.write("// assign constants or create your own logic for missing ports \n")
        out_file.write("  ); \n")
        out_file.write("\n")
        out_file.write("endmodule")
        out_file.close()

def pad_policy_check(pad_dict):
    valid_type  = ["V", "H"]
    valid_dir  = ["in", "out", "io"]
    in_v_checked = False
    in_h_checked = False
    out_v_checked = False
    out_h_checked = False
    io_v_checked = False
    io_h_checked = False

    if set(list(pad_dict.keys())) == set(valid_dir) and len(pad_dict) == 3:
        if len(pad_dict["in"]) == 2:
            for i in range(len(pad_dict["in"])):
                if pad_dict["in"][i]["type"] == "V" and in_v_checked == False:
                    in_v_checked = True
                elif pad_dict["in"][i]["type"] == "H" and in_h_checked == False:
                    in_h_checked = True
                else:
                   print("Error: \"Input pad direction has to have Horizontal and Vertical types\" ")
        else:
            print("Error: \"Input pad direction has to have two types\" ")
            
        if len(pad_dict["out"]) == 2:
            for i in range(len(pad_dict["out"])):
                if pad_dict["out"][i]["type"] == "V" and out_v_checked == False:
                    out_v_checked = True
                elif pad_dict["out"][i]["type"] == "H" and out_h_checked == False:
                    out_h_checked = True
                else:
                   print("Error: \"Output pad direction has to have Horizontal and Vertical types\" ")
        else:
            print("Error: \"Output pad direction has to have two types\" ")

        if len(pad_dict["io"]) == 2:
            for i in range(len(pad_dict["io"])):
                if pad_dict["io"][i]["type"] == "V" and io_v_checked == False:
                    io_v_checked = True
                elif pad_dict["io"][i]["type"] == "H" and io_h_checked == False:
                    io_h_checked = True
                else:
                   print("Error: \"Inout pad direction has to have Horizontal and Vertical types\" ")
        else:
            print("Error: \"Inout pad direction has to have two types\" ")

    else:
        print("Error: \"asic_padlist file must have three pads directions - in, out and io\" ")

    if in_v_checked and in_h_checked and out_v_checked and out_h_checked and io_v_checked and io_h_checked:
        valid_pads = True
    else:
        valid_pads = False

    return valid_pads


def pad_gen(out_path, pad_dict, valid_pads):

    if valid_pads == True:

        cnt = 0
    
        for idx in range(len(pad_dict["in"])):
            file = out_path + "/INPAD_" + pad_dict["in"][idx]["type"] + ".v"
            module = "INPAD_" + pad_dict["in"][idx]["type"]
            pad_dir = "IN"
            pad_type = pad_dict["in"][idx]["type"]
            macro_name = pad_dict["in"][idx]["macro_name"]
            if os.path.exists(file):
                None
            else:
                print_wrap_pad(file, module, macro_name, pad_dir, pad_type)
                print("\"input pad %s\" generated!" %(' '.join(map(str, list(pad_dict["in"][idx].values())))))
            
        for idx in range(len(pad_dict["out"])):
            file = out_path + "/OUTPAD_" + pad_dict["out"][idx]["type"] + ".v"
            module = "OUTPAD_" + pad_dict["out"][idx]["type"]
            pad_dir = "OUT"
            pad_type = pad_dict["out"][idx]["type"]
            macro_name = pad_dict["out"][idx]["macro_name"]
            if os.path.exists(file):
                None
            else:
                print_wrap_pad(file, module, macro_name, pad_dir, pad_type)
                print("\"output pad %s\" generated!" %(' '.join(map(str, list(pad_dict["out"][idx].values())))))
            
        for idx in range(len(pad_dict["io"])):
            file = out_path + "/IOPAD_" + pad_dict["io"][idx]["type"] + ".v"
            module = "IOPAD_" + pad_dict["io"][idx]["type"]
            pad_dir = "IO"
            pad_type = pad_dict["io"][idx]["type"]
            macro_name = pad_dict["io"][idx]["macro_name"]
            if os.path.exists(file):
                None
            else:
                print_wrap_pad(file, module, macro_name, pad_dir, pad_type)
                print("\"inout pad %s\" generated!" %(' '.join(map(str, list(pad_dict["io"][idx].values())))))


out_path = sys.argv[1]
pad_list = []
with open("asic_padlist.txt", "r") as pads:
    for pad_line in pads:
        pad_list.append(pad_line.split())
pads.close()

pad_dict = {"in" : [],
            "out": [],
            "io" : []}        

pad_dict = data_struct(pad_list)
valid_pads = pad_policy_check(pad_dict)
pad_gen(out_path, pad_dict, valid_pads)


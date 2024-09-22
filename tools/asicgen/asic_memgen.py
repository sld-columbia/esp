#!/usr/bin/env python
# coding: utf-8

import os
import sys
import math

def data_struct(memory_list):

    for row in memory_list:
        if str(row[0]) == "llc":
            mem_dict["llc"].append({"macro_name": str(row[1]),
                                    "address_size": str(row[2]),
                                    "word_size": str(row[3]),
                                    "area": str(row[4]),
                                    "port_type": str(row[5])})
        if str(row[0]) == "l2":
            mem_dict["l2"].append({"macro_name": str(row[1]),
                                    "address_size": str(row[2]),
                                    "word_size": str(row[3]),
                                    "area": str(row[4]),
                                    "port_type": str(row[5])})
        if str(row[0]) == "l1":
            mem_dict["l1"].append({"macro_name": str(row[1]),
                                    "address_size": str(row[2]),
                                    "word_size": str(row[3]),
                                    "area": str(row[4]),
                                    "port_type": str(row[5])})
        if str(row[0]) == "slm":
            mem_dict["slm"].append({"macro_name": str(row[1]),
                                    "address_size": str(row[2]),
                                    "word_size": str(row[3]),
                                    "area": str(row[4]),
                                    "port_type": str(row[5])})
        if str(row[0]) == "io":
            mem_dict["io"].append({"macro_name": str(row[1]),
                                    "address_size": str(row[2]),
                                    "word_size": str(row[3]),
                                    "area": str(row[4]),
                                    "port_type": str(row[5])})
        if str(row[0]) == "acc":
            mem_dict["acc"].append({"macro_name": str(row[1]),
                                    "address_size": str(row[2]),
                                    "word_size": str(row[3]),
                                    "area": str(row[4]),
                                    "port_type": str(row[5])})
            
        
    return mem_dict


def print_lib(file1, lib_list, tile_type):

    list_2rw = []
    list_1rw = []
    list_1rw1r = []
    has_2rw = False
    has_1rw1r = False

    if os.path.exists(file1):
        out_file = open(file1, "r")
        f = out_file.read()
        fl = f.split()
        for i in range(len(lib_list)):
            if lib_list[i][2] not in fl:
                if lib_list[i][-1] == "1rw":
                    list_1rw.append(lib_list[i])
                elif lib_list[i][-1] == "2rw":
                    list_2rw.append(lib_list[i])
                elif lib_list[i][-1] == "1rw1r":
                    list_1rw1r.append(lib_list[i])
        if "2rw" in f:
            has_2rw = True
        if "1rw1r" in f:
            has_1rw1r = True

        if len(list_1rw) > 0:
            for i in range(len(list_1rw)):
                if tile_type == "io":
                    if has_1rw1r or has_2rw:
                        out_file.seek(0)
                        f_line = out_file.readlines()
                        for j, line in enumerate(f_line):
                            if line.startswith("dual_port"):
                                f_line.insert(j, "%s 1 \n" %(' '.join(map(str, list(list_1rw[i][0:-1])))))
                                break
                        out_file = open(file1, "w")
                        out_file.writelines(f_line)
                        out_file.close()
                    else:
                        out_file = open(file1, "a")
                        out_file.write("%s 1 \n" %(' '.join(map(str, list(list_1rw[i][0:-1])))))
                        out_file.close()
                else:
                    if has_2rw:
                        out_file.seek(0)
                        f_line = out_file.readlines()
                        for j, line in enumerate(f_line):
                            if line.startswith("dual_port"):
                                f_line.insert(j, "%s 1 \n" %(' '.join(map(str, list(list_1rw[i][0:-1])))))
                                break
                        out_file = open(file1, "w")
                        out_file.writelines(f_line)
                        out_file.close()
                    else:
                        out_file = open(file1, "a")
                        out_file.write("%s 1 \n" %(' '.join(map(str, list(list_1rw[i][0:-1])))))
                        out_file.close()

        if len(list_1rw1r) > 0 and tile_type == "io":
            out_file = open(file1, "a+")
            for i in range(len(list_1rw1r)):
                if list_1rw1r[i][-1] == "1rw1r":
                    out_file.write("%s 2 \n" %(' '.join(map(str, list(list_1rw1r[i][0:-1])))))
        elif len(list_2rw) > 0:
            out_file = open(file1, "a+")
            for i in range(len(list_2rw)):
                if list_2rw[i][-1] == "2rw":
                    out_file.write("%s 2 \n" %(' '.join(map(str, list(list_2rw[i][0:-1])))))
            out_file.close()

    else:    
        out_file = open(file1, "w")
        out_file.write("# delay 0.5 \n")
        out_file.write("# setup 0.14 \n")
        out_file.write("# single_port \n")
        for i in range(len(lib_list)):
            if lib_list[i][-1] == "1rw":
                out_file.write("%s 1 \n" %(' '.join(map(str, list(lib_list[i][0:-1])))))
            elif lib_list[i][-1] == "1rw1r":
                list_1rw1r.append(lib_list[i])
            elif lib_list[i][-1] == "2rw":
                list_2rw.append(lib_list[i])
        if len(list_1rw1r) > 0 and tile_type == "io":
            out_file.write("# dual_port \n")
            for i in range(len(list_1rw1r)):
                if list_1rw1r[i][-1] == "1rw1r":
                    out_file.write("%s 2 \n" %(' '.join(map(str, list(list_1rw1r[i][0:-1])))))
        if len(list_2rw) > 0:
            out_file.write("# dual_port \n")
            for i in range(len(list_2rw)):
                if list_2rw[i][-1] == "2rw":
                    out_file.write("%s 2 \n" %(' '.join(map(str, list(list_2rw[i][0:-1])))))
        out_file.close()            

        
def print_wrap_sp(file1, module1, address1, word1, macro_name):

    if os.path.exists(file1):
        None
    else:
        out_file = open(file1, "w")
        out_file.write("`timescale 1 ps / 1ps \n")
        out_file.write("\n")
        out_file.write("module %s (CLK0, A0, D0, Q0, WE0, WEM0, CE0); \n" %module1)
        out_file.write("\n")
        out_file.write("  input           CLK0;\n")
        out_file.write("  input           WE0;\n")
        out_file.write("  input           CE0;\n")
        out_file.write("  input  [%d : 0] A0;\n" %(address1 - 1))
        out_file.write("  input  [%d : 0] D0;\n" %(word1 - 1))
        out_file.write("  input  [%d : 0] WEM0;\n" %(word1 - 1))
        out_file.write("  output [%d : 0] Q0;\n" %(word1 - 1))
        out_file.write("\n")
        out_file.write("// In case of chip enable and write enable active low \n")
        out_file.write("// Uncomment this logic \n")
        out_file.write("/* \n")
        out_file.write("  reg CEN; \n")
        out_file.write("  reg GWEN; \n")
        out_file.write("  reg [%d : 0] WEN; \n" %(word1 -1))
        out_file.write("  reg [%d : 0] A; \n" %(address1 -1))
        out_file.write("  reg [%d : 0] D; \n" %(word1 -1))
        out_file.write("\n")
        out_file.write("  always @(*) begin \n")
        out_file.write("    CEN = ~CE0; \n")
        out_file.write("    GWEN = ~WE0; \n")
        out_file.write("    WEN = ~WEM0; \n")
        out_file.write("    A = A0; \n")
        out_file.write("    D = D0; \n")
        out_file.write("  end \n")
        out_file.write("*/ \n")
        out_file.write("\n")
        out_file.write("  %s sram \n" %macro_name)
        out_file.write("  ( \n")
        out_file.write("// map the memory interface with the wrapper \n")
        out_file.write("// assign constants or create your own logic for missing ports \n")
        out_file.write("  ); \n")
        out_file.write("\n")
        out_file.write("endmodule")
        out_file.close()

def print_wrap_sp_tb(file1, module1, address1, word1):

    if os.path.exists(file1):
        None
    else:
        out_file = open(file1, "w")
        out_file.write("`timescale 1 ps / 1ps \n")
        out_file.write("\n")
        out_file.write("module %s_tb; \n" %module1)
        out_file.write("\n")
        out_file.write("    parameter ADDR_WIDTH=%d; \n" %(address1))
        out_file.write("    parameter DATA_WIDTH=%d; \n" %(word1))
        out_file.write("\n")
        out_file.write("    reg clk; \n")
        out_file.write("    reg we; \n")
        out_file.write("    reg ce; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] wem; \n")
        out_file.write("    reg [ADDR_WIDTH-1 : 0] addr; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] wr_data; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] rd_data; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] tmp_mem [0:2**ADDR_WIDTH-1]; \n")
        out_file.write("\n")
        out_file.write("    integer errors; \n")
        out_file.write("\n")
        out_file.write("    %s sram (\n" %module1)
        out_file.write("      .CLK0(clk),\n")
        out_file.write("      .WE0(we),\n")
        out_file.write("      .CE0(ce),\n")
        out_file.write("      .A0(addr),\n")
        out_file.write("      .D0(wr_data),\n")
        out_file.write("      .WEM0(wem),\n")
        out_file.write("      .Q0(rd_data)\n")
        out_file.write("    );\n")
        out_file.write("\n")
        out_file.write("    always #5 clk = ~clk;\n")
        out_file.write("\n")
        out_file.write("    initial begin\n")
        out_file.write("        {clk, ce, we, wem, addr, wr_data} <= 0;\n")
        out_file.write("        errors <= 0;\n")
        out_file.write("\n")
        out_file.write("        repeat (2) @(posedge clk);\n")
        out_file.write("\n")
        out_file.write("        ce <= 1'b1;\n")
        out_file.write("        we <= 1'b1;\n")
        out_file.write("        wem <= {DATA_WIDTH{1'b1}};\n")
        out_file.write("\n")
        out_file.write("        for (integer i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin\n")
        out_file.write("            addr = i;\n")
        out_file.write("            wr_data = $random;\n")
        out_file.write("            tmp_mem[i] = wr_data;\n")
        out_file.write("            repeat (1) @(posedge clk);\n")
        out_file.write("        end\n")
        out_file.write("\n")
        out_file.write("        we <= 1'b0;\n")
        out_file.write("\n")
        out_file.write("        for (integer i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin\n")
        out_file.write("            addr <= i;\n")
        out_file.write("            repeat (1) @(posedge clk);\n")
        out_file.write("            if (i!=0 && rd_data !== tmp_mem[i-1]) begin\n")
        out_file.write("                $display(\"Mismatch at time=%0t a=0x%0h exp=0x%0h got=0x%0h\", $time, i-1, tmp_mem[i-1], rd_data);\n")
        out_file.write("                errors <= errors + 1;\n")
        out_file.write("            end\n")
        out_file.write("        end\n")
        out_file.write("\n")
        out_file.write("        $display(\"Errors: %0d\", errors);\n")
        out_file.write("        $finish;\n")
        out_file.write("    end\n")
        out_file.write("\n")
        out_file.write("endmodule\n")
        out_file.close()

def print_wrap_io_dp(file1, module1, address1, word1, macro_name):
     
    if os.path.exists(file1):
        None
    else:
        out_file = open(file1, "w")
        out_file.write("`timescale 1 ps / 1ps \n")
        out_file.write("\n")
        out_file.write("module %s (CLK0, A0, Q0, CE0, \n" %module1)
        out_file.write("           CLK1, A1, D1, WE1, WEM1, CE1); \n")
        out_file.write("\n")
        out_file.write("  input           CLK0;\n")
        out_file.write("  input           CLK1;\n")
        out_file.write("  input           CE0;\n")
        out_file.write("  input           CE1;\n")
        out_file.write("  input           WE1;\n")
        out_file.write("  input  [%d : 0] A0;\n" %(address1 - 1))
        out_file.write("  input  [%d : 0] A1;\n" %(address1 - 1))
        out_file.write("  input  [%d : 0] D1;\n" %(word1 - 1))
        out_file.write("  input  [%d : 0] WEM1;\n" %(word1 - 1))
        out_file.write("  output [%d : 0] Q0;\n" %(word1 - 1))
        out_file.write("\n")
        out_file.write("// In case of chip enable and write enable active low \n")
        out_file.write("// Uncomment this logic \n")
        out_file.write("/* \n")
        out_file.write("  reg P0_CEN; \n")
        out_file.write("  reg P1_CEN; \n")
        out_file.write("  reg [%d : 0] P1_WEN; \n" %(word1 -1))
        out_file.write("  reg [%d : 0] P0_A; \n" %(address1 -1))
        out_file.write("  reg [%d : 0] P1_A; \n" %(address1 -1))
        out_file.write("  reg [%d : 0] P1_D; \n" %(word1 -1))
        out_file.write("\n")
        out_file.write("  always @(*) begin \n")
        out_file.write("    P0_CEN = ~CE0; \n")
        out_file.write("    P0_A = A0; \n")
        out_file.write("    P1_CEN = ~CE1; \n")
        out_file.write("    P1_WEN = (WE1 == 1'b1)? ~WEM1 : {%d{1'b1}}; \n" %word1)
        out_file.write("    P1_A = A1; \n")
        out_file.write("    P1_D = D1; \n")
        out_file.write("  end \n")
        out_file.write("*/ \n")
        out_file.write("\n")
        out_file.write("  %s sram \n" %macro_name)
        out_file.write("  ( \n")
        out_file.write("// map the memory interface with the wrapper \n")
        out_file.write("// assign constants or create your own logic for missing ports \n")
        out_file.write("  ); \n")
        out_file.write("\n")
        out_file.write("endmodule")
        out_file.close()

def print_wrap_io_dp_tb(file1, module1, address1, word1):

    if os.path.exists(file1):
        None
    else:
        out_file = open(file1, "w")
        out_file.write("`timescale 1 ps / 1ps \n")
        out_file.write("\n")
        out_file.write("module %s_tb; \n" %module1)
        out_file.write("\n")
        out_file.write("    parameter ADDR_WIDTH=%d; \n" %(address1))
        out_file.write("    parameter DATA_WIDTH=%d; \n" %(word1))
        out_file.write("\n")
        out_file.write("    reg clk; \n")
        out_file.write("    reg we; \n")
        out_file.write("    reg ce; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] wem; \n")
        out_file.write("    reg [ADDR_WIDTH-1 : 0] addr; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] wr_data; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] rd_data; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] tmp_mem [0:2**ADDR_WIDTH-1]; \n")
        out_file.write("\n")
        out_file.write("    integer errors; \n")
        out_file.write("\n")
        out_file.write("    %s sram (\n" %module1)
        out_file.write("      .CLK0(clk),\n")
        out_file.write("      .CE0(ce),\n")
        out_file.write("      .A0(addr),\n")
        out_file.write("      .Q0(rd_data),\n")
        out_file.write("      .CLK1(clk),\n")
        out_file.write("      .CE1(ce),\n")
        out_file.write("      .A1(addr),\n")
        out_file.write("      .WE1(we),\n")
        out_file.write("      .WEM1(wem),\n")
        out_file.write("      .D1(wr_data)\n")
        out_file.write("    );\n")
        out_file.write("\n")
        out_file.write("    always #5 clk = ~clk;\n")
        out_file.write("\n")
        out_file.write("    initial begin\n")
        out_file.write("        {clk, ce, we, wem, addr, wr_data} <= 0;\n")
        out_file.write("        errors <= 0;\n")
        out_file.write("\n")
        out_file.write("        repeat (2) @(posedge clk);\n")
        out_file.write("\n")
        out_file.write("        ce <= 1'b1;\n")
        out_file.write("        we <= 1'b1;\n")
        out_file.write("        wem <= {DATA_WIDTH{1'b1}};\n")
        out_file.write("\n")
        out_file.write("        for (integer i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin\n")
        out_file.write("            addr = i;\n")
        out_file.write("            wr_data = $random;\n")
        out_file.write("            tmp_mem[i] = wr_data;\n")
        out_file.write("            repeat (1) @(posedge clk);\n")
        out_file.write("        end\n")
        out_file.write("\n")
        out_file.write("        we <= 1'b0;\n")
        out_file.write("\n")
        out_file.write("        for (integer i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin\n")
        out_file.write("            addr <= i;\n")
        out_file.write("            repeat (1) @(posedge clk);\n")
        out_file.write("            if (i!=0 && rd_data !== tmp_mem[i-1]) begin\n")
        out_file.write("                $display(\"Mismatch at time=%0t a=0x%0h exp=0x%0h got=0x%0h\", $time, i-1, tmp_mem[i-1], rd_data);\n")
        out_file.write("                errors <= errors + 1;\n")
        out_file.write("            end\n")
        out_file.write("        end\n")
        out_file.write("\n")
        out_file.write("        $display(\"Errors: %0d\", errors);\n")
        out_file.write("        $finish;\n")
        out_file.write("    end\n")
        out_file.write("\n")
        out_file.write("endmodule\n")
        out_file.close()

def print_wrap_dp(file1, module1, address1, word1, macro_name):
     
    if os.path.exists(file1):
        None
    else:
        out_file = open(file1, "w")
        out_file.write("`timescale 1 ps / 1ps \n")
        out_file.write("\n")
        out_file.write("module %s (CLK0, A0, D0, WE0, WEM0, Q0, CE0, \n" %module1)
        out_file.write("           CLK1, A1, D1, WE1, WEM1, Q1, CE1); \n")
        out_file.write("\n")
        out_file.write("  input           CLK0;\n")
        out_file.write("  input           CLK1;\n")
        out_file.write("  input           CE0;\n")
        out_file.write("  input           CE1;\n")
        out_file.write("  input           WE0;\n")
        out_file.write("  input           WE1;\n")
        out_file.write("  input  [%d : 0] A0;\n" %(address1 - 1))
        out_file.write("  input  [%d : 0] A1;\n" %(address1 - 1))
        out_file.write("  input  [%d : 0] D0;\n" %(word1 - 1))
        out_file.write("  input  [%d : 0] D1;\n" %(word1 - 1))
        out_file.write("  input  [%d : 0] WEM0;\n" %(word1 - 1))
        out_file.write("  input  [%d : 0] WEM1;\n" %(word1 - 1))
        out_file.write("  output [%d : 0] Q0;\n" %(word1 - 1))
        out_file.write("  output [%d : 0] Q1;\n" %(word1 - 1))
        out_file.write("\n")
        out_file.write("// In case of chip enable and write enable active low \n")
        out_file.write("// Uncomment this logic \n")
        out_file.write("/* \n")
        out_file.write("  reg P0_CEN; \n")
        out_file.write("  reg P1_CEN; \n")
        out_file.write("  reg [%d : 0] P0_WEN; \n" %(word1 -1))
        out_file.write("  reg [%d : 0] P1_WEN; \n" %(word1 -1))
        out_file.write("  reg [%d : 0] P0_A; \n" %(address1 -1))
        out_file.write("  reg [%d : 0] P1_A; \n" %(address1 -1))
        out_file.write("  reg [%d : 0] P0_D; \n" %(word1 -1))
        out_file.write("  reg [%d : 0] P1_D; \n" %(word1 -1))
        out_file.write("\n")
        out_file.write("  always @(*) begin \n")
        out_file.write("    P0_CEN = ~CE0; \n")
        out_file.write("    P0_WEN = (WE0 == 1'b1)? ~WEM0 : {%d{1'b1}}; \n" %word1)
        out_file.write("    P0_A = A0; \n")
        out_file.write("    P0_D = D0; \n")
        out_file.write("    P1_CEN = ~CE1; \n")
        out_file.write("    P1_WEN = (WE1 == 1'b1)? ~WEM1 : {%d{1'b1}}; \n" %word1)
        out_file.write("    P1_A = A1; \n")
        out_file.write("    P1_D = D1; \n")
        out_file.write("  end \n")
        out_file.write("*/ \n")
        out_file.write("\n")
        out_file.write("  %s sram \n" %macro_name)
        out_file.write("  ( \n")
        out_file.write("// map the memory interface with the wrapper \n")
        out_file.write("// assign constants or create your own logic for missing ports \n")
        out_file.write("  ); \n")
        out_file.write("\n")
        out_file.write("endmodule")
        out_file.close()

def print_wrap_dp_tb(file1, module1, address1, word1):

    if os.path.exists(file1):
        None
    else:
        out_file = open(file1, "w")
        out_file.write("`timescale 1 ps / 1ps \n")
        out_file.write("\n")
        out_file.write("module %s_tb; \n" %module1)
        out_file.write("\n")
        out_file.write("    parameter ADDR_WIDTH=%d; \n" %(address1))
        out_file.write("    parameter DATA_WIDTH=%d; \n" %(word1))
        out_file.write("\n")
        out_file.write("    reg clk; \n")
        out_file.write("    reg we0; \n")
        out_file.write("    reg we1; \n")
        out_file.write("    reg ce0; \n")
        out_file.write("    reg ce1; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] wem0; \n")
        out_file.write("    reg [ADDR_WIDTH-1 : 0] addr0; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] wr_data0; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] rd_data0; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] wem1; \n")
        out_file.write("    reg [ADDR_WIDTH-1 : 0] addr1; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] wr_data1; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] rd_data1; \n")
        out_file.write("    reg [DATA_WIDTH-1 : 0] tmp_mem [0:2**ADDR_WIDTH-1]; \n")
        out_file.write("\n")
        out_file.write("    integer errors; \n")
        out_file.write("\n")
        out_file.write("    %s sram (\n" %module1 )
        out_file.write("      .CLK0(clk),\n")
        out_file.write("      .CE0(ce0),\n")
        out_file.write("      .WE0(we0),\n")
        out_file.write("      .WEM0(wem0),\n")
        out_file.write("      .A0(addr0),\n")
        out_file.write("      .D0(wr_data0),\n")
        out_file.write("      .Q0(rd_data0),\n")
        out_file.write("      .CLK1(clk),\n")
        out_file.write("      .CE1(ce1),\n")
        out_file.write("      .A1(addr1),\n")
        out_file.write("      .WE1(we1),\n")
        out_file.write("      .WEM1(wem1),\n")
        out_file.write("      .D1(wr_data1),\n")
        out_file.write("      .Q1(rd_data1)\n")
        out_file.write("    );\n")
        out_file.write("\n")
        out_file.write("    always #5 clk = ~clk;\n")
        out_file.write("\n")
        out_file.write("    initial begin\n")
        out_file.write("        {clk, ce0, we0, wem0, addr0, wr_data0} <= 0;\n")
        out_file.write("        errors <= 0;\n")
        out_file.write("\n")
        out_file.write("        repeat (2) @(posedge clk);\n")
        out_file.write("\n")
        out_file.write("        ce0 <= 1'b1;\n")
        out_file.write("        we0 <= 1'b1;\n")
        out_file.write("        wem0 <= {DATA_WIDTH{1'b1}};\n")
        out_file.write("\n")
        out_file.write("        ce1 <= 1'b1;\n")
        out_file.write("        we1 <= 1'b0;\n")
        out_file.write("        wem1 <= {DATA_WIDTH{1'b1}};\n")
        out_file.write("\n")
        out_file.write("        for (integer i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin\n")
        out_file.write("            addr0 = i;\n")
        out_file.write("            wr_data0 = $random;\n")
        out_file.write("            tmp_mem[i] = wr_data0;\n")
        out_file.write("            repeat (1) @(posedge clk);\n")
        out_file.write("        end\n")
        out_file.write("\n")
        out_file.write("        we0 <= 1'b0;\n")
        out_file.write("\n")
        out_file.write("        for (integer i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin\n")
        out_file.write("            addr1 <= i;\n")
        out_file.write("            repeat (1) @(posedge clk);\n")
        out_file.write("            if (i!=0 && rd_data1 !== tmp_mem[i-1]) begin\n")
        out_file.write("                $display(\"Mismatch at time=%0t a=0x%0h exp=0x%0h got=0x%0h\", $time, i-1, tmp_mem[i-1], rd_data1);\n")
        out_file.write("                errors <= errors + 1;\n")
        out_file.write("            end\n")
        out_file.write("        end\n")
        out_file.write("\n")
        out_file.write("        $display(\"Errors: %0d\", errors);\n")
        out_file.write("        $finish;\n")
        out_file.write("    end\n")
        out_file.write("\n")
        out_file.write("endmodule\n")
        out_file.close()


def print_cache_def(memory, module, address_size):

    file = "cache_def_mem_asic.sv"
    match = False
    mem_type = memory.split("_")[0]
    f_mem_list = []
    if os.path.exists(file):
        out_file = open(file, "a+r")
        f = out_file.readlines()
        for i in range(len(f)):
            f_split = f[i].split("_")
            f_mem_list.append(f_split[0].split()[1])
        if mem_type not in f_mem_list:
            out_file.write("`define %s_ASIC_SRAM_SIZE %s \n" %(mem_type, address_size))
        if memory not in f:
            out_file.write("`define %s %s \n" %(memory, module))

    else:
        out_file = open(file, "w")
        out_file.write("`define %s_ASIC_SRAM_SIZE %s \n" %(mem_type, address_size))
        out_file.write("`define %s %s \n" %(memory, module))
    out_file.close()

def llc_policy_check(mem_dict):
    idx = {}
    valid_addresses = []
    valid_bits = ["64", "28", "16"]
    for i in range(len(mem_dict["llc"])):
        idx[mem_dict["llc"][i]["address_size"]] = 0
    
    for i in range(len(mem_dict["llc"])):
        if int(mem_dict["llc"][i]["word_size"]) == 64:
            idx[mem_dict["llc"][i]["address_size"]] += 1
        if int(mem_dict["llc"][i]["word_size"]) == 28:
            idx[mem_dict["llc"][i]["address_size"]] += 1
        if int(mem_dict["llc"][i]["word_size"]) == 16:
            idx[mem_dict["llc"][i]["address_size"]] += 1

    for i in idx.keys():
        if idx[i] == 3:
            #print("LLC address size %s passed in policy check" %i)
            valid_addresses.append(i)
        elif idx[i] == 2:
            print("Error: \"llc %s failed in policy check\" " %i)
            print("       LLC must have the same address size for 64, 28, and 16 bits")
        elif idx[i] == 1:
            print("Error: \"llc %s failed in policy check\" " %i)
            print("       LLC must have the same address size for 64, 28, and 16 bits")
            
    for i in range(len(mem_dict["llc"])):
        if mem_dict["llc"][i]["word_size"] not in valid_bits:
            print("Error: \"llc %s\" " %(' '.join(map(str, list(mem_dict["llc"][i].values())))))
            print('''       LLC must have the following word sizes:
                CACHE LINE -> 64 bits
                CACHE MIXED -> 28 bits
                CACHE SHARED -> 16 bits
                ''')

    valid_addresses.sort()        

    return valid_addresses


def llc_sp_gen(out_path, mem_dict, val_addr):

    lib_list = []
    cnt = 0
    
    for idx in range(len(mem_dict["llc"])):
        if mem_dict["llc"][idx]["address_size"] in val_addr:
            if int(mem_dict["llc"][idx]["word_size"]) == 64:
                file = out_path + "/LLC_SRAM_SP_LINE_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"] + ".v"
                file_tb = out_path + "/tb/LLC_SRAM_SP_LINE_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"] + "_tb.sv"
                module = "LLC_SRAM_SP_LINE_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"]
                memory = "LLC_SRAM_SP_LINE"
                address = int(math.log(int(mem_dict["llc"][idx]["address_size"]),2))
                word = int(mem_dict["llc"][idx]["word_size"])
                macro_name = mem_dict["llc"][idx]["macro_name"]
                address_size = mem_dict["llc"][idx]["address_size"]
                area = mem_dict["llc"][idx]["area"]
                port_type = mem_dict["llc"][idx]["port_type"]
                lib_list.append([address_size, word, module, area, port_type])
                if os.path.exists(file):
                    None
                else:
                    print_wrap_sp(file, module, address, word, macro_name)
                    print("\"llc %s\" generated!" %(' '.join(map(str, list(mem_dict["llc"][idx].values())))))
                if os.path.exists(file_tb):
                    None
                else:
                    print_wrap_sp_tb(file_tb, module, address, word)
                    print("\"llc_tb %s\" generated!" %(' '.join(map(str, list(mem_dict["llc"][idx].values())))))
                if cnt < 3:
                    print_cache_def(memory, module, address_size)
                cnt += 1
        
            elif int(mem_dict["llc"][idx]["word_size"]) == 28:
                file = out_path + "/LLC_SRAM_SP_MIXED_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"] + ".v"
                file_tb = out_path + "/tb/LLC_SRAM_SP_MIXED_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"] + "_tb.sv"
                module = "LLC_SRAM_SP_MIXED_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"]
                memory = "LLC_SRAM_SP_MIXED"
                address = int(math.log(int(mem_dict["llc"][idx]["address_size"]),2))
                word = int(mem_dict["llc"][idx]["word_size"])
                macro_name = mem_dict["llc"][idx]["macro_name"]
                address_size = mem_dict["llc"][idx]["address_size"]
                area = mem_dict["llc"][idx]["area"]
                port_type = mem_dict["llc"][idx]["port_type"]
                lib_list.append([address_size, word, module, area, port_type])
                if os.path.exists(file):
                    None
                else:
                    print_wrap_sp(file, module, address, word, macro_name)
                    print("\"llc %s\" generated!" %(' '.join(map(str, list(mem_dict["llc"][idx].values())))))
                if os.path.exists(file_tb):
                    None
                else:
                    print_wrap_sp_tb(file_tb, module, address, word)
                    print("\"llc_tb %s\" generated!" %(' '.join(map(str, list(mem_dict["llc"][idx].values())))))
                if cnt < 3:
                    print_cache_def(memory, module, address_size)
                cnt += 1

        
            elif int(mem_dict["llc"][idx]["word_size"]) == 16:
                file = out_path + "/LLC_SRAM_SP_SHARED_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"] + ".v"
                file_tb = out_path + "/tb/LLC_SRAM_SP_SHARED_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"] + "_tb.sv"
                module = "LLC_SRAM_SP_SHARED_" + mem_dict["llc"][idx]["address_size"] + "x" + mem_dict["llc"][idx]["word_size"]
                memory = "LLC_SRAM_SP_SHARED"
                address = int(math.log(int(mem_dict["llc"][idx]["address_size"]),2))
                word = int(mem_dict["llc"][idx]["word_size"])
                macro_name = mem_dict["llc"][idx]["macro_name"]
                address_size = mem_dict["llc"][idx]["address_size"]
                area = mem_dict["llc"][idx]["area"]
                port_type = mem_dict["llc"][idx]["port_type"]
                lib_list.append([address_size, word, module, area, port_type])
                if os.path.exists(file):
                    None
                else:
                    print_wrap_sp(file, module, address, word, macro_name)
                    print("\"llc %s\" generated!" %(' '.join(map(str, list(mem_dict["llc"][idx].values())))))
                if os.path.exists(file_tb):
                    None
                else:
                    print_wrap_sp_tb(file_tb, module, address, word)
                    print("\"llc_tb %s\" generated!" %(' '.join(map(str, list(mem_dict["llc"][idx].values())))))
                if cnt < 3:
                    print_cache_def(memory, module, address_size)
                cnt += 1
        
            else:
                None
            
    if len(lib_list)>0:
        file = out_path + "/llc_lib.txt"
        print_lib(file, lib_list, "llc")


def l2_policy_check(mem_dict):
    idx = {}
    valid_addresses = []
    valid_bits = ["64", "24"]
    for i in range(len(mem_dict["l2"])):
        idx[mem_dict["l2"][i]["address_size"]] = 0
    
    for i in range(len(mem_dict["l2"])):
        if int(mem_dict["l2"][i]["word_size"]) == 64:
            idx[mem_dict["l2"][i]["address_size"]] += 1
        if int(mem_dict["l2"][i]["word_size"]) == 24:
            idx[mem_dict["l2"][i]["address_size"]] += 1

    for i in idx.keys():
        if idx[i] == 2:
            #print("L2 address size %s passed in policy check" %i)
            valid_addresses.append(i)
        elif idx[i] == 1:
            print("Error: \"l2 %s failed in policy check\" " %i)
            print("       L2 must have the same address size for 64, and 24 bits")
            
    for i in range(len(mem_dict["l2"])):
        if mem_dict["l2"][i]["word_size"] not in valid_bits:
            print("Error: \"l2 %s\" " %(' '.join(map(str, list(mem_dict["l2"][i].values())))))
            print('''       L2 must have the following word sizes:
                CACHE LINE -> 64 bits
                CACHE MIXED -> 24 bits
                ''')
    
    valid_addresses.sort()
        
    return valid_addresses


def l2_sp_gen(out_path, mem_dict, val_addr):

    lib_list = []
    cnt = 0
    
    for idx in range(len(mem_dict["l2"])):
        if mem_dict["l2"][idx]["address_size"] in val_addr:
            if int(mem_dict["l2"][idx]["word_size"]) == 64:
                file = out_path + "/L2_SRAM_SP_LINE_" + mem_dict["l2"][idx]["address_size"] + "x" + mem_dict["l2"][idx]["word_size"] + ".v"
                file_tb = out_path + "/tb/L2_SRAM_SP_LINE_" + mem_dict["l2"][idx]["address_size"] + "x" + mem_dict["l2"][idx]["word_size"] + "_tb.sv"
                module = "L2_SRAM_SP_LINE_" + mem_dict["l2"][idx]["address_size"] + "x" + mem_dict["l2"][idx]["word_size"]
                memory = "L2_SRAM_SP_LINE"
                address = int(math.log(int(mem_dict["l2"][idx]["address_size"]),2))
                word = int(mem_dict["l2"][idx]["word_size"])
                macro_name = mem_dict["l2"][idx]["macro_name"]
                address_size = mem_dict["l2"][idx]["address_size"]
                area = mem_dict["l2"][idx]["area"]
                port_type = mem_dict["l2"][idx]["port_type"]
                lib_list.append([address_size, word, module, area, port_type])
                if os.path.exists(file):
                    None
                else:
                    print_wrap_sp(file, module, address, word, macro_name)
                    print("\"l2 %s\" generated!" %(' '.join(map(str, list(mem_dict["l2"][idx].values())))))
                if os.path.exists(file_tb):
                    None
                else:
                    print_wrap_sp_tb(file_tb, module, address, word)
                    print("\"l2_tb %s\" generated!" %(' '.join(map(str, list(mem_dict["l2"][idx].values())))))
                if cnt < 2:
                    print_cache_def(memory, module, address_size)
                cnt += 1
        
            elif int(mem_dict["l2"][idx]["word_size"]) == 24:
                file = out_path + "/L2_SRAM_SP_MIXED_" + mem_dict["l2"][idx]["address_size"] + "x" + mem_dict["l2"][idx]["word_size"] + ".v"
                file_tb = out_path + "/tb/L2_SRAM_SP_MIXED_" + mem_dict["l2"][idx]["address_size"] + "x" + mem_dict["l2"][idx]["word_size"] + "_tb.sv"
                module = "L2_SRAM_SP_MIXED_" + mem_dict["l2"][idx]["address_size"] + "x" + mem_dict["l2"][idx]["word_size"]
                memory = "L2_SRAM_SP_MIXED"
                address = int(math.log(int(mem_dict["l2"][idx]["address_size"]),2))
                word = int(mem_dict["l2"][idx]["word_size"])
                macro_name = mem_dict["l2"][idx]["macro_name"]
                address_size = mem_dict["l2"][idx]["address_size"]
                area = mem_dict["l2"][idx]["area"]
                port_type = mem_dict["l2"][idx]["port_type"]
                lib_list.append([address_size, word, module, area, port_type])
                if os.path.exists(file):
                    None
                else:
                    print_wrap_sp(file, module, address, word, macro_name)
                    print("\"l2 %s\" generated!" %(' '.join(map(str, list(mem_dict["l2"][idx].values())))))
                if os.path.exists(file_tb):
                    None
                else:
                    print_wrap_sp_tb(file_tb, module, address, word)
                    print("\"l2_tb %s\" generated!" %(' '.join(map(str, list(mem_dict["l2"][idx].values())))))
                if cnt < 2:
                    print_cache_def(memory, module, address_size)
                cnt += 1
        
            else:
                None
            
    if len(lib_list)>0:
        file = out_path + "/l2_lib.txt"
        print_lib(file, lib_list, "l2")


def l1_sp_gen(out_path, mem_dict):
    
    lib_list = []

    if int(mem_dict["l1"][0]["word_size"]) == 64:
        if int(mem_dict["l1"][0]["address_size"]) == 256:
            file = out_path + "/L1_SRAM_SP" + ".v"
            file_tb = out_path + "/tb/L1_SRAM_SP_tb.sv"
            module = "L1_SRAM_SP"
            address = int(math.log(int(mem_dict["l1"][0]["address_size"]),2))
            word = int(mem_dict["l1"][0]["word_size"])
            macro_name = mem_dict["l1"][0]["macro_name"]
            address_size = mem_dict["l1"][0]["address_size"]
            area = mem_dict["l1"][0]["area"]
            port_type = mem_dict["l1"][0]["port_type"]
            lib_list.append([address_size, word, module, area, port_type])
            if os.path.exists(file):
                None
            else:
                print_wrap_sp(file, module, address, word, macro_name)
                print("\"l1 %s\" generated!" %(' '.join(map(str, list(mem_dict["l1"][0].values())))))
            if os.path.exists(file_tb):
                None
            else:
                print_wrap_sp_tb(file_tb, module, address, word)
                print("\"l1_tb %s\" generated!" %(' '.join(map(str, list(mem_dict["l1"][0].values())))))
            file = out_path + "/l1_lib.txt"
            print_lib(file, lib_list, "l1")
                
        else:
            print("Error: \"l1 %s\" " %(' '.join(map(str, list(mem_dict["l1"][0].values())))))
            print('''       L1 must have 256 address size
            ''')
    else:
        print("Error: \"l1 %s\" " %(' '.join(map(str, list(mem_dict["l1"][0].values())))))
        print('''       L1 must have 64 word size
        ''')
                


def slm_policy_check(mem_dict):
    valid_word_size = []
    valid_bits = ["64"]
    
    for i in range(len(mem_dict["slm"])):
        if mem_dict["slm"][i]["word_size"] not in valid_bits:
            print("Error: \"slm %s\" " %(' '.join(map(str, list(mem_dict["slm"][i].values())))))
            print('''       SLM must have word size of 64
                ''')
        else:
            valid_word_size.append(mem_dict["slm"][i]["word_size"])
            
    return valid_word_size


def slm_sp_gen(out_path, mem_dict, val_word):

    lib_list = []
    
    for idx in range(len(mem_dict["slm"])):
        if mem_dict["slm"][idx]["word_size"] in val_word:
            file = out_path + "/SLM_SRAM_SP_" + mem_dict["slm"][idx]["address_size"] + "x" + mem_dict["slm"][idx]["word_size"] + ".v"
            file_tb = out_path + "/tb/SLM_SRAM_SP_" + mem_dict["slm"][idx]["address_size"] + "x" + mem_dict["slm"][idx]["word_size"] + "_tb.sv"
            module = "SLM_SRAM_SP_" + mem_dict["slm"][idx]["address_size"] + "x" + mem_dict["slm"][idx]["word_size"]
            address = int(math.log(int(mem_dict["slm"][idx]["address_size"]),2))
            word = int(mem_dict["slm"][idx]["word_size"])
            macro_name = mem_dict["slm"][idx]["macro_name"]
            address_size = mem_dict["slm"][idx]["address_size"]
            area = mem_dict["slm"][idx]["area"]
            port_type = mem_dict["slm"][idx]["port_type"]
            lib_list.append([address_size, word, module, area, port_type])
            if os.path.exists(file):
                None
            else:
                print_wrap_sp(file, module, address, word, macro_name)
                print("\"slm %s\" generated!" %(' '.join(map(str, list(mem_dict["slm"][idx].values())))))
            if os.path.exists(file_tb):
                None
            else:
                print_wrap_sp_tb(file_tb, module, address, word)
                print("\"slm_tb %s\" generated!" %(' '.join(map(str, list(mem_dict["slm"][idx].values())))))
    
        else:
            None

    if len(lib_list) > 0:
        file = out_path + "/slm_lib.txt"
        print_lib(file, lib_list, "slm")


def io_dp_policy_check(mem_dict):
    
    valid_conf = []
    valid_comb = [("4096","16"), ("256","32")]
    
    for i in range(len(mem_dict["io"])):
        if mem_dict["io"][i]["port_type"] == "1rw1r" or mem_dict["io"][i]["port_type"] == "2rw":
            if (mem_dict["io"][i]["address_size"], mem_dict["io"][i]["word_size"]) not in valid_comb:
                print("Error: \"io %s\" " %(' '.join(map(str, list(mem_dict["io"][i].values())))))
                print('''       Dual port IO memory supports the following configuration:
                address size of 4096 and word size of 16 bits
                address size of 256 and word size of 32 bits
                ''')
            else:
                valid_conf.append((mem_dict["io"][i]["address_size"], mem_dict["io"][i]["word_size"]))
            
    return valid_conf


def io_sp_policy_check(mem_dict):
    
    valid_conf = []
    valid_bits = ["8"]
    valid_addresses = ["256", "512", "1024", "2048", "4096", "8192", "16384"]
    
    for i in range(len(mem_dict["io"])):
        if mem_dict["io"][i]["port_type"] == "1rw":
            if mem_dict["io"][i]["address_size"] not in valid_addresses:
                print("Error: \"io %s\" " %(' '.join(map(str, list(mem_dict["io"][i].values())))))
                print('''       Single port IO memory support the following address sizes:
                %s
                ''' %(' '.join(map(str, list(valid_addresses)))))
            elif mem_dict["io"][i]["word_size"] not in valid_bits:
                print("Error: \"io %s\" " %(' '.join(map(str, list(mem_dict["io"][i].values())))))
                print('''       Single port IO memory support the following bit sizes:
                %s
                ''' %(' '.join(map(str, list(valid_bits)))))
                
            else:
                valid_conf.append((mem_dict["io"][i]["address_size"], mem_dict["io"][i]["word_size"]))
                
    return valid_conf


def io_gen(out_path, mem_dict, val_dp_conf, val_sp_conf):
    
    lib_list = []

    for idx in range(len(mem_dict["io"])):
        if mem_dict["io"][idx]["port_type"] == "1rw1r" or mem_dict["io"][idx]["port_type"] == "2rw":
            if (mem_dict["io"][idx]["address_size"], mem_dict["io"][idx]["word_size"]) in val_dp_conf:
                file = out_path + "/IO_DP_" + mem_dict["io"][idx]["address_size"] + "x" + mem_dict["io"][idx]["word_size"] + ".v"
                file_tb = out_path + "/tb/IO_DP_" + mem_dict["io"][idx]["address_size"] + "x" + mem_dict["io"][idx]["word_size"] + "_tb.sv"
                module = "IO_DP_" + mem_dict["io"][idx]["address_size"] + "x" + mem_dict["io"][idx]["word_size"]
                address = int(math.log(int(mem_dict["io"][idx]["address_size"]),2))
                word = int(mem_dict["io"][idx]["word_size"])
                macro_name = mem_dict["io"][idx]["macro_name"]
                address_size = mem_dict["io"][idx]["address_size"]
                area = mem_dict["io"][idx]["area"]
                port_type = mem_dict["io"][idx]["port_type"]

                lib_list.append([address_size, word, module, area, port_type])
                if os.path.exists(file):
                    None
                else:
                    print_wrap_io_dp(file, module, address, word, macro_name)
                    print("\"io dual port %s\" generated!" %(' '.join(map(str, list(mem_dict["io"][idx].values())))))
                if os.path.exists(file_tb):
                    None
                else:
                    print_wrap_io_dp_tb(file_tb, module, address, word)
                    print("\"io_tb dual port %s\" generated!" %(' '.join(map(str, list(mem_dict["io"][idx].values())))))
    
            else:
                None

        elif mem_dict["io"][idx]["port_type"] == "1rw":
            if (mem_dict["io"][idx]["address_size"], mem_dict["io"][idx]["word_size"]) in val_sp_conf:
                file = out_path + "/IO_SP_" + mem_dict["io"][idx]["address_size"] + "x" + mem_dict["io"][idx]["word_size"] + ".v"
                file_tb = out_path + "/tb/IO_SP_" + mem_dict["io"][idx]["address_size"] + "x" + mem_dict["io"][idx]["word_size"] + "_tb.sv"
                module = "IO_SP_" + mem_dict["io"][idx]["address_size"] + "x" + mem_dict["io"][idx]["word_size"]
                address = int(math.log(int(mem_dict["io"][idx]["address_size"]),2))
                word = int(mem_dict["io"][idx]["word_size"])
                macro_name = mem_dict["io"][idx]["macro_name"]
                address_size = mem_dict["io"][idx]["address_size"]
                area = mem_dict["io"][idx]["area"]
                port_type = mem_dict["io"][idx]["port_type"]
                lib_list.append([address_size, word, module, area, port_type])
                if os.path.exists(file):
                    None
                else:
                    print_wrap_sp(file, module, address, word, macro_name)
                    print("\"io single port %s\" generated!" %(' '.join(map(str, list(mem_dict["io"][idx].values())))))
                if os.path.exists(file_tb):
                    None
                else:
                    print_wrap_sp_tb(file_tb, module, address, word)
                    print("\"io_tb single port %s\" generated!" %(' '.join(map(str, list(mem_dict["io"][idx].values())))))
    
        else:
            None    
            
    if len(lib_list) > 0:
        file = out_path + "/io_lib.txt"
        print_lib(file, lib_list, "io")

def acc_gen(out_path, mem_dict):
    
    lib_list = []

    for idx in range(len(mem_dict["acc"])):
        if mem_dict["acc"][idx]["port_type"] == "2rw":
            file = out_path + "/ACC_SRAM_DP_" + mem_dict["acc"][idx]["address_size"] + "x" + mem_dict["acc"][idx]["word_size"] + ".v"
            file_tb = out_path + "/tb/ACC_SRAM_DP_" + mem_dict["acc"][idx]["address_size"] + "x" + mem_dict["acc"][idx]["word_size"] + "_tb.sv"
            module = "ACC_SRAM_DP_" + mem_dict["acc"][idx]["address_size"] + "x" + mem_dict["acc"][idx]["word_size"]
            address = int(math.log(int(mem_dict["acc"][idx]["address_size"]),2))
            word = int(mem_dict["acc"][idx]["word_size"])
            macro_name = mem_dict["acc"][idx]["macro_name"]
            address_size = mem_dict["acc"][idx]["address_size"]
            area = mem_dict["acc"][idx]["area"]
            port_type = mem_dict["acc"][idx]["port_type"]
            lib_list.append([address_size, word, module, area, port_type])
            if os.path.exists(file):
                None
            else:
                print_wrap_dp(file, module, address, word, macro_name)
                print("\"acc dual port %s\" generated!" %(' '.join(map(str, list(mem_dict["acc"][idx].values())))))
            if os.path.exists(file_tb):
                None
            else:
                print_wrap_dp_tb(file_tb, module, address, word)
                print("\"acc_tb dual port %s\" generated!" %(' '.join(map(str, list(mem_dict["acc"][idx].values())))))
    
        elif mem_dict["acc"][idx]["port_type"] == "1rw":
            file = out_path + "/ACC_SRAM_SP_" + mem_dict["acc"][idx]["address_size"] + "x" + mem_dict["acc"][idx]["word_size"] + ".v"
            file_tb = out_path + "/tb/ACC_SRAM_SP_" + mem_dict["acc"][idx]["address_size"] + "x" + mem_dict["acc"][idx]["word_size"] + "_tb.sv"
            module = "ACC_SRAM_SP_" + mem_dict["acc"][idx]["address_size"] + "x" + mem_dict["acc"][idx]["word_size"]
            address = int(math.log(int(mem_dict["acc"][idx]["address_size"]),2))
            word = int(mem_dict["acc"][idx]["word_size"])
            macro_name = mem_dict["acc"][idx]["macro_name"]
            address_size = mem_dict["acc"][idx]["address_size"]
            area = mem_dict["acc"][idx]["area"]
            port_type = mem_dict["acc"][idx]["port_type"]
            lib_list.append([address_size, word, module, area, port_type])
            if os.path.exists(file):
                None
            else:
                print_wrap_sp(file, module, address, word, macro_name)
                print("\"acc single port %s\" generated!" %(' '.join(map(str, list(mem_dict["acc"][idx].values())))))
            if os.path.exists(file_tb):
                None
            else:
                print_wrap_sp_tb(file_tb, module, address, word)
                print("\"acc_tb single port %s\" generated!" %(' '.join(map(str, list(mem_dict["acc"][idx].values())))))
    
        else:
            print("NONE")
            None    
            
    if len(lib_list) > 0:
        file = out_path + "/acc_lib.txt"
        print_lib(file, lib_list, "acc")

out_path = sys.argv[1]
memory_list = []
with open("asic_memlist.txt", "r") as memories:
    for mem_line in memories:
        memory_list.append(mem_line.split())
memories.close()

mem_dict = {"llc": [],
           "l2": [],
           "l1": [],
           "slm": [],
           "io": [],
           "acc": []}        

mem_dict = data_struct(memory_list)

val_addr = llc_policy_check(mem_dict)
llc_sp_gen(out_path, mem_dict, val_addr)

l2_val_addr = l2_policy_check(mem_dict)
l2_sp_gen(out_path, mem_dict, l2_val_addr)

l1_sp_gen(out_path, mem_dict)

slm_val_word = slm_policy_check(mem_dict)
slm_sp_gen(out_path, mem_dict, slm_val_word)

io_sp_val_conf = io_sp_policy_check(mem_dict)
io_dp_val_conf = io_dp_policy_check(mem_dict)

io_gen(out_path, mem_dict, io_dp_val_conf, io_sp_val_conf)

acc_gen(out_path, mem_dict)

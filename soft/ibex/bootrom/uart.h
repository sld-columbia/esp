#pragma once

#include <stdint.h>
#include "esplink.h"

#define UART_BASE 0x60000100

#define UART_DATA       (UART_BASE + 0x0)
#define UART_STATUS     (UART_BASE + 0x4)
#define UART_CONTROL    (UART_BASE + 0x8)
#define UART_SCALER     (UART_BASE + 0xC)
#define UART_FIFO_DBG   (UART_BASE + 0x10)

#define UART_CTRL_RE 0x1
#define UART_CTRL_TE 0x2
#define UART_CTRL_RI 0x4
#define UART_CTRL_TI 0x8
#define UART_CTRL_PS 0x10
#define UART_CTRL_PE 0x20
#define UART_CTRL_FL 0x40
#define UART_CTRL_LB 0x80
#define UART_CTRL_EC 0x100
#define UART_CTRL_TF 0x200
#define UART_CTRL_RF 0x400
#define UART_CTRL_DB 0x800
#define UART_CTRL_FA 0x80000000

#define UART_STATUS_DR 0x1
#define UART_STATUS_TS 0x2
#define UART_STATUS_TE 0x4
#define UART_STATUS_BR 0x8
#define UART_STATUS_OV 0x10
#define UART_STATUS_PE 0x20
#define UART_STATUS_FE 0x40
#define UART_STATUS_TH 0x80
#define UART_STATUS_RH 0x100
#define UART_STATUS_TF 0x200
#define UART_STATUS_RF 0x400

void init_uart();

void print_uart(const char* str);

void print_uart_int(uint32_t data);

void print_uart_addr(uint64_t addr);

void print_uart_byte(uint8_t byte);

void print_uart_int64(uint64_t data);

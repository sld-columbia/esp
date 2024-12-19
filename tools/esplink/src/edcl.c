// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "edcl.h"

// Helper functions
static void print_progress(u64 progress, u64 total, const char *prefix)
{
    const u32 symbols = 40;
    int i;

    u64 percent = progress * 100 / total;

    u64 fraction = progress * symbols / total;

    printf("%s: [", prefix);

    for (i = 0; i < symbols; ++i) {
        char c = i < fraction ? '#' : ' ';
        printf("%c", c);
    }

    printf("] %lld%%", percent);
    if (progress == total) printf("\n");
    else
        printf("\r");
    fflush(stdout);
}

static void set_offset(u8 *_m, u32 _x)
{
    _m[0] = (u8)(_x >> 8);
    _m[1] = (u8)(_x >> 0);
}

static u32 get_offset(u8 *_m)
{
    u32 _x;
    _x = ((u32)_m[0]) << 8;
    _x |= ((u32)_m[1]) << 0;
    return _x;
}

void set_sequence(u8 *_m, u32 _x)
{
    _m[2] = _m[2] | (u8)(0xff & ((_x << 2) >> 8));
    _m[3] = _m[3] | (u8)(0xff & ((_x << 2) >> 0));
}

u32 get_sequence(u8 *_m)
{
    u32 _x;
    _x = (((u32)_m[2]) << 8) >> 2;
    _x |= (((u32)_m[3]) << 0) >> 2;
    return _x;
}

void set_write(u8 *_m, u32 _x) { _m[3] = _m[3] | (u8)(_x << 1); }

u32 get_nack(u8 *_m)
{
    u32 _x;
    _x = 0x1 & (((u32)_m[3]) >> 1);
    return _x;
}

void set_length(u8 *_m, u32 _x)
{
    _m[3] = _m[3] | (u8)(0xff & (_x >> 9));
    _m[4] = _m[4] | (u8)(0xff & (_x >> 1));
    _m[5] = _m[5] | (u8)(0xff & (_x << 7));
}
u32 get_length(u8 *_m)
{
    u32 _x;
    _x = (0x1 & (u32)_m[3]) << 9;
    _x |= ((u32)_m[4]) << 1;
    _x |= ((u32)_m[5]) >> 7;
    return _x;
}

void set_address(u8 *_m, u32 _x)
{
    _m[6] = (u8)(0xff & (_x >> 24));
    _m[7] = (u8)(0xff & (_x >> 16));
    _m[8] = (u8)(0xff & (_x >> 8));
    _m[9] = (u8)(0xff & (_x >> 0));
}

u32 get_address(u8 *_m)
{
    u32 _x;
    _x = ((u32)_m[6]) << 24;
    _x |= ((u32)_m[7]) << 16;
    _x |= ((u32)_m[8]) << 8;
    _x |= ((u32)_m[9]) << 0;
    return _x;
}

void set_data(u8 *_m, u32 *_x, u32 _n)
{
    u32 i;
    for (i = 0; i < _n; i++) {
        u32 index     = i * 4 + 10;
        _m[index + 0] = (u8)(0xff & (_x[i] >> 24));
        _m[index + 1] = (u8)(0xff & (_x[i] >> 16));
        _m[index + 2] = (u8)(0xff & (_x[i] >> 8));
        _m[index + 3] = (u8)(0xff & (_x[i] >> 0));
    }
}

void get_data(u8 *_m, u32 *_x, u32 _n)
{
    u32 i;
    for (i = 0; i < _n; i++) {
        u32 index = i * 4 + 10;
        _x[i]     = ((u32)_m[index + 0]) << 24;
        _x[i] |= ((u32)_m[index + 1]) << 16;
        _x[i] |= ((u32)_m[index + 2]) << 8;
        _x[i] |= ((u32)_m[index + 3]) << 0;
    }
}

static void set_edcl_msg(u8 *buf, edcl_snd_t *msg)
{
    set_offset(buf, msg->offset);
    set_sequence(buf, msg->sequence);
    set_write(buf, msg->write);
    set_length(buf, msg->length);
    set_address(buf, msg->address);
    if (msg->write) set_data(buf, msg->data, msg->length / 4);
    msg->msglen = 10 + (msg->write * msg->length);
}

static void get_edcl_msg(u8 *buf, edcl_rcv_t *msg)
{
    msg->offset   = get_offset(buf);
    msg->sequence = get_sequence(buf);
    msg->nack     = get_nack(buf);
    msg->length   = get_length(buf);
    msg->address  = get_address(buf);
    get_data(buf, msg->data, msg->length / 4);
    msg->msglen = 10 + msg->length;
}

struct sockaddr_in serv_addr, cli_addr;
static int s;

static void handle_edcl_message(edcl_snd_t *snd, edcl_rcv_t *rcv)
{
#ifdef VERBOSE
    int i = 0;
#endif
    int iter       = 0;
    u8 *buf_snd    = malloc(BUFSIZE_MAX_SND * sizeof(u8));
    u8 *buf_rcv    = malloc(BUFSIZE_MAX_RCV * sizeof(u8));
    socklen_t clen = sizeof(struct sockaddr_in);

    // Prepare Ethernet packet payload
    set_edcl_msg(buf_snd, snd);

    while (1) {
#ifdef VERBOSE
        // Print message payload
        printf("Sending payload: ");
        for (i = 0; i < snd->msglen; i++)
            printf("%02x ", buf_snd[i]);
        printf("\n");
#endif
retry:
        // send the message
        if (sendto(s, buf_snd, snd->msglen, 0, (struct sockaddr *)&serv_addr,
                   sizeof(struct sockaddr_in)) == -1)
            die("sendto()");

        /* if (!snd->write) { */
        // clear the buffer by filling null, it might have previously received data
        memset(buf_rcv, '\0', BUFSIZE_MAX_RCV);

        // try to receive some data, this is a blocking call
        if (recvfrom(s, buf_rcv, BUFSIZE_MAX_RCV, 0, (struct sockaddr *)&cli_addr, &clen) == -1) {
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                printf("\ntimeout, retrying...\n");
                goto retry;
            }
            else {
                die("recvfrom()");
            }
        }

        get_edcl_msg(buf_rcv, rcv);

#ifdef VERBOSE
        // Print received message payload
        printf("Receiving payload: ");
        for (i = 0; i < rcv->msglen; i++)
            printf("%02x ", buf_rcv[i]);
        printf("\n");
#endif
        // Resend if necessary
        if (rcv->nack) {
            snd->sequence = rcv->sequence;
            set_sequence(buf_snd, snd->sequence);
            iter++;
        }
        else {
            break;
        }

        if (iter > 10) die("Error: Handle EDCL message failed after 10 attempts");
        /* } else { */
        /* 	break; */
        /* } */
    }

    free(buf_snd);
    free(buf_rcv);
}

/* static void clear_rcv_edcl() */
/* { */
/* 	int iter = 0; */
/* 	u8 *buf_rcv = malloc(BUFSIZE_MAX_RCV * sizeof(u8)); */
/* 	socklen_t clen = sizeof(struct sockaddr_in); */

/* 	while (recvfrom(s, buf_rcv, BUFSIZE_MAX_RCV, MSG_DONTWAIT, (struct sockaddr *) &cli_addr,
 * &clen) >= 0) */
/* 		iter++; */

/* 	free(buf_rcv); */
/* } */

// EDCL API Functions
void die(char *s)
{
    perror(s);
    exit(EXIT_FAILURE);
}

void connect_edcl(const char *server)
{
    /* printf("Connect ESPLink\n"); */

    // Open socket
    if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1) die("socket");

    struct timeval tv;
    tv.tv_sec  = 3;
    tv.tv_usec = 0;
    if (setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0) die("setsockopt");

    // Configure EDCL server address
    memset((char *)&serv_addr, 0, sizeof(struct sockaddr_in));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port   = htons(PORT);
    if (inet_aton(server, &serv_addr.sin_addr) == 0) die("inet_aton");

    // Configure client address
    memset((char *)&cli_addr, 0, sizeof(struct sockaddr_in));
    cli_addr.sin_family      = AF_INET;
    cli_addr.sin_port        = htons(PORT);
    cli_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind(s, (struct sockaddr *)&cli_addr, sizeof(struct sockaddr_in)) == -1) die("bind");
}

void load_memory(char *fname)
{
    edcl_snd_t *snd = malloc(sizeof(edcl_snd_t));
    edcl_rcv_t *rcv = malloc(sizeof(edcl_rcv_t));
    u32 i;
    int r;
    u32 addr;
    FILE *fp = fopen(fname, "r");
    if (!fp) die("fopen");

    // First packet
    snd->offset   = 0;
    snd->sequence = 0x0;
    snd->write    = 1;

    while (1) {
        r = fscanf(fp, "%08x %08x\n", &snd->address, &snd->data[0]);

        if (r == EOF) break;

        if (r != 2) die("fscanf");

        for (i = 1; i < NWORD_MAX_SND; i++) {
            r = fscanf(fp, "%08x %08x\n", &addr, &snd->data[i]);
            if (r == EOF) break;
            if (r != 2) die("fscanf");
        }

        snd->length = i * 4;

        handle_edcl_message(snd, rcv);

        snd->sequence++;
    }

    fclose(fp);
    free(snd);
    free(rcv);
}

void dump_memory(u32 address, u32 size, char *fname)
{
    edcl_snd_t *snd = malloc(sizeof(edcl_snd_t));
    edcl_rcv_t *rcv = malloc(sizeof(edcl_rcv_t));
    u32 rem         = size;
    u32 i;
    FILE *fp = fopen(fname, "w+");
    if (!fp) die("fopen");

    // First packet
    snd->offset   = 0;
    snd->sequence = 0x0;
    snd->write    = 0;
    snd->length   = size < MAX_RCV_SZ ? size : MAX_RCV_SZ;
    snd->address  = address;

    while (rem > 0) {
        handle_edcl_message(snd, rcv);

        for (i = 0; i < snd->length / 4; i++) {
            u32 addr = rcv->address + i * 4;
            u32 data = rcv->data[i];
            fprintf(fp, "%08x %08x\n", addr, data);
        }

        rem -= snd->length;

        snd->sequence++;
        snd->address += snd->length;
        snd->length = rem < MAX_RCV_SZ ? rem : MAX_RCV_SZ;
    }

    fclose(fp);
    free(snd);
    free(rcv);
}

void load_memory_bin(u32 base_addr, char *fname)
{
    edcl_snd_t *snd = malloc(sizeof(edcl_snd_t));
    edcl_rcv_t *rcv = malloc(sizeof(edcl_rcv_t));
    FILE *fp        = fopen(fname, "rb");
    size_t sz;
    size_t rem;
    u32 i = 0;

    if (!fp) die("fopen");

    // Get binary size
    fseek(fp, 0L, SEEK_END);
    sz = ftell(fp);
    rewind(fp);
    rem = sz;

    // First packet
    snd->offset   = 0;
    snd->sequence = 0x0;
    snd->write    = 1;
    snd->address  = base_addr;
    snd->length   = rem < MAX_SND_SZ ? rem : MAX_SND_SZ;

    while (rem > 0) {
        if (lefread(&snd->data[0], sizeof(u32), snd->length / sizeof(u32), fp) !=
            snd->length / sizeof(u32))
            die("fread");

        handle_edcl_message(snd, rcv);

        rem -= snd->length;
        i += snd->length / sizeof(u32);

        print_progress(sz - rem, sz, "loading binary");

        snd->address += snd->length;
        snd->length = rem < MAX_SND_SZ ? rem : MAX_SND_SZ;
        snd->sequence++;
    }

    fclose(fp);
    free(snd);
    free(rcv);

    /* clear_rcv_edcl(); */
    printf("Loaded %zu Bytes at %08x\n", sz, base_addr);
}

void dump_memory_bin(u32 address, u32 size, char *fname)
{
    edcl_snd_t *snd = malloc(sizeof(edcl_snd_t));
    edcl_rcv_t *rcv = malloc(sizeof(edcl_rcv_t));
    u32 rem         = size;
    FILE *fp        = fopen(fname, "wb+");
    if (!fp) die("fopen");

    // First packet
    snd->offset   = 0;
    snd->sequence = 0x0;
    snd->write    = 0;
    snd->length   = size < MAX_RCV_SZ ? size : MAX_RCV_SZ;
    snd->address  = address;

    while (rem > 0) {
        handle_edcl_message(snd, rcv);
        fwrite(&rcv->data[0], sizeof(u32), snd->length / sizeof(u32), fp);

        rem -= snd->length;

        print_progress(size - rem, size, "loading binary");

        snd->sequence++;
        snd->address += snd->length;
        snd->length = rem < MAX_RCV_SZ ? rem : MAX_RCV_SZ;
    }

    fclose(fp);
    free(snd);
    free(rcv);

    printf("Dumped %u Bytes starting at %08x\n", size, address);
}

void reset(u32 addr)
{
    edcl_snd_t *snd = malloc(sizeof(edcl_snd_t));
    edcl_rcv_t *rcv = malloc(sizeof(edcl_rcv_t));

    snd->offset   = 0;
    snd->sequence = 0x0;
    snd->write    = 1;
    snd->address  = addr;
    snd->data[0]  = 0x1;
    snd->length   = 4;

    // Reset must be sent twice
    handle_edcl_message(snd, rcv);
    usleep(500000);

    free(snd);
    free(rcv);

    snd = malloc(sizeof(edcl_snd_t));
    rcv = malloc(sizeof(edcl_rcv_t));

    snd->offset   = 0;
    snd->sequence = 0x0;
    snd->write    = 1;
    snd->address  = addr;
    snd->data[0]  = 0x1;
    snd->length   = 4;

    handle_edcl_message(snd, rcv);
    usleep(500000);

    free(snd);
    free(rcv);

    printf("Reset ESP processor cores\n");
}

void set_word(u32 addr, u32 data)
{
    edcl_snd_t *snd = malloc(sizeof(edcl_snd_t));
    edcl_rcv_t *rcv = malloc(sizeof(edcl_rcv_t));

    // First packet
    snd->offset   = 0;
    snd->sequence = 0x0;
    snd->write    = 1;
    snd->address  = addr;
    snd->data[0]  = data;
    snd->length   = 4;

    handle_edcl_message(snd, rcv);

    free(snd);
    free(rcv);

    printf("Write %08x at %08x\n", data, addr);
}

void get_word(u32 addr)
{
    edcl_snd_t *snd = malloc(sizeof(edcl_snd_t));
    edcl_rcv_t *rcv = malloc(sizeof(edcl_rcv_t));

    // First packet
    snd->offset   = 0;
    snd->sequence = 0x0;
    snd->write    = 0;
    snd->address  = addr;
    snd->length   = 4;

    handle_edcl_message(snd, rcv);

    printf("Read %08x at %08x\n", rcv->data[0], addr);

    free(snd);
    free(rcv);
}

void disconnect_edcl() { close(s); }

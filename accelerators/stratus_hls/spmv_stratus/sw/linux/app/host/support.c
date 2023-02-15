// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "support.h"
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <errno.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/stat.h>

// In general, fd_printf is used for individual values.
#define SUFFICIENT_SPRINTF_SPACE 256
// It'd be nice if dprintf was c99. But it ain't.
static inline int fd_printf(int fd, const char *format, ...) {
  va_list args;
  int buffered, written, status;
  char buffer[SUFFICIENT_SPRINTF_SPACE];
  va_start(args, format);
  buffered = vsnprintf(buffer, SUFFICIENT_SPRINTF_SPACE, format, args);
  va_end(args);
  assert(buffered<SUFFICIENT_SPRINTF_SPACE && "Overran fd_printf buffer---output possibly corrupt");
  written = 0;
  while(written<buffered) {
    status = write(fd, &buffer[written], buffered-written);
    assert(status>=0 && "Write failed");
    written += status;
  }
  assert(written==buffered && "Wrote more data than given");
  return written;
}

///// File and section functions
char *readfile(int fd) {
  char *p; 
  struct stat s;
  off_t len;
  ssize_t bytes_read, status;

  assert(fd>1 && "Invalid file descriptor");
  assert(0==fstat(fd, &s) && "Couldn't determine file size");
  len = s.st_size;
  assert(len>0 && "File is empty");
  p = (char *)malloc(len+1);
  bytes_read = 0;
  while( bytes_read<len ) {
    status = read(fd, &p[bytes_read], len-bytes_read);
    assert(status>=0 && "read() failed");
    bytes_read+=status;
  }
  p[len] = (char)0; // Add NULL terminator
  close(fd);
  return p;
}

char *find_section_start(char *s, int n) {
  int i=0;

  assert(n>=0 && "Invalid section number");
  if(n==0)
    return s;

  // Find the nth "%%\n" substring (if *s==0, there wasn't one)
  while(i<n && (*s)!=(char)0) {
    // This comparison will short-circuit before overrunning the string, so no length check.
    if( s[0]=='%' && s[1]=='%' && s[2]=='\n' ) {
      i++;
    }
    s++;
  }
  if(*s!=(char)0)
    return s+2; // Skip the section header itself, return pointer to the content
  return s; // Hit the end, return an empty string
}

///// Array read functions
int parse_string(char *s, char *arr, int n) {
  int k;
  assert(s!=NULL && "Invalid input string");

  if( n<0 ) { // terminated string
    k = 0;
    while( s[k]!=(char)0 && s[k+1]!=(char)0 && s[k+2]!=(char)0
        && !(s[k]=='\n'  && s[k+1]=='%'     && s[k+2]=='%') ) {
      k++;
    }
  } else { // fixed-length string
    k = n;
  }

  memcpy( arr, s, k );
  if( n<0 )
    arr[k] = 0;

  return 0;
}

#define generate_parse_TYPE_array(TYPE, STRTOTYPE) \
int parse_##TYPE##_array(char *s, TYPE *arr, int n) { \
  char *line, *endptr; \
  int i=0; \
  TYPE v; \
  \
  assert(s!=NULL && "Invalid input string"); \
  \
  line = strtok(s,"\n"); \
  while( line!=NULL && i<n ) { \
    endptr = line; \
    /*errno=0;*/ \
    v = (TYPE)(STRTOTYPE(line, &endptr)); \
    if( (*endptr)!=(char)0 ) { \
      fprintf(stderr, "Invalid input: line %d of section\n", i); \
    } \
    /*assert((*endptr)==(char)0 && "Invalid input character"); */\
    /*if( errno!=0 ) { \
      fprintf(stderr, "Couldn't convert string \"%s\": line %d of section\n", line, i); \
    }*/ \
    /*assert(errno==0 && "Couldn't convert the string"); */\
    arr[i] = v; \
    i++; \
    line[strlen(line)] = '\n'; /* Undo the strtok replacement.*/ \
    line = strtok(NULL,"\n"); \
  } \
  if(line!=NULL) { /* stopped because we read all the things */ \
    line[strlen(line)] = '\n'; /* Undo the strtok replacement.*/ \
  } \
  \
  return 0; \
}

#define strtol_10(a,b) strtol(a,b,10)
generate_parse_TYPE_array(uint8_t, strtol_10)
generate_parse_TYPE_array(uint16_t, strtol_10)
generate_parse_TYPE_array(uint32_t, strtol_10)
generate_parse_TYPE_array(uint64_t, strtol_10)
generate_parse_TYPE_array(int8_t, strtol_10)
generate_parse_TYPE_array(int16_t, strtol_10)
generate_parse_TYPE_array(int32_t, strtol_10)
generate_parse_TYPE_array(int64_t, strtol_10)

generate_parse_TYPE_array(float, strtof)
generate_parse_TYPE_array(double, strtod)

///// Array write functions
int write_string(int fd, char *arr, int n) {
  int status, written;
  assert(fd>1 && "Invalid file descriptor");
  if( n<0 ) { // NULL-terminated string
    n = strlen(arr);
  }
  written = 0;
  while(written<n) {
    status = write(fd, &arr[written], n-written);
    assert(status>=0 && "Write failed");
    written += status;
  }
  // Write terminating '\n'
  do {
    status = write(fd, "\n", 1);
    assert(status>=0 && "Write failed");
  } while(status==0);

  return 0;
}

// Not strictly necessary, but nice for future-proofing.
#define generate_write_TYPE_array(TYPE, FORMAT) \
int write_##TYPE##_array(int fd, TYPE *arr, int n) { \
  int i; \
  assert(fd>1 && "Invalid file descriptor"); \
  for( i=0; i<n; i++ ) { \
    fd_printf(fd, "%" FORMAT "\n", arr[i]); \
  } \
  return 0; \
}

generate_write_TYPE_array(uint8_t, PRIu8)
generate_write_TYPE_array(uint16_t, PRIu16)
generate_write_TYPE_array(uint32_t, PRIu32)
generate_write_TYPE_array(uint64_t, PRIu64)
generate_write_TYPE_array(int8_t, PRId8)
generate_write_TYPE_array(int16_t, PRId16)
generate_write_TYPE_array(int32_t, PRId32)
generate_write_TYPE_array(int64_t, PRId64)

generate_write_TYPE_array(float, ".16f")
generate_write_TYPE_array(double, ".16f")

int write_section_header(int fd) {
  assert(fd>1 && "Invalid file descriptor");
  fd_printf(fd, "%%%%\n"); // Just prints %%
  return 0;
}

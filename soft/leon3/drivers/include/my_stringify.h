#ifndef MY_STRINGIFY_H
#define MY_STRINGIFY_H

/* doing two levels of stringification allows us to stringify a macro */
#define my_stringify_l(x...)	#x
#define my_stringify(x...)	my_stringify_l(x)

#endif /* MY_STRINGIFY_H */

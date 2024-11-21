#ifndef __PRINTK_H__
#define __PRINTK_H__

#include "stddef.h"

#define bool _Bool
#define true 1
#define false 0

#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define BLUE "\033[34m"
#define PURPLE "\033[35m"
#define DEEPGREEN "\033[36m"

#define BOLD "\033[1m"
#define UNDERLINE "\033[4m"
#define REVERSED "\033[7m"

#define FG_COLOR(r, g, b) "\033[38;2;" #r ";" #g ";" #b "m"
#define BG_COLOR(r, g, b) "\033[48;2;" #r ";" #g ";" #b "m"

#define COLOR1 FG_COLOR(255, 135, 00)
#define COLOR2 FG_COLOR(255, 135, 95)
#define COLOR3 FG_COLOR(255, 135, 135)
#define COLOR4 FG_COLOR(255, 135, 175)
#define COLOR5 FG_COLOR(255, 135, 215)
#define COLOR6 FG_COLOR(255, 135, 255)

#define CLEAR "\033[0m"

#define Log(format, ...) \
    printk("\33[1;35m[%s,%d,%s] " format "\33[0m\n", \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__)

#define Err(format, ...) {                              \
    printk("\33[1;31m[%s,%d,%s] " format "\33[0m\n",    \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__);  \
    while(1);                                           \
}
        
int printk(const char *, ...);

#endif
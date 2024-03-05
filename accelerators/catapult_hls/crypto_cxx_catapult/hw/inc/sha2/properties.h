#ifndef __SHA2_PROPERTIES_H__
#define __SHA2_PROPERTIES_H__

#ifdef PROPERTIES_ENABLED

int check_rule_R01()
{
    // Do not use broken hash functions
    return 0;
}

int check()
{
    int ret = 0;

    ret |= (check_rule_R01() << 1);

    return ret;
}

#endif /* PROPERTIES_ENABLED */
#endif /* __PROPERTIES_H__ */

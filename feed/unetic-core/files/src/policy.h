#ifndef POLICY_H
#define POLICY_H

#include <libubox/blobmsg.h>

extern const struct blobmsg_policy set_wifi_config_policy[];
extern const struct blobmsg_policy maintenance_policy[];
extern const struct blobmsg_policy set_wan_policy[];
extern const struct blobmsg_policy ping_policy[];

#endif

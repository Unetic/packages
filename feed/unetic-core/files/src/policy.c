#include "policy.h"

enum {
    SET_WIFI_CONFIG_SSID,
    SET_WIFI_CONFIG_ENCRYPTION,
    SET_WIFI_CONFIG_KEY,
    SET_WIFI_CONFIG_EXPECTED_REVISION,
    SET_WIFI_CONFIG_REQUEST_ID,
    __SET_WIFI_CONFIG_MAX,
};

const struct blobmsg_policy set_wifi_config_policy[__SET_WIFI_CONFIG_MAX] = {
    [SET_WIFI_CONFIG_SSID] = { .name = "ssid", .type = BLOBMSG_TYPE_STRING },
    [SET_WIFI_CONFIG_ENCRYPTION] = { .name = "encryption", .type = BLOBMSG_TYPE_STRING },
    [SET_WIFI_CONFIG_KEY] = { .name = "key", .type = BLOBMSG_TYPE_STRING },
    [SET_WIFI_CONFIG_EXPECTED_REVISION] = { .name = "expected_revision", .type = BLOBMSG_TYPE_INT64 },
    [SET_WIFI_CONFIG_REQUEST_ID] = { .name = "request_id", .type = BLOBMSG_TYPE_STRING },
};

enum {
    MAINTENANCE_REASON,
    __MAINTENANCE_MAX,
};

const struct blobmsg_policy maintenance_policy[__MAINTENANCE_MAX] = {
    [MAINTENANCE_REASON] = { .name = "reason", .type = BLOBMSG_TYPE_STRING },
};

enum {
    SET_WAN_WAN,
    SET_WAN_EXPECTED_REVISION,
    SET_WAN_REQUEST_ID,
    __SET_WAN_MAX,
};

const struct blobmsg_policy set_wan_policy[__SET_WAN_MAX] = {
    [SET_WAN_WAN] = { .name = "wan", .type = BLOBMSG_TYPE_TABLE },
    [SET_WAN_EXPECTED_REVISION] = { .name = "expected_revision", .type = BLOBMSG_TYPE_INT64 },
    [SET_WAN_REQUEST_ID] = { .name = "request_id", .type = BLOBMSG_TYPE_STRING },
};

enum {
    PING_HOST,
    __PING_MAX,
};

const struct blobmsg_policy ping_policy[__PING_MAX] = {
    [PING_HOST] = { .name = "host", .type = BLOBMSG_TYPE_STRING },
};

#ifndef SERVER_H
#define SERVER_H

#include <libubus.h>

typedef char *(*unetic_handler_fn)(void *userdata, const char *method,
                                    const char *request_json);

struct unetic_server {
    struct ubus_context *ctx;
    struct ubus_object object;
    struct ubus_object_type type;
    unetic_handler_fn handler;
    void *userdata;
};

#endif

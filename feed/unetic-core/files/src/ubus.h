#ifndef UBUS_H
#define UBUS_H

#include "server.h"

void *unetic_ubus_server_new(unetic_handler_fn handler, void *userdata);
int unetic_ubus_server_poll(void *handle, int timeout_ms);
int unetic_ubus_server_notify(void *handle, const char *event, const char *json);
void unetic_ubus_server_free(void *handle);

#endif

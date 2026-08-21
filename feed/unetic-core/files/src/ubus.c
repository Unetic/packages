#include "ubus.h"
#include "methods.h"

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libubox/blobmsg.h>
#include <libubox/blobmsg_json.h>
#include <libubox/uloop.h>
#include <libubox/utils.h>

void *unetic_ubus_server_new(unetic_handler_fn handler, void *userdata)
{
    struct unetic_server *server;
    int rc;

    if (!handler)
        return NULL;

    server = calloc(1, sizeof(*server));
    if (!server)
        return NULL;

    if (uloop_init() != 0) {
        free(server);
        return NULL;
    }

    server->ctx = ubus_connect(NULL);
    if (!server->ctx) {
        uloop_done();
        free(server);
        return NULL;
    }

    server->handler = handler;
    server->userdata = userdata;

    server->type.name = "unetic";
    server->type.methods = unetic_methods;
    server->type.n_methods = unetic_methods_count;

    server->object.name = "unetic";
    server->object.type = &server->type;
    server->object.methods = unetic_methods;
    server->object.n_methods = unetic_methods_count;

    rc = ubus_add_object(server->ctx, &server->object);
    if (rc != UBUS_STATUS_OK) {
        ubus_free(server->ctx);
        uloop_done();
        free(server);
        return NULL;
    }

    ubus_add_uloop(server->ctx);

    return server;
}

int unetic_ubus_server_poll(void *handle, int timeout_ms)
{
    struct unetic_server *server = handle;

    if (!server)
        return UBUS_STATUS_INVALID_ARGUMENT;

    if (timeout_ms < 0)
        timeout_ms = 100;

    uloop_cancelled = false;
    uloop_run_timeout(timeout_ms);
    return UBUS_STATUS_OK;
}

int unetic_ubus_server_notify(void *handle, const char *event,
                              const char *json)
{
    struct unetic_server *server = handle;
    struct blob_buf message = {0};
    int rc;

    if (!server || !event || !json)
        return UBUS_STATUS_INVALID_ARGUMENT;

    blobmsg_buf_init(&message);
    if (!blobmsg_add_json_from_string(&message, json)) {
        blob_buf_free(&message);
        return UBUS_STATUS_INVALID_ARGUMENT;
    }

    rc = ubus_notify(server->ctx, &server->object, event, message.head, -1);
    blob_buf_free(&message);
    return rc;
}

void unetic_ubus_server_free(void *handle)
{
    struct unetic_server *server = handle;

    if (!server)
        return;

    ubus_remove_object(server->ctx, &server->object);
    ubus_free(server->ctx);
    uloop_done();
    free(server);
}

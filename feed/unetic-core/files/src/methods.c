#include "methods.h"
#include "policy.h"
#include "server.h"

#include <stdlib.h>
#include <libubox/blobmsg.h>
#include <libubox/blobmsg_json.h>
#include <libubox/utils.h>

static int unetic_method_handler(struct ubus_context *ctx,
                                 struct ubus_object *obj,
                                 struct ubus_request_data *req,
                                 const char *method,
                                 struct blob_attr *msg)
{
    struct unetic_server *server = container_of(obj, struct unetic_server, object);
    struct blob_buf reply = {0};
    char *request_json = NULL;
    char *response_json = NULL;
    int rc = UBUS_STATUS_OK;

    if (msg)
        request_json = blobmsg_format_json(msg, true);

    response_json = server->handler(server->userdata, method,
                                    request_json ? request_json : "{}");
    free(request_json);

    if (!response_json)
        return UBUS_STATUS_UNKNOWN_ERROR;

    blob_buf_init(&reply, 0);
    if (!blobmsg_add_json_from_string(&reply, response_json)) {
        free(response_json);
        blob_buf_free(&reply);
        return UBUS_STATUS_UNKNOWN_ERROR;
    }

    free(response_json);
    
    rc = ubus_send_reply(ctx, req, reply.head);
    blob_buf_free(&reply);
    return rc;
}

const struct ubus_method unetic_methods[] = {
    UBUS_METHOD_NOARG("state", unetic_method_handler),
    UBUS_METHOD_NOARG("wifi.get", unetic_method_handler),
    UBUS_METHOD("wifi.set_config", unetic_method_handler, set_wifi_config_policy),
    UBUS_METHOD_NOARG("wan.get", unetic_method_handler),
    UBUS_METHOD("wan.set", unetic_method_handler, set_wan_policy),
    UBUS_METHOD("wan.set_config", unetic_method_handler, set_wan_policy),
    UBUS_METHOD_NOARG("switch.get", unetic_method_handler),
    UBUS_METHOD_NOARG("system.info", unetic_method_handler),
    UBUS_METHOD_NOARG("devices.list", unetic_method_handler),
    UBUS_METHOD_NOARG("operation.get", unetic_method_handler),
    UBUS_METHOD_NOARG("maintenance.get", unetic_method_handler),
    UBUS_METHOD("maintenance.enter", unetic_method_handler, maintenance_policy),
    UBUS_METHOD_NOARG("maintenance.exit", unetic_method_handler),
    UBUS_METHOD_NOARG("health.get", unetic_method_handler),
    UBUS_METHOD("tools.ping", unetic_method_handler, ping_policy),
};

const int unetic_methods_count = ARRAY_SIZE(unetic_methods);

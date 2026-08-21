#include <stdio.h>
#include <libubox/blobmsg.h>
#include <libubox/blobmsg_json.h>

int main() {
    struct blob_buf b = {0};
    blobmsg_buf_init(&b);
    blobmsg_add_json_from_string(&b, "{\"a\": 1}");
    printf("Type: %d\n", blob_id(b.head));
    return 0;
}

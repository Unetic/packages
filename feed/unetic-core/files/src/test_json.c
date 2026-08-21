#include <stdio.h>
#include <libubox/blobmsg.h>
#include <libubox/blobmsg_json.h>

int main() {
    struct blob_buf b = {0};
    blob_buf_init(&b, 0);
    blobmsg_add_json_from_string(&b, "{\"a\": 1}");
    printf("Type: %d, len: %d\n", blob_id(b.head), blob_len(b.head));
    return 0;
}

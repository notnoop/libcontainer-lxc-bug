#include <stdio.h>

#include <lxc/lxccontainer.h>

#define BUFSIZE 256

void function_that_never_gets_called() {
    printf("I should not have been called\n");

#ifdef LINK_LXC
    lxc_attach_run_command(NULL);
#endif
}

int main() {
    // print something simple
    printf("Hello I am here\n");

    // let's see what cgroup we are in
    FILE *cgroup = fopen("/proc/self/cgroup", "r"); 
    if (cgroup == NULL) {
        printf("Cannot open file %s \n", "/proc/self/cgroup"); 
        exit(1); 
    } 
  
    char buf[BUFSIZE];
    int n = 0;
    while ((n = fread(&buf, sizeof(char), BUFSIZE, cgroup)) > 0) {
        if (fwrite(buf, sizeof(char), n, stdout) != n) {
            fprintf(stderr, "write error\n");
            fclose(cgroup);
            exit(1);
        }
    }

    fclose(cgroup); 
    return 0; 
}

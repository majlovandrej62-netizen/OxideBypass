#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

void (*orig_exit)(int);
void new_exit(int status) {
    NSLog(@"[Bypass] Blocked exit call with status: %d", status);
}

void (*orig__exit)(int);
void new__exit(int status) {
    NSLog(@"[Bypass] Blocked _exit call with status: %d", status);
}

int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);
int new_ptrace(int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) { 
        return 0;
    }
    return orig_ptrace(request, pid, addr, data);
}

const char* (*orig_dyld_get_image_name)(uint32_t image_index);
const char* new_dyld_get_image_name(uint32_t image_index) {
    const char* name = orig_dyld_get_image_name(image_index);
    if (name && (strstr(name, "Bypass") || strstr(name, "Cheat") || strstr(name, "H5GG") || strstr(name, "substrate"))) {
        return "/usr/lib/libSystem.B.dylib"; 
    }
    return name;
}

%ctor {
    NSLog(@"[Bypass] Anti-Cheat Bypass Loaded!");
    
    MSHookFunction((void *)exit, (void *)new_exit, (void **)&orig_exit);
    MSHookFunction((void *)_exit, (void *)new__exit, (void **)&orig__exit);
    MSHookFunction((void *)ptrace, (void *)new_ptrace, (void **)&orig_ptrace);
    MSHookFunction((void *)_dyld_get_image_name, (void *)new_dyld_get_image_name, (void **)&orig_dyld_get_image_name);
}

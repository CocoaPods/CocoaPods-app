#import "CPDebuggerCheck.h"
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <stdlib.h>

// https://developer.apple.com/library/mac/qa/qa1361/_index.html
// http://www.coredump.gr/articles/ios-anti-debugging-protections-part-2/

static int is_debugger_present(void)
{
    int name[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);

    info.kp_proc.p_flag = 0;

    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();

    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        perror("sysctl");
        NSLog(@"unknown error");
        return 0;
    }

    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

@implementation CPDebuggerCheck

+ (BOOL)isInDebugger
{
    return is_debugger_present();
}

@end

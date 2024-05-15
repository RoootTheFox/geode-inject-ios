#import <spawn.h>
#import <dlfcn.h>
#import "utils.h"

extern char** environ;
int ptrace(int, pid_t, caddr_t, int);

#define CS_DEBUGGED 0x10000000
int csops(pid_t pid, unsigned int ops, void *useraddr, size_t usersize);

//this is copied from https://stackoverflow.com/questions/6530364/how-to-detect-that-the-app-is-running-on-a-jailbroken-device

bool fileExistsAtPath(NSString* path) {
    FILE *pFile;
    pFile = fopen([path cStringUsingEncoding:[NSString defaultCStringEncoding]], "r");
    if (pFile == NULL) {
        return false;
    }
    else
        fclose(pFile);
    return true;
}
//very simple paths
bool isJailBroken() {

    NSArray *paths = @[@"/var/jb/Applications/Sileo.app",
                       @"/var/jb/Applications/Zebra.app",
                       @"/Applications/Cydia.app",
                       ];

    for (NSString *path in paths) {
        if (fileExistsAtPath(path)) {
            return true;
        }
    }

    return false;
}


//getting if it has jit. its copied from what do you thing where?

bool Pojavlaunchercheckforjit(int pid) {
    

    int flags;
    csops(pid, 0, &flags, sizeof(flags));
    bool Doesithavejit = (flags & CS_DEBUGGED) != 0;
    if (!Doesithavejit) {
        sleep(1);
        Pojavlaunchercheckforjit(pid);
    }
    return true; //thank you for jit
}


__attribute__((constructor)) static void entry(int argc, char **argv, char *envp[])
{
    int pid = [[NSProcessInfo processInfo] processIdentifier];
    NSLog(@"mrow INIT");
    if (!isJailBroken()) {Pojavlaunchercheckforjit(pid);}
   
            

    init_bypassDyldLibValidation();
    init_fixCydiaSubstrate();

    init_loadGeode();
    
}

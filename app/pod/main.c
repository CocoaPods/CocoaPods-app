#include <stdio.h>
#include <pwd.h>
#include <CoreServices/CoreServices.h>

int main(int argc, const char * argv[]) {
  CFErrorRef error = NULL;
  CFArrayRef URLs = LSCopyApplicationURLsForBundleIdentifier(CFSTR("org.cocoapods.CocoaPods"), &error);
  CFURLRef appURL = CFArrayGetValueAtIndex(URLs, 0);
  CFURLRef bundleEnvURL = CFBundleCopyResourceURLInDirectory(appURL, CFSTR("bundle/bin/bundle-env"), NULL, NULL);

  const char bundleEnvPath[PATH_MAX];
  CFURLGetFileSystemRepresentation(bundleEnvURL, false, (UInt8 *)bundleEnvPath, PATH_MAX);

  size_t len;

  char *homePath = getenv("HOME");
  if (homePath == NULL) {
    homePath = getpwuid(getuid())->pw_dir;
  }
  len = strlen(homePath) + 6;
  char envHome[len];
  snprintf(envHome, len, "HOME=%s", homePath);

  char *term = getenv("TERM");
  if (term == NULL) {
    term = "xterm-256color";
  }
  len = strlen(term) + 6;
  char envTerm[len];
  snprintf(envTerm, len, "TERM=%s", term);

  char *const env[] = {
    "LANG=en_GB.UTF-8",
    envHome,
    envTerm,
    NULL
  };

  char *shPath = "/bin/sh";

  const char *args[argc+3];
  args[0] = shPath;
  args[1] = bundleEnvPath;
  args[2] = "pod";
  for (int i = 1; i < argc; i++) {
    args[i+2] = *(argv+i);
  }
  args[argc+2] = NULL;

//  for (const char **i = args; *i != NULL; i++) {
//    printf("ARG: %s\n", *i);
//  }

  execve(shPath, (char *const *)args, env);

  fprintf(stderr, "Failed to execute `%s` (%d - %s)\n", bundleEnvPath, errno, strerror(errno));
  return errno;
}

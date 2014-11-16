#include <stdio.h>
#include <pwd.h>
#include <CoreServices/CoreServices.h>

int main(int argc, const char * argv[]) {
  CFStringRef bundleID = CFSTR("org.cocoapods.CocoaPods");
  CFStringRef envScript = CFSTR("bundle/bin/bundle-env");
  const char *shPath = "/bin/sh";
  const char *podBin = "pod";

  CFErrorRef error = NULL;
  CFArrayRef URLs = LSCopyApplicationURLsForBundleIdentifier(bundleID, &error);
  if (error != NULL) {
    if (CFErrorGetCode(error) == kLSApplicationNotFoundErr) {
      fprintf(stderr, "[!] Unable to locate the CocoaPods.app application " \
                      "bundle. Please ensure the application is available " \
                      "and launch the application at least once.\n");
    } else {
      CFShow(error);
    }
    return -1;
  }

  CFURLRef appURL = CFArrayGetValueAtIndex(URLs, 0);
  CFURLRef envScriptURL = CFBundleCopyResourceURLInDirectory(appURL,
                                                             envScript,
                                                             NULL,
                                                             NULL);
  assert(envScriptURL != NULL);

  const char envScriptPath[PATH_MAX];
  assert(CFURLGetFileSystemRepresentation(envScriptURL,
                                          false,
                                          (UInt8 *)envScriptPath,
                                          PATH_MAX));

  // Set up minimally required environment.
  size_t len;

  char *homePath = getenv("HOME");
  if (homePath == NULL) {
    homePath = getpwuid(getuid())->pw_dir;
    assert(homePath);
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

  char *const env[] = { "LANG=en_GB.UTF-8", envHome, envTerm, NULL };

  // Create arguments list for that calls `/bin/sh /path/to/bundle-env pod […]`
  // and appends the arguments that were passed to this program.
  const char *args[argc+3];
  args[0] = shPath;
  args[1] = envScriptPath;
  args[2] = podBin;
  for (int i = 1; i < argc; i++) {
    args[i+2] = *(argv+i);
  }
  args[argc+2] = NULL;

//  for (const char **i = args; *i != NULL; i++) {
//    printf("ARG: %s\n", *i);
//  }

  execve(shPath, (char *const *)args, env);

  fprintf(stderr, "Failed to execute `%s` (%d - %s)\n", envScriptPath,
                                                        errno,
                                                        strerror(errno));
  return errno;
}

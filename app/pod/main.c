#include <stdio.h>
#include <pwd.h>
#include <CoreServices/CoreServices.h>

int main(int argc, const char * argv[]) {
  CFErrorRef error = NULL;
  CFArrayRef URLs = LSCopyApplicationURLsForBundleIdentifier(CFSTR("org.cocoapods.CocoaPods"), &error);
  CFURLRef appURL = CFArrayGetValueAtIndex(URLs, 0);
  CFURLRef prefixURL = CFBundleCopyResourceURLInDirectory(appURL, CFSTR("bundle"), NULL, NULL);

  CFURLRef binURL = CFURLCreateCopyAppendingPathComponent(NULL, prefixURL, CFSTR("bin"), true);
  CFURLRef pythonLibURL = CFURLCreateCopyAppendingPathComponent(NULL, prefixURL, CFSTR("lib/python2.7/site-packages"), true);
  CFURLRef gitTemplateURL = CFURLCreateCopyAppendingPathComponent(NULL, prefixURL, CFSTR("share/git-core/templates"), true);
  CFURLRef gitExecURL = CFURLCreateCopyAppendingPathComponent(NULL, prefixURL, CFSTR("libexec/git-core"), true);

  CFURLRef podURL = CFURLCreateCopyAppendingPathComponent(NULL, binURL, CFSTR("pod"), false);
  CFURLRef rubyURL = CFURLCreateCopyAppendingPathComponent(NULL, binURL, CFSTR("ruby"), false);

  const char rubyPath[PATH_MAX];
  CFURLGetFileSystemRepresentation(rubyURL, false, (UInt8 *)rubyPath, PATH_MAX);
  const char podPath[PATH_MAX];
  CFURLGetFileSystemRepresentation(podURL, false, (UInt8 *)podPath, PATH_MAX);

  const char buffer[PATH_MAX];
  size_t len;

  CFURLGetFileSystemRepresentation(binURL, false, (UInt8 *)buffer, PATH_MAX);
  len = strlen(buffer) + 36;
  char envPath[len];
  snprintf(envPath, len, "PATH=%s:/usr/bin:/bin:/usr/sbin:/sbin", buffer);

  CFURLGetFileSystemRepresentation(pythonLibURL, false, (UInt8 *)buffer, PATH_MAX);
  len = strlen(buffer) + 12;
  char envPythonPath[len];
  snprintf(envPythonPath, len, "PYTHONPATH=%s", buffer);

  CFURLGetFileSystemRepresentation(gitTemplateURL, false, (UInt8 *)buffer, PATH_MAX);
  len = strlen(buffer) + 18;
  char envGitTemplateDir[len];
  snprintf(envGitTemplateDir, len, "GIT_TEMPLATE_DIR=%s", buffer);

  CFURLGetFileSystemRepresentation(gitExecURL, false, (UInt8 *)buffer, PATH_MAX);
  len = strlen(buffer) + 15;
  char envGitExecPath[len];
  snprintf(envGitExecPath, len, "GIT_EXEC_PATH=%s", buffer);

  char *homePath = getpwuid(getuid())->pw_dir;
  len = strlen(homePath) + 6;
  char envHome[len];
  snprintf(envHome, len, "HOME=%s", homePath);

  char *const env[] = {
    "TERM=xterm-256color",
    "LANG=en_US.UTF-8",
    envHome,
    envPath,
    envPythonPath,
    envGitTemplateDir,
    envGitExecPath,
    NULL
  };

  const char *args[argc+2];
  args[0] = rubyPath;
  args[1] = podPath;
  for (int i = 1; i < argc; i++) {
    args[i+1] = *(argv+i);
  }
  args[argc+1] = NULL;

//  for (const char **i = args; *i != NULL; i++) {
//    printf("ARG: %s\n", *i);
//  }

  execve(rubyPath, (char *const *)args, env);

  fprintf(stderr, "Failed to execute `%s` (%d - %s)\n", rubyPath, errno, strerror(errno));
  return -1;
}

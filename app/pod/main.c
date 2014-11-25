//
// This tool is placed in the user's LOAD path so that they can use the CocoaPods CLI without having
// to worry about where the tools are installed.
//
// To do this, it uses Launch Services to locate the application bundle by Bundle Identifier.
// Meaning that the user is free to move the application bundle on disk after installing this tool.
// Solutions like symbolic links would break if the bundle was moved and 'aliases' can break when
// updating the application and the file the alias pointed to no longer exists.
//
// IMPORTANT:
//
// A benefit of this is that we do *not* need to ask the user to install this tool *again* after an
// update, unless there was a bug in this tool. As such, it is extremely important to keep this tool
// as lean as possible. Any environmental settings pertaining to the working of bundled tools should
// be updated in the `bundle-env` script instead, which resides inside the application bundle and as
// such will be easily updatable.
//

#include <stdio.h>
#include <pwd.h>
#include <CoreServices/CoreServices.h>

int main(int argc, const char * argv[]) {
  CFStringRef bundleID = CFSTR("org.cocoapods.CocoaPods");
  CFStringRef envScript = CFSTR("bundle/bin/bundle-env");
  const char *shPath = "/bin/sh";
  const char *podBin = "pod";

  // -----------------------------------------------------------------------------------------------
  // Try to locate the CocoaPods.app bundle.
  // -----------------------------------------------------------------------------------------------
  CFURLRef appURL = NULL;
  CFStringRef appFilename = CFSTR("CocoaPods.app");

  const char *explicitApp = getenv("CP_APP");
  if (explicitApp) {
    if (access(explicitApp, F_OK) == 0) {
      // An existing path is specified, so assume that the user meant that that’s the app bundle.
      size_t len = strlen(explicitApp);
      appURL = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *)explicitApp, len, true);
    } else {
      // Try to find an app bundle with the specified name (without extname) as filename.
      size_t len = strlen(explicitApp)+5;
      char filename[len];
      snprintf(filename, len, "%s.app", explicitApp);
      appFilename = CFStringCreateWithCString(NULL, filename, kCFStringEncodingUTF8);
    }
  } else {
    // See if the user has specified a default that specifies the path to the app bundle.
    // NOTE This is not going to be advertised just yet, but investigative users may use it :)
    CFStringRef appPath = CFPreferencesCopyAppValue(CFSTR("CPApplicationBundlePath"), bundleID);
    if (appPath) {
      appURL = CFURLCreateWithFileSystemPath(NULL, appPath, kCFURLPOSIXPathStyle, true);
      CFRelease(appPath);
    }
  }

  if (appURL == NULL) {
    OSType creator = kLSUnknownCreator;
    OSStatus status = LSFindApplicationForInfo(creator, bundleID, appFilename, NULL, &appURL);
    Boolean found = status != kLSApplicationNotFoundErr;
    if (found && explicitApp != NULL) {
      CFStringRef foundAppFilename = CFURLCopyLastPathComponent(appURL);
      found = CFStringCompare(appFilename, foundAppFilename, 0) == kCFCompareEqualTo;
      CFRelease(foundAppFilename);
    }
    if (!found) {
      CFIndex len = CFStringGetLength(appFilename)+1;
      char filename[len];
      CFStringGetCString(appFilename, filename, len, kCFStringEncodingUTF8);
      fprintf(stderr, "[!] Unable to locate the %s application bundle. Please ensure the " \
                      "application is available and launch it at least once.\n", filename);
      CFRelease(appURL);
      CFRelease(appFilename);
      return -1;
    }
  }

  CFURLRef envScriptURL = CFBundleCopyResourceURLInDirectory(appURL, envScript, NULL, NULL);
  assert(envScriptURL != NULL);

  CFRelease(appURL);
  CFRelease(appFilename);

  const char envScriptPath[PATH_MAX];
  assert(CFURLGetFileSystemRepresentation(envScriptURL, false, (UInt8 *)envScriptPath, PATH_MAX));
  CFRelease(envScriptURL);

  // -----------------------------------------------------------------------------------------------
  // Create arguments list for that calls `/bin/sh /path/to/bundle-env pod […]` and appends the
  // arguments that were passed to this program.
  // -----------------------------------------------------------------------------------------------
  const char *args[argc+3];
  args[0] = shPath;
  args[1] = envScriptPath;
  args[2] = podBin;
  for (int i = 1; i < argc; i++) {
    args[i+2] = *(argv+i);
  }
  args[argc+2] = NULL;

  // -----------------------------------------------------------------------------------------------
  // Replace process.
  // -----------------------------------------------------------------------------------------------
#ifdef DEBUG
  printf("$ '%s'", envScriptPath);
  for (const char **i = args; *i != NULL; i++) {
    printf(" '%s'", *i);
  }
  printf("\n");
#endif

  execv(shPath, (char *const *)args);

  fprintf(stderr, "Failed to execute `%s` (%d - %s)\n", envScriptPath, errno, strerror(errno));
  return errno;
}

# Tasks

The main tasks can be found with `rake -T`:

```
rake build_bundle  # Build complete dist bundle
rake bundle        # Build bundle tarball
rake clean         # Clean all build artefacts
rake clean:all     # Clean all artefacts, including downloads
rake ruby          # Build all dependencies and Ruby
rake test          # Test bundle
```

If you’re working on the build system and want to debug intermediate steps, be
sure to checkout _all_ the unnamed tasks with `rake -T -A`.

# Story 20.10 — Fix Android R8 Minification (Missing Play Core Class)

## Problem This Solves

The `deploy_android` job was failing at the `Build Release AAB (prod flavor)` step:

```
Missing class com.google.android.play.core.tasks.Task (referenced from:
void io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager
.installDeferredComponent(int, java.lang.String))

FAILURE: Build failed with an exception.
Execution failed for task ':app:minifyProdReleaseWithR8'.
> Compilation failed to complete
```

## Root Cause

When building a release AAB, Gradle runs **R8** (the Android code shrinker/minifier).
R8 resolves all class references in the codebase, including transitive ones.

Flutter's `PlayStoreDeferredComponentManager` (part of Flutter's deferred component
system) references `com.google.android.play.core.tasks.Task`. The Play Core library
that contains this class is **not a direct dependency** of Gatherli — Gatherli does
not use Flutter deferred components. However, R8 still encounters the reference and
by default treats a missing class as a hard error.

## Fix

Added one line to `android/app/proguard-rules.pro`:

```pro
-dontwarn com.google.android.play.core.**
```

This tells R8 to suppress warnings about any class in the `com.google.android.play.core`
package. Since Gatherli does not use deferred components or the Play Core library at
runtime, suppressing these warnings is safe — it does not affect app functionality.

## File Changed

**`android/app/proguard-rules.pro`**

```pro
# Suppress warnings for optional Play Core classes referenced by Flutter internals
-dontwarn com.google.android.play.core.**
```

## Why Not Add the Play Core Dependency?

Adding `implementation 'com.google.android.play:core:1.10.3'` as a dependency would
also resolve the error, but it would:

- Increase APK/AAB size unnecessarily
- Pull in a library the app does not use
- Require ongoing dependency maintenance

The `-dontwarn` approach is the correct fix when the referenced class is part of an
optional/unused code path (as documented by Google for Flutter deferred components).

// Provides portable implemention of Low-Level memory barriers,plus a few
// semi-portable utility macros (for inlining and alignment).Alose has a basic
// atomic type (limited to hardware-supported atomics with no memory ordering
// guarantees). USES the AE_* prefix for macros,and the moodycamel namespace for
// symbols.

#include <cassert>
#include <stdio.h>

// Platform detection
#if defined (__INTEL_COMPILER)


ses

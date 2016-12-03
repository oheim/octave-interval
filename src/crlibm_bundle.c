// Definitions from crlibm/CMakeLists.txt

#define SCS_NB_WORDS 8
#define SCS_NB_BITS 30

#ifdef __i386__
#define CRLIBM_TYPECPU_X86 1
#endif
#ifdef __i486__
#define CRLIBM_TYPECPU_X86 1
#endif
#ifdef __i586__
#define CRLIBM_TYPECPU_X86 1
#endif
#ifdef __i686__
#define CRLIBM_TYPECPU_X86 1
#endif

#ifdef __alpha__
#define CRLIBM_TYPECPU_ALPHA 1
#endif

#ifdef __powerpc__
#define CRLIBM_TYPECPU_POWERPC 1
#endif
#ifdef __powerpc64__
#define CRLIBM_TYPECPU_POWERPC 1
#endif

#ifdef __sparc__
#define CRLIBM_TYPECPU_SPARC 1
#endif

#ifdef __x86_64__
#define CRLIBM_TYPECPU_AMD64 1
#endif
#ifdef __amd64__
#define CRLIBM_TYPECPU_AMD64 1
#endif

#ifdef __ia64__
#define CRLIBM_TYPECPU_ITANIUM 1
#endif

// Definitions from automake

#define HAVE_INTTYPES_H 1
#define CRLIBM_HAS_FPU_CONTROL 1


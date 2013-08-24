#ifndef _CTYPE_H_
#define _CTYPE_H_

#include "_ansi.h"

_BEGIN_STD_C

  /* Indicate that we honor AEABI portability if requested.  */
#if defined _AEABI_PORTABILITY_LEVEL && _AEABI_PORTABILITY_LEVEL != 0 && !defined _AEABI_PORTABLE
# define _AEABI_PORTABLE
#endif

#if defined _AEABI_PORTABLE
extern unsigned char _CONST __aebi_ctype_table_C[257];
extern unsigned char _CONST __aebi_ctype_table_[257];

# ifdef _AEABI_LC_CTYPE
#  define _AEABI_CTYPE_TABLE(_X) __aebi_ctype_table_ ## _X
#  define _AEABI_CTYPE(_X) _AEABI_CTYPE_TABLE(_X)
#  define __aeabi_ctype_table _AEABI_CTYPE (_AEABI_LC_CTYPE)
# else
#  define __aeabi_ctype_table __aeabi_ctype_table_
# endif /* _AEABI_LC_CTYPE */

#define _AEABI_A	1	/* Alphabetic.  */
#define _AEABI_X	2	/* A-F a-f 0-9. */
#define _AEABI_P	4	/* Punctuation.  */
#define _AEABI_B	8	/* Printable blank.  */
#define _AEABI_S	16	/* Whitespace.  */
#define _AEABI_L	32	/* Lower case letter.  */
#define _AEABI_U	64	/* Upper case letter.  */
#define _AEABI_C	128	/* Control chars.  */

#define isspace(x)	((__aeabi_ctype_table+1)[x] & _AEABI_S)
#define isalpha(x)	((__aeabi_ctype_table+1)[x] & _AEABI_A)
#define isalnum(x)	((__aeabi_ctype_table+1)[x] << 30)
#define isprint(x)	((__aeabi_ctype_table+1)[x] << 28)
#define isupper(x)	((__aeabi_ctype_table+1)[x] & _AEABI_U)
#define islower(x)	((__aeabi_ctype_table+1)[x] & _AEABI_L)
#define isxdigit(x)	((__aeabi_ctype_table+1)[x] & _AEABI_X)
/* isblank */
#define isgraph(x)	((__aeabi_ctype_table+1)[x] << 29)
#define iscntrl(x)	((__aeabi_ctype_table+1)[x] & _AEABI_C)
#define ispunct(x)	((__aeabi_ctype_table+1)[x] & _AEABI_P)

#else

int _EXFUN(isalnum, (int __c));
int _EXFUN(isalpha, (int __c));
int _EXFUN(iscntrl, (int __c));
int _EXFUN(isdigit, (int __c));
int _EXFUN(isgraph, (int __c));
int _EXFUN(islower, (int __c));
int _EXFUN(isprint, (int __c));
int _EXFUN(ispunct, (int __c));
int _EXFUN(isspace, (int __c));
int _EXFUN(isupper, (int __c));
int _EXFUN(isxdigit,(int __c));
int _EXFUN(tolower, (int __c));
int _EXFUN(toupper, (int __c));

#if (!defined __STRICT_ANSI__ && !defined _AEABI_PORTABLE) || defined(__cplusplus) || __STDC_VERSION__ >= 199901L
int _EXFUN(isblank, (int __c));
#endif

#if !defined __STRICT_ANSI__ && !defined _AEABI_PORTABLE
int _EXFUN(isascii, (int __c));
int _EXFUN(toascii, (int __c));
int _EXFUN(_tolower, (int __c));
int _EXFUN(_toupper, (int __c));
#endif

#define	_U	01
#define	_L	02
#define	_N	04
#define	_S	010
#define _P	020
#define _C	040
#define _X	0100
#define	_B	0200

extern	__IMPORT _CONST char	*__ctype_ptr__;

#ifndef __cplusplus
#define	isalpha(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&(_U|_L))
#define	isupper(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&_U)
#define	islower(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&_L)
#define	isdigit(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&_N)
#define	isxdigit(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&(_X|_N))
#define	isspace(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&_S)
#define ispunct(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&_P)
#define isalnum(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&(_U|_L|_N))
#define isprint(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&(_P|_U|_L|_N|_B))
#define	isgraph(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&(_P|_U|_L|_N))
#define iscntrl(c)	((__ctype_ptr__)[(unsigned)((c)+1)]&_C)


/* Non-gcc versions will get the library versions, and will be
   slightly slower */
#ifdef __GNUC__
# define toupper(c) \
	__extension__ ({ int __x = (c); islower(__x) ? (__x - 'a' + 'A') : __x;})
# define tolower(c) \
	__extension__ ({ int __x = (c); isupper(__x) ? (__x - 'A' + 'a') : __x;})
#endif
#endif /* !__cplusplus */

#if !defined __STRICT_ANSI__ && !defined _AEABI_PORTABLE
#define isascii(c)	((unsigned)(c)<=0177)
#define toascii(c)	((c)&0177)
#endif

#endif /* _AEABI_PORTABLE */

/* For C++ backward-compatibility only.  */
extern	__IMPORT _CONST char	_ctype_[];

_END_STD_C

#endif /* _CTYPE_H_ */

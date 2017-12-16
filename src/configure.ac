#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
#
### Copyright (C) 2017 Olaf Till <i7tiol@t-online.de>
### Copyright (C) 2017 Oliver Heimlich <oheim@posteo.de>
###
### This program is free software; you can redistribute it and/or
### modify it under the terms of the GNU General Public License as
### published by the Free Software Foundation; either version 3 of the
### License, or (at your option) any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
### General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program; if not, see
### <http://www.gnu.org/licenses/>.

AC_PREREQ([2.69])
AC_INIT([interval], [m4_esyscmd_s([grep ^Version:\  ../DESCRIPTION | cut -f2 -d\ ])], [Oliver Heimlich <oheim@posteo.de>])
AC_CONFIG_SRCDIR([mpfr_function_d.cc])

# Checks for programs.
AC_PROG_CXX

AC_LANG([C++])

# Checks for libraries.
AC_CHECK_LIB([mpfr], [mpfr_init2], [], [
  AC_MSG_ERROR([could not find the mpfr library])
])
AC_CHECK_LIB([m], [exp])

# Checks for header files.
AC_CHECK_HEADERS([fenv.h])
AC_CHECK_HEADERS([mpfr.h], [], [
  AC_MSG_ERROR([could not find mpfr.h, possibly an mpfr development package has to be installed])
])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_INT32_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T
AC_TYPE_UINT8_T

# Checks for library functions.
AC_FUNC_ERROR_AT_LINE
AC_CHECK_FUNCS([fesetround floor])

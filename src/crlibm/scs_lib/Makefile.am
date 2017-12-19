## Process this file with automake to produce Makefile.in

# Copyright (C) 2002 David Defour, Catherine Daramy, and Florent de Dinechin
#
# This file is part of scslib, the Software Carry-Save multiple-precision
# library, which has been developed by the Arénaire project at École normale
# supérieure de Lyon.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

lib_LIBRARIES = libscs.a
AM_CPPFLAGS=-I$(top_srcdir)


libscs_a_SOURCES = scs.h scs_private.h scs_private.c \
	double2scs.c print_scs.c \
	division_scs.c\
	addition_scs.c multiplication_scs.c\
	scs2double.c zero_scs.c \
	scs2mpfr.c 


include_HEADERS = scs.h ../crlibm_config.h


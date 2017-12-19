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

bin_PROGRAMS =  scs_test_timing scs_test_accuracy

LDADD= $(top_builddir)/libscs.a
INCLUDES=-I$(top_srcdir)

../libscs.a:
	cd $(top_srcdir); make libscs.a 

scs_test_timing_SOURCES = test_timing.c tbx_timing.h

scs_test_accuracy_SOURCES = test_accuracy.c
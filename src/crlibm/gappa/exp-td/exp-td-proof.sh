#/bin/bash

# This file is part of crlibm, the correctly rounded mathematical library,
# which has been developed by the Arénaire project at École normale supérieure
# de Lyon.
#
# Copyright (C) 2004-2011 David Defour, Catherine Daramy-Loirat,
# Florent de Dinechin, Matthieu Gallet, Nicolas Gast, Christoph Quirin Lauter,
# and Jean-Michel Muller
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

GAPPA=~/gappa/src/gappa

sed -f ../maple/TEMPEXP/exp-td-accurate.sed exp-td-accurate1.gappa | $GAPPA 
sed -f ../maple/TEMPEXP/exp-td-accurate.sed exp-td-accurate2.gappa | $GAPPA 
sed -f ../maple/TEMPEXP/exp-td-accurate.sed exp-td-accurate3.gappa | $GAPPA 
sed -f ../maple/TEMPEXP/exp-td-accurate.sed exp-td-accurate4.gappa | $GAPPA 


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

GAPPA=~/schorle/gappa/src/gappa

echo Proving error bound on sqrt12...
sed -f sqrt.sed sqrt12.gappa | $GAPPA
echo Proving error bound on sqrt13...
sed -f sqrt.sed sqrt13.gappa | $GAPPA


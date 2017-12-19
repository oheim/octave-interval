#!/bin/sh

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

# This will only function if you have a modified version of the gappa tool
#
# You probably need to edit the path to the gappa executable
GAPPA=~/ble/gappa-0.4.5/src/gappa


cat log-td.gappa | grep "#MAPLE" | sed -e s/=/:=/ -e "s/;/:/" > log-td.gappa.autocheck.mpl
echo "printf(\"You should see only zeros in what follows:\\n\");" >> log-td.gappa.autocheck.mpl
sed -f ./TEMPLOG/log-td_1.sed log-td.gappa | $GAPPA 2>&1 | grep simplify >> log-td.gappa.autocheck.mpl
echo "printf(\"If you have seen only zeros up to now, everything's fine \\n\");" >> log-td.gappa.autocheck.mpl

cat log-td-E0.gappa | grep "#MAPLE" | sed -e s/=/:=/ -e "s/;/:/" > log-td-E0.gappa.autocheck.mpl
echo "printf(\"You should see only zeros in what follows:\\n\");" >> log-td-E0.gappa.autocheck.mpl
sed -f ./TEMPLOG/log-td_1.sed log-td-E0.gappa | $GAPPA 2>&1 | grep simplify >> log-td-E0.gappa.autocheck.mpl
echo "printf(\"If you have seen only zeros up to now, everything's fine \\n\");" >> log-td-E0.gappa.autocheck.mpl

cat log-td-E0-logir0.gappa | grep "#MAPLE" | sed -e s/=/:=/ -e "s/;/:/" > log-td-E0-logir0.gappa.autocheck.mpl
echo "printf(\"You should see only zeros in what follows:\\n\");" >> log-td-E0-logir0.gappa.autocheck.mpl
sed -f ./TEMPLOG/log-td_1.sed log-td-E0-logir0.gappa | $GAPPA 2>&1 | grep simplify >> log-td-E0-logir0.gappa.autocheck.mpl
echo "printf(\"If you have seen only zeros up to now, everything's fine \\n\");" >> log-td-E0-logir0.gappa.autocheck.mpl

cat log-td-accurate.gappa | grep "#MAPLE" | sed -e s/=/:=/ -e "s/;/:/" > log-td-accurate.gappa.autocheck.mpl
echo "printf(\"You should see only zeros in what follows:\\n\");" >> log-td-accurate.gappa.autocheck.mpl
sed -f ./TEMPLOG/log-td-accurate_1.sed log-td-accurate.gappa | $GAPPA 2>&1 | grep simplify >> log-td-accurate.gappa.autocheck.mpl
echo "printf(\"If you have seen only zeros up to now, everything's fine \\n\");" >> log-td-accurate.gappa.autocheck.mpl

cat log-td-accurate-E0.gappa | grep "#MAPLE" | sed -e s/=/:=/ -e "s/;/:/" > log-td-accurate-E0.gappa.autocheck.mpl
echo "printf(\"You should see only zeros in what follows:\\n\");" >> log-td-accurate-E0.gappa.autocheck.mpl
sed -f ./TEMPLOG/log-td-accurate_1.sed log-td-accurate-E0.gappa | $GAPPA 2>&1 | grep simplify >> log-td-accurate-E0.gappa.autocheck.mpl
echo "printf(\"If you have seen only zeros up to now, everything's fine \\n\");" >> log-td-accurate-E0.gappa.autocheck.mpl

cat log-td-accurate-E0-logir0.gappa | grep "#MAPLE" | sed -e s/=/:=/ -e "s/;/:/" > log-td-accurate-E0-logir0.gappa.autocheck.mpl
echo "printf(\"You should see only zeros in what follows:\\n\");" >> log-td-accurate-E0-logir0.gappa.autocheck.mpl
sed -f ./TEMPLOG/log-td-accurate_1.sed log-td-accurate-E0-logir0.gappa | $GAPPA 2>&1 | grep simplify >> log-td-accurate-E0-logir0.gappa.autocheck.mpl
echo "printf(\"If you have seen only zeros up to now, everything's fine \\n\");" >> log-td-accurate-E0-logir0.gappa.autocheck.mpl



echo "read \"log-td.gappa.autocheck.mpl\";" | maple
echo "read \"log-td-E0.gappa.autocheck.mpl\";" | maple
echo "read \"log-td-E0-logir0.gappa.autocheck.mpl\";" | maple
echo "read \"log-td-accurate.gappa.autocheck.mpl\";" | maple
echo "read \"log-td-accurate-E0.gappa.autocheck.mpl\";" | maple
echo "read \"log-td-accurate-E0-logir0.gappa.autocheck.mpl\";" | maple


#######################################################################
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

# To use:
# restart; read "exp-td.mpl";
Digits := 120:

interface(quiet=true):

read "common-procedures.mpl":
read "triple-double.mpl":
mkdir("TEMPEXP"):

L := 12:

printf("   memory requirement for L = %d and two triple-double tables: %d bytes\n",L,48*2^(ceil(L/2)));

rmax := log(2) / (2^(L+1)):

printf("   maximal absolute value for rmax = 2^(%f)\n",log[2](rmax)):


MsLog2Div2L := evalf(-log(2)/(2^L)):

msLog2Div2Lh, msLog2Div2Lm, msLog2Div2Ll := hi_mi_lo(MsLog2Div2L):

epsMsLog2Div2L := evalf(abs(((msLog2Div2Lh + msLog2Div2Lm + msLog2Div2Ll) - MsLog2Div2L)/MsLog2Div2L)):
epsDDMsLog2Div2L := evalf(abs(((msLog2Div2Lh + msLog2Div2Lm) - MsLog2Div2L)/MsLog2Div2L)):

printf("   error made by storing MsLog2Div2L as a double-double: 2^(%f)\n",log[2](epsDDMsLog2Div2L)):
printf("   error made by storing MsLog2Div2L as a triple-double: 2^(%f)\n",log[2](epsMsLog2Div2L)):

gap := -floor(-log[2](abs(msLog2Div2Lm/msLog2Div2Lh))):

printf("   |msLog2Div2Lm| <= 2^(%f) * |msLog2Div2Lh|\n",gap):


log2InvMult2L := nearest(2^L / (log(2))):

shiftConst := 2^(52) + 2^(51):

indexmask1 := 2^(L/2) - 1:
indexmask2 := indexmask1 * 2^(L/2):

largest := 2^(1023) * ((2^(53) - 1) / 2^(52)):
smallest := 2^(-1023) * 1 * 2^(-51):

overflowbound := nearest(log(largest)):

overflowboundHex := ieeehexa(overflowbound):
overflowSimplebound := convert(overflowboundHex[1],decimal,hex):

underflowbound := nearest(log(2^(-1075))):

denormbound := nearest(log(2^(-1022) * 1)):


overUnderflowboundHex := ieeehexa(min(abs(underflowbound),min(abs(overflowbound),abs(denormbound)))):
overUnderflowSimplebound := convert(overUnderflowboundHex[1],decimal,hex):

twoPowerM1000 := 2^(-1000):
twoPower1000 := 2^(1000):

twoM52 := 2^(-52):
mTwoM53 := - 2^(-53):

for i from 0 to 2^(L/2) - 1 do
	twoPowerIndex1hi[i], twoPowerIndex1mi[i], twoPowerIndex1lo[i] := hi_mi_lo(evalf(2^(i/(2^L)))):
	twoPowerIndex2hi[i], twoPowerIndex2mi[i], twoPowerIndex2lo[i] := hi_mi_lo(evalf(2^(i/(2^(L/2))))):
od: 



PolyDegreeQuick:=4:
printf("   degree of the polynomial used in the quick phase is %d\n",PolyDegreeQuick);



polyQuick:= poly_exact(1 + x + 0.5*x^2 + x^3 * (numapprox[minimax](((exp(x) - (1 + x + 0.5*x^2))/x^3),  
				x=-rmax..rmax, [PolyDegreeQuick-3,0], 1 ,  'deltaApprox'))):

epsilonApproxQuick := numapprox[infnorm]( ((polyQuick-1)/(exp(x)-1))-1, x=-rmax..rmax):
printf("   approximation rel error for the quick phase is 2^(%2f)\n", log2(epsilonApproxQuick) ) :
deltaApproxQuick := numapprox[infnorm]( polyQuick-exp(x), x=-rmax..rmax):
printf("   approximation abs error for the quick phase is 2^(%2f)\n", log2(deltaApproxQuick) ) :

	

PolyDegreeAccurate:=7:

printf("   degree of the polynomial used in the accurate phase is %d\n",PolyDegreeAccurate):

DDNumberAccu:=5:


printf("   number of double doubles used for the coefficients is %d\n",DDNumberAccu):



polyAccurate:= poly_exact2(1 + x + 0.5*x^2 + x^3 * (numapprox[minimax](((exp(x) - (1 + x + 0.5*x^2))/x^3),  
				x=-rmax..rmax, [PolyDegreeAccurate-3,0], 1 ,  'deltaApprox')), 
				DDNumberAccu):	


epsilonApproxAccurate := numapprox[infnorm]( ((polyAccurate-1)/(exp(x)-1))-1, x=-rmax..rmax):
printf("   approximation rel error for the accurate phase is 2^(%2f)\n", log2(epsilonApproxAccurate) ) :
deltaApproxAccurate := numapprox[infnorm]( polyAccurate-exp(x), x=-rmax..rmax):
printf("   approximation abs error for the accurate phase is 2^(%2f)\n", log2(deltaApproxAccurate) ) :


epsilonApproxRmAccurate := numapprox[infnorm]( (x/(exp(x)-1))-1, x=-rmax*2^(-52)..rmax*2^(-52)):
epsilonApproxRlAccurate := numapprox[infnorm]( (x/(exp(x)-1))-1, x=-rmax*2^(-105)..rmax*2^(-105)):

printf("   approximation rel error for approximating exp(rm) - 1 by rm is 2^(%2f)\n", log2(abs(epsilonApproxRmAccurate))):
printf("   approximation rel error for approximating exp(rl) - 1 by rl is 2^(%2f)\n", log2(abs(epsilonApproxRlAccurate))):

epsilonApproxAccurateSpecial := numapprox[infnorm]( ((polyAccurate-1)/(exp(x)-1))-1, x=-2^(-30)..2^(-30)):
printf("   approximation rel error for the accurate phase in the special interval (|r| \\leq 2^(-30)) is 2^(%2f)\n", 
log2(epsilonApproxAccurateSpecial) ) :

epsilonApproxAccurateSpecial2 := numapprox[infnorm]( ((polyAccurate-1)/(exp(x)-1))-1, x=-2^(-18)..2^(-18)):
printf("   approximation rel error for the accurate phase in the special interval (|r| \\leq 2^(-18)) is 2^(%2f)\n", 
log2(epsilonApproxAccurateSpecial2) ) :



epsilon_quick := 2^(-64): # The Gappa proof will show this bound





#-------------------------------------------------------------------
# Output

filename:="TEMPEXP/exp-td.h":
fd:=fopen(filename, WRITE, TEXT):

fprintf(fd, "#include \"crlibm.h\"\n#include \"crlibm_private.h\"\n"):

fprintf(fd, "\n/*File generated by maple/exp-td.mpl*/\n"):

fprintf(fd, "\#define L %d\n",L):
fprintf(fd, "\#define LHALF %d\n",L/2):
fprintf(fd, "\#define log2InvMult2L %1.50e\n",log2InvMult2L):
fprintf(fd, "\#define msLog2Div2Lh %1.50e\n",msLog2Div2Lh):
fprintf(fd, "\#define msLog2Div2Lm %1.50e\n",msLog2Div2Lm):
fprintf(fd, "\#define msLog2Div2Ll %1.50e\n",msLog2Div2Ll):
fprintf(fd, "\#define shiftConst %1.50e\n",shiftConst):
fprintf(fd, "\#define INDEXMASK1 0x%08x\n",indexmask1):
fprintf(fd, "\#define INDEXMASK2 0x%08x\n",indexmask2):
fprintf(fd, "\#define OVRUDRFLWSMPLBOUND 0x%08x\n",overUnderflowSimplebound):
fprintf(fd, "\#define OVRFLWBOUND %1.50e\n",overflowbound):
fprintf(fd, "\#define LARGEST %1.50e\n",largest):
fprintf(fd, "\#define SMALLEST %1.50e\n",smallest):
fprintf(fd, "\#define DENORMBOUND %1.50e\n",denormbound):
fprintf(fd, "\#define UNDERFLWBOUND %1.50e\n",underflowbound):
fprintf(fd, "\#define twoPowerM1000 %1.50e\n",twoPowerM1000):
fprintf(fd, "\#define twoPower1000 %1.50e\n",twoPower1000):
fprintf(fd, "\#define ROUNDCST %1.50e\n", compute_rn_constant(epsilon_quick)):   
fprintf(fd, "\#define RDROUNDCST %1.50e\n", epsilon_quick):   
fprintf(fd, "\#define twoM52 %1.50e\n", twoM52):   
fprintf(fd, "\#define mTwoM53 %1.50e\n", mTwoM53):   

fprintf(fd,"\n\n"):

for i from 3 to PolyDegreeQuick do
	fprintf(fd, "\#define c%d %1.50e\n",i,coeff(polyQuick,x,i)):
od:


for i from 3 to DDNumberAccu-1 do
	(hi,lo) := hi_lo(coeff(polyAccurate,x,i)):
	fprintf(fd, "\#define accPolyC%dh %1.50e\n",i,hi):
	fprintf(fd, "\#define accPolyC%dl %1.50e\n",i,lo):
od:

for i from DDNumberAccu to PolyDegreeAccurate do
	fprintf(fd, "\#define accPolyC%d %1.50e\n",i,coeff(polyAccurate,x,i)):
od:

fprintf(fd,"\n\n"):

# Print the tables
fprintf(fd, "typedef struct tPi_t_tag {double hi; double mi; double lo;} tPi_t;  \n"):
fprintf(fd, "static const tPi_t twoPowerIndex1[%d] = {\n", 2^(L/2)):
for i from 0 to 2^(L/2)-1 do
      fprintf(fd, "  { \n"):      
      fprintf(fd, "    %1.50e, /* twoPowerIndex1hi[%d] */ \n", twoPowerIndex1hi[i], i):
      fprintf(fd, "    %1.50e, /* twoPowerIndex1mi[%d] */ \n", twoPowerIndex1mi[i], i):
      fprintf(fd, "    %1.50e, /* twoPowerIndex1lo[%d] */ \n", twoPowerIndex1lo[i], i):
      fprintf(fd, "  } "):
      if(i<2^(L/2)-1) then  fprintf(fd, ", \n"): fi
od:
fprintf(fd, "}; \n \n"):
fprintf(fd, "static const tPi_t twoPowerIndex2[%d] = {\n", 2^(L/2)):
for i from 0 to 2^(L/2)-1 do
      fprintf(fd, "  { \n"):      
      fprintf(fd, "    %1.50e, /* twoPowerIndex2hi[%d] */ \n", twoPowerIndex2hi[i], i):
      fprintf(fd, "    %1.50e, /* twoPowerIndex2mi[%d] */ \n", twoPowerIndex2mi[i], i):
      fprintf(fd, "    %1.50e, /* twoPowerIndex2lo[%d] */ \n", twoPowerIndex2lo[i], i):
      fprintf(fd, "  } "):
      if(i<2^(L/2)-1) then  fprintf(fd, ", \n"): fi
od:
fprintf(fd, "}; \n \n"):

fprintf(fd, "\n\n"):

fclose(fd):

filename:="TEMPEXP/exp-td-accurate.sed":
fd:=fopen(filename, WRITE, TEXT):
fprintf(fd, " s/_rhmax/%1.50e/g\n", rmax):
fprintf(fd, " s/_rmmax/%1.50e/g\n", rmax*2^(-52)):
fprintf(fd, " s/_rlmax/%1.50e/g\n", rmax*2^(-105)):
fprintf(fd, " s/_epsilonApproxAccurate/%1.50e/g\n", epsilonApproxAccurate):
fprintf(fd, " s/_epsilonApproxRmAccurate/%1.50e/g\n", epsilonApproxRmAccurate):
fprintf(fd, " s/_epsilonApproxRlAccurate/%1.50e/g\n", epsilonApproxRlAccurate):
fprintf(fd, " s/_epsilonApproxSpecial/%1.50e/g\n", epsilonApproxAccurateSpecial):

for i from 3 to DDNumberAccu-1 do
	(hi,lo) := hi_lo(coeff(polyAccurate,x,i)):
	fprintf(fd, "s/_accPolyC%dh/%1.50e/g\n",i,hi):
	fprintf(fd, "s/_accPolyC%dl/%1.50e/g\n",i,lo):
od:

for i from DDNumberAccu to PolyDegreeAccurate do
	fprintf(fd, "s/_accPolyC%d/%1.50e/g\n",i,coeff(polyAccurate,x,i)):
od:

fclose(fd):



printf("----DONE---\n") :



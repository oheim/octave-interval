#######################################################################
# To use:
# restart; read "log.mpl";
Digits := 100:

interface(quiet=true):

read "common-procedures.mpl":
read "double-extended.mpl":
mkdir("TEMPLOG"):


ln2h,ln2l := hiloExt(log(2)):

L := 8: # number of bits used to address the table (imposed by frcpa)

read"frcpa.mpl";
for i from 0 to 2^L-1 do
    (logirh[i], logirl[i]) := hiloExt(-log(r[i])):
od:

zmax:=2^(-8.886): # given by the doc of the frcpa

minyfast:=(1-zmax)*(1+2^(-21)): # mult by 1+2^(-21) to ensure the bound computed below is valid
MINYFAST:=ieeehexa(minyfast)[1]:

maxyfast:=(1+zmax)*(1-2^(-21)): # mult by 1-2^(-21) to ensure the bound computed below is valid
MAXYFAST:=ieeehexa(maxyfast)[1]:

PolyDegreeAccurate:=13:

printf("Computing the polynomial for accurate phase (this may take some time...)\n"):
pe:= x  * numapprox[minimax](  log(1+x)/x,  x=-zmax..zmax,  [PolyDegreeAccurate-1,0], 1 ,  'delta_approx'):
log2(delta_approx):
# 123 bits



MaxDegreeDDE:=8:  #

polyAccurate := polyExact2Ext(pe, MaxDegreeDDE):
#delta_approx := numapprox[infnorm](polyAccurate-log(1+x), x=-zmax..zmax):
epsilon_approx_accurate := numapprox[infnorm]( 1-polyAccurate/log(1+x), x=-zmax..zmax):
printf("   approximation error for the accurate phase is 2^(%2f)\n", log2(epsilon_approx_accurate) ) :


PolyDegreeQuick:=6: # On peut faire 6 pour les grands exposants. A voir

if(1+1=3) then
# Here we tried to use the polynomial from the accurate phase for the
# quick one.  This loses 7 bits of precision compared to a clean minimax, meaning
# one degree more. Better do two polynomials. To investigate some day,
# there must be a polynomial that does both.

#truncated to PolyDegreeQuick and to DE. We use the fact that series(p)=p
polyQuick := convert(series(polyExact2Ext(polyAccurate, 0), x=0, PolyDegreeQuick+1), polynom):
#delta_approx := numapprox[infnorm](polyAccurate-log(1+x), x=-zmax..zmax):
epsilon_approx := numapprox[infnorm]( 1-polyQuick/log(1+x), x=-zmax..zmax):
printf("   approximation error for the quick phase is 2^(%2f)\n", log2(epsilon_approx) ) ;
fi:


polyQuick:= polyExact2Ext(x  * numapprox[minimax](  log(1+x)/x,  x=-zmax..zmax,  [PolyDegreeQuick-1,0], 1 ,  'delta_approx'), 0):
epsilon_approx_quick := numapprox[infnorm]( 1-polyQuick/log(1+x), x=-zmax..zmax):
printf("   approximation rel error for the quick phase is 2^(%2f)\n", log2(epsilon_approx_quick) ) :
delta_approx_quick := numapprox[infnorm]( polyQuick-log(1+x), x=-zmax..zmax):
printf("   approximation abs error for the quick phase is 2^(%2f)\n", log2(delta_approx_quick) ) :





filename:="TEMPLOG/log-de2.h":
fd:=fopen(filename, WRITE, TEXT):

fprintf(fd, "/*File generated by maple/log-de2.mpl*/\n\n"):

  # Various constants
  fprintf(fd, "#define L        %d\n", L):
  fprintf(fd, "static const long double ln2h  = %1.50eL ;\n", ln2h):
  fprintf(fd, "static const long double ln2l  = %1.50eL ;\n", ln2l):
  fprintf(fd, "static const long double two64 = %1.50eL ;\n", evalf(2^64)):

  fprintf(fd, "#define MINYFAST 0x%s\n", MINYFAST):
  fprintf(fd, "#define MAXYFAST 0x%s\n", MAXYFAST):

  # The polynomials
  #  polynomial for quick phase
#  for i from PolyDegreeQuick to 1 by -1 do
#    fprintf(fd, "static const long double c%d =    %1.50eL ;\n", i, coeff(polyQuick,x,i)):
#  od:
   fprintf(fd, "static const long double c[%d] =  {\n",PolyDegreeQuick):
   for i from PolyDegreeQuick to 1 by -1 do
     fprintf(fd, "   /* c[%d]  = */ %1.50eL, \n", i, coeff(polyQuick,x,i)):
   od:
  fprintf(fd, "}; \n \n"):

  #  polynomial for accurate phase
  for i from PolyDegreeAccurate to MaxDegreeDDE by -1 do
    fprintf(fd, "static const long double c%dh =    %1.50eL ;\n", i, coeff(polyAccurate,x,i)):
  od:
  for i from  MaxDegreeDDE-1 to 1 by -1 do
    (ch, cl) := hiloExt(coeff(polyAccurate,x,i)):
    fprintf(fd, "static const long double c%dh =    %1.50eL ;\n", i, ch):
    fprintf(fd, "static const long double c%dl =    %1.50eL ;\n", i, cl):
  od:

  # The tables


  fprintf(fd, "#if defined(CRLIBM_TYPECPU_X86) || defined(CRLIBM_TYPECPU_AMD64)\n"):
  fprintf(fd, "typedef struct dde_tag {long double h; float r; long double l; } dde ;  \n"):
  fprintf(fd, "static const dde argredtable[%d] = {\n", 2^L):
  for i from 0 to 2^L-1 do
      fprintf(fd, "  { \n"):
      fprintf(fd, "    %1.50eL, /* logirh[%d] */ \n", logirh[i], i):
      fprintf(fd, "    %1.10f,   /* frcpa[%d] */ \n", r[i], i):
      fprintf(fd, "    %1.50eL, /* logirl[%d] */ \n", logirl[i], i):
      fprintf(fd, "  } "):
      if(i<2^L-1) then  fprintf(fd, ", \n"): fi
  od:
fprintf(fd, "}; \n \n"):
  fprintf(fd, "#else /* not(defined(CRLIBM_TYPECPU_X86) || defined(CRLIBM_TYPECPU_AMD64)),\n   assuming Itanium, otherwise we shouldn't be there */ \n"):
  fprintf(fd, "typedef struct dde_tag {long double h;  long double l; } dde ;  \n\n"):
  fprintf(fd, "static const dde argredtable[%d] = {\n", 2^L):
  for i from 0 to 2^L-1 do
      fprintf(fd, "  { \n"):
      fprintf(fd, "    %1.50eL, /* logirh[%d] */ \n", logirh[i], i):
      fprintf(fd, "    %1.50eL, /* logirl[%d] */ \n", logirl[i], i):
      fprintf(fd, "  } "):
      if(i<2^L-1) then  fprintf(fd, ", \n"): fi
  od:
fprintf(fd, "}; \n \n"):
  fprintf(fd, "#endif /* defined(CRLIBM_TYPECPU_X86) || defined(CRLIBM_TYPECPU_AMD64) */ \n"):


fclose(fd):

printf("----DONE---\n") :


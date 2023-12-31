/*
 * Correctly rounded logarithm
 *
 * Copyright (C) 2004-2011 David Defour, Catherine Daramy-Loirat,
 * Florent de Dinechin, Matthieu Gallet, Nicolas Gast, Christoph Quirin Lauter,
 * and Jean-Michel Muller
 *
 * This file is part of crlibm, the correctly rounded mathematical library,
 * which has been developed by the Arénaire project at École normale supérieure
 * de Lyon.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include "crlibm.h"
#include "crlibm_private.h"

/*File generated by maple/coef_log.mw*/

#define SQRT_2 1.4142135623730950489e0 

#define DEGREE 12

#define EMIN_MEDIUMPATH 23.000 
#define EMIN_FASTPATH 185.000 
/* Constants for rounding  */
static const double epsilon[4] =
{
  /* Case E=0  */
  4.47385432225115274522995672974873440655535693998277e-18, 
  /* Middle case   */
  8.40963020519242390613590856552459545441732156457476e-19, 
  /* Case E>EminMedPath  */
  3.19013236586914638175957676953204491380730158561523e-20, 
  /* And for the fast path  */
  1.65439555368591958127629148820687373633319579538065e-19 

};

static const double rncst[4] =
{
  /* Case E=0  */
  1.08596671427669422271833354898262768983840942382813e+00, 
  /* Middle case   */
  1.01526872993599659444896587956463918089866638183594e+00, 
  /* Case E>EminMedPath  */
  1.00057496390146027920309279579669237136840820312500e+00, 
  /* And for the fast path  */
  1.00298612635768380485501438670326024293899536132813e+00 
};

#ifdef WORDS_BIGENDIAN
static const db_number ln2hi = {{0x3FE62E42,0xFEFA3800}} /* +6.9314718056e-01 */;
static const db_number ln2lo = {{0x3D2EF357,0x93C76730}} /* +5.4979230187e-14 */;
static const db_number two52 = {{0x43300000,0x00000000}} /* +4.5035996274e+15 */;
static const db_number middle[8] =
{
{{0x3FE7504F,0x333F9DE3}} /* +7.2855339059e-01 */ ,
{{0x3FE90000,0x00000000}} /* +7.8125000000e-01 */ ,
{{0x3FEB0000,0x00000000}} /* +8.4375000000e-01 */ ,
{{0x3FED0000,0x00000000}} /* +9.0625000000e-01 */ ,
{{0x3FF00000,0x00000000}} /* +1.0000000000e+00 */ ,
{{0x3FF20000,0x00000000}} /* +1.1250000000e+00 */ ,
{{0x3FF40000,0x00000000}} /* +1.2500000000e+00 */ ,
{{0x3FF5D04F,0x333F9DE9}} /* +1.3633567812e+00 */
};

static const db_number Poly_h[8][13] =
{
 /* polynomial 1 */
{
{{0xBFD444B8,0x73F60B09}} /* -3.1669436764e-01 */ ,
{{0x3FF5F619,0x980C433A}} /* +1.3725830020e+00 */ ,
{{0xBFEE24CC,0x824C9A57}} /* -9.4199204873e-01 */ ,
{{0x3FEB954C,0x47881604}} /* +8.6197484942e-01 */ ,
{{0xBFEC6529,0xC58FCD22}} /* -8.8734901987e-01 */ ,
{{0x3FEF2E06,0x1AC1D834}} /* +9.7436814524e-01 */ ,
{{0xBFF1D4FE,0xF5D42E1A}} /* -1.1145009616e+00 */ ,
{{0x3FF4FAB7,0x67F441DC}} /* +1.3112100659e+00 */ ,
{{0xBFF93248,0xEA47B471}} /* -1.5747765686e+00 */ ,
{{0x3FFEBDCE,0x85276A57}} /* +1.9213395311e+00 */ ,
{{0xC002FCE1,0x0ABAD697}} /* -2.3734761084e+00 */ ,
{{0x4007BFE9,0x8C0B7AF7}} /* +2.9687071744e+00 */ ,
{{0xC00DE4D4,0xF57FD2EC}} /* -3.7367343120e+00 */
},
 /* polynomial 2 */
{
{{0xBFCF991C,0x6CB3B379}} /* -2.4686007793e-01 */ ,
{{0x3FF47AE1,0x47AE147B}} /* +1.2800000000e+00 */ ,
{{0xBFEA36E2,0xEB1C432D}} /* -8.1920000000e-01 */ ,
{{0x3FE65E9F,0x80F29213}} /* +6.9905066667e-01 */ ,
{{0xBFE5798E,0xE2308C3F}} /* -6.7108864000e-01 */ ,
{{0x3FE5FD7F,0xE1793910}} /* +6.8719476736e-01 */ ,
{{0xBFE774CC,0xAC3CC49E}} /* -7.3300775185e-01 */ ,
{{0x3FE9BC1F,0x779F31B6}} /* +8.0421422351e-01 */ ,
{{0xBFECD2B2,0x9C89806A}} /* -9.0071993421e-01 */ ,
{{0x3FF065A0,0xF663DD55}} /* +1.0248117089e+00 */ ,
{{0xBFF2E3A7,0x64D28253}} /* -1.1805795611e+00 */ ,
{{0x3FF613D4,0x162168A9}} /* +1.3798409333e+00 */ ,
{{0xBFF9EC69,0x1E7E75E1}} /* -1.6202174369e+00 */
},
 /* polynomial 3 */
{
{{0xBFC5BF40,0x6B543DB2}} /* -1.6989903680e-01 */ ,
{{0x3FF2F684,0xBDA12F68}} /* +1.1851851852e+00 */ ,
{{0xBFE67980,0xE0BF08C7}} /* -7.0233196159e-01 */ ,
{{0x3FE1C1FA,0x5F678885}} /* +5.5492895731e-01 */ ,
{{0xBFDF91BD,0x1B62B9D2}} /* -4.9327018427e-01 */ ,
{{0x3FDDEEAF,0x8242EF01}} /* +4.6769321175e-01 */ ,
{{0xBFDD9015,0xA36B029B}} /* -4.6191922149e-01 */ ,
{{0x3FDE0836,0x7F176341}} /* +4.6925127422e-01 */ ,
{{0xBFDF24F6,0x26663631}} /* -4.8663095236e-01 */ ,
{{0x3FE067BA,0x19D8F153}} /* +5.1266198204e-01 */ ,
{{0xBFE17FB2,0xECA216B7}} /* -5.4683824747e-01 */ ,
{{0x3FE2ECE6,0x2FABC4B9}} /* +5.9141835509e-01 */ ,
{{0xBFE492F3,0x21A51E4E}} /* -6.4293819972e-01 */
},
 /* polynomial 4 */
{
{{0xBFB9335E,0x5D594989}} /* -9.8440072813e-02 */ ,
{{0x3FF1A7B9,0x611A7B96}} /* +1.1034482759e+00 */ ,
{{0xBFE37B48,0x24872744}} /* -6.0879904875e-01 */ ,
{{0x3FDCA99C,0x29F8DE8E}} /* +4.4785217379e-01 */ ,
{{0xBFD7B881,0x3D37E454}} /* -3.7063628176e-01 */ ,
{{0x3FD4F08E,0x55D1F3A8}} /* +3.2718237286e-01 */ ,
{{0xBFD3413F,0x346E99D3}} /* -3.0085735436e-01 */ ,
{{0x3FD23625,0x15433E66}} /* +2.8455473973e-01 */ ,
{{0xBFD19561,0x9976A7ED}} /* -2.7474250781e-01 */ ,
{{0x3FD13F21,0x5935F4CB}} /* +2.6947816574e-01 */ ,
{{0xBFD120AC,0x8299A6A4}} /* -2.6761925463e-01 */ ,
{{0x3FD13CDB,0x325D4F09}} /* +2.6933936995e-01 */ ,
{{0xBFD1720B,0x858B6D5D}} /* -2.7258575479e-01 */
},
 /* polynomial 5 */
{
{{0x00000000,0x00000000}} /* +0.0000000000e-01 */ ,
{{0x3FF00000,0x00000000}} /* +1.0000000000e+00 */ ,
{{0xBFE00000,0x00000000}} /* -5.0000000000e-01 */ ,
{{0x3FD55555,0x55555582}} /* +3.3333333333e-01 */ ,
{{0xBFD00000,0x000000A9}} /* -2.5000000000e-01 */ ,
{{0x3FC99999,0x99958511}} /* +1.9999999999e-01 */ ,
{{0xBFC55555,0x554BF922}} /* -1.6666666665e-01 */ ,
{{0x3FC24924,0xA3AEF673}} /* +1.4285715096e-01 */ ,
{{0xBFC00000,0x1CE3E886}} /* -1.2500001345e-01 */ ,
{{0x3FBC7184,0x13CEB1B9}} /* +1.1110711559e-01 */ ,
{{0xBFB99941,0xE1BDC076}} /* -9.9994771588e-02 */ ,
{{0x3FB78146,0xBC144107}} /* +9.1816349905e-02 */ ,
{{0xBFB595CF,0x0AA58754}} /* -8.4317150211e-02 */
},
 /* polynomial 6 */
{
{{0x3FBE2707,0x6E2AF2E6}} /* +1.1778303566e-01 */ ,
{{0x3FEC71C7,0x1C71C71C}} /* +8.8888888889e-01 */ ,
{{0xBFD948B0,0xFCD6E9E0}} /* -3.9506172840e-01 */ ,
{{0x3FCDF756,0x80FEB690}} /* +2.3411065386e-01 */ ,
{{0xBFC3FA39,0xAB547A1A}} /* -1.5607376924e-01 */ ,
{{0x3FBC6990,0x98A29957}} /* +1.1098579146e-01 */ ,
{{0xBFB50BD3,0x6791851B}} /* -8.2211697374e-02 */ ,
{{0x3FB00902,0xA288F0A9}} /* +6.2637486154e-02 */ ,
{{0xBFA8F192,0x5F283335}} /* -4.8718046299e-02 */ ,
{{0x3FA3B540,0xE7508F6E}} /* +3.8492229687e-02 */ ,
{{0xBF9F8850,0xBFE2263F}} /* -3.0793439590e-02 */ ,
{{0x3F99B300,0x12EF8724}} /* +2.5096894413e-02 */ ,
{{0xBF94F85D,0x99AF0E14}} /* -2.0478689675e-02 */
},
 /* polynomial 7 */
{
{{0x3FCC8FF7,0xC79A9A22}} /* +2.2314355131e-01 */ ,
{{0x3FE99999,0x9999999A}} /* +8.0000000000e-01 */ ,
{{0xBFD47AE1,0x47AE147B}} /* -3.2000000000e-01 */ ,
{{0x3FC5D867,0xC3ECE2B2}} /* +1.7066666667e-01 */ ,
{{0xBFBA36E2,0xEB1C436A}} /* -1.0240000000e-01 */ ,
{{0x3FB0C6F7,0xA0B52722}} /* +6.5535999999e-02 */ ,
{{0xBFA65E9F,0x80EFFFCD}} /* -4.3690666665e-02 */ ,
{{0x3F9EADA7,0x96E552E6}} /* +2.9959314904e-02 */ ,
{{0xBF95798E,0xEF8F2073}} /* -2.0971520778e-02 */ ,
{{0x3F8E8A9C,0x71A5F85C}} /* +1.4912817210e-02 */ ,
{{0xBF85FD5B,0xDA92B978}} /* -1.0737149818e-02 */ ,
{{0x3F801A73,0xDB58E5DE}} /* +7.8629542651e-03 */ ,
{{0xBF77A54B,0x588CDC6F}} /* -5.7728713226e-03 */
},
 /* polynomial 8 */
{
{{0x3FD3D638,0x05AA02DB}} /* +3.0994988015e-01 */ ,
{{0x3FE778B2,0xD84B7B4A}} /* +7.3348371739e-01 */ ,
{{0xBFD13748,0x582A4354}} /* -2.6899918184e-01 */ ,
{{0x3FC0D63A,0x08B6E75D}} /* +1.3153767992e-01 */ ,
{{0xBFB28638,0xBDFF0D07}} /* -7.2360559831e-02 */ ,
{{0x3FA5BD59,0x0841B395}} /* +4.2460233934e-02 */ ,
{{0xBF9A937C,0x93FDD519}} /* -2.5953241856e-02 */ ,
{{0x3F90B55A,0xB37AD191}} /* +1.6316811757e-02 */ ,
{{0xBF857265,0xA500F702}} /* -1.0472101305e-02 */ ,
{{0x3F7BF747,0x97F62E2F}} /* +6.8276211381e-03 */ ,
{{0xBF727615,0x37BCA347}} /* -4.5071438615e-03 */ ,
{{0x3F68B6F6,0x340868F6}} /* +3.0169304521e-03 */ ,
{{0xBF60A0BF,0x5B164CA3}} /* -2.0297753733e-03 */
}
};

static const db_number Poly_l[8][2] =
{
 /* polynomial 1 */
{
{{0xBC531A78,0xC9731542}} /* -4.1423907624e-18 */ ,
{{0x3C6DA901,0xD7E733C1}} /* +1.2863054535e-17 */ ,

},
 /* polynomial 2 */
{
{{0xBC6F6650,0x792F85DD}} /* -1.3617434188e-17 */ ,
{{0xBC7EB9DF,0xF7DDA2CA}} /* -2.6650620715e-17 */ ,

},
 /* polynomial 3 */
{
{{0x3C21F5B3,0xE8EE7A2B}} /* +4.8680071630e-19 */ ,
{{0x3C92F660,0x2CEA2030}} /* +6.5789058301e-17 */ ,

},
 /* polynomial 4 */
{
{{0x3C5478A8,0x527726CF}} /* +4.4390095748e-18 */ ,
{{0x3C71A77F,0xA4B8A6F9}} /* +1.5312656901e-17 */ ,

},
 /* polynomial 5 */
{
{{0x00000000,0x00000000}} /* +0.0000000000e-01 */ ,
{{0xBC03E91A,0xAAF9039B}} /* -1.3491922402e-19 */ ,

},
 /* polynomial 6 */
{
{{0xBC3615B0,0xDBC40302}} /* -1.1972156066e-18 */ ,
{{0x3C8C55D6,0x047FA77E}} /* +4.9153904729e-17 */ ,

},
 /* polynomial 7 */
{
{{0xBC64F68B,0x97A41961}} /* -9.0912813346e-18 */ ,
{{0xBC89A0B0,0x9DE4BE41}} /* -4.4456964079e-17 */ ,

},
 /* polynomial 8 */
{
{{0xBC3B294D,0xE20C7AD0}} /* -1.4724194439e-18 */ ,
{{0xBC818759,0xCA7AB225}} /* -3.0407471421e-17 */ ,

}
};

#else
static const db_number ln2hi = {{0xFEFA3800,0x3FE62E42}} /* +6.9314718056e-01 */;
static const db_number ln2lo = {{0x93C76730,0x3D2EF357}} /* +5.4979230187e-14 */;
static const db_number two52 = {{0x00000000,0x43300000}} /* +4.5035996274e+15 */;
static const db_number middle[8] =
{
{{0x333F9DE3,0x3FE7504F}} /* +7.2855339059e-01 */ ,
{{0x00000000,0x3FE90000}} /* +7.8125000000e-01 */ ,
{{0x00000000,0x3FEB0000}} /* +8.4375000000e-01 */ ,
{{0x00000000,0x3FED0000}} /* +9.0625000000e-01 */ ,
{{0x00000000,0x3FF00000}} /* +1.0000000000e+00 */ ,
{{0x00000000,0x3FF20000}} /* +1.1250000000e+00 */ ,
{{0x00000000,0x3FF40000}} /* +1.2500000000e+00 */ ,
{{0x333F9DE9,0x3FF5D04F}} /* +1.3633567812e+00 */
};

static const db_number Poly_h[8][13] =
{
 /* polynomial 1 */
{
{{0x73F60B09,0xBFD444B8}} /* -3.1669436764e-01 */ ,
{{0x980C433A,0x3FF5F619}} /* +1.3725830020e+00 */ ,
{{0x824C9A57,0xBFEE24CC}} /* -9.4199204873e-01 */ ,
{{0x47881604,0x3FEB954C}} /* +8.6197484942e-01 */ ,
{{0xC58FCD22,0xBFEC6529}} /* -8.8734901987e-01 */ ,
{{0x1AC1D834,0x3FEF2E06}} /* +9.7436814524e-01 */ ,
{{0xF5D42E1A,0xBFF1D4FE}} /* -1.1145009616e+00 */ ,
{{0x67F441DC,0x3FF4FAB7}} /* +1.3112100659e+00 */ ,
{{0xEA47B471,0xBFF93248}} /* -1.5747765686e+00 */ ,
{{0x85276A57,0x3FFEBDCE}} /* +1.9213395311e+00 */ ,
{{0x0ABAD697,0xC002FCE1}} /* -2.3734761084e+00 */ ,
{{0x8C0B7AF7,0x4007BFE9}} /* +2.9687071744e+00 */ ,
{{0xF57FD2EC,0xC00DE4D4}} /* -3.7367343120e+00 */
},
 /* polynomial 2 */
{
{{0x6CB3B379,0xBFCF991C}} /* -2.4686007793e-01 */ ,
{{0x47AE147B,0x3FF47AE1}} /* +1.2800000000e+00 */ ,
{{0xEB1C432D,0xBFEA36E2}} /* -8.1920000000e-01 */ ,
{{0x80F29213,0x3FE65E9F}} /* +6.9905066667e-01 */ ,
{{0xE2308C3F,0xBFE5798E}} /* -6.7108864000e-01 */ ,
{{0xE1793910,0x3FE5FD7F}} /* +6.8719476736e-01 */ ,
{{0xAC3CC49E,0xBFE774CC}} /* -7.3300775185e-01 */ ,
{{0x779F31B6,0x3FE9BC1F}} /* +8.0421422351e-01 */ ,
{{0x9C89806A,0xBFECD2B2}} /* -9.0071993421e-01 */ ,
{{0xF663DD55,0x3FF065A0}} /* +1.0248117089e+00 */ ,
{{0x64D28253,0xBFF2E3A7}} /* -1.1805795611e+00 */ ,
{{0x162168A9,0x3FF613D4}} /* +1.3798409333e+00 */ ,
{{0x1E7E75E1,0xBFF9EC69}} /* -1.6202174369e+00 */
},
 /* polynomial 3 */
{
{{0x6B543DB2,0xBFC5BF40}} /* -1.6989903680e-01 */ ,
{{0xBDA12F68,0x3FF2F684}} /* +1.1851851852e+00 */ ,
{{0xE0BF08C7,0xBFE67980}} /* -7.0233196159e-01 */ ,
{{0x5F678885,0x3FE1C1FA}} /* +5.5492895731e-01 */ ,
{{0x1B62B9D2,0xBFDF91BD}} /* -4.9327018427e-01 */ ,
{{0x8242EF01,0x3FDDEEAF}} /* +4.6769321175e-01 */ ,
{{0xA36B029B,0xBFDD9015}} /* -4.6191922149e-01 */ ,
{{0x7F176341,0x3FDE0836}} /* +4.6925127422e-01 */ ,
{{0x26663631,0xBFDF24F6}} /* -4.8663095236e-01 */ ,
{{0x19D8F153,0x3FE067BA}} /* +5.1266198204e-01 */ ,
{{0xECA216B7,0xBFE17FB2}} /* -5.4683824747e-01 */ ,
{{0x2FABC4B9,0x3FE2ECE6}} /* +5.9141835509e-01 */ ,
{{0x21A51E4E,0xBFE492F3}} /* -6.4293819972e-01 */
},
 /* polynomial 4 */
{
{{0x5D594989,0xBFB9335E}} /* -9.8440072813e-02 */ ,
{{0x611A7B96,0x3FF1A7B9}} /* +1.1034482759e+00 */ ,
{{0x24872744,0xBFE37B48}} /* -6.0879904875e-01 */ ,
{{0x29F8DE8E,0x3FDCA99C}} /* +4.4785217379e-01 */ ,
{{0x3D37E454,0xBFD7B881}} /* -3.7063628176e-01 */ ,
{{0x55D1F3A8,0x3FD4F08E}} /* +3.2718237286e-01 */ ,
{{0x346E99D3,0xBFD3413F}} /* -3.0085735436e-01 */ ,
{{0x15433E66,0x3FD23625}} /* +2.8455473973e-01 */ ,
{{0x9976A7ED,0xBFD19561}} /* -2.7474250781e-01 */ ,
{{0x5935F4CB,0x3FD13F21}} /* +2.6947816574e-01 */ ,
{{0x8299A6A4,0xBFD120AC}} /* -2.6761925463e-01 */ ,
{{0x325D4F09,0x3FD13CDB}} /* +2.6933936995e-01 */ ,
{{0x858B6D5D,0xBFD1720B}} /* -2.7258575479e-01 */
},
 /* polynomial 5 */
{
{{0x00000000,0x00000000}} /* +0.0000000000e-01 */ ,
{{0x00000000,0x3FF00000}} /* +1.0000000000e+00 */ ,
{{0x00000000,0xBFE00000}} /* -5.0000000000e-01 */ ,
{{0x55555582,0x3FD55555}} /* +3.3333333333e-01 */ ,
{{0x000000A9,0xBFD00000}} /* -2.5000000000e-01 */ ,
{{0x99958511,0x3FC99999}} /* +1.9999999999e-01 */ ,
{{0x554BF922,0xBFC55555}} /* -1.6666666665e-01 */ ,
{{0xA3AEF673,0x3FC24924}} /* +1.4285715096e-01 */ ,
{{0x1CE3E886,0xBFC00000}} /* -1.2500001345e-01 */ ,
{{0x13CEB1B9,0x3FBC7184}} /* +1.1110711559e-01 */ ,
{{0xE1BDC076,0xBFB99941}} /* -9.9994771588e-02 */ ,
{{0xBC144107,0x3FB78146}} /* +9.1816349905e-02 */ ,
{{0x0AA58754,0xBFB595CF}} /* -8.4317150211e-02 */
},
 /* polynomial 6 */
{
{{0x6E2AF2E6,0x3FBE2707}} /* +1.1778303566e-01 */ ,
{{0x1C71C71C,0x3FEC71C7}} /* +8.8888888889e-01 */ ,
{{0xFCD6E9E0,0xBFD948B0}} /* -3.9506172840e-01 */ ,
{{0x80FEB690,0x3FCDF756}} /* +2.3411065386e-01 */ ,
{{0xAB547A1A,0xBFC3FA39}} /* -1.5607376924e-01 */ ,
{{0x98A29957,0x3FBC6990}} /* +1.1098579146e-01 */ ,
{{0x6791851B,0xBFB50BD3}} /* -8.2211697374e-02 */ ,
{{0xA288F0A9,0x3FB00902}} /* +6.2637486154e-02 */ ,
{{0x5F283335,0xBFA8F192}} /* -4.8718046299e-02 */ ,
{{0xE7508F6E,0x3FA3B540}} /* +3.8492229687e-02 */ ,
{{0xBFE2263F,0xBF9F8850}} /* -3.0793439590e-02 */ ,
{{0x12EF8724,0x3F99B300}} /* +2.5096894413e-02 */ ,
{{0x99AF0E14,0xBF94F85D}} /* -2.0478689675e-02 */
},
 /* polynomial 7 */
{
{{0xC79A9A22,0x3FCC8FF7}} /* +2.2314355131e-01 */ ,
{{0x9999999A,0x3FE99999}} /* +8.0000000000e-01 */ ,
{{0x47AE147B,0xBFD47AE1}} /* -3.2000000000e-01 */ ,
{{0xC3ECE2B2,0x3FC5D867}} /* +1.7066666667e-01 */ ,
{{0xEB1C436A,0xBFBA36E2}} /* -1.0240000000e-01 */ ,
{{0xA0B52722,0x3FB0C6F7}} /* +6.5535999999e-02 */ ,
{{0x80EFFFCD,0xBFA65E9F}} /* -4.3690666665e-02 */ ,
{{0x96E552E6,0x3F9EADA7}} /* +2.9959314904e-02 */ ,
{{0xEF8F2073,0xBF95798E}} /* -2.0971520778e-02 */ ,
{{0x71A5F85C,0x3F8E8A9C}} /* +1.4912817210e-02 */ ,
{{0xDA92B978,0xBF85FD5B}} /* -1.0737149818e-02 */ ,
{{0xDB58E5DE,0x3F801A73}} /* +7.8629542651e-03 */ ,
{{0x588CDC6F,0xBF77A54B}} /* -5.7728713226e-03 */
},
 /* polynomial 8 */
{
{{0x05AA02DB,0x3FD3D638}} /* +3.0994988015e-01 */ ,
{{0xD84B7B4A,0x3FE778B2}} /* +7.3348371739e-01 */ ,
{{0x582A4354,0xBFD13748}} /* -2.6899918184e-01 */ ,
{{0x08B6E75D,0x3FC0D63A}} /* +1.3153767992e-01 */ ,
{{0xBDFF0D07,0xBFB28638}} /* -7.2360559831e-02 */ ,
{{0x0841B395,0x3FA5BD59}} /* +4.2460233934e-02 */ ,
{{0x93FDD519,0xBF9A937C}} /* -2.5953241856e-02 */ ,
{{0xB37AD191,0x3F90B55A}} /* +1.6316811757e-02 */ ,
{{0xA500F702,0xBF857265}} /* -1.0472101305e-02 */ ,
{{0x97F62E2F,0x3F7BF747}} /* +6.8276211381e-03 */ ,
{{0x37BCA347,0xBF727615}} /* -4.5071438615e-03 */ ,
{{0x340868F6,0x3F68B6F6}} /* +3.0169304521e-03 */ ,
{{0x5B164CA3,0xBF60A0BF}} /* -2.0297753733e-03 */
}
};

static const db_number Poly_l[8][2] =
{
 /* polynomial 1 */
{
{{0xC9731542,0xBC531A78}} /* -4.1423907624e-18 */ ,
{{0xD7E733C1,0x3C6DA901}} /* +1.2863054535e-17 */ ,

},
 /* polynomial 2 */
{
{{0x792F85DD,0xBC6F6650}} /* -1.3617434188e-17 */ ,
{{0xF7DDA2CA,0xBC7EB9DF}} /* -2.6650620715e-17 */ ,

},
 /* polynomial 3 */
{
{{0xE8EE7A2B,0x3C21F5B3}} /* +4.8680071630e-19 */ ,
{{0x2CEA2030,0x3C92F660}} /* +6.5789058301e-17 */ ,

},
 /* polynomial 4 */
{
{{0x527726CF,0x3C5478A8}} /* +4.4390095748e-18 */ ,
{{0xA4B8A6F9,0x3C71A77F}} /* +1.5312656901e-17 */ ,

},
 /* polynomial 5 */
{
{{0x00000000,0x00000000}} /* +0.0000000000e-01 */ ,
{{0xAAF9039B,0xBC03E91A}} /* -1.3491922402e-19 */ ,

},
 /* polynomial 6 */
{
{{0xDBC40302,0xBC3615B0}} /* -1.1972156066e-18 */ ,
{{0x047FA77E,0x3C8C55D6}} /* +4.9153904729e-17 */ ,

},
 /* polynomial 7 */
{
{{0x97A41961,0xBC64F68B}} /* -9.0912813346e-18 */ ,
{{0x9DE4BE41,0xBC89A0B0}} /* -4.4456964079e-17 */ ,

},
 /* polynomial 8 */
{
{{0xE20C7AD0,0xBC3B294D}} /* -1.4724194439e-18 */ ,
{{0xCA7AB225,0xBC818759}} /* -3.0407471421e-17 */ ,

}
};

#endif



/*
 * Constant to compute the natural logarithm.
 *
 * Copyright (C) 2002 David Defour, Catherine Daramy, and Florent de Dinechin
 *
 * This file is part of scslib, the Software Carry-Save multiple-precision
 * library, which has been developed by the Arénaire project at École normale
 * supérieure de Lyon.
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

#ifdef WORDS_BIGENDIAN
static const scs_db_number 
  norm_number = {{0x3FD60000, 0x00000000}}; /* 11*2^(-5) */
#else
static const scs_db_number 
  norm_number = {{0x00000000, 0x3FD60000}}; /* 11*2^(-5) */
#endif

#ifdef SCS_TYPECPU_SPARC
static const scs 
   sc_ln2={{0x0162e42f, 0x01df473d, 0x01cd5e4f, 0x003b3980, 
	    0x007e5ed5, 0x01d03cd0, 0x0193394c, 0x00b62d8a},
	   DB_ONE,  -1,   1 }; 

static const scs table_ti[13]=
/* ~-3.746934e-01 */ 
{{{0x00bfd7d1, 0x01bd8151, 0x017dbcdf, 0x016d4cb1, 
0x0044bcca, 0x01f38987, 0x013333aa, 0x007cf0d4},
DB_ONE,  -1,  -1 } 
,
/* ~-2.876821e-01 */ 
{{0x00934b10, 0x01134db9, 0x004f077d, 0x00dd9db0, 
0x00554e15, 0x0030f490, 0x01b996a8, 0x00de6ad6},
DB_ONE,  -1,  -1 } 
,
/* ~-2.076394e-01 */ 
{{0x006a4fb4, 0x01e456cf, 0x0036f2be, 0x014ef4b9, 
0x00037337, 0x0077188a, 0x01f1e9e8, 0x016e7b9f},
DB_ONE,  -1,  -1 } 
,
/* ~-1.335314e-01 */ 
{{0x00445e3a, 0x00113f23, 0x01bde338, 0x01683f8e, 
0x00b7a078, 0x01dda8fe, 0x01878496, 0x01e28def},
DB_ONE,  -1,  -1 } 
,
/* ~-6.453852e-02 */ 
{{0x00210b31, 0x00d678e8, 0x0034451f, 0x01d9bf50, 
0x0066e582, 0x00bf1b16, 0x007f8dd1, 0x011cb965},
DB_ONE,  -1,  -1 } 
,
/* ~6.062462e-02 */ 
{{0x001f0a30, 0x018022c5, 0x009985f3, 0x004b8b77, 
0x00b32f13, 0x0034d1d3, 0x0099bada, 0x01259671},
DB_ONE,  -1,   1 } 
,
/* ~1.177830e-01 */ 
{{0x003c4e0e, 0x01b8abcb, 0x012f4f54, 0x007ffe1f, 
0x01d3c2ab, 0x016e53af, 0x00200bfb, 0x00f957dd},
DB_ONE,  -1,   1 } 
,
/* ~1.718503e-01 */ 
{{0x0057fcc1, 0x01853c9e, 0x013c873e, 0x004140e4, 
0x0048eebf, 0x0135571c, 0x01aafef9, 0x01e631c0},
DB_ONE,  -1,   1 } 
,
/* ~2.231436e-01 */ 
{{0x00723fdf, 0x003cd4d1, 0x001ac25d, 0x0103de5f, 
0x01ee6892, 0x0171d97a, 0x013a08d6, 0x01c1b170},
DB_ONE,  -1,   1 } 
,
/* ~2.719337e-01 */ 
{{0x008b3ae5, 0x00baba60, 0x01c07398, 0x01f55c41, 
0x01717047, 0x01c19f41, 0x00521e0c, 0x01f534c3},
DB_ONE,  -1,   1 } 
,
/* ~3.184537e-01 */ 
{{0x00a30c5e, 0x0021c5ec, 0x004fa16f, 0x00cdeccf, 
0x0039a20a, 0x01dcb349, 0x006005a2, 0x00393cb5},
DB_ONE,  -1,   1 } 
,
/* ~3.629055e-01 */ 
{{0x00b9cebf, 0x016bbd00, 0x00d39c49, 0x0114feb4, 
0x01f7bcb5, 0x00b77843, 0x00e752cb, 0x0157bbbc},
DB_ONE,  -1,   1 } 
};

static const scs table_inv_wi[13]=
/* ~1.454545e+00 */ 
{{{0x00000001, 0x00e8ba2e, 0x011745d1, 0x00e8ba2e, 
0x011745d1, 0x00e8ba2e, 0x011745d1, 0x00e8ba2e},
DB_ONE,   0,   1 } 
,
/* ~1.333333e+00 */ 
{{0x00000001, 0x00aaaaaa, 0x01555555, 0x00aaaaaa, 
0x01555555, 0x00aaaaaa, 0x01555555, 0x00aaaaaa},
DB_ONE,   0,   1 } 
,
/* ~1.230769e+00 */ 
{{0x00000001, 0x00762762, 0x00ec4ec4, 0x01d89d89, 
0x01b13b13, 0x01627627, 0x00c4ec4e, 0x0189d89d},
DB_ONE,   0,   1 } 
,
/* ~1.142857e+00 */ 
{{0x00000001, 0x00492492, 0x00924924, 0x01249249, 
0x00492492, 0x00924924, 0x01249249, 0x00492492},
DB_ONE,   0,   1 } 
,
/* ~1.066667e+00 */ 
{{0x00000001, 0x00222222, 0x00444444, 0x00888888, 
0x01111111, 0x00222222, 0x00444444, 0x00888888},
DB_ONE,   0,   1 } 
,
/* ~1.000000e+00 */ 
{{0x00000001, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000},
DB_ONE,   0,   1 } 
,
/* ~9.411765e-01 */ 
{{0x01e1e1e1, 0x01c3c3c3, 0x01878787, 0x010f0f0f, 
0x001e1e1e, 0x003c3c3c, 0x00787878, 0x00f0f0f0},
DB_ONE,  -1,   1 } 
,
/* ~8.888889e-01 */ 
{{0x01c71c71, 0x018e38e3, 0x011c71c7, 0x0038e38e, 
0x0071c71c, 0x00e38e38, 0x01c71c71, 0x018e38e3},
DB_ONE,  -1,   1 } 
,
/* ~8.421053e-01 */ 
{{0x01af286b, 0x019435e5, 0x001af286, 0x0179435e, 
0x00a1af28, 0x00d79435, 0x01ca1af2, 0x010d7943},
DB_ONE,  -1,   1 } 
,
/* ~8.000000e-01 */ 
{{0x01999999, 0x01333333, 0x00666666, 0x00cccccc, 
0x01999999, 0x01333333, 0x00666666, 0x00cccccc},
DB_ONE,  -1,   1 } 
,
/* ~7.619048e-01 */ 
{{0x01861861, 0x010c30c3, 0x00186186, 0x0030c30c, 
0x00618618, 0x00c30c30, 0x01861861, 0x010c30c3},
DB_ONE,  -1,   1 } 
,
/* ~7.272727e-01 */ 
{{0x01745d17, 0x008ba2e8, 0x01745d17, 0x008ba2e8, 
0x01745d17, 0x008ba2e8, 0x01745d17, 0x008ba2e8},
DB_ONE,  -1,   1 } 
,
/* ~6.956522e-01 */ 
{{0x01642c85, 0x0121642c, 0x010b2164, 0x00590b21, 
0x00c8590b, 0x0042c859, 0x001642c8, 0x00b21642},
DB_ONE,  -1,   1 } 
};

static const scs constant_poly[20]=
/* ~-5.023367e-02 */ 
{{{0x0019b83a, 0x00b9d6ab, 0x002e59e9, 0x00a24f80, 
0x0027986a, 0x007928b4, 0x005ddb72, 0x00619d7f},
DB_ONE,  -1,  -1 } 
,
/* ~5.286469e-02 */ 
{{0x001b1114, 0x01894bfd, 0x012e0600, 0x005542f4, 
0x00af2119, 0x00f848c9, 0x00ffffb2, 0x00e80ead},
DB_ONE,  -1,   1 } 
,
/* ~-5.555504e-02 */ 
{{0x001c71b5, 0x01bc1996, 0x014e2328, 0x00d31ffd, 
0x01d9197b, 0x01dd617b, 0x008f49f5, 0x0114fa8f},
DB_ONE,  -1,  -1 } 
,
/* ~5.882305e-02 */ 
{{0x001e1e0d, 0x01be311c, 0x01d73257, 0x00706242, 
0x016f89de, 0x01a8eccc, 0x01f56b8f, 0x0007fe91},
DB_ONE,  -1,   1 } 
,
/* ~-6.250000e-02 */ 
{{0x00200000, 0x000adcae, 0x0185071e, 0x017bf346, 
0x00ca1252, 0x0061b6b6, 0x013f5139, 0x01ca868c},
DB_ONE,  -1,  -1 } 
,
/* ~6.666667e-02 */ 
{{0x00222222, 0x004dd3cc, 0x01922a63, 0x00f3c5d7, 
0x01a47f93, 0x00ff9671, 0x00e00ecb, 0x00bd3330},
DB_ONE,  -1,   1 } 
,
/* ~-7.142857e-02 */ 
{{0x00249249, 0x00492279, 0x00db5116, 0x00671689, 
0x006a3376, 0x003f35c0, 0x00661341, 0x002815e5},
DB_ONE,  -1,  -1 } 
,
/* ~7.692308e-02 */ 
{{0x00276276, 0x004ec339, 0x005ea9a2, 0x01011824, 
0x0075bd24, 0x003cc34f, 0x01c99f69, 0x0129e78c},
DB_ONE,  -1,   1 } 
,
/* ~-8.333333e-02 */ 
{{0x002aaaaa, 0x01555555, 0x012d8c96, 0x010abd3b, 
0x018f2c29, 0x0196754b, 0x019ec134, 0x00768c4d},
DB_ONE,  -1,  -1 } 
,
/* ~9.090909e-02 */ 
{{0x002e8ba2, 0x01d1745d, 0x008e49f5, 0x01341475, 
0x0081f0c0, 0x014f2ec1, 0x01dd9fe2, 0x01f38d59},
DB_ONE,  -1,   1 } 
,
/* ~-1.000000e-01 */ 
{{0x00333333, 0x00666666, 0x00ccc2cc, 0x01fb84f5, 
0x01eebd5a, 0x013af37f, 0x012bc6d5, 0x004c47a1},
DB_ONE,  -1,  -1 } 
,
/* ~1.111111e-01 */ 
{{0x0038e38e, 0x0071c71c, 0x00e387cf, 0x00be22fc, 
0x014bae85, 0x01b43f38, 0x002876db, 0x010a8b36},
DB_ONE,  -1,   1 } 
,
/* ~-1.250000e-01 */ 
{{0x00400000, 0x00000000, 0x00000000, 0x00eb1b6c, 
0x00227096, 0x01596ab4, 0x00492bc3, 0x018163ed},
DB_ONE,  -1,  -1 } 
,
/* ~1.428571e-01 */ 
{{0x00492492, 0x00924924, 0x01249249, 0x00c76cd0, 
0x00055827, 0x00afd708, 0x015a6f90, 0x01d11663},
DB_ONE,  -1,   1 } 
,
/* ~-1.666667e-01 */ 
{{0x00555555, 0x00aaaaaa, 0x01555555, 0x00aaa4bb, 
0x00cc61d7, 0x0044a5cf, 0x01cf9970, 0x004415cc},
DB_ONE,  -1,  -1 } 
,
/* ~2.000000e-01 */ 
{{0x00666666, 0x00cccccc, 0x01999999, 0x013330bb, 
0x017cdd12, 0x013269ea, 0x00761531, 0x010437bf},
DB_ONE,  -1,   1 } 
,
/* ~-2.500000e-01 */ 
{{0x00800000, 0x00000000, 0x00000000, 0x00000000, 
0x00232b9b, 0x0054cd5a, 0x00b651a3, 0x011d0f4b},
DB_ONE,  -1,  -1 } 
,
/* ~3.333333e-01 */ 
{{0x00aaaaaa, 0x01555555, 0x00aaaaaa, 0x01555555, 
0x00b43c17, 0x00b2094a, 0x003eef44, 0x0118c38a},
DB_ONE,  -1,   1 } 
,
/* ~-5.000000e-01 */ 
{{0x00ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 
0x01ffffe1, 0x009bd81b, 0x01b07b1e, 0x01fa34a2},
DB_ONE,  -1,  -1 } 
,
/* ~1.000000e+00 */ 
{{0x01ffffff, 0x01ffffff, 0x01ffffff, 0x01ffffff, 
0x01fffffc, 0x01e04b7e, 0x00472719, 0x0176878b},
DB_ONE,  -1,   1 } 
};


#else

static const scs 
   sc_ln2={{0x2c5c85fd, 0x3d1cf79a, 0x2f278ece, 0x1803f2f6, 
	     0x2bd03cd0, 0x3267298b, 0x18b62834, 0x175b8baa},
	    DB_ONE,  -1,   1 };

static const scs table_ti[13]=
/* ~-3.746934e-01 */ 
{{{0x17fafa3b, 0x360546fb, 0x1e6fdb53, 0x0b1225e6, 
0x15f38987, 0x26664702, 0x3cb1bf6d, 0x118a64f9},
DB_ONE,  -1,  -1 } 
,
/* ~-2.876821e-01 */ 
{{0x12696211, 0x0d36e49e, 0x03beb767, 0x1b02aa70, 
0x2a30f490, 0x3732bb37, 0x2425c6da, 0x1fc53d0e},
DB_ONE,  -1,  -1 } 
,
/* ~-2.076394e-01 */ 
{{0x0d49f69e, 0x115b3c6d, 0x395f53bd, 0x0b901b99, 
0x2e77188a, 0x3e3d1ab5, 0x1147dede, 0x05483ae4},
DB_ONE,  -1,  -1 } 
,
/* ~-1.335314e-01 */ 
{{0x088bc741, 0x04fc8f7b, 0x319c5a0f, 0x38e5bd03, 
0x31dda8fe, 0x30f08645, 0x2fa1d5c5, 0x02c6529d},
DB_ONE,  -1,  -1 } 
,
/* ~-6.453852e-02 */ 
{{0x0421662d, 0x19e3a068, 0x228ff66f, 0x3503372c, 
0x04bf1b16, 0x0ff1b85c, 0x006c21b2, 0x21a9efd6},
DB_ONE,  -1,  -1 } 
,
/* ZERO         */
{{0x00000000, 0x00000000, 0x00000000, 0x00000000,
0x00000000, 0x00000000, 0x00000000, 0x00000000},
{{0, 0}},  0,   1 }
,
/* ~6.062462e-02 */ 
{{0x03e14618, 0x008b1533, 0x02f992e2, 0x37759978, 
0x2634d1d3, 0x13375edb, 0x2e4634ea, 0x1dcf0aef},
DB_ONE,  -1,   1 } 
,
/* ~1.177830e-01 */ 
{{0x0789c1db, 0x22af2e5e, 0x27aa1fff, 0x21fe9e15, 
0x176e53af, 0x04015c6b, 0x021a0541, 0x006df1d7},
DB_ONE,  -1,   1 } 
,
/* ~1.718503e-01 */ 
{{0x0aff9838, 0x14f27a79, 0x039f1050, 0x0e424775, 
0x3f35571c, 0x355ff008, 0x1ca13efc, 0x3c2c8490},
DB_ONE,  -1,   1 } 
,
/* ~2.231436e-01 */ 
{{0x0e47fbe3, 0x33534435, 0x212ec0f7, 0x25ff7344, 
0x2571d97a, 0x274129e2, 0x12b111db, 0x2c051568},
DB_ONE,  -1,   1 } 
,
/* ~2.719337e-01 */ 
{{0x11675cab, 0x2ae98380, 0x39cc7d57, 0x041b8b82, 
0x0fc19f41, 0x0a43c91d, 0x1523ef69, 0x164b69f6},
DB_ONE,  -1,   1 } 
,
/* ~3.184537e-01 */ 
{{0x14618bc2, 0x0717b09f, 0x10b7b37b, 0x0cf1cd10, 
0x15dcb349, 0x0c00c397, 0x2c39cc9b, 0x274c94a8},
DB_ONE,  -1,   1 } 
,
{{0x1739d7f6, 0x2ef401a7, 0x0e24c53f, 0x2b4fbde5, 
0x2ab77843, 0x1cea5975, 0x1eeef249, 0x384d2344},
DB_ONE,  -1,   1 } 
};

static const scs table_inv_wi[13]=
/* ~1.454545e+00 */ 
{{{0x00000001, 0x1d1745d1, 0x1d1745d1, 0x1d1745d1, 
0x1d1745d1, 0x1d1745d1, 0x1d183e2a, 0x36835582},
DB_ONE,   0,   1 } 
,
/* ~1.333333e+00 */ 
{{0x00000001, 0x15555555, 0x15555555, 0x15555555, 
0x15555555, 0x15555555, 0x15549b7e, 0x1a416c6b},
DB_ONE,   0,   1 } 
,
/* ~1.230769e+00 */ 
{{0x00000001, 0x0ec4ec4e, 0x313b13b1, 0x0ec4ec4e, 
0x313b13b1, 0x0ec4ec4e, 0x313a6825, 0x3ab28b77},
DB_ONE,   0,   1 } 
,
/* ~1.142857e+00 */ 
{{0x00000001, 0x09249249, 0x09249249, 0x09249249, 
0x09249249, 0x09249249, 0x09238b74, 0x26f620a6},
DB_ONE,   0,   1 } 
,
/* ~1.066667e+00 */ 
{{0x00000001, 0x04444444, 0x11111111, 0x04444444, 
0x11111111, 0x04444444, 0x1111d60e, 0x1f0c9d58},
DB_ONE,   0,   1 } 
,
/* ~1.000000e+00 */ 
{{0x00000001, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000},
DB_ONE,   0,   1 } 
,
/* ~9.411765e-01 */ 
{{0x3c3c3c3c, 0x0f0f0f0f, 0x03c3c3c3, 0x30f0f0f0, 
0x3c3c3c3c, 0x0f0f923d, 0x16e0e0a4, 0x3a84202f},
DB_ONE,  -1,   1 } 
,
/* ~8.888889e-01 */ 
{{0x38e38e38, 0x38e38e38, 0x38e38e38, 0x38e38e38, 
0x38e38e38, 0x38e3946a, 0x2e0ee2c9, 0x0d6e0fbd},
DB_ONE,  -1,   1 } 
,
/* ~8.421053e-01 */ 
{{0x35e50d79, 0x10d79435, 0x39435e50, 0x35e50d79, 
0x10d79435, 0x3943324d, 0x0637ea85, 0x131a67ba},
DB_ONE,  -1,   1 } 
,
/* ~8.000000e-01 */ 
{{0x33333333, 0x0ccccccc, 0x33333333, 0x0ccccccc, 
0x33333333, 0x0ccccccc, 0x33333333, 0x0ccccccc},
DB_ONE,  -1,   1 } 
,
/* ~7.619048e-01 */ 
{{0x30c30c30, 0x30c30c30, 0x30c30c30, 0x30c30c30, 
0x30c30c30, 0x30c2f1a4, 0x160958a1, 0x2b03bc88},
DB_ONE,  -1,   1 } 
,
/* ~7.272727e-01 */ 
{{0x2e8ba2e8, 0x2e8ba2e8, 0x2e8ba2e8, 0x2e8ba2e8, 
0x2e8ba2e8, 0x2e8bcb74, 0x2d78b525, 0x00a1db67},
DB_ONE,  -1,   1 } 
,
/* ~6.956522e-01 */ 
{{0x2c8590b2, 0x0590b216, 0x10b21642, 0x321642c8, 
0x1642c859, 0x02c8590b, 0x08590b21, 0x190b2164},
DB_ONE,  -1,   1 } 
};



static const scs constant_poly[20]=
/*0 ~-5.023367e-02 */ 
{{{0x0337074b, 0x275aac5c, 0x2cf4a893, 0x38013cc3, 
0x149a3416, 0x0e067307, 0x12745608, 0x1658e0d5},
DB_ONE,  -1,  -1 } 
,
/*1 ~5.286469e-02 */ 
{{0x03622298, 0x252ff65c, 0x03001550, 0x2f457908, 
0x32f78ecc, 0x17442a4e, 0x1d806366, 0x2c50350e},
DB_ONE,  -1,   1 } 
,
/*2 ~-5.555504e-02 */ 
{{0x038e36bb, 0x30665a9c, 0x119434c7, 0x3fdec8cb, 
0x37dd3adb, 0x2663cd45, 0x230e43e9, 0x32b9663c},
DB_ONE,  -1,  -1 } 
,
/*3 ~5.882305e-02 */ 
{{0x03c3c1bb, 0x38c473ae, 0x192b9c18, 0x242b7c4e, 
0x3da8edc8, 0x04454ffe, 0x2cf133c6, 0x0c926fd0},
DB_ONE,  -1,   1 } 
,
/*4 ~-6.250000e-02 */ 
{{0x04000000, 0x2b72bb0a, 0x038f5efc, 0x34665092, 
0x2461b6c9, 0x172f7050, 0x1218b5c1, 0x104862d7},
DB_ONE,  -1,  -1 } 
,
/*5 ~6.666667e-02 */ 
{{0x04444444, 0x374f3324, 0x1531bcf1, 0x1d7d23fc, 
0x26ff9670, 0x38fc33ae, 0x15bf1cfb, 0x2c9f1c2d},
DB_ONE,  -1,   1 } 
,
/*6 ~-7.142857e-02 */ 
{{0x04924924, 0x2489e5b6, 0x288b19c5, 0x2893519b, 
0x2c3f35c0, 0x0b8bfdce, 0x3541ab49, 0x1de415bc},
DB_ONE,  -1,  -1 } 
,
/*7 ~7.692308e-02 */ 
{{0x04ec4ec4, 0x3b0ce4bd, 0x14d14046, 0x0243ade9, 
0x083cc34f, 0x393e6a5a, 0x2c1855f2, 0x259d599f},
DB_ONE,  -1,   1 } 
,
/*8 ~-8.333333e-02 */ 
{{0x05555555, 0x1555565b, 0x064b42af, 0x13bc7961, 
0x1396754b, 0x33d85415, 0x2ba548d4, 0x039c4ff6},
DB_ONE,  -1,  -1 } 
,
/*9 ~9.090909e-02 */ 
{{0x05d1745d, 0x05d1751c, 0x24facd05, 0x07540f86, 
0x014f2ec1, 0x3bb3fa8b, 0x02e1da4c, 0x3304817c},
DB_ONE,  -1,   1 } 
,
/*10 ~-1.000000e-01 */ 
{{0x06666666, 0x19999999, 0x21667ee1, 0x0f5f75ea, 
0x353af37f, 0x2578daa1, 0x07c76f47, 0x16541534},
DB_ONE,  -1,  -1 } 
,
/*11 ~1.111111e-01 */ 
{{0x071c71c7, 0x071c71c7, 0x03e7af88, 0x2fca5d74, 
0x0bb43f38, 0x050edb70, 0x3631b696, 0x1fc3e0d3},
DB_ONE,  -1,   1 } 
,
/*12 ~-1.250000e-01 */ 
{{0x08000000, 0x00000000, 0x00003ac6, 0x36c11384, 
0x2d596ab4, 0x09257878, 0x0597dc26, 0x2d60813a},
DB_ONE,  -1,  -1 } 
,
/*13 ~1.428571e-01 */ 
{{0x09249249, 0x09249249, 0x0924b1db, 0x0d002ac1, 
0x0eafd708, 0x2b4df21d, 0x0458da93, 0x2d11460c},
DB_ONE,  -1,   1 } 
,
/*14 ~-1.666667e-01 */ 
{{0x0aaaaaaa, 0x2aaaaaaa, 0x2aaaaaa9, 0x0bb6630e, 
0x2e44a5cf, 0x39f32e04, 0x105732b9, 0x01a76208},
DB_ONE,  -1,  -1 } 
,
/*15 ~2.000000e-01 */ 
{{0x0ccccccc, 0x33333333, 0x0ccccccc, 0x0bbbe6e8, 
0x253269ea, 0x0ec2a630, 0x10defc5c, 0x238aef3b},
DB_ONE,  -1,   1 } 
,
/*16 ~-2.500000e-01 */ 
{{0x10000000, 0x00000000, 0x00000000, 0x0001195c, 
0x3654cd5a, 0x16ca3471, 0x343d2da0, 0x235273f2},
DB_ONE,  -1,  -1 } 
,
/*17 ~3.333333e-01 */ 
{{0x15555555, 0x15555555, 0x15555555, 0x1555a1e0, 
0x2eb2094a, 0x07dde891, 0x230e2bfa, 0x28aae6ab},
DB_ONE,  -1,   1 } 
,
/*18 ~-5.000000e-01 */ 
{{0x1fffffff, 0x3fffffff, 0x3fffffff, 0x3fffffff, 
0x029bd81b, 0x360f63df, 0x28d28bd3, 0x3c15f394},
DB_ONE,  -1,  -1 } 
,
/*19 ~1.000000e+00 */ 
{{0x3fffffff, 0x3fffffff, 0x3fffffff, 0x3fffffff, 
0x39e04b7e, 0x08e4e337, 0x1a1e2ed3, 0x23e85705},
DB_ONE,  -1,   1 } 
};
#endif



#define sc_ln2_ptr        (scs_ptr)(&sc_ln2)
#define constant_poly_ptr (scs_ptr)&constant_poly
#define table_ti_ptr      (scs_ptr)&table_ti
#define table_inv_wi_ptr  (scs_ptr)&table_inv_wi
 

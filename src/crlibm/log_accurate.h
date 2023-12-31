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
/*
 * Constant to compute the natural logarithm. 
 */

#ifdef WORDS_BIGENDIAN
static const db_number 
  norm_number = {{0x3FD60000, 0x00000000}}; /* 11*2^(-5) */
#else
static const db_number 
  norm_number = {{0x00000000, 0x3FD60000}}; /* 11*2^(-5) */
#endif

#define SQRT_2 1.4142135623730950489e0 

static const scs 
   sc_ln2={{0x2c5c85fd, 0x3d1cf79a, 0x2f278ece, 0x1803f2f6, 
	     0x2bd03cd0, 0x3267298b, 0x18b62834, 0x175b8baa},
	    DB_ONE,  -1,   1 };
#define sc_ln2_ptr (scs_ptr)(&sc_ln2)


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
#define table_ti_ptr      (scs_ptr)&table_ti

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
#define table_inv_wi_ptr  (scs_ptr)&table_inv_wi


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
#define constant_poly_ptr (scs_ptr)&constant_poly

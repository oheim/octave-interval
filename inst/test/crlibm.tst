## Copyright 2016-2017 Oliver Heimlich
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

%!shared testdata
%! testdata = load (file_in_loadpath ("test/crlibm.mat"));;

%!function verify (fname, rnd, data)
%!  assert (crlibm_function (fname, rnd, data.input), data.output);
%!endfunction

%!test verify ("acos", -inf, testdata.acos_rd);
%!test verify ("acos", +inf, testdata.acos_ru);
%!test verify ("acos",  0.5, testdata.acos_rn);
%!test verify ("acos",  0,   testdata.acos_rz);

%!test verify ("asin", -inf, testdata.asin_rd);
%!test verify ("asin", +inf, testdata.asin_ru);
%!test verify ("asin",  0.5, testdata.asin_rn);
%!test verify ("asin",  0,   testdata.asin_rz);

%!test verify ("atan", -inf, testdata.atan_rd);
%!test verify ("atan", +inf, testdata.atan_ru);
%!test verify ("atan",  0.5, testdata.atan_rn);
%!test verify ("atan",  0,   testdata.atan_rz);

%!test verify ("cos", -inf, testdata.cos_rd);
%!test verify ("cos", +inf, testdata.cos_ru);
%!test verify ("cos",  0.5, testdata.cos_rn);
%!test verify ("cos",  0,   testdata.cos_rz);

%!test verify ("cosh", -inf, testdata.cosh_rd);
%!test verify ("cosh", +inf, testdata.cosh_ru);
%!test verify ("cosh",  0.5, testdata.cosh_rn);
%!test verify ("cosh",  0,   testdata.cosh_rz);

%!test verify ("exp", -inf, testdata.exp_rd);
%!test verify ("exp", +inf, testdata.exp_ru);
%!test verify ("exp",  0.5, testdata.exp_rn);
%!test verify ("exp",  0,   testdata.exp_rz);

%!test verify ("expm1", -inf, testdata.expm1_rd);
%!test verify ("expm1", +inf, testdata.expm1_ru);
%!test verify ("expm1",  0.5, testdata.expm1_rn);
%!test verify ("expm1",  0,   testdata.expm1_rz);

%!test verify ("log", -inf, testdata.log_rd);
%!test verify ("log", +inf, testdata.log_ru);
%!test verify ("log",  0.5, testdata.log_rn);
%!test verify ("log",  0,   testdata.log_rz);

%!test verify ("log10", -inf, testdata.log10_rd);
%!test verify ("log10", +inf, testdata.log10_ru);
%!test verify ("log10",  0.5, testdata.log10_rn);
%!test verify ("log10",  0,   testdata.log10_rz);

%!test verify ("log1p", -inf, testdata.log1p_rd);
%!test verify ("log1p", +inf, testdata.log1p_ru);
%!test verify ("log1p",  0.5, testdata.log1p_rn);
%!test verify ("log1p",  0,   testdata.log1p_rz);

%!test verify ("log2", -inf, testdata.log2_rd);
%!test verify ("log2", +inf, testdata.log2_ru);
%!test verify ("log2",  0.5, testdata.log2_rn);
%!test verify ("log2",  0,   testdata.log2_rz);

%!test verify ("sin", -inf, testdata.sin_rd);
%!test verify ("sin", +inf, testdata.sin_ru);
%!test verify ("sin",  0.5, testdata.sin_rn);
%!test verify ("sin",  0,   testdata.sin_rz);

%!test verify ("sinh", -inf, testdata.sinh_rd);
%!test verify ("sinh", +inf, testdata.sinh_ru);
%!test verify ("sinh",  0.5, testdata.sinh_rn);
%!test verify ("sinh",  0,   testdata.sinh_rz);

%!test verify ("tan", -inf, testdata.tan_rd);
%!test verify ("tan", +inf, testdata.tan_ru);
%!test verify ("tan",  0.5, testdata.tan_rn);
%!test verify ("tan",  0,   testdata.tan_rz);

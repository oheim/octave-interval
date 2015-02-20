##
## Copyright 2013 - 2015 Marco Nehmeier (nehmeier@informatik.uni-wuerzburg.de)
## Copyright 2015 Oliver Heimlich (oheim@posteo.de)
## 
## Original author: Marco Nehmeier (unit tests in libieeep1788)
## Converted into portable ITL format by Oliver Heimlich with minor corrections.
## 
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
## 
##     http://www.apache.org/licenses/LICENSE-2.0
## 
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
%! ## Test library imports
%!function s = to_string (x)
%!    if (isnumeric (x))
%!        s = num2str (x);
%!    elseif (isa (x, 'infsup'))
%!        s = intervaltotext (x);
%!    else
%!        # x probably is a char.
%!        s = x;
%!    endif
%!endfunction
%
%!function n = decval (dec)
%! n = find (strcmp (dec, {"ill", "trv", "def", "dac", "com"}));
%!endfunction

%!test "minimal_isCommonInterval_test";
%! assert (all (eq (...
%!    iscommoninterval (infsup (-27.0, -27.0)), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (-27.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (0.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (-0.0, -0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (-0.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (0.0, -0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (5.0, 12.4)), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsup ("-0x1.FFFFFFFFFFFFFp1023", "0x1.FFFFFFFFFFFFFp1023")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (-inf, inf)), ...
%!    false)))
%! assert (all (eq (...
%!    iscommoninterval (infsup ()), ...
%!    false)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (-inf, 0.0)), ...
%!    false)))
%! assert (all (eq (...
%!    iscommoninterval (infsup (0.0, inf)), ...
%!    false)))

%!test "minimal_isCommonInterval_dec_test";
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-27.0, -27.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-27.0, 0.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (0.0, 0.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-0.0, -0.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-0.0, 0.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (0.0, -0.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (5.0, 12.4, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec ("-0x1.FFFFFFFFFFFFFp1023", "0x1.FFFFFFFFFFFFFp1023", "com")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-27.0, -27.0, "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-27.0, 0.0, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (0.0, 0.0, "dac")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-0.0, -0.0, "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-0.0, 0.0, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (0.0, -0.0, "dac")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (5.0, 12.4, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec ("-0x1.FFFFFFFFFFFFFp1023", "0x1.FFFFFFFFFFFFFp1023", "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (entire, "dac")), ...
%!    false)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (-inf, 0.0, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    iscommoninterval (infsupdec (0.0, inf, "def")), ...
%!    false)))

%!test "minimal_isSingleton_test";
%! assert (all (eq (...
%!    issingleton (infsup (-27.0, -27.0)), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsup (-2.0, -2.0)), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsup (12.0, 12.0)), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsup (17.1, 17.1)), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsup (-0.0, -0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsup (0.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsup (-0.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsup (0.0, -0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsup ()), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsup (-inf, inf)), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsup (-1.0, 0.0)), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsup (-1.0, -0.5)), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsup (1.0, 2.0)), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsup (-inf, "-0x1.FFFFFFFFFFFFFp1023")), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsup (-1.0, inf)), ...
%!    false)))

%!test "minimal_isSingleton_dec_test";
%! assert (all (eq (...
%!    issingleton (infsupdec (-27.0, -27.0, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsupdec (-2.0, -2.0, "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsupdec (12.0, 12.0, "dac")), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsupdec (17.1, 17.1, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsupdec (-0.0, -0.0, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsupdec (0.0, 0.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsupdec (-0.0, 0.0, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsupdec (0.0, -0.0, "dac")), ...
%!    true)))
%! assert (all (eq (...
%!    issingleton (infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsupdec (entire, "def")), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsupdec (-1.0, 0.0, "dac")), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsupdec (-1.0, -0.5, "com")), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsupdec (1.0, 2.0, "def")), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsupdec (-inf, "-0x1.FFFFFFFFFFFFFp1023", "dac")), ...
%!    false)))
%! assert (all (eq (...
%!    issingleton (infsupdec (-1.0, inf, "trv")), ...
%!    false)))

%!test "minimal_isMember_test";
%! assert (all (eq (...
%!    ismember (-27.0, infsup (-27.0, -27.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (-27.0, infsup (-27.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (-7.0, infsup (-27.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsup (-27.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (-0.0, infsup (0.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsup (0.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsup (-0.0, -0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsup (-0.0, 0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsup (0.0, -0.0)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (5.0, infsup (5.0, 12.4)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (6.3, infsup (5.0, 12.4)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (12.4, infsup (5.0, 12.4)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsup (-inf, inf)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (5.0, infsup (-inf, inf)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (6.3, infsup (-inf, inf)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (12.4, infsup (-inf, inf)), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (-71.0, infsup (-27.0, 0.0)), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (0.1, infsup (-27.0, 0.0)), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-0.01, infsup (0.0, 0.0)), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (0.000001, infsup (0.0, 0.0)), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (111110.0, infsup (-0.0, -0.0)), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (4.9, infsup (5.0, 12.4)), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-6.3, infsup (5.0, 12.4)), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (0.0, infsup ()), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-4535.3, infsup ()), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-inf, infsup ()), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (inf, infsup ()), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-inf, infsup (-inf, inf)), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (inf, infsup (-inf, inf)), ...
%!    false)))

%!test "minimal_isMember_dec_test";
%! assert (all (eq (...
%!    ismember (-27.0, infsupdec (-27.0, -27.0, "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (-27.0, infsupdec (-27.0, 0.0, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (-7.0, infsupdec (-27.0, 0.0, "dac")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsupdec (-27.0, 0.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (-0.0, infsupdec (0.0, 0.0, "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsupdec (0.0, 0.0, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsupdec (-0.0, -0.0, "dac")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsupdec (-0.0, 0.0, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsupdec (0.0, -0.0, "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (5.0, infsupdec (5.0, 12.4, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (6.3, infsupdec (5.0, 12.4, "dac")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (12.4, infsupdec (5.0, 12.4, "com")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (0.0, infsupdec (entire, "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (5.0, infsupdec (entire, "def")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (6.3, infsupdec (entire, "dac")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (12.4, infsupdec (entire, "trv")), ...
%!    true)))
%! assert (all (eq (...
%!    ismember (-71.0, infsupdec (-27.0, 0.0, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (0.1, infsupdec (-27.0, 0.0, "def")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-0.01, infsupdec (0.0, 0.0, "dac")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (0.000001, infsupdec (0.0, 0.0, "com")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (111110.0, infsupdec (-0.0, -0.0, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (4.9, infsupdec (5.0, 12.4, "def")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-6.3, infsupdec (5.0, 12.4, "dac")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (0.0, infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (0.0, infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-4535.3, infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-4535.3, infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-inf, infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-inf, infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (inf, infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (inf, infsupdec (empty, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (-inf, infsupdec (entire, "trv")), ...
%!    false)))
%! assert (all (eq (...
%!    ismember (inf, infsupdec (entire, "def")), ...
%!    false)))

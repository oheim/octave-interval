## Copyright 2014-2017 Oliver Heimlich
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

## -*- texinfo -*-
## @documentencoding UTF-8
## @defmethod {@@infsupdec} decorationpart (@var{X})
## @defmethodx {@@infsupdec} decorationpart (@var{X}, @var{TYPE})
##
## Return the decoration of the decorated interval @var{X}.
##
## The returned value depends on the requested @var{TYPE}.
## @table @asis
## @item @option{char} (default)
## The decoration is a cell array of character strings and its size equals the
## size of its interval part.  Possible values: @option{ill}, @option{trv},
## @option{def}, @option{dac}, @option{com}.
## @item @option{uint8}
## The decoration is an array of uint8 numbers and its size equals the size of
## its interval part.  Possible values: @option{0}, @option{4}, @option{8},
## @option{12}, @option{16} as defined by IEEE Std 1788-2015, 14.4 Interchange
## representations and encodings.
## @end table
##
## @example
## @group
## x = infsupdec ("[0, 1] [1, inf] [-1, 1]_def [empty]");
## decorationpart (x)
##   @result{} ans =
##     @{
##       [1,1] = com
##       [1,2] = dac
##       [1,3] = def
##       [1,4] = trv
##     @}
## decorationpart (x, "uint8")
##   @result{} ans =
##
##       16  12   8   4
##
## @end group
## @end example
## @seealso{@@infsupdec/intervalpart}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function dec = decorationpart (x, type)

  if (nargin > 2)
    print_usage ();
    return
  endif

  if (nargin < 2)
    type = "char";
  endif

  switch (type)
    case "char"
                                # see below
    case "uint8"
      dec = x.dec;
      return
    otherwise
      error ("decorationpart: illegal value for parameter TYPE")
  endswitch

  persistent dec_translation = {...
                                # 0 = ill
                                 "ill", [], [], [], ...
                                # 4 = trv
                                 "trv", [], [], [], ...
                                # 8 = def
                                 "def", [], [], [], ...
                                # 12 = dac
                                 "dac", [], [], [], ...
                                # 16 = com
                                 "com"};

  dec = cell (size (x.dec));
  dec(:) = dec_translation(x.dec(:) + 1);

endfunction

%!assert (decorationpart (infsupdec (3, 4)), {"com"});
%!assert (decorationpart (infsupdec (3, inf)), {"dac"});
%!assert (decorationpart (infsupdec ("[3, 4]_def")), {"def"});
%!assert (decorationpart (infsupdec ()), {"trv"});
%!assert (decorationpart (nai), {"ill"});

%!assert (decorationpart (nai, "uint8") ...
%!      < decorationpart (infsupdec ("[3, 4]_trv"), "uint8"));
%!assert (decorationpart (infsupdec ("[3, 4]_trv"), "uint8") ...
%!      < decorationpart (infsupdec ("[3, 4]_def"), "uint8"));
%!assert (decorationpart (infsupdec ("[3, 4]_def"), "uint8") ...
%!      < decorationpart (infsupdec ("[3, 4]_dac"), "uint8"));
%!assert (decorationpart (infsupdec ("[3, 4]_dac"), "uint8") ...
%!      < decorationpart (infsupdec ("[3, 4]_com"), "uint8"));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.decorationPart;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     decorationpart (testcase.in{1}), ...
%!     {testcase.out}));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.decorationPart;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = {testcases.out}';
%! assert (isequaln (decorationpart (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.decorationPart;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = {testcases.out}';
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (decorationpart (in1), out));

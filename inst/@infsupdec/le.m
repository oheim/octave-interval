## Copyright 2014-2016 Oliver Heimlich
## Copyright 2017 Joel Dahne
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
## @defop Method {@@infsupdec} le (@var{A}, @var{B})
## @defopx Operator {@@infsupdec} {@var{A} <= @var{B}}
##
## Compare intervals @var{A} and @var{B} for weakly less.
##
## True, if all numbers from @var{A} are weakly less than any number in
## @var{B}.  False, if @var{A} contains a number which is strictly greater than
## all numbers in @var{B}.
##
## Evaluated on interval arrays, this functions is applied element-wise.
##
## @seealso{@@infsupdec/eq, @@infsupdec/lt, @@infsupdec/ge, @@infsupdec/subset, @@infsupdec/interior, @@infsupdec/disjoint}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = le (a, b)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
  endif
  if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
  endif

  result = le (a.infsup, b.infsup);
  result (isnai (a) | isnai (b)) = false;

endfunction

%!assert (le (infsupdec (1, 3), infsupdec (3)));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.less;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     le (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.less;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (le (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.less;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (le (in1, in2), out));

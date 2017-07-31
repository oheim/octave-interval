## Copyright 2014-2016 Oliver Heimlich
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
## @defop Method {@@infsup} minus (@var{X}, @var{Y})
## @defopx Operator {@@infsup} {@var{X} - @var{Y}}
##
## Subtract all numbers of interval @var{Y} from all numbers of @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x - y
##   @result{} ans = [0, 2]
## @end group
## @end example
## @seealso{@@infsup/plus}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function x = minus (x, y)

  if (nargin ~= 2)
    print_usage ();
    return
  endif
  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif
  if (not (isa (y, "infsup")))
    y = infsup (y);
  elseif (isa (y, "infsupdec"))
    ## Workaround for bug #42735
    result = minus (x, y);
    return
  endif

  l = mpfr_function_d ('minus', -inf, x.inf, y.sup);
  u = mpfr_function_d ('minus', +inf, x.sup, y.inf);

  emptyresult = isempty (x) | isempty (y);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (infsup (2, 3) - infsup (1, 2) == infsup (0, 2));

%!# correct use of signed zeros
%!test
%! x = minus (infsup (0), infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.sub;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     minus (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.sub;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (minus (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sub;
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
%! assert (isequaln (minus (in1, in2), out));

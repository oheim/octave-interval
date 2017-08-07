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
## @deftypemethod {@@infsupdec} {@var{X} =} absrev (@var{C}, @var{X})
## @deftypemethodx {@@infsupdec} {@var{X} =} absrev (@var{C})
##
## Compute the reverse absolute value function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{abs (x) ∈ @var{C}}.
##
## Accuracy: The result is a tight enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## No one way of decorating this operations gives useful information in all
## contexts.  Therefore, the result will carry a @code{trv} decoration at best.
##
## @example
## @group
## absrev (infsupdec (-2, 1))
##   @result{} ans = [-1, +1]_trv
## @end group
## @end example
## @seealso{@@infsupdec/abs}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = absrev (c, x)

  if (nargin > 2)
    print_usage ();
    return
  endif

  if (nargin < 2)
    x = infsupdec (-inf, inf);
  endif
  if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
  endif
  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif

  result = infsupdec (absrev (c.infsup, x.infsup), "trv");
  result.dec(isnai (c) | isnai (x)) = _ill ();

endfunction

%!# Empty interval
%!assert (isequal (absrev (infsupdec ()), infsupdec ()));
%!assert (isequal (absrev (infsupdec (0, 1), infsupdec ()), infsupdec ()));
%!assert (isequal (absrev (infsupdec (0, 1), infsupdec (7, 9)), infsupdec ()));
%!assert (isequal (absrev (infsupdec (), infsupdec (0, 1)), infsupdec ()));
%!assert (isequal (absrev (infsupdec (-2, -1)), infsupdec ()));

%!# Singleton intervals
%!assert (isequal (absrev (infsupdec (1)), infsupdec (-1, 1, "trv")));
%!assert (isequal (absrev (infsupdec (0)), infsupdec (0, "trv")));
%!assert (isequal (absrev (infsupdec (-1)), infsupdec ()));
%!assert (isequal (absrev (infsupdec (realmax)), infsupdec (-realmax, realmax, "trv")));
%!assert (isequal (absrev (infsupdec (realmin)), infsupdec (-realmin, realmin, "trv")));
%!assert (isequal (absrev (infsupdec (-realmin)), infsupdec ()));
%!assert (isequal (absrev (infsupdec (-realmax)), infsupdec ()));

%!# Bound intervals
%!assert (isequal (absrev (infsupdec (1, 2)), infsupdec (-2, 2, "trv")));
%!assert (isequal (absrev (infsupdec (1, 2), infsupdec (0, 2)), infsupdec (1, 2, "trv")));
%!assert (isequal (absrev (infsupdec (0, 1), infsupdec (-0.5, 2)), infsupdec (-0.5, 1, "trv")));
%!assert (isequal (absrev (infsupdec (-1, 1)), infsupdec (-1, 1, "trv")));
%!assert (isequal (absrev (infsupdec (-1, 0)), infsupdec (0, "trv")));

%!# Unbound intervals
%!assert (isequal (absrev (infsupdec (0, inf)), infsupdec (-inf, inf, "trv")));
%!assert (isequal (absrev (infsupdec (-inf, inf)), infsupdec (-inf, inf, "trv")));
%!assert (isequal (absrev (infsupdec (-inf, 0)), infsupdec (0, "trv")));
%!assert (isequal (absrev (infsupdec (1, inf), infsupdec (-inf, 0)), infsupdec (-inf, -1, "trv")));
%!assert (isequal (absrev (infsupdec (-1, inf)), infsupdec (-inf, inf, "trv")));
%!assert (isequal (absrev (infsupdec (-inf, -1)), infsupdec ()));
%!assert (isequal (absrev (infsupdec (-inf, 1)), infsupdec (-1, 1, "trv")));

%!# from the documentation string
%!assert (isequal (absrev (infsupdec (-2, 1)), infsupdec (-1, 1, "trv")));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation with one argument
%! testcases = testdata.NoSignal.infsupdec.absRev;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     absrev (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation with one argument
%! testcases = testdata.NoSignal.infsupdec.absRev;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (absrev (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.absRev;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (absrev (in1), out));

%!test
%! # Scalar evaluation with two arguments
%! testcases = testdata.NoSignal.infsupdec.absRevBin;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     absrev (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation with two arguments
%! testcases = testdata.NoSignal.infsupdec.absRevBin;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (absrev (in1, in2), out));

%!test
%! # N-dimensional array evaluation with two arguments
%! testcases = testdata.NoSignal.infsupdec.absRevBin;
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
%! assert (isequaln (absrev (in1, in2), out));

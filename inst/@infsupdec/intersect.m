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
## @defmethod {@@infsupdec} intersect (@var{A})
## @defmethodx {@@infsupdec} intersect (@var{A}, @var{B})
## @defmethodx {@@infsupdec} intersect (@var{A}, [], @var{DIM})
##
## Intersect intervals.
##
## With two arguments the intersection is built pair-wise.  Otherwise the
## intersection is computed for all interval members along dimension @var{DIM},
## which defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## The function is a set operation and the result carries the @code{trv}
## decoration at best.
##
## @example
## @group
## x = infsupdec (1, 3);
## y = infsupdec (2, 4);
## intersect (x, y)
##   @result{} ans = [2, 3]_trv
## @end group
## @end example
## @seealso{@@infsupdec/union, @@infsupdec/setdiff, @@infsupdec/setxor}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = intersect (a, b, dim)

  if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
  endif

  switch (nargin)
    case 1
      result = infsupdec (intersect (a.infsup), "trv");
      result.dec = min (result.dec, min (a.dec));

    case 2
      if (not (isa (b, "infsupdec")))
        b = infsupdec (b);
      endif
      result = infsupdec (intersect (a.infsup, b.infsup), "trv");
      warning ("off", "Octave:broadcast", "local");
      result.dec = min (result.dec, min (a.dec, b.dec));
    case 3
      if (not (builtin ("isempty", b)))
        warning ("intersect: second argument is ignored");
      endif
      result = infsupdec (intersect (a.infsup, [], dim), "trv");
      result.dec = min (result.dec, min (a.dec, [], dim));
    otherwise
      print_usage ();
      return
  endswitch

endfunction

%!# from the documentation string
%!assert (isequal (intersect (infsupdec (1, 3), infsupdec (2, 4)), infsupdec (2, 3, "trv")));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.intersection;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     intersect (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.intersection;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (intersect (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.intersection;
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
%! assert (isequaln (intersect (in1, in2), out));

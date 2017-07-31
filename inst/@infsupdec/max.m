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
## @defmethod {@@infsupdec} max (@var{X})
## @defmethodx {@@infsupdec} max (@var{X}, @var{Y})
## @defmethodx {@@infsupdec} max (@var{X}, [], @var{DIM})
##
## Compute the maximum value chosen from intervals.
##
## This function does not return the greatest element of the interval (see
## @code{sup}), but returns an interval enclosure of the function:
## @display
## max (@var{x}, @var{y}) = ( (x + y) + abs (x - y) ) / 2
## @end display
##
## With two arguments the function is applied element-wise.  Otherwise the
## maximum is computed for all interval members along dimension @var{DIM},
## which defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## max (x, y)
##   @result{} ans = [2, 3]_com
## @end group
## @end example
## @seealso{@@infsupdec/min}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = max (x, y, dim)

  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif

  switch (nargin)
    case 1
      bare = max (x.infsup);
    case 2
      if (not (isa (y, "infsupdec")))
        y = infsupdec (y);
      endif
      bare = max (x.infsup, y.infsup);
    case 3
      if (not (builtin ("isempty", y)))
        warning ("max: second argument is ignored");
      endif
      bare = max (x.infsup, [], dim);
    otherwise
      print_usage ();
      return
  endswitch

  result = newdec (bare);
  ## max is defined and continuous everywhere
  switch (nargin)
    case 1
      result.dec = min (result.dec, min (x.dec));
    case 2
      warning ("off", "Octave:broadcast", "local");
      result.dec = min (result.dec, min (x.dec, y.dec));
    case 3
      result.dec = min (result.dec, min (x.dec, [], dim));
  endswitch

endfunction

%!# from the documentation string
%!assert (isequal (max (infsupdec (2, 3), infsupdec (1, 2)), infsupdec (2, 3)));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.max;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     max (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.max;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (max (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.max;
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
%! assert (isequaln (max (in1, in2), out));

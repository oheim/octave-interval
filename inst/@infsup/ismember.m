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
## @defmethod {@@infsup} ismember (@var{M}, @var{X})
##
## Check if the interval @var{X} contains the number @var{M}.
##
## The number can be a numerical data type or a string representation of a
## decimal number.
##
## Evaluated on interval arrays, this functions is applied element-wise.
##
## @seealso{@@infsup/eq, @@infsup/isentire, @@infsup/issingleton, @@infsup/isempty}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = ismember (real, interval)

  if (nargin ~= 2)
    print_usage ();
    return
  endif
  if (not (isa (interval, "infsup")))
    interval = infsup (interval);
  endif

  if (isreal (real) && isfloat (real))
    ## Simple checking is only possible with floating point numbers
    result = isfinite (real) & interval.inf <= real & real <= interval.sup;
  else
    ## Mixed mode comparison between integers and floats can be problematic
    ## as well as comparison with decimal numbers
    result = subset (infsup (real), interval);
  endif

endfunction

%!assert (ismember (0, entire ()));
%!assert (ismember (0, intervalpart (entire ())));

%!assert (not (ismember (0, empty ())));
%!assert (not (ismember (0, intervalpart (empty ()))));

%!warning assert (not (ismember (0, infsupdec (2, 1))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.isMember;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     ismember (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.isMember;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (ismember (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.isMember;
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
%! assert (isequaln (ismember (in1, in2), out));

%!test
%! # Decorated scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.isMember;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     ismember (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Decorated vector evaluation
%! testcases = testdata.NoSignal.infsupdec.isMember;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (ismember (in1, in2), out));

%!test
%! # Decorated N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.isMember;
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
%! assert (isequaln (ismember (in1, in2), out));

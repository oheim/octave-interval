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
## @defmethod {@@infsupdec} tan (@var{X})
##
## Compute the tangent in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## tan (infsupdec (1))
##   @result{} ans ⊂ [1.5574, 1.5575]_com
## @end group
## @end example
## @seealso{@@infsupdec/atan, @@infsupdec/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = tan (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = newdec (tan (x.infsup));

  ## Because tan (nextdown (pi / 2)) < realmax, we can simple check for
  ## a singularity by comparing the result with entire.
  domain = not (isentire (result));
  result.dec(not (domain)) = _trv ();

  result.dec = min (result.dec, x.dec);

endfunction

%!# from the documentation string
%!assert (isequal (tan (infsupdec (1)), infsupdec ("[0x1.8EB245CBEE3A5, 0x1.8EB245CBEE3A6]")));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.tan;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     tan (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.tan;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (tan (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.tan;
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
%! assert (isequaln (tan (in1), out));

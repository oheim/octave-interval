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
## @defmethod {@@infsupdec} precedes (@var{A}, @var{B})
##
## Evaluate precedes comparison on intervals.
##
## True, if @var{A} is left of @var{B}. The intervals may touch.
##
## Evaluated on interval arrays, this functions is applied element-wise.
##
## @seealso{@@infsupdec/eq, @@infsupdec/le, @@infsupdec/lt, @@infsupdec/gt, @@infsupdec/strictprecedes, @@infsupdec/subset, @@infsupdec/interior, @@infsupdec/disjoint}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = precedes (a, b)

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

  result = precedes (a.infsup, b.infsup);
  result(isnai (a) | isnai (b)) = false;

endfunction

%!assert (precedes (infsupdec (1, 2), infsupdec (2, 3)));
%!assert (not (precedes (infsupdec (1, 2.1), infsupdec (1.9, 3))));

%!shared testdata
%! # Load compiled test data (from test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.precedes;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     precedes (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.precedes;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (precedes (in1, in2), out));

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
## @deftypemethod {@@infsup} {@var{X} =} pownrev (@var{C}, @var{X}, @var{P})
## @deftypemethodx {@@infsup} {@var{X} =} pownrev (@var{C}, @var{P})
##
## Compute the reverse monomial @code{x^@var{P}}.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{pown (x, @var{P}) ∈ @var{C}}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{P} ≥ -2.  The result also is a tight enclosure if the
## reciprocal of @var{P} can be computed exactly in double-precision.
##
## @seealso{@@infsup/pown}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pownrev (c, x, p)

  if (nargin < 2 || nargin > 3)
    print_usage ();
    return
  endif
  if (nargin < 3)
    p = x;
    x = infsup (-inf, inf);
  endif
  if (not (isa (c, "infsup")))
    c = infsup (c);
  endif
  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif

  if (not (isnumeric (p)) || any ((fix (p) ~= p)(:)))
    error ("interval:InvalidOperand", "pownrev: exponent is not an integer");
  endif

  ## Resize, if broadcasting is needed
  if (not (size_equal (x.inf, c.inf)))
    x.inf = ones (size (c.inf)) .* x.inf;
    x.sup = ones (size (c.inf)) .* x.sup;
    c.inf = ones (size (x.inf)) .* c.inf;
    c.sup = ones (size (x.inf)) .* c.sup;
  endif
  if (not (size_equal (x.inf, p)))
    x.inf = ones (size (p)) .* x.inf;
    x.sup = ones (size (p)) .* x.sup;
    c.inf = ones (size (p)) .* c.inf;
    c.sup = ones (size (p)) .* c.sup;
    p = ones (size (x.inf)) .* p;
  endif

  even = mod (p, 2) == 0;
  odd = not (even);

  result = x;
  ## x^0 == 1
  result.inf(p == 0 & (c.inf > 1 | c.sup < 1)) = inf;
  result.sup(p == 0 & (c.inf > 1 | c.sup < 1)) = -inf;

  even = not (p == 0) & even;

  idx.type = "()";
  idx.subs = {even};

  result = subsasgn (result, idx, ...
                     union (intersect (subsref (x, idx), ...
                                       nthroot (intersect (subsref (c, idx), ...
                                                           infsup (0, inf)),
                                                p(even))), ...
                            intersect (subsref (x, idx), ...
                                       -nthroot (intersect (subsref (c, idx), ...
                                                            infsup (0, inf)),
                                                 p(even)))));

  idx.subs = {odd};
  result = subsasgn (result, idx, ...
                     union (intersect (subsref (x, idx), ...
                                       nthroot (intersect (subsref (c, idx), ...
                                                           infsup (0, inf)),
                                                p(odd))), ...
                            intersect (subsref (x, idx), ...
                                       nthroot (intersect (subsref (c, idx), ...
                                                           infsup (-inf, 0)),
                                                p(odd)))));
endfunction

%!assert (pownrev (infsup (25, 36), infsup (0, inf), 2) == infsup (5, 6));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.pownRev;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     pownrev (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.pownRev;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (pownrev (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.pownRev;
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
%! assert (isequaln (pownrev (in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.pownRevBin;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     pownrev (testcase.in{1}, testcase.in{2}, testcase.in{3}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.pownRevBin;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! assert (isequaln (pownrev (in1, in2, in3), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.pownRevBin;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! in3 = reshape ([in3; in3(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (pownrev (in1, in2, in3), out));

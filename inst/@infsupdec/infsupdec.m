## Copyright 2014-2017 Oliver Heimlich
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
## @deftypeop Constructor {@@infsupdec} {[@var{X}, @var{ISEXACT}] =} infsupdec ()
## @deftypeopx Constructor {@@infsupdec} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{M})
## @deftypeopx Constructor {@@infsupdec} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{M}, @var{D})
## @deftypeopx Constructor {@@infsupdec} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{S})
## @deftypeopx Constructor {@@infsupdec} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{L}, @var{U})
## @deftypeopx Constructor {@@infsupdec} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{L}, @var{U}, @var{D})
## @deftypeopx Constructor {@@infsupdec} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{I}, @var{D})
##
## Create a decorated interval from boundaries.  Convert boundaries to double
## precision.
##
## The syntax without parameters creates an (exact) empty interval.  The syntax
## with a single parameter @code{infsupdec (@var{M})} equals
## @code{infsupdec (@var{M}, @var{M})}.  The syntax
## @code{infsupdec (@var{M}, @var{D})} equals
## @code{infsupdec (@var{M}, @var{M}, @var{D})}.  The syntax
## @code{infsupdec (@var{S})} parses a possibly decorated interval literal in
## inf-sup form or as a special value, where @code{infsupdec ("[S1, S2]")} is
## equivalent to @code{infsupdec ("S1", "S2")} and, if [S1, S2]_D is a valid
## interval literal,
## @code{infsupdec ("[S1, S2]_D")} is equivalent to
## @code{infsupdec ("S1", "S2", "D")}.  The syntax
## @code{infsupdec (@var{I}, @var{D})} overrides an interval @var{I}'s
## decoration with a new decoration @var{D}.  A second, logical output
## @var{ISEXACT} indicates if @var{X}'s boundaries both have been converted
## without precision loss and without changes to the optional, desired
## decoration.
##
## If construction fails, the special value NaI, “not an interval,” will be
## returned and a warning message will be raised.  NaI is equivalent to
## [Empty] together with an ill-formed decoration.
##
## Each boundary can be provided in the following formats: literal constants
## [+-]inf[inity], e, pi; scalar real numeric data types, i. e., double,
## single, [u]int[8,16,32,64]; or decimal numbers as strings of the form
## [+-]d[,.]d[[eE][+-]d]; or hexadecimal numbers as string of the form
## [+-]0xh[,.]h[[pP][+-]d]; or decimal numbers in rational form
## [+-]d/d.
##
## Also it is possible, to construct intervals from the uncertain form in the
## form @code{m?ruE}, where @code{m} is a decimal mantissa,
## @code{r} is empty (= half ULP) or a decimal integer ULP count or a
## second @code{?} character for unbounded intervals, @code{u} is
## empty or a direction character (u: up, d: down), and @code{E} is an
## exponential field.
##
## If decimal or hexadecimal numbers are no binary64 floating point numbers, a
## tight enclosure will be computed.  int64 and uint64 numbers of high
## magnitude (> 2^53) can also be affected from precision loss.
##
## The decoration @var{D} must be any of @code{com}, @code{dac}, @code{def},
## @code{trv}, or @code{ill}.  Illegal decorations within interval literals
## will produce NaIs, whereas illegal decorations provided as an additional
## function parameter will be automatically adjusted.
##
## For the creation of interval arrays, arguments may be provided as (1) cell
## arrays with arbitrary/mixed types, (2) numeric arrays, or for matrices (3)
## strings.  Scalar values do broadcast.
##
## Non-standard behavior: This class constructor is not described by IEEE Std
## 1788-2015, however it implements the standard functions setDec,
## numsToInterval, and textToInterval.
##
## @example
## @group
## v = infsupdec ()
##   @result{} v = [Empty]_trv
## w = infsupdec (1)
##   @result{} w = [1]_com
## x = infsupdec (2, 3)
##   @result{} x = [2, 3]_com
## y = infsupdec ("0.1")
##   @result{} y ⊂ [0.099999, 0.10001]_com
## z = infsupdec ("0.1", "0.2")
##   @result{} z ⊂ [0.099999, 0.20001]_com
## @end group
## @end example
## @seealso{exacttointerval, hull, midrad, @@infsup/newdec}
## @end deftypeop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function [x, isexact] = infsupdec (varargin)

  persistent scalar_empty_interval = class (struct ("dec", _trv), ...
                                            "infsupdec", infsup ());

  ## Enable all mixed mode functions to use decorated variants with implicit
  ## conversion from bare to decorated intervals.
  ##
  ## There is bug #42735 in GNU Octave core, which makes this a little
  ## complicated: When [infsup] [operator] [infsupdec] syntax is used, the
  ## decoration from the second argument would be lost, because the bare
  ## implementation for the operator is evaluated. However, sufficient runtime
  ## checks have been placed in the overloaded class operator implementations of
  ## the infsup class as a workaround.
  ##
  ## The workaround is necessary, because otherwise this could lead to wrong
  ## results, which is catastrophic for a verified computation package.
  superiorto ("infsup");

  if (nargin == 0)
    x = scalar_empty_interval;
    isexact = true;
    return
  endif

  if (nargin == 1 && isa (varargin{1}, "infsupdec"))
    x = varargin{1};
    isexact = true;
    return
  endif

  warning ("off", "Octave:broadcast", "local");

  for i = 1 : numel (varargin)
    if (ischar (varargin{i}))
      varargin{i} = __split_interval_literals__ (varargin{i});
    endif
  endfor

  if (nargin >= 1 && ...
      iscellstr (varargin{end}) && ...
      not (isempty (varargin{end})) && ...
      any (strcmpi (varargin{end}{1}, ...
                    {"com", "dac", "def", "trv", "ill"})))
    ## The decoration information has been passed as the last parameter
    decstr = varargin{end};
    varargin = varargin(1 : end - 1);

    ## The setDec function, as described by IEEE Std 1788-2015,
    ## may fix decorations
    fix_illegal_decorations = true;
  elseif (nargin == 1 && iscell (varargin{1}))
    ## Extract decorations from possibly decorated interval literals
    char_idx = cellfun ("ischar", varargin{1});

    ## Split bare interval literal and decoration
    literal_and_decoration = cellfun ("strsplit", ...
                                      varargin{1}(char_idx), {"_"}, ...
                                      "UniformOutput", false);

    number_of_parts = cellfun ("numel", literal_and_decoration);
    illegal_local_idx = number_of_parts > 2;
    if (any (illegal_local_idx(:)))
      ## More than 2 underscores in any literal
      warning ("interval:UndefinedOperation", ...
               "illegal decorated interval literal")
      literal_and_decoration(illegal_local_idx) = {"[nai]"};
    endif

    ## Ignore strings without decoration
    has_decoration_local_idx = (number_of_parts == 2);
    literal_and_decoration = literal_and_decoration(has_decoration_local_idx);
    char_idx(char_idx) = has_decoration_local_idx;

    ## Extract decoration
    decstr = cell (size (varargin{1}));
    decstr(char_idx) = vertcat ({}, ...
                                cellindexmat (literal_and_decoration, 2){:});
    varargin{1}(char_idx) = vertcat({}, ...
                                    cellindexmat (literal_and_decoration, ...
                                                  1){:});

    ## Interval literals must not carry illegal decorations
    fix_illegal_decorations = false;
  else
    ## Undecorated interval boundaries
    decstr = {""};
    ## No need to fix illegal decorations
    fix_illegal_decorations = false;
  endif

  switch numel (varargin)
    case 0
      [bare, isexact] = infsup ();
      isnai = overflow = false;

    case 1
      switch class (varargin{1})
        case "infsup"
          bare = varargin{1};
          isexact = true;
          isnai = overflow = false (size (bare));
          if (nargin == 1 && any (not (isempty (bare)(:))))
            warning ("interval:ImplicitPromote", ...
                     ["Implicitly decorated bare interval; ", ...
                      "resulting decoration may be wrong"]);
          endif

        case "infsupdec"
          ## setDec and newDec replace the current decoration
          ## with a new one
          bare = struct (varargin{1}).infsup;
          isexact = true;
          isnai = overflow = false (size (bare));

        case "cell"
          ## [nai] is a legal literal, but not allowed in the infsup
          ## constructor.  Create a silent nai in these cases.
          char_idx = cellfun ("ischar", varargin{1});
          nai_literal_local_idx = not (cellfun ("isempty", ...
                                                regexp (varargin{1}(char_idx), ...
                                                        '^\s*\[\s*nai\s*\]\s*$', ...
                                                        "ignorecase")));
          nai_literal_idx = find (char_idx)(nai_literal_local_idx);
          varargin{1}(nai_literal_idx) = "[]";
          [bare, isexact, overflow, isnai] = infsup (varargin{1});
          isnai(nai_literal_idx) = true;

          ## There is no version of [nai], which may carry decoration.
          if (any (not (cellfun ("isempty", decstr))(nai_literal_idx)(:)))
            warning ("interval:UndefinedOperation", ...
              "the [NaI] literal may not carry decoration")
            decstr(nai_literal_idx) = "";
          endif

        otherwise
          [bare, isexact, overflow, isnai] = infsup (varargin{1});

      endswitch

    case 2
      [bare, isexact, overflow, isnai] = infsup (varargin{1}, varargin{2});

    otherwise
      print_usage ();
      return
  endswitch

  ## Convert decoration strings into decoration matrix.
  ## Initialize the matrix with the ill decoration, which is not allowed to
  ## be used explicitly as a parameter to this function.
  dec = repmat (_ill, size (decstr));

  ## Missing decorations will later be assigned their final value
  missingdecoration_value = uint8 (1); # magic value, not used otherwise
  dec(cellfun ("isempty", decstr)) = missingdecoration_value;

  dec(strcmpi (decstr, "com")) = _com;
  dec(strcmpi (decstr, "dac")) = _dac;
  dec(strcmpi (decstr, "def")) = _def;
  dec(strcmpi (decstr, "trv")) = _trv;

  if (any ((dec == _ill)(:)))
    warning ("interval:UndefinedOperation", "illegal decoration");
  endif

  ## Broadcast decoration and bare interval
  if (not (isequal (size (bare), size (dec))))
    for dim = 1 : max (ndims (bare), ndims (dec))
      if (size (bare, dim) != 1 && size (dec, dim) != 1 && ...
          size (bare, dim) != size (dec, dim))
        warning ("interval:InvalidOperand", ...
                 ["infsupdec: Dimensions of decoration and interval ", ...
                  "are not compatible"]);
        ## Unable to recover from this kind of error
        x = scalar_empty_interval;
        isexact = false;
        return
      endif
    endfor
    dec = dec + zeros (size (bare), "uint8");
    bare = bare + zeros (size (dec));
  endif

  ## If creation failed in infsup constructor, make an illegal interval
  dec(isnai) = _ill;

  ## Silently fix decoration when overflow occurred
  dec(overflow & (dec == _com)) = _dac;

  ## Add missing decoration
  missingdecoration = (dec == missingdecoration_value);
  dec(missingdecoration) = _dac;
  dec(missingdecoration & isempty (bare)) = _trv;
  dec(missingdecoration & iscommoninterval (bare)) = _com;

  ## Check decoration
  empty_not_trv = isempty (bare) & (dec ~= _trv) & (dec ~= _ill);
  if (any (empty_not_trv(:)))
    if (not (fix_illegal_decorations))
      warning ("interval:UndefinedOperation", ...
               "illegal decorated empty interval literal")
      dec(empty_not_trv) = _ill;
    else
      dec(empty_not_trv) = _trv;
    endif
    isexact = false ();
  endif
  uncommon_com = not (iscommoninterval (bare)) & (dec == _com);
  if (any (uncommon_com(:)))
    if (not (fix_illegal_decorations))
      warning ("interval:UndefinedOperation", ...
               "illegal decorated uncommon interval literal")
      dec(uncommon_com) = _ill;
    else
      dec(uncommon_com) = _dac;
    endif
    isexact = false ();
  endif

  ## Illegal intervals must be empty
  illegal = (dec == _ill);
  if (any (illegal(:)))
    bare(illegal) = infsup ();
    isexact = false ();
  endif

  x = class (struct ("dec", dec), "infsupdec", bare);

endfunction

%!# [NaI]s
%!assert (isnai (infsupdec ("[nai]"))); # quiet [NaI]
%!assert (isnai (infsupdec (" [ nai ] "))); # quiet [NaI]
%!assert (isnai (infsupdec ({0, "[nai]"})), [false, true]); # quiet [NaI]
%!warning id=interval:UndefinedOperation
%! assert (isnai (infsupdec (3, 2))); # illegal boundaries
%!warning id=interval:UndefinedOperation
%! assert (isnai (infsupdec (inf, -inf))); # illegal boundaries
%!warning id=interval:UndefinedOperation
%! assert (isnai (infsupdec ("Flugeldufel"))); # illegal literal
%!warning id=interval:UndefinedOperation
%! assert (isnai (infsupdec ("[1, Inf]_com"))); # illegal decorated literal
%!warning id=interval:UndefinedOperation
%! assert (isnai (infsupdec ("[Empty]_def"))); # illegal decorated literal

%!# decoration adjustments, setDec function
%!test
%! x = infsupdec (42, inf, "com");
%! assert (inf (x), 42);
%! assert (sup (x), inf);
%! assert (decorationpart (x), {"dac"});
%!test
%! x = infsupdec (-inf, inf, {"com"});
%! assert (inf (x), -inf);
%! assert (sup (x), inf);
%! assert (decorationpart (x), {"dac"});
%!test
%! x = infsupdec ("def");
%! assert (inf (x), inf);
%! assert (sup (x), -inf);
%! assert (decorationpart (x), {"trv"});

%!# overflow
%!test
%! x = infsupdec ("[1, 1e999]_com");
%! assert (inf (x), 1);
%! assert (sup (x), inf);
%! assert (decorationpart (x), {"dac"});

%!# decorated interval literal
%!test
%! x = infsupdec ("[2, 3]_def");
%! assert (inf (x), 2);
%! assert (sup (x), 3);
%! assert (decorationpart (x), {"def"});
%!test
%! x = infsupdec ("[1, 5]_dac");
%! assert (inf (x), 1);
%! assert (sup (x), 5);
%! assert (decorationpart (x), {"dac"});
%!test
%! x = infsupdec ("[1, Infinity]_dac");
%! assert (inf (x), 1);
%! assert (sup (x), inf);
%! assert (decorationpart (x), {"dac"});
%!test
%! x = infsupdec ("[Empty]_trv");
%! assert (inf (x), inf);
%! assert (sup (x), -inf);
%! assert (decorationpart (x), {"trv"});

%!# automatic decoration / undecorated interval literal / newDec function
%!test
%! x = infsupdec ("[2, 3]");
%! assert (inf (x), 2);
%! assert (sup (x), 3);
%! assert (decorationpart (x), {"com"});
%!test
%! x = infsupdec ("[Empty]");
%! assert (inf (x), inf);
%! assert (sup (x), -inf);
%! assert (decorationpart (x), {"trv"});
%!test
%! x = infsupdec ("[Entire]");
%! assert (inf (x), -inf);
%! assert (sup (x), inf);
%! assert (decorationpart (x), {"dac"});
%!test
%! x = infsupdec ("");
%! assert (inf (x), -inf);
%! assert (sup (x), inf);
%! assert (decorationpart (x), {"dac"});

%!# separate decoration information
%!test
%! x = infsupdec ("[2, 3]", "def");
%! assert (inf (x), 2);
%! assert (sup (x), 3);
%! assert (decorationpart (x), {"def"});

%!# cell array with decorated interval literals
%!test
%! x = infsupdec ({"[2, 3]_def", "[4, 5]_dac"});
%! assert (inf (x), [2, 4]);
%! assert (sup (x), [3, 5]);
%! assert (decorationpart (x), {"def", "dac"});

%!#cell array with separate decoration cell array
%!test
%! x = infsupdec ({"[2, 3]", "[4, 5]"}, {"def", "dac"});
%! assert (inf (x), [2, 4]);
%! assert (sup (x), [3, 5]);
%! assert (decorationpart (x), {"def", "dac"});

%!# cell array with separate decoration vector
%!test
%! x = infsupdec ({"[2, 3]"; "[4, 5]"}, ["def"; "dac"]);
%! assert (inf (x), [2; 4]);
%! assert (sup (x), [3; 5]);
%! assert (decorationpart (x), {"def"; "dac"});

%!# cell array with broadcasting decoration
%!test
%! x = infsupdec ({"[2, 3]", "[4, 5]"}, "def");
%! assert (inf (x), [2, 4]);
%! assert (sup (x), [3, 5]);
%! assert (decorationpart (x), {"def", "def"});
%!test
%! x = infsupdec ({"[2, 3]", "[4, 5]"}, "def; dac");
%! assert (inf (x), [2, 4; 2, 4]);
%! assert (sup (x), [3, 5; 3, 5]);
%! assert (decorationpart (x), {"def", "def"; "dac", "dac"});

%!# separate boundaries with decoration
%!test
%! x = infsupdec (2, 3, "def");
%! assert (inf (x), 2);
%! assert (sup (x), 3);
%! assert (decorationpart (x), {"def"});

%!# matrix boundaries with decoration
%!test
%! x = infsupdec ([3, 16], {"def", "trv"});
%! assert (inf (x), [3, 16]);
%! assert (sup (x), [3, 16]);
%! assert (decorationpart (x), {"def", "trv"});

%!# separate matrix boundaries with broadcasting decoration
%!test
%! x = infsupdec (magic (3), magic (3) + 1, "def");
%! assert (inf (x), magic (3));
%! assert (sup (x), magic (3) + 1);
%! assert (decorationpart (x), {"def", "def", "def"; "def", "def", "def"; "def", "def", "def"});

%!# N-dimensional arrays
%!test
%! x = infsupdec (zeros (2, 2, 2));
%! assert (x.inf, zeros (2, 2, 2));
%! assert (x.sup, zeros (2, 2, 2));
%! assert (decorationpart (x), repmat ({"com"}, [2, 2, 2]));
%!test
%! x = infsupdec (zeros (2, 2, 2), ones (2, 2, 2), repmat ({"trv"}, [2, 2, 2]));
%! assert (x.inf, zeros (2, 2, 2));
%! assert (x.sup, ones (2, 2, 2));
%! assert (decorationpart (x), repmat ({"trv"}, [2, 2, 2]));
%!test
%! x = infsupdec (zeros (1, 1, 2), ones (1, 2, 1), {"trv"; "trv"});
%! assert (x.inf, zeros (2, 2, 2));
%! assert (x.sup, ones (2, 2, 2));
%! assert (decorationpart (x), repmat ({"trv"}, [2, 2, 2]));
%!test
%! c1 = reshape ({1, 2, 3, 4, 5, 6, 7, 8}, 2, 2, 2);
%! c2 = reshape ({2, 3, 4, 5, 6, 7, 8, 9}, 2, 2, 2);
%! decpart = reshape ({"trv", "def", "dac", "com", "trv", "def", "dac", "com"}, 2, 2, 2);
%! x = infsupdec (c1, c2, decpart);
%! assert (x.inf, reshape (1:8, 2, 2, 2));
%! assert (x.sup, reshape (2:9, 2, 2, 2));
%! assert (decorationpart (x), decpart)

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.setDec;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     infsupdec (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.setDec;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (infsupdec (in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.("d-numsToInterval");
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     infsupdec (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.("d-numsToInterval");
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (infsupdec (in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.("d-textToInterval");
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     infsupdec (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.("d-textToInterval");
%! in1 = vertcat (testcases.in);
%! out = vertcat (testcases.out);
%! assert (isequaln (infsupdec (in1), out));

%!warning
%! testcases = testdata.PossiblyUndefinedOperation.infsupdec.("d-textToInterval");
%! for testcase = [testcases]'
%!   lastwarn ("", "");
%!   assert (isequaln (...
%!     infsupdec (testcase.in{1}), ...
%!     testcase.out));
%!   assert (nthargout (2, @lastwarn), "interval:PossiblyUndefinedOperation");
%! endfor

%!warning
%! testcases = testdata.UndefinedOperation.infsupdec.("d-textToInterval");
%! for testcase = [testcases]'
%!   lastwarn ("", "");
%!   assert (isequaln (...
%!     infsupdec (testcase.in{1}), ...
%!     testcase.out));
%!   assert (nthargout (2, @lastwarn), "interval:UndefinedOperation");
%! endfor

%!warning
%! testcases = testdata.UndefinedOperation.infsupdec.("d-numsToInterval");
%! for testcase = [testcases]'
%!   lastwarn ("", "");
%!   assert (isequaln (...
%!     infsupdec (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%!   assert (nthargout (2, @lastwarn), "interval:UndefinedOperation");
%! endfor

%!warning
%! testcases = testdata.UndefinedOperation.infsup.setDec;
%! for testcase = [testcases]'
%!   lastwarn ("", "");
%!   assert (isequaln (...
%!     infsupdec (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%!   assert (nthargout (2, @lastwarn), "interval:UndefinedOperation");
%! endfor

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.("d-numsToInterval");
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
%! assert (isequaln (infsupdec (in1, in2), out));

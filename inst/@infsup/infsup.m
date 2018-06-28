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
## @deftypeop Constructor {@@infsup} {[@var{X}, @var{ISEXACT}] =} infsup ()
## @deftypeopx Constructor {@@infsup} {[@var{X}, @var{ISEXACT}] =} infsup (@var{M})
## @deftypeopx Constructor {@@infsup} {[@var{X}, @var{ISEXACT}] =} infsup (@var{S})
## @deftypeopx Constructor {@@infsup} {[@var{X}, @var{ISEXACT}] =} infsup (@var{L}, @var{U})
##
## Create an interval (from boundaries).  Convert boundaries to double
## precision.
##
## The syntax without parameters creates an (exact) empty interval.  The syntax
## with a single parameter @code{infsup (@var{M})} equals
## @code{infsup (@var{M}, @var{M})}.  The syntax @code{infsup (@var{S})} parses
## an interval literal in inf-sup form or as a special value, where
## @code{infsup ("[S1, S2]")} is equivalent to @code{infsup ("S1", "S2")}.  A
## second, logical output @var{ISEXACT} indicates if @var{X}'s boundaries both
## have been converted without precision loss.
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
## For the creation of interval arrays, arguments may be provided as (1) cell
## arrays with arbitrary/mixed types, (2) numeric arrays, or for matrices (3)
## strings.  Scalar values do broadcast.
##
## Non-standard behavior: This class constructor is not described by IEEE Std
## 1788-2015, IEEE standard for interval arithmetic, however it implements both
## standard functions numsToInterval and textToInterval for bare intervals.
##
## @example
## @group
## infsup ()
##   @result{} ans = [Empty]
## infsup ("[1]")
##   @result{} ans = [1]
## infsup (2, 3)
##   @result{} ans = [2, 3]
## infsup ("0.1")
##   @result{} ans ⊂ [0.099999, 0.10001]
## infsup ("0.1", "0.2")
##   @result{} ans ⊂ [0.099999, 0.20001]
## infsup ("0xff", "0x1.ffp14")
##   @result{} ans = [255, 32704]
## infsup ("1/3")
##   @result{} ans ⊂ [0.33333, 0.33334]
## infsup ("[1/9, 47/11]")
##   @result{} ans ⊂ [0.11111, 4.2728]
## infsup ("7.3?9u")
##   @result{} ans ⊂ [7.2999, 8.2001]
## infsup ("0??")
##   @result{} ans = [Entire]
## infsup ("911??de-2")
##   @result{} ans ⊂ [-inf, +9.1101]
## infsup ("10?")
##   @result{} ans = [9.5, 10.5]
## @end group
## @end example
## @seealso{exacttointerval}
## @end deftypeop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function [x, isexact, overflow, isnai] = infsup (l, u)

  persistent scalar_empty_interval = class (struct ("inf", inf, ...
                                                    "sup", -inf), ...
                                            "infsup");

  warning ("off", "Octave:broadcast", "local");

  ## Part 1
  ##
  ## Split any arguments into l and u, where l and u denote lower and upper
  ## boundaries.  l and u shall be either numeric arrays or cell arrays with
  ## strings or numeric entries.  The size of l and u will equal the interval
  ## array size of the final result (unless broadcasting is going to be applied
  ## as a very last step).
  ##
  ## Strings in l and u will be normalized, that is, trimmed and converted to
  ## lower case.

  switch nargin
    case 0
      ## empty interval
      x = scalar_empty_interval;
      isexact = true;
      isnai = overflow = false;
      return

    case 1
      if (isa (l, "infsup"))
        ## already an interval—nothing to be done
        x = l;
        isexact = true ();
        isnai = overflow = false (size (l.inf));
        return
      endif
      if (ischar (l))
        ## Character string may contain a vector or a matrix of intervals,
        ## split the interval literals into a cell array of strings.
        ## Interval literals will be trimmed by the split function.
        l = __split_interval_literals__ (lower (l));
        char_idx = true (size (l));
      elseif (iscell (l))
        ## Make sure that in a cell array (with possibly mixed types) all
        ## strings are trimmed.  This is required during splitting of
        ## interval literals into lower and upper bounds.
        char_idx = cellfun ("ischar", l);
        l(char_idx) = lower (strtrim (l(char_idx)));
      else
        ## Not cell or char, e. g. numeric array.
        ## Syntax infsup (x) has to be equivalent with infsup (x, x).
        ## No need to trim or normalize character case.
        u = l;
      endif

      ## Correct construction of empty intervals is only possible by calling
      ## this constructor without arguments (see above), or by using one of
      ## the two interval literals [] or [empty].
      ## Otherwise, construction of empty intervals must signal
      ## “UndefinedOperation”.
      ## In particular, the interval literal [+inf, -inf] is illegal and
      ## “numsToInterval (+inf, -inf)” would be an illegal function call,
      ## according to IEEE Std 1788-2015.
      ##
      ##  1. isnai defaults to -1 (unknown).
      ##  2. any non-empty interval (l <= u) is legal and we set isnai to
      ##     false for those in the end.
      ##  3. for legal empty interval literals we set isnai = false
      ##     explicitly.
      ##  4. for certain illegal interval literals we give a special warning
      ##     and set isnai = true explicitly.
      ##  5. it remains isnai = -1 for any illegal intervals which have not
      ##     been handled with, we give a warning and we return an empty
      ##     interval in these cases.
      isnai = -ones (size (l), "int8");
      illegal_boundary = struct ("inf", false (size (l)), ...
                                 "sup", false (size (l)));

      if (iscell (l))
        ## At this point, only a cell array can contain interval literals
        ## as string.  Split intervals and interval literals into lower and
        ## upper bounds.  Except for empty intervals, strings are not
        ## converted into numeric values yet.
        ##
        ## []       -> (+inf, -inf)
        ## [empty]  -> (+inf, -inf)
        ## [entire] -> (, )
        ## [,]      -> (, )
        ## [l, u]   -> (l, u)
        ## [m]      -> (m, m)
        ## m        -> (m, m)
        ## m?r      -> (m?r, m?r)
        ## m?ru     -> (m, m?r)
        ## m?rd     -> (m?r, m)
        ## m??      -> (, )
        ## m??u     -> (m, )
        ## m??d     -> (, m)

        ## Initialize u such that the syntax infsup (x) is equivalent with
        ## infsup (x, x) unless interval literals are used.
        u = l;

        ## Find interval literals with square brackets.  The strings are
        ## trimmed already, so they will start at the first character.
        square_bracket_idx = strncmp (l, "[", 1);
        %!# Verify correct behaviour of strncmp for empty strings and non-string
        %!# values within the cell array.
        %!assert (strncmp ({"[", double("["), ""}, "[", 1), logical ([1 0 0]));

        ## A bare interval literal which starts with a square bracket
        ## must end with a square bracket as well.
        square_bracket_idx = ...
        find (square_bracket_idx)(...
                                   cellfun (@(s) s(end) == "]", ...
                                            l(square_bracket_idx)));

        ## Strip square brackets and white space within square brackets.
        nobrackets = strtrim (cellfun (@(s) s([2 : (end - 1)]), ...
                                       l(square_bracket_idx), ...
                                       "UniformOutput", false));

        ## Construction of empty intervals with the correct literal either
        ## [empty] or [] is legit.
        empty_interval_local_idx = strcmp (nobrackets, "empty") ...
                                   | cellfun ("isempty", nobrackets);
        empty_interval_idx = square_bracket_idx(empty_interval_local_idx);
        isnai(empty_interval_idx) = false;

        ## We remove the empty interval cases from the current work basket
        ## and don't need special handling of comma-less strings below
        ## ([] represents the empty interval, whereas [,] represents the
        ## set of all real numbers).
        square_bracket_idx = ...
        square_bracket_idx(not (empty_interval_local_idx));
        nobrackets = nobrackets(not (empty_interval_local_idx));
        char_idx(empty_interval_idx) = false;
        l(empty_interval_idx) = +inf;
        u(empty_interval_idx) = -inf;

        ## [entire] is equivalent to [,]
        nobrackets(strcmp (nobrackets, "entire")) = {""};

        ## Split [l, u] literals into l and u strings at the comma.
        nobrackets = cellfun ("strsplit", nobrackets, {","}, ...
                              "UniformOutput", false);
        nobrackets_parts = cellfun ("numel", nobrackets);

        ## For point intervals [m] we have removed the square brackets,
        ## trimmed any white space inside the square brackets and must
        ## store m into both l and u for further parsing below.
        ## Each boundary will be parsed individually with opposite rounding
        ## direction.
        point_interval_local_idx = (nobrackets_parts == 1);
        point_interval_idx = square_bracket_idx(point_interval_local_idx);
        l(point_interval_idx) = u(point_interval_idx) = ...
        vertcat ({}, nobrackets(point_interval_local_idx){:});

        ## For infsup intervals [l, u] we can store the trimmed l and u
        ## strings for further parsing below.
        infsup_interval_local_idx = (nobrackets_parts == 2);
        infsup_interval_idx = square_bracket_idx(infsup_interval_local_idx);
        l(infsup_interval_idx) = strtrim (vertcat ({}, ...
                                                   cellindexmat (nobrackets(infsup_interval_local_idx), 1){:}));
        u(infsup_interval_idx) = strtrim (vertcat ({}, ...
                                                   cellindexmat (nobrackets(infsup_interval_local_idx), 2){:}));

        ## Find interval literals in uncertain form.
        uncertain_idx = char_idx;
        uncertain_idx(square_bracket_idx) = false; # already processed

        ## Find uncertain form with directed uncertainty (down or up)
        [~, ~, ~, ~, groups] = regexp (l(uncertain_idx), ...
                                       ["([^?]+)", ... # 1: mantissa
                                        "([?])", ...   # 2: ?
                                        "(.*)", ...    # 3: uncertainty
                                        "([du])", ...  # 4: direction
                                        "(.*)"]);      # 5: exponent
        directed_local_idx = not (cellfun ("isempty", groups));
        directed_uncertain_idx = uncertain_idx;
        directed_uncertain_idx(uncertain_idx) = directed_local_idx;
        groups = vertcat ({}, groups(directed_local_idx){:});

        ## Remove directed down/up uncertainty.
        for direction = ["d", "u"]
          direction_local_idx = strcmp (...
                                         vertcat ({}, ...
                                                  cellindexmat (groups, ...
                                                                4){:}), ...
                                         direction);
          direction_idx = directed_uncertain_idx;
          direction_idx(directed_uncertain_idx) = direction_local_idx;

          ## Remove direction character
          persistent join_groups = @(parts) strcat (parts{:});
          undirected_uncertain_form = ...
          cellfun (...
                    join_groups, ...
                    cellindexmat (groups(direction_local_idx), ...
                                  [1 2 3 5]), ...
                    "UniformOutput", false);
          ## Also remove uncertainty
          undirected_certain_form = ...
          cellfun (...
                    join_groups, ...
                    cellindexmat (groups(direction_local_idx), ...
                                  [1 5]), ...
                    "UniformOutput", false);

          ## Store uncertain boundaries without directed uncertainty
          switch direction
            case "d"
              l(direction_idx) = undirected_uncertain_form;
              u(direction_idx) = undirected_certain_form;
            case "u"
              l(direction_idx) = undirected_certain_form;
              u(direction_idx) = undirected_uncertain_form;
          endswitch

          ## Remove parsed uncertain form from work basket to prevent
          ## double parsing (strings with both d and u uncertainty).
          directed_uncertain_idx(direction_idx) = false;
          groups = groups(not (direction_local_idx));
        endfor

        ## Remove unbound uncertainty ??
        ## FIXME We should verify correctness of the interval literal more
        ## thoroughly.  Otherwise we would ignore illegal literals which
        ## contain the double question mark.
        l_unbound_idx = uncertain_idx;
        l_unbound_idx(uncertain_idx) = ...
        not (cellfun ("isempty", strfind (l(uncertain_idx), "??")));
        l(l_unbound_idx) = {""};
        u_unbound_idx = uncertain_idx;
        u_unbound_idx(uncertain_idx) = ...
        not (cellfun ("isempty", strfind (u(uncertain_idx), "??")));
        u(u_unbound_idx) = {""};
      endif

    case 2
      ## Split interval vectors if supplied as strings.
      if (ischar (l))
        l = __split_interval_literals__ (l);
      endif
      if (ischar (u))
        u = __split_interval_literals__ (u);
      endif

      ## Check dimensions and whether broadcasting is possible
      for dim = 1 : max (ndims (l), ndims (u))
        if (size (l, dim) != 1 && size (u, dim) != 1 && ...
            size (l, dim) != size (u, dim))
          warning ("interval:InvalidOperand", ...
                   ["infsup: Dimensions of lower and upper ", ...
                    "boundaries are not compatible"]);
          ## Unable to recover from this kind of error
          x = scalar_empty_interval;
          isexact = false;
          overflow = false;
          isnai = true;
          return
        endif
      endfor

      ## Compute result size after broadcasting and mark any empty intervals
      ## as illegal (will trigger “UndefinedOperation” signal later on).
      ## Construction of silent empty intervals is impossible with two args.
      isnai = zeros (size (l), "int8") - ones (size (u), "int8"); #-1=unknown
      illegal_boundary = struct ("inf", false (size (l)), ...
                                 "sup", false (size (u)));

      for argument = ["l", "u"]
        switch argument
          case "l"
            current_arg = l;
          case "u"
            current_arg = u;
        endswitch
        if (iscell (current_arg))
          ## Normalize strings: trim and convert to lower case
          ## (as is done in the nargin == 1 case).
          char_idx = cellfun ("ischar", current_arg);
          current_arg(char_idx) = ...
          lower (strtrim (current_arg(char_idx)));

          ## In contrast to the nargin == 1 case we cannot allow interval
          ## literals here.  Only simple boundaries are allowed if two
          ## arguments are given.
          square_bracket_idx = strncmp (current_arg, "[", 1);
          uncertain_idx = char_idx;
          uncertain_idx(square_bracket_idx) = false;
          uncertain_idx(uncertain_idx) = ...
          not (cellfun ("isempty", ...
                        strfind (current_arg(uncertain_idx), "?")));
          illegal_literal_idx = (square_bracket_idx | uncertain_idx);
          if (any (illegal_literal_idx(:)))
            switch argument
              case "l"
                warning ("interval:UndefinedOperation", ...
                         "Lower boundary contains an interval literal");
                current_arg(illegal_literal_idx) = +inf;
                illegal_boundary.inf(illegal_literal_idx) = true;
              case "u"
                warning ("interval:UndefinedOperation", ...
                         "Upper boundary contains an interval literal");
                current_arg(illegal_literal_idx) = -inf;
                illegal_boundary.sup(illegal_literal_idx) = true;
            endswitch
          endif
          switch argument
            case "l"
              l = current_arg;
            case "u"
              u = current_arg;
          endswitch
        endif
      endfor

    otherwise # nargin >= 3
      print_usage ();
      return
  endswitch

  ## Part 2
  ##
  ## Boundaries have been split into lower and upper boundaries and shall be
  ## converted to binary64 arrays with string parsing and outward rounding.
  ##
  ## l contains a cell array or an array of lower boundaries.
  ## u contains a cell array or an array of upper boundaries.
  ##
  ## Each of l and u will be converted into binary64 individually and will be
  ## stored in x.inf and x.sup respectively.

  isexact = true ();
  x = struct ("inf", inf (size (l)), ...
              "sup", -inf (size (u)));
  for [boundaries, key] = struct ("inf", {l}, "sup", {u})
    if (isfloat (boundaries) && isreal (boundaries))
      ## Simple case: the boundaries already are binary floating point
      ## numbers in single or double precision.
      ## This kind of operation is often used in internal functions and shall
      ## be fast.  We check for NaNs later.
      x.(key) = double (boundaries);
      possiblyundefined.(key) = overflow.(key) = false (size (boundaries));
      continue
    endif

    if (not (iscell (boundaries)))
      if (not (isnumeric (boundaries)))
        warning ("interval:InvalidOperand", ...
                 ["infsup: Invalid argument type, only strings, ", ...
                  "numerics, and cell arrays thereof are allowed"]);
        ## Unable to recover from this kind of error
        x = scalar_empty_interval;
        isexact = false;
        overflow = false;
        isnai = true;
        return
      endif
      boundaries = num2cell (boundaries);
    endif

    overflow.(key) = true (size (boundaries));
    possiblyundefined.(key) = false (size (boundaries));

    ## Track the entries in cell array boundaries, which haven't been
    ## converted yet.
    todo = true (size (boundaries));

    ## [,] = [-inf, +inf]
    unbound_idx = cellfun ("isempty", boundaries);
    switch key
      case "inf"
        x.inf(unbound_idx) = -inf;
      case "sup"
        x.sup(unbound_idx) = +inf;
    endswitch
    overflow.(key)(unbound_idx) = false;
    todo(unbound_idx) = false;

    ## In the cell array each entry must represent a scalar value.
    non_scalar_entry_idx = todo & not (...
                                        cellfun ("isscalar", boundaries) |...
                                        cellfun ("ischar", boundaries));
    if (any (non_scalar_entry_idx(:)))
      warning ("interval:UndefinedOperation", ...
               "Cell arrays of matrix entries do not contain scalar values");
         # Use default value of [empty] for these entries and continue
      todo(non_scalar_entry_idx) = false;
      illegal_boundary.(key)(non_scalar_entry_idx) = true;
    endif

    ## 64 bit integers: approximate in double precision.
    integer_idx = find (todo & ( ...
                                 cellfun ("isa", boundaries, {"uint64"}) ...
                                 | cellfun ("isa", boundaries, {"int64"})));
    integers = vertcat (boundaries{integer_idx});
    converted_integers = double (integers);
    exact_integer_local_idx = (converted_integers == integers);
    if (any (not (exact_integer_local_idx(:))))
      isexact = false;
      possiblyundefined.(key)(integer_idx(not (exact_integer_local_idx))) ...
      = true;
    endif
    ## Fix conversion in cases where rounding to nearest has resulted in the
    ## wrong value, i. e., in a value that has not been rounded outward,
    ## but inward.
    switch key
      case "inf"
        wrong_round_local_idx = (converted_integers > integers);
        converted_integers(wrong_round_local_idx) = ...
        mpfr_function_d ('minus', -inf, ...
                         converted_integers(wrong_round_local_idx), ...
                         pow2 (-1074));
      case "sup"
        wrong_round_local_idx = (converted_integers < integers);
        converted_integers(wrong_round_local_idx) = ...
        mpfr_function_d ('plus', +inf, ...
                         converted_integers(wrong_round_local_idx), ...
                         pow2 (-1074));
    endswitch
    x.(key)(integer_idx) = converted_integers;
    overflow.(key)(integer_idx) = false;
    todo(integer_idx) = false;

    ## Lossless conversion from binary32, binary64, (u)int8, (u)int16, (u)int32
    ## and logicals.
    real_idx = todo & ...
               ( ...
                 ( ...
                   cellfun ("isreal", boundaries) ...
                   & cellfun ("isfloat", boundaries) ...
                 ) ...
                 |   cellfun ("isinteger", boundaries) ...
                 |   cellfun ("islogical", boundaries)
               );
    x.(key)(real_idx) = double (vertcat (boundaries{real_idx}));
    overflow.(key)(real_idx) = false;
    todo(real_idx) = false;

    ## Complex numbers: not allowed, will be mapped to [empty].
    complex_idx = todo & cellfun ("iscomplex", boundaries);
    if (any (complex_idx(:)))
      warning ("interval:InvalidOperand", ...
               "infsup: Complex arguments are not permitted");
      todo(complex_idx) = false;
      illegal_boundary.(key)(complex_idx) = true;
    endif

    ## Other kinds of parameters that are not strings
    char_idx = todo & cellfun ("ischar", boundaries);
    if (any ((todo & not (char_idx))(:)))
      warning ("interval:InvalidOperand", ...
               "infsup: Illegal boundary: must be numeric or string");
      illegal_boundary.(key)(todo & not (char_idx)) = true;
    endif
    todo = char_idx;

    ## Hex strings
    hex_idx = find (todo & (strncmp (boundaries, "0x", 2) ...
                            | strncmp (boundaries, "+0x", 3) ...
                            | strncmp (boundaries, "-0x", 3)));
    switch key
      case "inf"
        direction = -inf;
      case "sup"
        direction = inf;
    endswitch
    for i = vec (hex_idx, 2)
      try
        [x.(key)(i), exact_conversion] = ...
        hex2double (boundaries{i}, direction);
        possiblyundefined.(key)(i) = not (exact_conversion);
        isexact = isexact && exact_conversion;
      catch
        warning ("interval:UndefinedOperation", lasterr ());
        illegal_boundary.(key)(i) = true;
      end_try_catch
    endfor
    overflow.(key)(hex_idx) = false;
    todo(hex_idx) = false;

    ## Selected boundary literals
    persistent boundary_const = struct (...
                                         "inf", ...
                                         struct (...
                                                  "-inf", -inf, ...
                                                  "-infinity", -inf, ...
                                                  "inf", inf, ...
                                                  "+inf", inf, ...
                                                  "infinity", inf, ...
                                                  "+infinity", inf, ...
                                                  "e",  0x56FC2A2 ...
                                                        * pow2 (-25) ...
                                                        + 0x628AED2 ...
                                                          * pow2 (-52), ...
                                                  "pi", 0x6487ED5 ...
                                                        * pow2 (-25) ...
                                                        + 0x442D180 ...
                                                          * pow2 (-55)), ...
                                         "sup", ...
                                         struct (...
                                                  "-inf", -inf, ...
                                                  "-infinity", -inf, ...
                                                  "inf", inf, ...
                                                  "+inf", inf, ...
                                                  "infinity", inf, ...
                                                  "+infinity", inf, ...
                                                  "e",  0x56FC2A2 ...
                                                        * pow2 (-25) ...
                                                        + 0x628AED4 ...
                                                          * pow2 (-52), ...
                                                  "pi", 0x6487ED5 ...
                                                        * pow2 (-25) ...
                                                        + 0x442D190 ....
                                                          * pow2 (-55)));
    for [val, lit] = boundary_const.(key)
      const_idx = todo & strcmp (boundaries, lit);
      x.(key)(const_idx) = val;
      overflow.(key)(const_idx) = false;
      possiblyundefined.(key)(const_idx) = isfinite (val);
      todo(const_idx) = false;
    endfor

    ## It remains the decimal boundary strings
    for i = vec (find (todo), 2)
      try
        boundary = boundaries{i};

        ## We have to parse a decimal string boundary and round the
        ## result up or down depending on the boundary
        ## (inf = down, sup = up).
        ## str2double will produce the correct answer in 50 % of
        ## all cases, because it uses rounding mode “to nearest”.
        ## The input and a double format approximation can be
        ## compared in a decimal floating point format without
        ## precision loss.

        if (strfind (boundary, "?"))
          ## Special case: uncertain-form
          [boundary, uncertain] = uncertainsplit (boundary);
        else
          uncertain = [];
        endif

        if (strfind (boundary, "/"))
          ## Special case: rational form
          boundary = strsplit (boundary, "/");
          if (length (boundary) ~= 2)
            warning ("interval:UndefinedOperation", ...
                     ["illegal " key " boundary: ", ...
                      "rational form must have single slash"]);
            illegal_boundary.(key)(i) = true;
            continue;
          endif
          [decimal, remainder] = decimaldivide (...
                                                 str2decimal (boundary{1}), ...
                                                 str2decimal (boundary{2}), 18);
          if (not (isempty (remainder.m)))
            ## This will guarantee the enclosure of the exact
            ## value
            decimal.m(19, 1) = 1;
            isexact = false ();
            if (key == "inf")
              possiblyundefined.(key)(i) = true;
            endif
          endif
          ## Write result back into boundary for conversion to
          ## double
          boundary = ["0.", num2str(decimal.m)', ...
                      "e", num2str(decimal.e)];
          if (decimal.s)
            boundary = ["-", boundary];
          endif
        else
          decimal = str2decimal (boundary);
        endif

        ## Parse and add uncertainty
        if (not (isempty (uncertain)))
          uncertain = str2decimal (uncertain);
          if ((key == "inf") == decimal.s)
            uncertain.s = decimal.s;
          else
            uncertain.s = not (decimal.s);
          endif
          decimal = decimaladd (decimal, uncertain);
          ## Write result back into boundary for conversion to
          ## double
          boundary = ["0.", num2str(decimal.m)', ...
                      "e", num2str(decimal.e)];
          if (decimal.s)
            boundary = ["-", boundary];
          endif
        endif
        clear uncertain;

        ## Check if number is outside of range
        ## Realmax == 1.7...e308 == 0.17...e309
        if (decimal.e > 309 || ...
            (decimal.e == 309 && ...
             decimal.s && ...
             decimalcompare (double2decimal (-realmax ()), ...
                             decimal) > 0) || ...
            (decimal.e == 309 && ...
             not (decimal.s) && ...
             decimalcompare (double2decimal (realmax ()), ...
                             decimal) < 0))
          switch key
            case "inf"
              if (decimal.s) # -inf ... -realmax
                x.inf(i) = -inf;
              else # realmax ... inf
                x.inf(i) = realmax ();
                overflow.inf(i) = false;
              endif
            case "sup"
              if (decimal.s) # -inf ... -realmax
                x.sup(i) = -realmax ();
                overflow.sup(i) = false;
              else # realmax ... inf
                x.sup(i) = inf;
              endif
          endswitch
          possiblyundefined.(key)(i) = true;
          isexact = false;
          continue
        endif
        overflow.(key)(i) = false;

        ## Compute approximation, this only works between ± realmax
        binary = str2double (strrep (boundary, ",", "."));

        ## Check approximation value
        comparison = decimalcompare (double2decimal (binary), ...
                                     decimal);
        if (comparison ~= 0)
          possiblyundefined.(key)(i) = true;
          isexact = false;
        endif
        if (comparison == 0 || ... # approximation is exact
            (comparison < 0 && key == "inf") || ... # lower bound
            (comparison > 0 && key == "sup")) # upper bound
          x.(key)(i) = binary;
        else
          ## Approximation is not exact and not rounded as needed
          ## However, because of faithful rounding the
          ## approximation is right next to the desired number.
          switch key
            case "inf"
              x.inf(i) = mpfr_function_d ('minus', -inf, ...
                                          binary, pow2 (-1074));
            case "sup"
              x.sup(i) = mpfr_function_d ('plus', +inf, ...
                                          binary, pow2 (-1074));
          endswitch
        endif
      catch
        warning ("interval:UndefinedOperation", lasterr ());
        illegal_boundary.(key)(i) = true;
      end_try_catch
    endfor
  endfor

  ## Part 3
  ##
  ## Check boundaries individually after conversion to double

  ## NaNs are illegal values
  for [boundary, key] = struct ("inf", {x.inf}, "sup", {x.sup})
    nanvalue = isnan (boundary);
    if (any (nanvalue(:)))
      warning ("interval:UndefinedOperation", ...
               "input contains NaN values");
      illegal_boundary.(key)(nanvalue) = true;
    endif
  endfor

  ## normalize boundaries:
  ## representation of the set containing only zero is always [-0,+0]
  x.inf(x.inf == 0) = -0;
  x.sup(x.sup == 0) = +0;

  ## Part 4
  ##
  ## Broadcast boundaries and final checks

  if (nargout >= 3)
    overflow = overflow.inf | overflow.sup;
    overflow(x.inf > -inf & x.sup < inf) = false;
  endif

  x.inf = x.inf - zeros (size (x.sup));
  x.sup = x.sup + zeros (size (x.inf));

  possiblyundefined = possiblyundefined.inf & possiblyundefined.sup;
  if (any (possiblyundefined(:)))
    if (not (iscell (l)) && not (iscell (u)))
      ## infsup (x, x) or infsup (x) is not possibly undefined
      possiblyundefined(l == u) = false;
    else
      ## infsup ("x", "x") or infsup ("x") is not possibly undefined
      if (not (iscell (l)))
        l = num2cell (l);
      endif
      if (not (iscell (u)))
        u = num2cell (u);
      endif
      possiblyundefined(cellfun ("isequal", l, u)) = false;
    endif
  endif

  ## Non-empty intervals are always legal.
  isnai(x.inf <= x.sup) = false;

  ## Check for illegal boundaries [inf,inf] and [-inf,-inf].
  illegal_inf_idx = not (isfinite (x.inf (x.inf == x.sup)));
  if (any (illegal_inf_idx(:)))
    warning ("interval:UndefinedOperation", ...
             "illegal interval boundaries: infimum = supremum = +/- infinity");
    isnai(find (x.inf == x.sup)(illegal_inf_idx)) = true;
  endif

  ## Illegal boundaries make illegal intervals,
  ## we have triggered a warning already (see above).
  isnai(illegal_boundary.inf | illegal_boundary.sup) = true;

  ## Check boundary order
  ## isnai has been initialized with -1.  Any non-empty or legal empty intervals
  ## have been set to 0.  Any illegal interval literals or illegal boundaries
  ## have been set to +1.  Any intervals with inf > sup still have their initial
  ## value of -1.
  wrong_boundary_order_idx = signbit (isnai);
  if (any (wrong_boundary_order_idx(:)))
    warning ("interval:UndefinedOperation", ...
             "illegal interval boundaries: infimum greater than supremum");
    isnai(wrong_boundary_order_idx) = true;
  endif
  isnai = logical(isnai);

  ## Return [empty] for any illegal intervals.
  x.inf(isnai) = +inf;
  x.sup(isnai) = -inf;
  possiblyundefined(isnai) = false;
  isexact = isexact && not (any (isnai(:)));

  ## Check for possibly wrong boundary order.
  if (any (possiblyundefined(:)))
    ## Let a, b, and c be three consecutive floating point numbers.
    ##
    ## If a < u < b < l < c, then u and l will both be mapped to the same
    ## number b by outward rounding.
    ##
    ## If a < u < l < b, then u and l will both be mapped to consecutive
    ## floating point numbers a and b.
    if (any ((x.inf(possiblyundefined) == x.sup(possiblyundefined))(:)) ...
        || ...
        any ((max (-realmax, ...
                   mpfr_function_d ('plus',...
                                    +inf, ...
                                    x.inf(possiblyundefined), ...
                                    pow2 (-1074))) ...
              == x.sup(possiblyundefined))(:)))
      warning ("interval:PossiblyUndefinedOperation", ...
               "infimum may be greater than supremum");
    endif
  endif

  x = class (x, "infsup");
endfunction

%!# Empty intervals
%!test
%! x = infsup ();
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!test
%! x = infsup ("[]");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!test
%! x = infsup ("[ ]");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!test
%! x = infsup ("[\t]");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!test
%! x = infsup ("[empty]");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!test
%! x = infsup ("[EMPTY]");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!test
%! x = infsup ("[ empty ]");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!test
%! x = infsup ("\t[\t Empty\t]\t");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);

%!# Entire interval
%!test
%! x = infsup ("[,]");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("[entire]");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("[ENTIRE]");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("[ entire ]");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup (" [Entire \t] ");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("[-inf,+inf]");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("[-infinity, +infinity]");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("[-INF, +INFinitY]");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);

%!# double boundaries
%!test
%! x = infsup (0);
%! assert (inf (x), 0);
%! assert (sup (x), 0);
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
%!test
%! x = infsup (2, 3);
%! assert (inf (x), 2);
%! assert (sup (x), 3);
%!test
%! x = infsup (-inf, 0.1);
%! assert (inf (x), -inf);
%! assert (sup (x), 0.1);
%!test
%! x = infsup (-inf, +inf);
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);

%!# NaN values
%!warning id=interval:UndefinedOperation
%! x = infsup (nan);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!warning id=interval:UndefinedOperation
%! x = infsup (nan, 2);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!warning id=interval:UndefinedOperation
%! x = infsup (3, nan);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);

%!# illegal numeric boundaries
%!warning id=interval:UndefinedOperation
%! x = infsup (+inf, -inf);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!warning id=interval:UndefinedOperation
%! x = infsup (+inf, +inf);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!warning id=interval:UndefinedOperation
%! x = infsup (-inf, -inf);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!warning id=interval:UndefinedOperation
%! x = infsup (3, 2);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!warning id=interval:UndefinedOperation
%! x = infsup (3, -inf);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);

%!# double matrix
%!test
%! x = infsup (magic (4));
%! assert (inf (x), magic (4));
%! assert (sup (x), magic (4));
%!test
%! x = infsup (magic (3), magic (3) + 1);
%! assert (inf (x), magic (3));
%! assert (sup (x), magic (3) + 1);
%!warning id=interval:UndefinedOperation
%! x = infsup (nan (3));
%! assert (inf (x), +inf (3));
%! assert (sup (x), -inf (3));
%!test
%! x = infsup (-inf (3), +inf (3));
%! assert (inf (x), -inf (3));
%! assert (sup (x), +inf (3));

%!# decimal boundaries
%!test
%! x = infsup ("0.1");
%! assert (inf (x), 0.1 - eps / 16);
%! assert (sup (x), 0.1);
%!test
%! x = infsup ("0.1e1");
%! assert (inf (x), 1);
%! assert (sup (x), 1);

%!# hexadecimal boundaries
%!test
%! x = infsup ("0xff");
%! assert (inf (x), 255);
%! assert (sup (x), 255);
%!test
%! x = infsup ("0xff.1");
%! assert (inf (x), 255.0625);
%! assert (sup (x), 255.0625);
%!test
%! x = infsup ("0xff.1p-1");
%! assert (inf (x), 127.53125);
%! assert (sup (x), 127.53125);

%!# named constants
%!test
%! x = infsup ("pi");
%! assert (inf (x), pi);
%! assert (sup (x), pi + 2 * eps);
%!test
%! x = infsup ("e");
%! assert (inf (x), e);
%! assert (sup (x), e + eps);

%!# uncertain form
%!test
%! x = infsup ("32?");
%! assert (inf (x), 31.5);
%! assert (sup (x), 32.5);
%!test
%! x = infsup ("32?8");
%! assert (inf (x), 24);
%! assert (sup (x), 40);
%!test
%! x = infsup ("32?u");
%! assert (inf (x), 32);
%! assert (sup (x), 32.5);
%!test
%! x = infsup ("32?d");
%! assert (inf (x), 31.5);
%! assert (sup (x), 32);
%!test
%! x = infsup ("32??");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("32??d");
%! assert (inf (x), -inf);
%! assert (sup (x), 32);
%!test
%! x = infsup ("32??u");
%! assert (inf (x), 32);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("32?e5");
%! assert (inf (x), 3150000);
%! assert (sup (x), 3250000);

%!# rational form
%!test
%! x = infsup ("6/9");
%! assert (inf (x), 2 / 3);
%! assert (sup (x), 2 / 3 + eps / 2);
%!test
%! x = infsup ("6e1/9");
%! assert (inf (x), 20 / 3 - eps * 2);
%! assert (sup (x), 20 / 3);
%!test
%! x = infsup ("6/9e1");
%! assert (inf (x), 2 / 30);
%! assert (sup (x), 2 / 30 + eps / 16);
%!test
%! x = infsup ("-6/9");
%! assert (inf (x), -(2 / 3 + eps / 2));
%! assert (sup (x), -2 / 3);
%!test
%! x = infsup ("6/-9");
%! assert (inf (x), -(2 / 3 + eps / 2));
%! assert (sup (x), -2 / 3);
%!test
%! x = infsup ("-6/-9");
%! assert (inf (x), 2 / 3);
%! assert (sup (x), 2 / 3 + eps / 2);
%!test
%! x = infsup ("6.6/9.9");
%! assert (inf (x), 2 / 3);
%! assert (sup (x), 2 / 3 + eps / 2);

%!# inf-sup interval literal
%!test
%! x = infsup ("[2, 3]");
%! assert (inf (x), 2);
%! assert (sup (x), 3);
%!test
%! x = infsup ("[0.1]");
%! assert (inf (x), 0.1 - eps / 16);
%! assert (sup (x), 0.1);
%!test
%! x = infsup ("[0xff, 0xff.1]");
%! assert (inf (x), 255);
%! assert (sup (x), 255.0625);
%!test
%! x = infsup ("[e, pi]");
%! assert (inf (x), e);
%! assert (sup (x), pi + 2 * eps);
%!test
%! x = infsup ("[6/9, 6e1/9]");
%! assert (inf (x), 2 / 3);
%! assert (sup (x), 20 / 3);

%!# corner cases
%!test
%! x = infsup (",");
%! assert (inf (x), -inf);
%! assert (sup (x), +inf);
%!test
%! x = infsup ("[, 3]");
%! assert (inf (x), -inf);
%! assert (sup (x), 3);
%!test
%! x = infsup ("", "3");
%! assert (inf (x), -inf);
%! assert (sup (x), 3);
%!test
%! x = infsup ("[2, ]");
%! assert (inf (x), 2);
%! assert (sup (x), inf);
%!test
%! x = infsup ("2", "");
%! assert (inf (x), 2);
%! assert (sup (x), inf);

%!# decimal vector
%!test
%! x = infsup (["0.1"; "0.2"; "0.3"]);
%! assert (inf (x), [0.1 - eps / 16; 0.2 - eps / 8; 0.3]);
%! assert (sup (x), [0.1; 0.2; 0.3 + eps / 8]);
%!test
%! x = infsup ("0.1; 0.2; 0.3");
%! assert (inf (x), [0.1 - eps / 16; 0.2 - eps / 8; 0.3]);
%! assert (sup (x), [0.1; 0.2; 0.3 + eps / 8]);
%!test
%! x = infsup ("0.1\n0.2\n0.3");
%! assert (inf (x), [0.1 - eps / 16; 0.2 - eps / 8; 0.3]);
%! assert (sup (x), [0.1; 0.2; 0.3 + eps / 8]);

%!# cell array with mixed boundaries
%!test
%! x = infsup ({"0.1", 42; "e", "3.2/8"}, {"0xffp2", "42e1"; "pi", 2});
%! assert (inf (x), [0.1 - eps / 16, 42; e, 0.4 - eps / 4]);
%! assert (sup (x), [1020, 420; pi + 2 * eps, 2]);
%!test
%! x = infsup ({"[2, 3]", "3/4", "[Entire]", "42?3", 1, "0xf"});
%! assert (inf (x), [2, 0.75, -inf, 39, 1, 15]);
%! assert (sup (x), [3, 0.75, +inf, 45, 1, 15]);

%!# broadcasting
%!test
%! x = infsup (magic (3), 10);
%! assert (inf (x), magic (3));
%! assert (sup (x), 10 .* ones (3));
%!test
%! x = infsup (zeros (1, 20), ones (20, 1));
%! assert (inf (x), zeros (20, 20));
%! assert (sup (x), ones (20, 20));

%!# nai
%!warning id=interval:UndefinedOperation
%! x = infsup ("[nai]");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!warning id=interval:UndefinedOperation
%! x = infsup ("Ausgeschnitzel");
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);

%!# interval literals vs. two arguments
%!warning id=interval:UndefinedOperation
%! x = infsup ("[empty]", 42);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);
%!warning id=interval:UndefinedOperation
%! x = infsup ("0?", 42);
%! assert (inf (x), +inf);
%! assert (sup (x), -inf);

%!# extraction of single errors
%!warning id=interval:UndefinedOperation
%! x = infsup ("0 1 2 [xxx] 3 4");
%! assert (inf (x), [0 1 2 +inf 3 4]);
%! assert (sup (x), [0 1 2 -inf 3 4]);
%!warning id=interval:UndefinedOperation
%! x = infsup ({1 2; 3 "[xxx]"});
%! assert (inf (x), [1 2; 3 +inf]);
%! assert (sup (x), [1 2; 3 -inf]);

%!# complex values
%!warning id=interval:InvalidOperand
%! x = infsup ([1 2 3+i 4+0i]);
%! assert (inf (x), [1 2 +inf 4]);
%! assert (sup (x), [1 2 -inf 4]);

%!# inaccurate conversion
%!warning id=interval:PossiblyUndefinedOperation
%! x = infsup ("1.000000000000000000002", "1.000000000000000000001");
%! assert (inf (x), 1);
%! assert (sup (x), 1 + eps);
%!test
%! n = uint64(2 ^ 53);
%! x = infsup (n, n + 1);
%! assert (inf (x), double (n));
%! assert (sup (x), double (n + 2));
%!test
%! n = uint64(2 ^ 53);
%! x = infsup ({n}, n + 1);
%! assert (inf (x), double (n));
%! assert (sup (x), double (n + 2));
%!test
%! n = uint64(2 ^ 53);
%! x = infsup (n + 1, n + 1);
%! assert (inf (x), double (n));
%! assert (sup (x), double (n + 2));
%!test
%! n = uint64(2 ^ 54);
%! x = infsup (n, n + 1);
%! assert (inf (x), double (n));
%! assert (sup (x), double (n + 4));
%!warning id=interval:PossiblyUndefinedOperation
%! n = uint64(2 ^ 54);
%! x = infsup (n + 1, n + 2);
%! assert (inf (x), double (n));
%! assert (sup (x), double (n + 4));
%!warning id=interval:PossiblyUndefinedOperation
%! x = infsup ("pi", "3.141592653589793");
%! assert (inf (x), pi);
%! assert (sup (x), pi);
%!warning id=interval:PossiblyUndefinedOperation
%! x = infsup ("pi", "3.1415926535897932");
%! assert (inf (x), pi);
%! assert (sup (x), pi + 2 * eps);

%!# isexact flag
%!test
%! [~, isexact] = infsup ();
%! assert (isexact);
%!test
%! [~, isexact] = infsup (0);
%! assert (isexact);
%!test
%! [~, isexact] = infsup ("1 2 3");
%! assert (isexact, true);
%!test
%! [~, isexact] = infsup ("1 2 3.1");
%! assert (isexact, false);
%!warning
%! [~, isexact] = infsup ("[nai]");
%! assert (not (isexact));

%!# overflow flag
%!test
%! [~, ~, overflow] = infsup ();
%! assert (not (overflow));
%!test
%! [~, ~, overflow] = infsup (0);
%! assert (not (overflow));
%!test
%! [~, ~, overflow] = infsup ([1 2 3]);
%! assert (overflow, false (1, 3));
%!warning
%! [~, ~, overflow] = infsup ("[nai]");
%! assert (not (overflow));
%!test
%! [~, ~, overflow] = infsup ("1e3000");
%! assert (overflow);
%!test
%! [~, ~, overflow] = infsup ("[1, inf]");
%! assert (not (overflow));

%!# isnai flag
%!test
%! [~, ~, ~, isnai] = infsup ();
%! assert (not (isnai));
%!test
%! [~, ~, ~, isnai] = infsup (0);
%! assert (not (isnai));
%!test
%! [~, ~, ~, isnai] = infsup ([1 2 3]);
%! assert (isnai, false (1, 3));
%!warning
%! [~, ~, ~, isnai] = infsup ("[nai]");
%! assert (isnai);
%!warning
%! [~, ~, ~, isnai] = infsup ("xxx");
%! assert (isnai);
%!warning
%! [~, ~, ~, isnai] = infsup ("1 2 xxx 4");
%! assert (isnai, [false, false, true, false]);
%!warning
%! [~, ~, ~, isnai] = infsup ("[-inf, inf] [inf, inf]");
%! assert (isnai, [false, true]);

%!# N-dimensional arrays
%!test
%! x = infsup (zeros (2, 2, 2));
%! assert (x.inf, zeros (2, 2, 2));
%! assert (x.sup, zeros (2, 2, 2));
%!test
%! x = infsup (zeros (2, 2, 2), ones (2, 2, 2));
%! assert (x.inf, zeros (2, 2, 2));
%! assert (x.sup, ones (2, 2, 2));
%!test
%! x = infsup (zeros (2, 1, 2, 1, 2, 1), ones (1, 3, 1, 3, 1, 3));
%! assert (x.inf, zeros (2, 3, 2, 3, 2, 3));
%! assert (x.sup, ones (2, 3, 2, 3, 2, 3));
%!test
%! c1 = reshape ({1, 2, 3, 4, 5, 6, 7, 8}, 2, 2, 2);
%! c2 = reshape ({2, 3, 4, 5, 6, 7, 8, 9}, 2, 2, 2);
%! x = infsup (c1, c2);
%! assert (x.inf, reshape (1:8, 2, 2, 2));
%! assert (x.sup, reshape (2:9, 2, 2, 2));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.("b-numsToInterval");
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     infsup (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.("b-numsToInterval");
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (infsup (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.("b-numsToInterval");
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
%! assert (isequaln (infsup (in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.("b-textToInterval");
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     infsup (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.("b-textToInterval");
%! in1 = vertcat (testcases.in);
%! out = vertcat (testcases.out);
%! assert (isequaln (infsup (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.("b-numsToInterval");
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
%! assert (isequaln (infsup (in1, in2), out));

%!warning
%! testcases = testdata.PossiblyUndefinedOperation.infsup.("b-textToInterval");
%! for testcase = [testcases]'
%!   lastwarn ("", "");
%!   assert (isequaln (...
%!     infsup (testcase.in{1}), ...
%!     testcase.out));
%!   assert (nthargout (2, @lastwarn), "interval:PossiblyUndefinedOperation");
%! endfor

%!warning
%! testcases = testdata.UndefinedOperation.infsup.("b-textToInterval");
%! for testcase = [testcases]'
%!   lastwarn ("", "");
%!   assert (isequaln (...
%!     infsup (testcase.in{1}), ...
%!     testcase.out));
%!   assert (nthargout (2, @lastwarn), "interval:UndefinedOperation");
%! endfor

%!warning
%! testcases = testdata.UndefinedOperation.infsup.("b-numsToInterval");
%! for testcase = [testcases]'
%!   lastwarn ("", "");
%!   assert (isequaln (...
%!     infsup (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%!   assert (nthargout (2, @lastwarn), "interval:UndefinedOperation");
%! endfor

/*
  Copyright 2018 Oliver Heimlich
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

#include <octave/oct.h>
#include <mpfr.h>
#include "mpfr_commons.h"

enum interval_form
{
  INF_SUP,
  UNCERTAIN_SYMMETRIC,
  UNCERTAIN_UP,
  UNCERTAIN_DOWN
};

enum text_case
{
  TITLE_CASE,
  LOWER_CASE,
  UPPER_CASE
};

enum plus_sign
{
  ALWAYS,
  INNER_ZERO,
  NEVER
};

struct interval_format
{
  // preferred overall field width
  uint16_t total_width;
  // whether output is in inf-sup of uncertain form
  // for uncertain form: default symmetric or one sided (u or d) forms
  interval_form form;

  // how Empty, Entire, and NaI are output
  text_case empty_entire_nai_case;
  // whether Entire becomes [Entire] or [-Inf, Inf] (only in inf-sup form)
  bool entire_boundaries;

  // [-1, 1], [-1, +1], [+1, +2]
  plus_sign display_plus;

  bool left_justify;
  bool pad_with_zeros;
  // field with of l, u, and m
  uint16_t number_width;
  // number of digits after the point (for l, u, and m)
  uint16_t number_precision;
  // field width of r (in uncertain form)
  uint16_t radius_width;
  // standard C format specifier (see printf)
  char number_format;

  // whether interval bounds have punctuation, e. g.
  // [1.234, 2.345] or 1.234 2.345
  bool hide_punctuation;
};

const interval_format
GENERAL_PURPOSE_LAYOUT =
{
  .total_width = 0,
  .form = INF_SUP,
  .empty_entire_nai_case = TITLE_CASE,
  .entire_boundaries = false,
  .display_plus = INNER_ZERO,
  .left_justify = false,
  .pad_with_zeros = false,
  .number_width = 0,
  .number_precision = 6,
  .radius_width = 0,
  .number_format = 'g',
  .hide_punctuation = false
};

// Parse an interval format string for all layout options.
interval_format
parse_conversion_specifier
(
  std::string buffer,
  std::size_t &characters_read
)
{
  interval_format
  layout = GENERAL_PURPOSE_LAYOUT;

  // Parse overall width
  {
    std::size_t
    end_of_overall_width = buffer.find_first_not_of ("0123456789");
    if (end_of_overall_width != std::string::npos)
      if (buffer.at (end_of_overall_width) == ':')
        {
          std::string
          overall_width = buffer.substr (0, end_of_overall_width);

          layout.total_width = atol (overall_width.c_str ());

          buffer = buffer.substr (end_of_overall_width);
          characters_read += end_of_overall_width;
          // skip ':'
          buffer = buffer.substr (1);
          characters_read ++;
        }
  }

  // Detect punctuation for inf-sup form, opening square bracket
  if (buffer.compare (0, 1, std::string ("[")) != 0)
    layout.hide_punctuation = true;
  else
    {
      buffer = buffer.substr (1);
      characters_read ++;
    }

  // Parse flags
  {
    bool is_flag = true;
    while (is_flag && !buffer.empty ())
      {
        switch (buffer.at (0))
          {
            case 'C':
              layout.empty_entire_nai_case = UPPER_CASE;
              break;
            case 'c':
              layout.empty_entire_nai_case = LOWER_CASE;
              break;
            case '<':
              layout.entire_boundaries = true;
              break;
            case '-':
              layout.left_justify = true;
              break;
            case '+':
              layout.display_plus = ALWAYS;
              break;
            case ' ':
              layout.display_plus = NEVER;
              break;
            case '0':
              layout.pad_with_zeros = true;
              break;
            case 'd':
              layout.form = UNCERTAIN_DOWN;
              break;
            case 'u':
              layout.form = UNCERTAIN_UP;
              break;
            default:
              is_flag = false;
          }
        if (is_flag)
          {
            buffer = buffer.substr (1);
            characters_read ++;
          }
      }
  }

  // Parse number field width
  {
    std::size_t
    end_of_width = buffer.find_first_not_of ("0123456789");

    std::string
    width = buffer.substr (0, end_of_width);

    layout.number_width = atol (width.c_str ());

    buffer = buffer.substr (width.length ());
    characters_read += width.length ();
  }

  // Parse number precision
  if (!buffer.empty ())
    if (buffer.at (0) == '.')
      {
        // skip '.'
        buffer = buffer.substr (1);
        characters_read ++;

        std::size_t
        end_of_precision = buffer.find_first_not_of ("0123456789");
        std::string
        precision = buffer.substr (0, end_of_precision);

        layout.number_precision = atol (precision.c_str ());

        buffer = buffer.substr (precision.length ());
        characters_read += precision.length ();
      }

  // Parse uncertain specifier
  if (!buffer.empty ())
    if (buffer.at (0) == '?')
      {
        if (layout.form == INF_SUP)
          {
            if (!layout.hide_punctuation)
              {
                error ("illegal conversion specifier: "
                      "you cannot use '?' in inf-sup form or missing ']'");
                return layout;
              }
            layout.form = UNCERTAIN_SYMMETRIC;
          }
        buffer = buffer.substr (1);
        characters_read ++;
      }

  // Parse radius width (only in uncertain form)
  if (layout.form == UNCERTAIN_SYMMETRIC ||
      layout.form == UNCERTAIN_DOWN ||
      layout.form == UNCERTAIN_UP)
    {
      std::size_t
      end_of_radius_width = buffer.find_first_not_of ("0123456789");
      std::string
      radius_width = buffer.substr (0, end_of_radius_width);

      layout.radius_width = atol (radius_width.c_str ());

      buffer = buffer.substr (radius_width.length ());
      characters_read += radius_width.length ();
    }

  // Parse number format
  {
    if (buffer.empty ())
      {
        error ("illegal conversion specifier: "
              "missing number format");
        return layout;
      }
    layout.number_format = buffer.at (0);
    buffer = buffer.substr (1);
    characters_read ++;
    switch (layout.number_format)
      {
        case 'e': case 'E':
        case 'f': case 'F':
        case 'g': case 'G':
          // always valid
          break;
        case 'a': case 'A':
          if (layout.form != INF_SUP)
            {
              error ("illegal conversion specifier: "
                    "hexadecimal format is only allowed in inf-sup form");
              return layout;
            }
          break;
        default:
          error ("illegal conversion specifier: "
                "unrecognized number format");
          return layout;
      }
  }

  // Parse closing square bracket
  if (layout.form == INF_SUP && !layout.hide_punctuation)
    {
      if (buffer.compare (0, 1, std::string ("]")) != 0)
        {
          error ("illegal conversion specifier: "
                "missing ']'");
          return layout;
        }
      buffer = buffer.substr (1);
      characters_read ++;
    }

  return layout;
}

// Compute a number format string for MPFR, which can be used to compute
// string representations of interval boundaries and the interval midpoint.
std::string
to_mpfr_format_string
(
  interval_format layout
)
{
  std::ostringstream format_string;

  format_string << "%";
  if (layout.number_width > 0)
    {
      if (layout.left_justify)
        format_string << "-";

      if (layout.display_plus == ALWAYS)
        format_string << "+";

      if (layout.pad_with_zeros)
        format_string << "0";

      format_string << layout.number_width;
    }

  format_string << "." << layout.number_precision;

  format_string << "R*";

  format_string << layout.number_format;

  return format_string.str ();
}

struct shared_conversion_resources
{
  // number format string for MPFR, can be used for a list of intervals
  const char *mpfr_template;
  // temporary buffer for to-string-conversion
  char *buf;
  // temporary MPFR variable with binary64 precision, can be used for
  // conversion and directed rounding operations
  mpfr_t mp;
  // flag, whether all to-string-conversions have been lossless
  bool is_exact;
};

// Convert a scalar double to string with directed rouding using MPFR
std::string
mpfr_to_string_d
(
  shared_conversion_resources &stat,
  const double &x,
  const mpfr_rnd_t &rnd
)
{
  mpfr_set_d (stat.mp, x, MPFR_RNDZ);
  mpfr_sprintf (stat.buf, stat.mpfr_template, rnd, stat.mp);
  std::string retval(stat.buf);

  if (stat.is_exact)
    {
      mpfr_rnd_t complementary_rnd;
      switch (rnd)
        {
          case MPFR_RNDD: complementary_rnd = MPFR_RNDU; break;
          case MPFR_RNDU: complementary_rnd = MPFR_RNDD; break;
          case MPFR_RNDZ: complementary_rnd = MPFR_RNDA; break;
          case MPFR_RNDA: complementary_rnd = MPFR_RNDZ; break;
          default: complementary_rnd = MPFR_RNDN;
        }

      mpfr_sprintf (stat.buf, stat.mpfr_template, complementary_rnd, stat.mp);
      stat.is_exact = (retval == stat.buf);
    }

  return retval;
}

// Lossless conversion of a scalar double to hexadecimal string
std::string
double_to_hex_string
(
  shared_conversion_resources &stat,
  const double &x
)
{
  return std::string ("to be copied from mpfr_to_string_d.cc");
}

// Convert a scalar double to string with directed rouding
std::string
double_to_string
(
  const interval_format &layout,
  shared_conversion_resources &stat,
  const double &x,
  const mpfr_rnd_t &rnd
)
{
  if (layout.number_format == 'a' || layout.number_format == 'A')
    return double_to_hex_string (stat, x);
  else
    return mpfr_to_string_d (stat, x, rnd);
}

// Compute the string representation of a scalar interval.
std::string
interval_to_text
(
  const interval_format &layout,
  shared_conversion_resources &stat,
  const double &inf,
  const double &sup,
  const uint8_t *dec = NULL
)
{
  std::string l;
  if (layout.form == INF_SUP || layout.form == UNCERTAIN_UP)
    l = double_to_string (layout, stat, inf, MPFR_RNDD);

  std::string u;
  if (layout.form == INF_SUP || layout.form == UNCERTAIN_DOWN)
    u = double_to_string (layout, stat, sup, MPFR_RNDU);

  std::string m;
  if (layout.form == UNCERTAIN_SYMMETRIC)
  {
    m = double_to_string (layout, stat, inf / 2 + sup / 2, MPFR_RNDZ);
  }

  return "[" + l + ", " + u + "]";
}

// Compute the string representations of an array of intervals.
// 2nd return value: flag, whether conversion has been lossless
std::pair <Array <std::string>, bool>
interval_to_text
(
  const interval_format &layout,
  const NDArray &inf,
  const NDArray &sup,
  const uint8NDArray *dec = NULL
)
{
  // Initialize temporary variables for conversion
  char * mpfr_template;
  {
    std::string s = to_mpfr_format_string (layout);
    mpfr_template = new char [s.length () + 1];
    std::strcpy (mpfr_template, s.c_str ());
  }
  shared_conversion_resources stat =
    {
      .mpfr_template = mpfr_template,
      .buf = new char[768],
      .mp = {},
      .is_exact = true
    };
  mpfr_init2 (stat.mp, BINARY64_PRECISION);

  Array <std::string> interval_literals (inf.dims ());

  const octave_idx_type n = inf.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      const double l = inf.elem (i);
      const double u = sup.elem (i);

      std::string s;
      if (dec == NULL)
        s = interval_to_text (layout, stat, l, u);
      else
        {
          const uint8_t d = (*dec).elem (i);
          s = interval_to_text (layout, stat, l, u, &d);
        }

      interval_literals(i) = s;
    }

  mpfr_clear (stat.mp);
  delete[] stat.buf;
  delete[] mpfr_template;

  return std::pair <Array <std::string>, bool>
    (interval_literals, stat.is_exact);
}

DEFUN_DLD (intervaltotext2, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@deftypefun {@var{s} =} intervaltotext (@var{X})\n"
  "@deftypefunx {@var{s} =} intervaltotext (@var{X}, @var{cs})\n"
  "\n"
  "Convert interval @var{X} to an interval literal string @var{s}, which "
  "contains @var{X}."
  "\n\n"
  "Output @var{s} is a simple string for scalar intervals, and a cell array "
  "of strings for interval arrays."
  "\n\n"
  "The interval boundaries of @var{X} are stored in binary floating point "
  "format and are converted to decimal or hexadecimal format with possible "
  "precision loss.  If output is not exact, the boundaries are rounded "
  "accordingly (e. g. the upper boundary is rounded towards infinite for "
  "output representation)."
  "\n\n"
  "The desired layout of interval literal @var{s} can be customized with "
  "conversion specifier @var{cs} as follows."
  "\n\n"
  "@table @code\n"
  "@item @var{overall_width} : "
  "[ @var{flags} @var{width} . @var{precision} @var{conversion} ]\n"
  "The output shall be an interval literal in inf-sup form (default).  "
  "Its format may be customized by the following options:"
  "\n"
  "@itemize\n"
  "@item\n"
  "The preferred @var{overall_width} for the interval string @var{s}.  If "
  "specified, it must be followed by a colon.  Use this option to vertically "
  "align a list of intervals."
  "\n"
  "@item\n"
  "To output the bounds of interval @var{X} without punctuation, omit the "
  "square brackets in the conversion specifier.  For instance, this might be "
  "a convenient way to write intervals to a file for use by another "
  "application."
  "\n"
  "@item\n"
  "The number format specification for the interval boundaries may be "
  "prefixed by the following @var{flags} to modify the default format:"
  "\n"
  "@table @code\n"
  "@item C\n"
  "Use upper case for Entire, Empty, and NaI\n"
  "@item c\n"
  "Use lower case for Entire, Empty, and NaI\n"
  "@item <\n"
  "Output Entire as @code{[-Inf, +Inf]} instead of @code{[Entire]}\n"
  "@item -\n"
  "Left justify within the given field width\n"
  "@item +\n"
  "Always use a plus sign for positive numbers.  By default the plus sign is "
  "only used for intervals with an inner zero.\n"
  "@item @ \n"
  "Never use a plus sign for positive numbers\n"
  "@item 0\n"
  "Left-pads the numbers with zeros instead of spaces within the field width\n"
  "@end table"
  "\n"
  "@item\n"
  "The preferred field @var{width} for upper and lower boundaries."
  "\n"
  "@item\n"
  "The @var{precision} for upper and lower boundaries, that is the number of "
  "digits after the point.  If specified, it must be preceded by a point."
  "\n"
  "@item\n"
  "The number format @var{conversion} defines the radix and notation of lower "
  "and upper boundaries.  This is the only mandatory component of the "
  "conversion specifier.  The following values are supported: @code{f} / "
  "@code{F} (for decimal floating-point), @code{e} / @code{E} (scientific "
  "notation), @code{g} / @code{G} (use either decimal floating-point or "
  "scientific notation, depending on what is more appropriate for the "
  "magnitude of the number), @code{a} / @code{A} (hexadecimal floating-point)."
  "\n"
  "@end itemize\n"
  "\n"
  "@item @var{overall_width} : "
  "@var{flags} @var{width} . @var{precision} ? @var{radius_width} @var{conversion}\n"
  "The output shall be an interval literal in uncertain form.  Its format may "
  "be customized by the following options:"
  "\n"
  "@itemize\n"
  "@item\n"
  "The preferred @var{overall_width} for the interval string @var{s}.  If "
  "specified, it must be followed by a colon.  Use this option to vertically "
  "align a list of intervals."
  "\n"
  "@item\n"
  "The number format specification for the interval midpoint may be "
  "prefixed by the following @var{flags} to modify the default format:"
  "\n"
  "@table @code\n"
  "@item d\n"
  "Use one-sided form with upper boundary and uncertain ulp-count in downward "
  "direction.  By default the symmetric form with midpoint and radius is "
  "used.\n"
  "@item u\n"
  "Use one-sided form with lower boundary and uncertain ulp-count in upward "
  "direction\n"
  "@item -\n"
  "Left justify within the given field width\n"
  "@item +\n"
  "Always use a plus sign for positive numbers\n"
  "@item 0\n"
  "Left-pads the interval midpoint with zeros instead of spaces within the "
  "field width\n"
  "@end table"
  "\n"
  "@item\n"
  "The preferred field @var{width} for the interval midpoint."
  "\n"
  "@item\n"
  "The @var{precision} for the interval midpoint, that is the number of "
  "digits after the point.  If specified, it must be preceded by a point."
  "\n"
  "@item\n"
  "The @var{radius_width} specifies the desired number of digits for the "
  "non-negative integer ulp-count.  The ulp-count will be padded with zeros, "
  "because whitespace is not permitted within the uncertain form."
  "\n"
  "@item\n"
  "The number format @var{conversion} defines whether an exponent field is "
  "absent or present. The following values are supported: @code{f} / "
  "@code{F} (for decimal floating-point), @code{e} / @code{E} (scientific "
  "notation), @code{g} / @code{G} (use either decimal floating-point or "
  "scientific notation, depending on what is more appropriate for the "
  "magnitude of the number)."
  "\n"
  "@end itemize\n"
  "\n"
  "@end itemize\n"
  "@end table\n"
  "@end deftypefun"
  )
{
  int nargin = args.length ();
  if (nargin < 1 || nargin > 2)
    {
      print_usage ();
      return octave_value_list ();
    }

  if (! args (0).is_instance_of ("infsup"))
    {
      error ("arg1 must be an interval");
      return octave_value_list ();
    }

  if (nargin >= 2 && ! args (1).is_string ())
    {
      error ("arg2 must be a conversion specifier string");
      return octave_value_list ();
    }

  octave_value_list retval;

  const bool
  decorated = args (0).is_instance_of ("infsupdec");

  const octave_scalar_map
  x = args (0).scalar_map_value ();

  interval_format layout;
  if (nargin < 2 || args (1).is_empty ())
    layout = GENERAL_PURPOSE_LAYOUT;
  else
    {
      const std::string
      cs = args (1).string_value ();

      std::size_t characters_read = 0;
      layout = parse_conversion_specifier (cs, characters_read);

      if (nargout >= 3)
        {
          // The remaining characters, after the conversion specifier, will be
          // returned as a third output argument.  This allows @infsup/*printf
          // methods to continue parsing a string format.
          const std::string
          remaining_characters = cs.substr (characters_read);
          retval.append (octave_value (remaining_characters));
        }
    }

  const octave_scalar_map
  bare = (!decorated)
      ? x
      : x.getfield ("infsup").scalar_map_value ();

  const uint8NDArray
  dec = (!decorated)
      ? uint8NDArray ()
      : x.getfield ("dec").uint8_array_value ();

  const NDArray
  inf = bare.getfield ("inf").array_value ();

  const NDArray
  sup = bare.getfield ("sup").array_value ();
  
  Array <std::string> interval_literals;
  bool is_exact;
  {
    std::pair <Array <std::string>, bool>
    conversion_result;
    if (!decorated)
      conversion_result = interval_to_text (layout, inf, sup);
    else
      conversion_result = interval_to_text (layout, inf, sup, &dec);

    interval_literals = conversion_result.first;
    is_exact = conversion_result.second;
  }

  if (nargout >= 2)
    retval.prepend (is_exact);

  if (interval_literals.numel () == 1)
    retval.prepend (octave_value (interval_literals.elem (0)));
  else
    retval.prepend (octave_value (interval_literals));

  return retval;
}

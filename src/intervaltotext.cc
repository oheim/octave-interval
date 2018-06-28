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
#include <octave/oct-map.h>
#include <mpfr.h>
#include "mpfr_commons.h"

enum interval_form
{
  SPECIAL,             // [empty], [entire], [nai]
  INF_SUP,             // [1, 2], [-inf, inf]
  UNCERTAIN_SYMMETRIC, // 3.56?1
  UNCERTAIN_UP,        // 3.560?2u
  UNCERTAIN_DOWN       // -10?d
};

enum text_case
{
  TITLE_CASE, // [Empty]
  LOWER_CASE, // [empty]
  UPPER_CASE  // [EMPTY]
};

enum plus_sign
{
  ALWAYS,     // [+1, +2], [-1, +2]
  INNER_ZERO, //   [1, 2], [-1, +2]
  NEVER       //   [1, 2],  [-1, 2]
};

struct interval_format
{
  // preferred overall field width
  uint16_t total_width;
  // whether output is in inf-sup of uncertain form
  // for uncertain form: default symmetric or one sided (u or d) forms
  interval_form form;

  // how Empty, Entire, and NaI are output
  text_case special_case;
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
  .special_case = TITLE_CASE,
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
              layout.special_case = UPPER_CASE;
              break;
            case 'c':
              layout.special_case = LOWER_CASE;
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
            if (layout.left_justify)
              {
                error ("illegal flag: "
                       "you cannot use '-' in uncertain form");
                return layout;
              }
            layout.form = UNCERTAIN_SYMMETRIC;
            layout.hide_punctuation = false;
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

inline
bool
is_exact_hexadecimal (const interval_format &layout)
{
  if (layout.number_format == 'a' || layout.number_format == 'A')
    {
      // hex format, 1 character = 4 bit
      if (layout.number_precision == (BINARY64_PRECISION - 1) / 4)
      {
        // 13 hexadecimal characters can be used to represent 52 bits,
        // which equals binary64 precision (excluding the hidden bit).
        return true;
      }
    }
    return false;
}

// Pre-compute number format strings for MPFR, which can be used to compute
// string representations of interval boundaries and the interval midpoint.
std::string
prepare_format_string
(
  const interval_format &layout,
  const bool &force_sign
)
{
  std::ostringstream format_string;

  format_string << "%";

  if (force_sign)
    format_string << "+";

  if (layout.number_width > 0)
    {
      if (layout.left_justify)
        format_string << "-";

      if (layout.pad_with_zeros)
        format_string << "0";

      format_string << layout.number_width;
    }

  format_string << "." << layout.number_precision;

  // MPFR will not be used for exact hexadecimal conversion
  if (!is_exact_hexadecimal (layout))
    format_string << "R*";

  format_string << layout.number_format;

  return format_string.str ();
}

std::string
prepare_radius_format_string
(
  const interval_format &layout
)
{
  std::ostringstream format_string;

  format_string << "%";

  if (layout.radius_width > 0)
    {
      format_string << "0";
      format_string << layout.radius_width;
    }

  format_string << "u";

  return format_string.str ();
}

struct shared_conversion_resources
{
  // number format strings, can be used for a list of intervals
  const char *signed_template;
  const char *unsigned_template;
  const char *radius_template;
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
  const bool &force_sign,
  const double &x,
  const mpfr_rnd_t &rnd
)
{
  const char *
  string_template = force_sign ? stat.signed_template : stat.unsigned_template;

  if (x == -0.0)
    mpfr_set_zero (stat.mp, 0); // never use negative zero to prevent sign
  else
    mpfr_set_d (stat.mp, x, MPFR_RNDZ);

  mpfr_sprintf (stat.buf, string_template, rnd, stat.mp);
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

      mpfr_sprintf (stat.buf, string_template, complementary_rnd, stat.mp);
      stat.is_exact = (retval == stat.buf);
    }

  return retval;
}

inline
void
pad_number_width
(
  const interval_format &layout,
  std::string &formatted_number
)
{
  if (layout.number_width > formatted_number.length ())
    {
      if (layout.left_justify)
        formatted_number.resize (layout.number_width, ' ');
      else
        formatted_number.insert (0, 
            layout.number_width - formatted_number.length (), ' ');
    }
}

// Lossless conversion of a scalar double to hexadecimal string
std::string
double_to_exact_hex_string
(
  const interval_format &layout,
  shared_conversion_resources &stat,
  const bool &force_sign,
  const double &x
)
{
  // Do not use MPFR for exact double to hex conversion.
  //
  // MPFR would use any of the 16 hex digits before the point, but
  // IEEE Std 1788-2015 requires the use of either 0 or 1 before the
  // point, where 1 is used for normal numbers and 0 is used for
  // subnormal numbers.  MPFR doesn't handle subnormal numbers.

  // C99's floating-point conversion will use 0 before the point for
  // subnormal numbers and non-zero before the point for normal
  // numbers.
  // https://www.gnu.org/software/libc/manual/html_node/Floating_002dPoint-Conversions.html
  //
  // However, it is not guaranteed that only 1 is used for normal
  // numbers before the point (although this is the case for my gcc
  // version 4.9.2).
  //
  // Also sprintf (... "%.13a" ...) is completely broken on Windows,
  // where it either returns wrong values, or creates an infinite loop.

  if (x == std::numeric_limits <double>::infinity ()
      || x == -std::numeric_limits <double>::infinity ())
    {
      if (force_sign)
        sprintf (stat.buf, stat.signed_template, x);
      else
        sprintf (stat.buf, stat.unsigned_template, x);

      return std::string (stat.buf);
    }

  const bool
  upper = (layout.number_format == 'A');

  mpfr_set_d (stat.mp, x, MPFR_RNDZ);

  long exponent;
  double mantissa = mpfr_get_d_2exp (&exponent, stat.mp, MPFR_RNDZ);

  // Use normal representation of numbers 1.xxx * 2 ^ e
  // with hidden mantissa bit before the point
  if (mantissa != 0.0)
    {
      exponent --;
      mantissa *= 2.0; // 1.0 <= mantissa < 2.0
    }
  // Make subnormal numbers use the exponent -1022
  if (exponent < std::numeric_limits <double>::min_exponent)
    {
      mantissa /= uint64_t (1) << (
                            std::numeric_limits
                              <double>::min_exponent - 1
                            - exponent);
      exponent = std::numeric_limits <double>::min_exponent - 1;
    }

  // Extract sign
  bool sign = std::signbit (mantissa);
  mantissa = std::abs (mantissa);

  // Extract hidden bit
  bool hiddenbit = (mantissa >= 1.0);
  if (hiddenbit)
    mantissa -= 1.0;

  // shift mantissa by 32 bits to format the first part
  // sprintf (... "%x" ...) requires an unsigned 4-byte int 
  mantissa *= uint64_t (1) << (sizeof (uint32_t) * 8);
  uint32_t first_part = static_cast <uint32_t> (mantissa);

  // remove first mantissa part
  mantissa -= first_part;

  // shift mantissa by remaining 20 bits such that
  // it is an integer
  mantissa *= uint64_t (1) << (
                        std::numeric_limits
                          <double>::digits - 1 - 32);
  uint32_t second_part = static_cast <uint32_t> (mantissa);

  // Format hexadecimal number from individual parts
  sprintf (stat.buf,
    upper ? "%s0X%u.%08X%05XP%+d" : "%s0x%u.%08x%05xp%+d",
    sign ? "-" : (force_sign) ? "+" : "",
    static_cast <uint8_t> (hiddenbit),
    first_part, second_part,
    static_cast <int32_t> (exponent));

  std::string retval (stat.buf);

  // TODO: Implement more layout options

  pad_number_width (layout, retval);

  return retval;
}

// Convert a scalar double to string with directed rouding
std::string
double_to_string
(
  const interval_format &layout,
  shared_conversion_resources &stat,
  const bool &force_sign,
  const double &x,
  const mpfr_rnd_t &rnd
)
{
  std::string retval;

  if (is_exact_hexadecimal (layout))
    retval = double_to_exact_hex_string (layout, stat, force_sign, x);
  else
    retval = mpfr_to_string_d (stat, force_sign, x, rnd);

  // Never display zeros with a sign, even for force_sign == true.
  // For interval arithmetic, according to IEEE Std 1788-2015, there is no
  // signed zero.  So, the number can be represented by 0 (not -0 or +0).
  if (retval.find_first_of ("iI123456789") == std::string::npos)
    {
      std::size_t
      sign_pos = retval.find_first_not_of (' ');
      if (sign_pos != std::string::npos
          && (retval[sign_pos] == '+' || retval[sign_pos] == '-'))
        {
          retval.erase (sign_pos, 1);
          pad_number_width (layout, retval);
        }
    }

  return retval;
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
  // Switch uncertain form for unbound intervals,
  // if the interval cannot be represented with the desired direction
  interval_form
  form = layout.form;
  switch (form)
    {
      case UNCERTAIN_SYMMETRIC:
        if (inf != -std::numeric_limits <double>::infinity ()
            && sup == std::numeric_limits <double>::infinity ())
          form = UNCERTAIN_UP;
        if (inf == -std::numeric_limits <double>::infinity ()
            && sup != std::numeric_limits <double>::infinity ())
          form = UNCERTAIN_DOWN;
        break;

      case UNCERTAIN_UP:
        if (inf == -std::numeric_limits <double>::infinity ())
          {
            if (sup == std::numeric_limits <double>::infinity ())
              form = UNCERTAIN_SYMMETRIC;
            else
              form = UNCERTAIN_DOWN;
          }
        break;

      case UNCERTAIN_DOWN:
        if (sup == std::numeric_limits <double>::infinity ())
          {
            if (inf == -std::numeric_limits <double>::infinity ())
              form = UNCERTAIN_SYMMETRIC;
            else
              form = UNCERTAIN_UP;
          }
        break;

      case INF_SUP:
        // switch between [-inf, inf] and [entire]
        if (!layout.entire_boundaries
            && inf == -std::numeric_limits <double>::infinity ()
            && sup == std::numeric_limits <double>::infinity ())
          form = SPECIAL;
        break;

      case SPECIAL:
        break;
    }

  // [nai] and [empty] can only be represented in special form
  if (inf > sup)
    form = SPECIAL; 

  std::string l;
  std::string u;
  std::string m_E;
  switch (form)
    {
      case INF_SUP:
        {
          bool
          force_sign = (layout.display_plus == ALWAYS ||
              (layout.display_plus == INNER_ZERO && inf < 0.0 && 0.0 < sup));
          l = double_to_string (layout, stat, force_sign, inf, MPFR_RNDD);
          u = double_to_string (layout, stat, force_sign, sup, MPFR_RNDU);
        }
        break;

      case UNCERTAIN_SYMMETRIC:
        {
          double mid;
          if (inf == -std::numeric_limits <double>::infinity ()
              && sup == std::numeric_limits <double>::infinity ())
            mid = 0.0;
          else
            mid = inf / 2.0 + sup / 2.0;

          mid = std::min (std::max (
            -std::numeric_limits <double>::max (),
            mid),
            std::numeric_limits <double>::max ());

          m_E = double_to_string (layout, stat, layout.display_plus == ALWAYS,
              mid, MPFR_RNDZ);
        }
        break;

      case UNCERTAIN_UP:
        m_E = double_to_string (layout, stat, layout.display_plus == ALWAYS,
            inf, MPFR_RNDD);
        break;

      case UNCERTAIN_DOWN:
        m_E = double_to_string (layout, stat, layout.display_plus == ALWAYS,
            sup, MPFR_RNDU);
        break;

      case SPECIAL:
        break;
    }

  // Prepare uncertain form m?rvE
  std::string uncertain;
  if (form == UNCERTAIN_SYMMETRIC
      || form == UNCERTAIN_DOWN
      || form == UNCERTAIN_UP)
    {
      // Split exponent
      std::string m;
      std::string E;
      {
        std::size_t
        e_pos = m_E.find_first_of ("eE");
        if (e_pos == std::string::npos)
          m = m_E;
        else
          {
            E = m_E.substr (e_pos);
            m = m_E.substr (0, e_pos);
          }
      }

      // Represent ulp(m) as decimal string
      std::string ulp;
      {
        ulp = m;

        // Remove sign in case of negative midpoint
        std::size_t
        sign_pos = ulp.find ('-');
        if (sign_pos != std::string::npos)
          ulp = ulp.erase (sign_pos, 1);

        // Replace all digits with zero and the last place with unit
        std::replace_if (ulp.begin (), ulp.end (), ::isdigit, '0');
        ulp[ulp.rfind ('0')] = '1';

        // Append exponent for proper scaling
        ulp += E;
      }

      // Compute ulp(m) (upper bound)
      double ulp_d;
      {
        mpfr_strtofr (stat.mp, ulp.c_str (), NULL, 10, MPFR_RNDU);
        ulp_d = mpfr_get_d (stat.mp, MPFR_RNDU);
        if (stat.is_exact)
          stat.is_exact = (1.0 <= ulp_d && ulp_d <= 1.0e16);
      }

      // Compute radius (upper bound)
      double rad = 0.0;
      {
        if (form == UNCERTAIN_SYMMETRIC
            || form == UNCERTAIN_UP)
          {
            mpfr_strtofr (stat.mp, m.c_str (), NULL, 10, MPFR_RNDD);
            mpfr_d_sub (stat.mp, sup, stat.mp, MPFR_RNDU);
            rad = std::max (rad, mpfr_get_d (stat.mp, MPFR_RNDU));
            if (stat.is_exact)
              {
                mpfr_strtofr (stat.mp, m.c_str (), NULL, 10, MPFR_RNDU);
                mpfr_d_sub (stat.mp, sup, stat.mp, MPFR_RNDD);
                stat.is_exact = (mpfr_cmp_d (stat.mp, rad) == 0);
              }
          }
        if (form == UNCERTAIN_SYMMETRIC
            || form == UNCERTAIN_DOWN)
          {
            mpfr_strtofr (stat.mp, m.c_str (), NULL, 10, MPFR_RNDU);
            mpfr_sub_d (stat.mp, stat.mp, inf, MPFR_RNDU);
            rad = std::max (rad, mpfr_get_d (stat.mp, MPFR_RNDU));
            if (stat.is_exact)
              {
                mpfr_strtofr (stat.mp, m.c_str (), NULL, 10, MPFR_RNDD);
                mpfr_sub_d (stat.mp, stat.mp, inf, MPFR_RNDD);
                stat.is_exact = (mpfr_cmp_d (stat.mp, rad) == 0);
              }
          }
      }

      // Compute radius as multiple of ulp(m) (upper bound)
      std::string r;
      {
        double r_d;
        {
          mpfr_set_d (stat.mp, rad, MPFR_RNDZ);
          mpfr_div_d (stat.mp, stat.mp, ulp_d, MPFR_RNDU);
          r_d = mpfr_get_d (stat.mp, MPFR_RNDU);
          if (stat.is_exact)
            {
              mpfr_set_d (stat.mp, rad, MPFR_RNDZ);
              mpfr_div_d (stat.mp, stat.mp, ulp_d, MPFR_RNDD);
              stat.is_exact = (mpfr_cmp_d (stat.mp, r_d) == 0);
            }
        }
        if (r_d <= 0.5)
          {
            r = "";
            if (stat.is_exact)
              stat.is_exact = (r_d == 0.5);
          }
        else if (r_d > static_cast <double>
            (std::numeric_limits <uint32_t>::max ()))
          {
            r = "?";
            if (stat.is_exact)
              stat.is_exact =
                  (r_d == std::numeric_limits <double>::infinity ());
          }
        else
          {
            uint32_t
            r_uint = std::ceil (r_d);
            if (stat.is_exact)
              stat.is_exact = (static_cast <double> (r_uint) == r_d);
            std::sprintf (stat.buf, stat.radius_template, r_uint);
            r = stat.buf;
          }
      }

      std::string v;
      if (form == UNCERTAIN_DOWN)
        v = "d";
      if (form == UNCERTAIN_UP)
        v = "u";

      uncertain = m + "?" + r + v + E;
    }

  std::string d;
  if (dec != NULL)
    {
      if (*dec == 16)
        d = "_com";
      else if (*dec == 12)
        d = "_dac";
      else if (*dec == 8)
        d = "_def";
      else if (*dec == 4)
        d = "_trv";
      else
        d = "_ill";
    }

  bool
  display_brackets
      = ((form == INF_SUP || form == SPECIAL) && !layout.hide_punctuation);

  std::string interval_parts[3] = {"", "", d};

  switch (form)
    {
      case INF_SUP:
        interval_parts[0] = l;
        if (l != u)
          interval_parts[1] = u;
        break;

      case UNCERTAIN_SYMMETRIC:
      case UNCERTAIN_UP:
      case UNCERTAIN_DOWN:
        interval_parts[1] = uncertain;
        break;

      case SPECIAL:
        if (d == "_ill")
          {
            switch (layout.special_case)
              {
                case UPPER_CASE: interval_parts[0] = "NAI"; break;
                case TITLE_CASE: interval_parts[0] = "NaI"; break;
                case LOWER_CASE: interval_parts[0] = "nai"; break;
              }
            interval_parts[2] = ""; // [NaI] carries no decoration
          }
        else if (inf > sup)
          {
            switch (layout.special_case)
              {
                case UPPER_CASE: interval_parts[0] = "EMPTY"; break;
                case TITLE_CASE: interval_parts[0] = "Empty"; break;
                case LOWER_CASE: interval_parts[0] = "empty"; break;
              }
          }
        else
          {
            switch (layout.special_case)
              {
                case UPPER_CASE: interval_parts[0] = "ENTIRE"; break;
                case TITLE_CASE: interval_parts[0] = "Entire"; break;
                case LOWER_CASE: interval_parts[0] = "entire"; break;
              }
          }
        break;
    }

  if (layout.hide_punctuation)
    {
      // Without punctuation, add spaces as column delimiters
      if (!interval_parts[2].empty ())
        interval_parts[2].insert (0, 1, ' ');
      if (!interval_parts[0].empty () && !interval_parts[1].empty ())
        interval_parts[0].resize (interval_parts[0].length () + 1, ' ');
    }

  bool display_comma = display_brackets;
  long available_number_width = layout.total_width;
  available_number_width -= interval_parts[2].length (); // decoration
  if (display_brackets)
    {
      available_number_width -= 2; // "[]"
      if (!interval_parts[0].empty () && !interval_parts[1].empty ())
        available_number_width -= 2; // ", "
      else
        display_comma = false;
    }

  long padding = available_number_width;
  padding -= interval_parts[0].length ();
  padding -= interval_parts[1].length ();
  if (padding > 0)
    {
      std::size_t padding1 = padding / 2;
      std::size_t padding0 = padding - padding1;

      interval_parts[0].insert (0, padding0, ' ');
      interval_parts[1].insert (0, padding1, ' ');
    }

  if (display_brackets)
    {
      return "[" + interval_parts[0]
          + (display_comma ? ", " : "") + interval_parts[1]
          + "]"  + interval_parts[2];
    }
  else
    return interval_parts[0] + interval_parts[1] + interval_parts[2];
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
  char * signed_template;
  char * unsigned_template;
  char * radius_template;
  {
    std::string s = prepare_format_string (layout, false);
    unsigned_template = new char [s.length () + 1];
    std::strcpy (unsigned_template, s.c_str ());

    if (layout.display_plus != NEVER)
      s = prepare_format_string (layout, true);

    signed_template = new char [s.length () + 1];
    std::strcpy (signed_template, s.c_str ());

    s = prepare_radius_format_string (layout);
    radius_template = new char [s.length () + 1];
    std::strcpy (radius_template, s.c_str ());
  }
  shared_conversion_resources stat =
    {
      .signed_template = signed_template,
      .unsigned_template = unsigned_template,
      .radius_template = radius_template,
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
  delete[] signed_template;
  delete[] unsigned_template;
  delete[] radius_template;

  return std::pair <Array <std::string>, bool>
    (interval_literals, stat.is_exact);
}

DEFUN_DLD (intervaltotext, args, nargout, 
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
  "used.  For unbound intervals, this flag is ignored and the direction is "
  "chosen automatically.\n"
  "@item u\n"
  "Use one-sided form with lower boundary and uncertain ulp-count in upward "
  "direction.  For unbound intervals, this flag is ignored.\n"
  "@item C\n"
  "Use upper case for Entire, Empty, and NaI\n"
  "@item c\n"
  "Use lower case for Entire, Empty, and NaI\n"
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
  if (nargin < 2 || isempty (args (1)))
    layout = GENERAL_PURPOSE_LAYOUT;
  else
    {
      std::string
      cs = args (1).string_value ();

      // For backwards compatibility with the old intervaltotext function
      if (cs == "decimal")
        cs = "[.16g]";
      else if (cs == "exact decimal")
        cs = "[.751g]";
      else if (cs == "exact hexadecimal")
        cs = "[.13a]";

      std::size_t
      characters_read = 0;
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

/*
%!assert (intervaltotext (infsup (1 + eps), "exact decimal"), "[1.0000000000000002220446049250313080847263336181640625]");
%!assert (intervaltotext (infsup (1 + eps), "exact hexadecimal"), "[0x1.0000000000001p+0]");
%!assert (intervaltotext (infsup (pi), "[.3g]"), "[3.14, 3.15]");
%!assert (intervaltotext (infsup (pi), "[.4g]"), "[3.141, 3.142]");

%!assert (intervaltotext (infsup (1 + eps)), "[1, 1.00001]");
%!assert (intervaltotext (infsup (1)), "[1]");

%!assert (reshape (intervaltotext (infsup (reshape (1:120, 2, 3, 4, 5))), 1, 120), intervaltotext (infsup (1:120)));

%!assert (intervaltotext (infsupdec (1 + eps), "exact decimal"), "[1.0000000000000002220446049250313080847263336181640625]_com");
%!assert (intervaltotext (infsupdec (1 + eps), "exact hexadecimal"), "[0x1.0000000000001p+0]_com");
%!assert (intervaltotext (infsupdec (1 + eps)), "[1, 1.00001]_com");
%!assert (intervaltotext (infsupdec (1)), "[1]_com");

%!assert (reshape (intervaltotext (infsupdec (reshape (1:120, 2, 3, 4, 5))), 1, 120), intervaltotext (infsupdec (1:120)));

%!assert (intervaltotext (infsup (2, 3), "[g]"), "[2, 3]");
%!assert (intervaltotext (infsup (2, 3), "9:[g]"), "[  2,  3]");
%!assert (intervaltotext (infsup (), "[g]"), "[Empty]");
%!assert (intervaltotext (infsup (), "9:[g]"), "[ Empty ]");

%!assert (intervaltotext (infsup (2, 3), "g"), "2 3");
%!assert (intervaltotext (infsupdec (2, 3), "g"), "2 3 _com");

%!assert (intervaltotext (infsup (), "[Cg]"), "[EMPTY]");
%!assert (intervaltotext (infsup (), "[cg]"), "[empty]");

%!assert (intervaltotext (infsup (-inf, inf), "[g]"), "[Entire]");
%!assert (intervaltotext (infsup (-inf, inf), "[<g]"), "[-inf, inf]");

%!assert (intervaltotext (infsup (2, 3), "[3g]"), "[  2,   3]");
%!assert (intervaltotext (infsup (2, 3), "[-3g]"), "[2  , 3  ]");
%!assert (intervaltotext (infsup (2, 3), "[03g]"), "[002, 003]");

%!assert (intervaltotext (infsup (2, 3), "[+g]"), "[+2, +3]");
%!assert (intervaltotext (infsup (2, 3), "[ g]"), "[2, 3]");
%!assert (intervaltotext (infsup (2, 3), "[g]"), "[2, 3]");
%!assert (intervaltotext (infsup (-2, 3), "[+g]"), "[-2, +3]");
%!assert (intervaltotext (infsup (-2, 3), "[ g]"), "[-2, 3]");
%!assert (intervaltotext (infsup (-2, 3), "[g]"), "[-2, +3]");

%!assert (intervaltotext (infsup (2, 3), "[f]"), "[2.000000, 3.000000]");
%!assert (intervaltotext (infsup (2, 3), "[e]"), "[2.000000e+00, 3.000000e+00]");
%!assert (intervaltotext (infsup (2, 3), "[E]"), "[2.000000E+00, 3.000000E+00]");
%!assert (intervaltotext (infsup (-inf, inf), "[<F]"), "[-INF, INF]");

%!assert (intervaltotext (infsup (2, 3), "?g"), "2.5?5");
%!assert (intervaltotext (infsup (2, 3), "9:?g"), "    2.5?5");
%!assert (intervaltotext (infsup (), "?g"), "[Empty]");
%!assert (intervaltotext (infsup (), "9:?g"), "[ Empty ]");

%!assert (intervaltotext (infsup (), "C?g"), "[EMPTY]");
%!assert (intervaltotext (infsup (), "c?g"), "[empty]");

%!assert (intervaltotext (infsup (-inf, inf), "?g"), "0??");

%!assert (intervaltotext (infsup (2, 3), "4?g"), " 2.5?5");
%!assert (intervaltotext (infsup (2, 3), "?3g"), "2.5?005");
%!assert (intervaltotext (infsup (2, 3), "04?g"), "02.5?5");

%!assert (intervaltotext (infsup (2, 3), "+?g"), "+2.5?5");

%!assert (intervaltotext (infsup (2, 3), "?f"), "2.500000?500000");
%!assert (intervaltotext (infsup (2, 3), "?e"), "2.500000?500000e+00");
%!assert (intervaltotext (infsup (2, 3), "?E"), "2.500000?500000E+00");

*/

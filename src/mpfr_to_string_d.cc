/*
  Copyright 2015-2016 Oliver Heimlich
  
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

#include <sstream>
#include <octave/oct.h>
#include <octave/octave.h>
#include <octave/parse.h>
#include <octave/ov-uint8.h>
#include <mpfr.h>
#include "mpfr_commons.h"

std::string inttostring (const int number)
{
  std::ostringstream buffer;
  buffer << number;
  return buffer.str ();
}

DEFUN_DLD (mpfr_to_string_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@defun mpfr_to_string_d (@var{R}, @var{FORMAT}, @var{X})\n"
  "\n"
  "Convert binary64 numbers @var{X} to string representation, either exact or "
  "correctly rounded."
  "\n\n"
  "The result is a cell array of strings and, if not exact, is rounded in "
  "the direction @var{R} (@option{0}: towards zero, @option{0.5}: towards "
  "nearest and ties to even, @option{+inf}: towards positive infinity, "
  "@option{-inf}: towards negative infinity)."
  "\n\n"
  "The @var{FORMAT} may be one of the following:\n"
  "@table @option\n"
  "@item auto\n"
  "Varying mantissa length with 5 or 15 places, depending on the currently "
  "active @command{format}.  It is also possible to define other values with "
  "the @command{output_precision} function.\n"
  "@item decimal\n"
  "Varying mantissa length with up to 16 or 17 places.  This format will "
  "correctly separate subsequent numbers of binary64 precision with the least "
  "possible number of digits.\n"
  "@item exact decimal\n"
  "Varying mantissa length with up to 751 places.\n"
  "@item exact hexadecimal\n"
  "Fixed mantissa length with 1+13 hexadecimal places.  The digit before the "
  "point is only zero if the number is denormalized.  For normalized numbers "
  "the digit before the point should be 1, but this is not guaranteed and "
  "depends on the C compiler used.\n"
  "@end table"
  "\n\n"
  "@example\n"
  "@group\n"
  "mpfr_to_string_d (-inf, \"exact hexadecimal\", magic (3) / 10)\n"
  "  @result{}\n"
  "    @{\n"
  "      [1,1] = 0x1.999999999999ap-1\n"
  "      [2,1] = 0x1.3333333333333p-2\n"
  "      [3,1] = 0x1.999999999999ap-2\n"
  "      [1,2] = 0x1.999999999999ap-4\n"
  "      [2,2] = 0x1.0000000000000p-1\n"
  "      [3,2] = 0x1.ccccccccccccdp-1\n"
  "      [1,3] = 0x1.3333333333333p-1\n"
  "      [2,3] = 0x1.6666666666666p-1\n"
  "      [3,3] = 0x1.999999999999ap-3\n"
  "    @}\n"
  "@end group\n"
  "@end example\n"
  "@end defun"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin != 3)
    {
      print_usage ();
      return octave_value_list ();
    }
  
  const mpfr_rnd_t rnd     = parse_rounding_mode (args (0).scalar_value ());
  std::string format = args (1).string_value ();
  std::string str_template;
  
  // Switch to hexadecimal, if “format hex” is active
  if (format == "auto")
    // Maybe there is an easier way to find out whether format hex is active?!
    if (octave::feval ("disp",
               octave_value_list(octave_value (octave_uint8(255))),
               1)
              (0).string_value () == "ff\n")
      format = "exact hexadecimal";
  
  // Switch the conversion template depending on the format
  if (format == "auto")
    {
      const int precision = octave::feval ("output_precision")
                                          (0).scalar_value ();
      str_template = "%."
                     + inttostring (precision)
                     + "R*g";
    }
  else if (format == "decimal")
    // This might be increased to 17 below, if 16 is not enough for the
    // particular number.
    str_template = "%.16R*g";
  else if (format == "exact hexadecimal")
    // We will not use MPFR below!
    str_template = "%R*a";
  else if (format == "exact decimal")
    str_template = "%.751R*g";
  else
    {
      error ("mpfr_to_string_d: Illegal format");
      return octave_value_list ();
    }
  
  const Matrix x = args (2).matrix_value ();

  char buf [768];
  mpfr_t mp;
  mpfr_t zero;
  mpfr_init2 (mp, BINARY64_PRECISION);
  mpfr_init2 (zero, BINARY64_PRECISION);
  mpfr_set_zero (zero, 0);
  
  Cell str (dim_vector (x.rows (), x.cols ()));
  bool isexact = true;
  const mpfr_rnd_t complementary_rnd = (rnd == MPFR_RNDD) ? MPFR_RNDU :
                                       (rnd == MPFR_RNDU) ? MPFR_RNDD :
                                       (rnd == MPFR_RNDZ) ? MPFR_RNDA :
                                       (rnd == MPFR_RNDA) ? MPFR_RNDZ :
                                       MPFR_RNDN;
  
  const octave_idx_type n = x.numel ();
  for (octave_idx_type i = 0; i < n; i++)
    {
      mpfr_set_d (mp, x.elem (i), MPFR_RNDZ);
      if (format != "exact hexadecimal")
        {
          mpfr_sprintf (buf, str_template.c_str (), rnd, mp);
        }
      else
        {
          // Do not use MPFR for double to hex conversion.
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
          
          long exponent;
          double mantissa = mpfr_get_d_2exp (&exponent, mp, rnd);
          
          if (mpfr_number_p (mp) == 0)
            {
              // NaN or infinity
              if (std::isnan (mantissa))
                {
                  // The NaN returned by MPFR might produce a sign,
                  // so let's use the implementation's default NaN.
                  mantissa = std::numeric_limits <double>::quiet_NaN ();
                }
              
              sprintf (buf, "%f", mantissa);
            }
          else
            {
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
              sprintf (buf, "%s0x%u.%08x%05xp%+d",
                sign ? "-" : "",
                static_cast <uint8_t> (hiddenbit),
                first_part, second_part,
                static_cast <int32_t> (exponent));
            }
        }
      
      str.elem (i) = buf;
      if (format == "decimal")
        {
          if (x.elem (i) != 0.0)
            {
              // Precision 16 might not be enough
              // Note: mpfr_sprintf does not set the inexact flag, so we must
              // check for precision loss ourself.
              mpfr_nexttoward (mp, zero);
              mpfr_sprintf (buf, str_template.c_str (), rnd, mp);
              mpfr_set_d (mp, x.elem (i), MPFR_RNDZ);
              if (str.elem (i).string_value () == buf)
                {
                  // Increase precision to 17
                  mpfr_sprintf (buf, "%.17R*g", rnd, mp);
                  str.elem (i) = buf;
                }
            }
        }
      // Check, whether output was exact
      if (isexact && nargout >=2 &&
          format != "exact decimal" &&
          format != "exact hexadecimal")
        {
          mpfr_sprintf (buf, str_template.c_str (), complementary_rnd, mp);
          if (str.elem (i).string_value () != buf)
            isexact = false;
        }
    }
  
  mpfr_clear (mp);
  mpfr_clear (zero);
  octave_value_list result;
  result (0) = str;
  result (1) = isexact;
  return result;
}

/*
%!test;
%!  [s, isexact] = mpfr_to_string_d (-inf, "decimal", .1);
%!  assert (s, {"0.1"});
%!  assert (isexact, false);
%!assert (mpfr_to_string_d (0, "exact hexadecimal", inf), {"inf"});
%!assert (mpfr_to_string_d (0, "exact hexadecimal", -inf), {"-inf"});
%!assert (mpfr_to_string_d (0, "exact hexadecimal", nan), {"nan"});
%!assert (mpfr_to_string_d (0, "exact hexadecimal", 0), {"0x0.0000000000000p+0"});
%!assert (mpfr_to_string_d (0, "exact hexadecimal", 2), {"0x1.0000000000000p+1"});
%!assert (mpfr_to_string_d (0, "exact hexadecimal", -1), {"-0x1.0000000000000p+0"});
%!assert (mpfr_to_string_d (0, "exact hexadecimal", pow2 (-1022)), {"0x1.0000000000000p-1022"});
%!assert (mpfr_to_string_d (0, "exact hexadecimal", pow2 (-1074)), {"0x0.0000000000001p-1022"});
*/

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
#include "mpfr_commons.cc"

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
  "Mantissa with exactly 13 hexadecimal places.\n"
  "@end table"
  "\n\n"
  "@example\n"
  "@group\n"
  "mpfr_to_string_d (-inf, \"exact hexadecimal\", magic (3) / 10)\n"
  "  @result{}\n"
  "    @{\n"
  "      [1,1] = 0XC.CCCCCCCCCCCD0P-4\n"
  "      [2,1] = 0X4.CCCCCCCCCCCCCP-4\n"
  "      [3,1] = 0X6.6666666666668P-4\n"
  "      [1,2] = 0X1.999999999999AP-4\n"
  "      [2,2] = 0X8.0000000000000P-4\n"
  "      [3,2] = 0XE.6666666666668P-4\n"
  "      [1,3] = 0X9.9999999999998P-4\n"
  "      [2,3] = 0XB.3333333333330P-4\n"
  "      [3,3] = 0X3.3333333333334P-4\n"
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
    if (feval ("disp",
               octave_value_list(octave_value (octave_uint8(255))),
               1)
              (0).string_value () == "ff\n")
      format = "exact hexadecimal";
  
  // Switch the conversion template depending on the format
  if (format == "auto")
    {
      const int precision = feval ("output_precision")(0).scalar_value ();
      str_template = "%."
                     + inttostring (precision)
                     + "R*g";
    }
  else if (format == "decimal")
    // This might be increased to 17 below, if 16 is not enough for the
    // particular number.
    str_template = "%.16R*g";
  else if (format == "exact hexadecimal")
    str_template = "%.13R*A";
  else if (format == "exact decimal")
    str_template = "%.751R*g";
  else
    {
      error ("mpfr_to_string_d: Illegal format");
      return octave_value_list ();
    }
  
  const Matrix x = args (2).matrix_value ();
  if (error_state)
    return octave_value_list ();
  
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
      mpfr_sprintf (buf, str_template.c_str (), rnd, mp);
      str.elem (i) = buf;
      if (format == "decimal")
        {
          if (x.elem (i) != 0.0)
            {
              // Precision 16 might not be enough
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
*/

/*
  Copyright 2015 Oliver Heimlich
  
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
#include "mpfr_commons.cc"

DEFUN_DLD (mpfr_to_string_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding utf-8\n"
  "@deftypefn  {Loadable Function} {} mpfr_to_string_d (@var{R}, @var{FORMAT}, @var{X})\n"
  "\n"
  "Convert a binary64 matrix @var{X} to string representation."
  "\n\n"
  "The result is a cell array of strings and, if not exact, is roundeded in "
  "the direction @var{R}."
  "\n\n"
  "The @var{FORMAT} may be one of the following: @code{decimal}, "
  "@code{exact decimal}, or @code{exact hexadecimal}."
  "\n\n"
  "@example\n"
  "@group\n"
  "mpfr_to_string (-inf, 'exact hexadecimal', magic (3) / 10)\n"
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
  "@end deftypefn"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin != 3)
    {
      print_usage ();
      return octave_value_list ();
    }

  const mpfr_rnd_t rnd     = parse_rounding_mode (
                             args (0).matrix_value ().elem (0));
  const std::string format = args (1).string_value ();
  const char* str_template = (format == "decimal") ? "%.16R*g" :
                             (format == "exact decimal") ? "%.751R*g" :
                             (format == "exact hexadecimal") ? "%.13R*A" :
                             "";
  const Matrix x           = args (2).matrix_value ();
  if (error_state)
    return octave_value_list ();
  if (str_template == "")
    {
      error ("mpfr_to_string_d: Illegal format");
      return octave_value_list ();
    }
  
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
  
  const unsigned n = x.numel ();
  for (int i = 0; i < n; i++)
    {
      mpfr_set_d (mp, x.elem (i), MPFR_RNDZ);
      mpfr_sprintf (buf, str_template, rnd, mp);
      str.elem (i) = buf;
      if (format == "decimal")
        {
          if (x.elem (i) != 0.0)
            {
              // Precision 16 might not be enough
              mpfr_nexttoward (mp, zero);
              mpfr_sprintf (buf, str_template, rnd, mp);
              mpfr_set_d (mp, x.elem (i), MPFR_RNDZ);
              if (str.elem (i).string_value () == buf)
                {
                  // Increase precision to 17
                  mpfr_sprintf (buf, "%.17R*g", rnd, mp);
                  str.elem (i) = buf;
                }
            }
          
          
          if (isexact && nargout >=2)
            {
              mpfr_sprintf (buf, str_template, complementary_rnd, mp);
              if (str.elem (i).string_value () != buf)
                isexact = false;
            }
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

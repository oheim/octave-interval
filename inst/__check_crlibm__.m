## Copyright 2016 Oliver Heimlich
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
## @defun __check_crlibm__ ()
## Check whether crlibm is available and working.
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-12-06

function result = __check_crlibm__ ()

  if (exist ("crlibm_function") != 3)
    ## oct file not in the path
    result = false;
  endif

  persistent use_crlibm = verify_crlibm ();

  result = use_crlibm;

endfunction

function works = verify_crlibm ()

  arithmetic_test_suite = fullfile (...
                                     fileparts (file_in_loadpath ("__check_crlibm__.m")), ...
                                     "test", ...
                                     "crlibm.tst");

  if (exist (arithmetic_test_suite) == 0)
    ## test suite missing: assume that a package maintainer has removed it to
    ## save some space after having verified that the test suite passes.
    works = true;
    return
  endif

  works = test (arithmetic_test_suite, "quiet");

  if (!works)
    warning ("interval:crlibm", ...
             "crlibm is not working properly, using MPFR as a fallback");
  endif

endfunction

%!assert (__check_crlibm__ ());

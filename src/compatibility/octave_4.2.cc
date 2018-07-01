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

// Implementation for Octave version 4.2 and older.

#include <octave/oct.h>
#include <octave/parse.h>

// The is_vector method has been replaced by isvector in Octave 4.4.
bool isvector (const Array <double> x)
{
  return x.is_vector ();
}

// The is_empty method has been replaced by isempty in Octave 4.4.
bool isempty (const octave_value x)
{
  return x.is_empty ();
}

// feval has been moved into octave::feval in Octave 4.4.
namespace octave
{
  octave_value_list feval
  (
    const std::string &name,
    const octave_value_list &args = octave_value_list (),
    int nargout = 0
  )
  {
    return ::feval (name, args, nargout);
  }
}

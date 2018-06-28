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

// This file contains wrappers around the Octave core API to support multiple
// versions of GNU Octave.  See octave_*.cc for implementations in different
// versions of Octave.

#include <octave/oct.h>

bool isvector (const Array <auto> x);
bool isempty (const octave_value x);

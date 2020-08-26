## Copyright (C) 2020 mschl
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{rodriguesRotMat} =} rotAxisAngle (@var{rotAxis}, @var{angle})
## Computes the 3x3 Rodriguez rotation matrix from the given @var{rotAxis} and @var{angle}.
## Compared to "rotv" from the linear-algebra package, this function uses 
## a right handed coordinate system and right-handed (conter-clockwise, ccw) rotation convention.
## See https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula#Matrix_notation.
## @seealso{}
## @end deftypefn

## Author: Markus Schlueter <mschlueter@geomar.de>
## Created: 2020-05-20

function rodriguesRotMat = rotAxisAngle (rotAxis, angle)
  
  k = normalize(rotAxis);
  
  crossProductMatrix = [ 
    [ 0,    -k(3),  k(2)],
    [ k(3),  0,    -k(1)],
    [-k(2),  k(1)   0   ]
  ];
  
  rodriguesRotMat = ...
    eye(3) + ...
    sin(angle)       * crossProductMatrix + ...
    (1 - cos(angle)) * crossProductMatrix*crossProductMatrix ;
  
  return;

endfunction

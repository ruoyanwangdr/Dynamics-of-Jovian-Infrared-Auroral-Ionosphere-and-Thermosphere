FUNCTION subpix_shift,arr,xsh,ysh
;
; A sub-pixel shift of a 1D (vector) or 2D (image) array ARR
; by a non-integer number of pixels XSH or (XSH,YSH) using
; the IDL INTERPOLATE function (linear or bilinear interpolation).
; The direction of the shift is the same as in the IDL SHIFT
; function (positive values shift the array to the right).
;
; INPUTS: ARR - 1D or 2D array, integer or float
;         XSH - shift in x (float)
;         YSH - shift in y (float) - in case of a 2D array
; OUTPUT: shifted array (always float)
;
; CALLING: shifted_array = SUBPIX_SHIFT(array,x_shift [,y_shift])
;
; 25.11.2011, Michal
;
on_error,1
if n_params() lt 2 then message,$
  'USAGE: shifted_array = SUBPIX_SHIFT(array, x_shift [,y_shift])'
si=size(arr)
if si(0) gt 2 then message,'It works only for 1D and 2D arrays'
if (n_params() lt 3) and (si(0) eq 2) then message,$
  'Missing y_shift (if no shift in y, put y_shift = 0)'

; 1D case
if si(0) eq 1 then begin
  x=lindgen(si(1))	; x coordinate grid for interpolation
  res=interpolate(float(arr),x-xsh)
  RETURN,res
endif

; 2D case
if si(0) eq 2 then begin
  x=lindgen(si(1),si(2))
  y = x/si(1)		; y coordinate grid for interpolation
  x = x MOD si(1)	; x coordinate grid for interpolation
  res=interpolate(float(arr),x-xsh,y-ysh)
  RETURN,res
endif

END

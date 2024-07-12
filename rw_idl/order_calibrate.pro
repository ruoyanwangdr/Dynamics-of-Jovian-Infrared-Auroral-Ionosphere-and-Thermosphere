pro order_calibrate

loadarray, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/skylines60p_offset_order34.txt', 1, sky2_shift
slit_scale = 247.05882352941177

for i = 22,59 do begin
	a = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s00' + strtrim(i,1) + '_order34.fits')
	
	b = a
	b = congrid(a, 1024, slit_scale, /interp)
	print, size(b)
	;for j = 0,144 do begin
	;	b(*,j) = subpix_shift(a(*,j), sky1_shift(j))
	;endfor
	
	writefits, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/new_frame/jun02s00' + strtrim(i,1) + '_order34.fits', b
endfor	

for i = 60,99 do begin
	a = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s00' + strtrim(i,1) + '_order34.fits')
	b = a
	b = congrid(a, 1024, slit_scale, /interp)
	print, size(b)
	;b = fltarr(1090, 140)
	;b = congrid(a, slit_scale, 140, /interp)
	;for j = 0,139 do begin
	;	t = congrid(a(*,j), slit_scale(j), /interp)
	;	b(*,j)=t[0:1089]
	;endfor
	
	;for k = 0,139 do begin
	;	b(*,k) = subpix_shift(a(*,k), sky2_shift(k))
	;endfor
	
	writefits, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/new_frame/jun02s00' + strtrim(i,1) + '_order34.fits', b
endfor

for i = 100,111 do begin
	a = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0' + strtrim(i,1) + '_order34.fits')
        
	b = a
	b = congrid(a, 1024, slit_scale, /interp)
	print, size(b)
	;for k = 0,139 do begin
        ;        b(*,k) = subpix_shift(a(*,k), sky2_shift(k))
	;endfor
	
	writefits, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/new_frame/jun02s0' + strtrim(i,1) + '_order34.fits', b
endfor

end 

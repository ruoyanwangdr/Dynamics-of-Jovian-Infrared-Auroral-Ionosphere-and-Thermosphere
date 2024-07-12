pro skyline_scale,a,b,c,d

a = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order37/test/jun02s0043_order37.fits')
b = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order37/test/jun02s0044_order37.fits')
slit_scale = 271.875

c = a - b
print, size(c)

;t=fltarr(1024, 260)
;print, size(d)
;for i = 0, 1023 do begin
;	t=congrid(c(i,*),260, slit_scale, /interp)
;	d(i,*)=t[0:259]
;endfor

d = congrid(c, 1024, slit_scale, /interp)
print, size(d)

;writefits, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order37/test/star_spat_scaled_order37.fits', d

end

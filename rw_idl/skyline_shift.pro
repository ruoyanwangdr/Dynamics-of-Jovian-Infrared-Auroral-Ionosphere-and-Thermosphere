pro skyline_shift,a,b,c

a = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/skylines60p_order34.fits')
b = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/skylines60m_order34.fits')
loadarray, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/skylines60p_offset_order34.txt', 1, slit_shift1

c = a
for i = 0, 139 do begin
        c(*,i) = subpix_shift(a(*,i), slit_shift1(i))
endfor

tvscl, c

writefits, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/skylines60p_shifted_order34.fits', c

end

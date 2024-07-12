pro skyline_prep,a,b,c,d
a1 = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0051_order34.fits')
a2 = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0059_order34.fits')
a3 = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0060_order34.fits')
a4 = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0072_order34.fits')
a5 = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0078_order34.fits')
a6 = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0079_order34.fits')
a7 = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0091_order34.fits')
a8 = readfits('/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/jun02s0103_order34.fits')

a = (a1 + a2)
acre, a, b, 1, 3

c = (a3 + a4 + a5 + a6 + a7 + a8)
acre, c, d, 1, 3

writefits, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/skylines60m_order34.fits', b>0<300
writefits, '/data/sol-ionosphere/h3p/observations/obs_17/02jun17/spec/order34/skylines60p_order34.fits', (d/3)>0<300

end

pro star,a,b,c,star2_1,star2_2

a = readfits('/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/nspec220929_0189.fits')
b = readfits('/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/nspec220929_0190.fits')

c = (a-b)>0<100

acre,c,star2_1,1,3

star2_2 = star2_1-star2_1

;writefits, '/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/star2_1.fits', star2_1
;writefits, '/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/star2_2.fits', star2_2

end


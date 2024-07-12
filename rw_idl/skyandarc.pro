pro skyandarc,a,b,c,e,l,m

sky4 = readfits('/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/nspec220929_0139.fits')
sky5 = readfits('/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/nspec220929_0151.fits')
sky6 = readfits('/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/nspec220929_0163.fits')

l = readfits('/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/nspec220929_0137.fits')

a = sky5 + sky6
b = a>400<8000

acre, a, c, 1, 3
acre, l, m, 1, 3

;d = (c+m)>700<1000

e = (c+m/8)>100<600

tvscl,e

writefits, '/data/sol-ionosphere/h3p/observations/obs_22/29sep22/spec/skyandarc2.fits', e

end

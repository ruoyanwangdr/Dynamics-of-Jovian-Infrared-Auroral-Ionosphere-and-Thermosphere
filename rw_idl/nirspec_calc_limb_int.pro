pro nirspec_calc_limb_int,direct,fullint,intcount
	
	
	window,0,xs=512*3,ys=512

	if n_params(0) eq 0 then begin

		direct='16dec00'
		;direct='24jul98'
		;direct='07aug97'
		;direct='08jul96'
		;direct='28apr96'
		;direct='31may96'

	endif


	plate_scale=0.161

	
	jup_calc_eqwidth,direct,jup_eqwidth
	
	jup_eqwidth=jup_eqwidth
	jup_calc_seangle,direct,jup_seangle
	jup_calc_posangle,direct,jup_posangle
	

	; calculate the limb distance and planetary distances

	flattening=0.06487
	losflattening=flattening*(1-sin(deg_to_rad(jup_seangle)))
	eq_po_ratio=1-losflattening

	limbdist=0.5*jup_eqwidth/plate_scale;/0.17;/0.15

	

		;;;; remove background
		cox=255
		coy=255
		DIST_ELLIPSE, IM9, 256, cox-128, coy-128, eq_po_ratio, jup_posangle, /DOUBLE

		jup_cml=0

		limbmask=fltarr(512,512)

		offsetxx=findgen(512)-cox
		offsetyy=findgen(512)-coy

		offsetx=findgen(512,2)
		offsetx(*,0)=offsetxx
		offsetx(*,1)=offsetxx
		offsetx=congrid(offsetx,512,512)

		offsety=findgen(2,512)
		offsety(0,*)=offsetyy
		offsety(1,*)=offsetyy
		offsety=congrid(offsety,512,512)

		DIST_ELLIPSE, IM2, 512, cox, coy, eq_po_ratio, jup_posangle, /DOUBLE
		limbpos9=where((im2 lt limbdist+1) ,lpcount2)

		R1= 71492.
		R2=(R1+300.)/R1
		R3=(R1+500.)/R1
		RR=IM2/limbdist

		los_coor= ((SQRT(R3^2 - RR^2) - SQRT(R2^2-RR^2))/(R3-R2)) >0.

;los_coor(*)=1.
		limbmask(limbpos9)=1.

		calcthesepixels=where(limbmask gt 0,ctpcount)

		ctp_xxx=offsetx(calcthesepixels)
		ctp_yyy=offsety(calcthesepixels)

		jup_pixel_radius=(jup_eqwidth/0.15)/2.

		latitude_array=fltarr(4,512,512)
		longitude_array=fltarr(4,512,512)

		nirspec_calc_lat_long_image,ctp_xxx,ctp_yyy,jup_pixel_radius,jup_seangle,jup_posangle,jup_cml,flattening,latit,longit

		cornerarray=fltarr(512,512)

		for corner=0,3 do begin
	
			cornerarray(*)=0.
			cornerarray(calcthesepixels)=latit(corner,*)
			latitude_array(corner,*,*)=cornerarray
			cornerarray(*)=0.
			cornerarray(calcthesepixels)=longit(corner,*)
			longitude_array(corner,*,*)=cornerarray
	
		endfor



		latitude=rad_to_deg(reform(latitude_array(0,*,*)))
		latitude2=rad_to_deg(reform(latitude_array(0,*,*)))
		longitude=reform(longitude_array(0,*,*))

		tvscl,latitude
		reasd

		zz=where(latitude ne 0,count)

x=fltarr(512,512)
for xx=0,511 do x(xx,*)=xx
y=fltarr(512,512)
for xx=0,511 do y(*,xx)=xx


;[[k, y, y2], [x, xy, xy2], [x2, x2y, x2y2]]


dawnside=fltarr(512,512)
dawnside(0:255,*)=1.
dawnside=rot(dawnside,(720-jup_posangle) mod 360.)
tvscl,dawnside

im=im2/limbdist
limb=where(im gt 1. and im lt 1.03,comp=notlimb)
insidelimb=where(im gt 0.98 and im lt 0.999,comp=notinsidelimb)


;;;;;calc lines of polar angle
;;
;;

x_y=fltarr(2,512.*512)
p_r=fltarr(2,512,512)
x_y(0,*)=offsetx
x_y(1,*)=offsety
polar=cv_coord(/to_polar,from_rect=x_y,/deg)
for i=0.,511 do p_r(0,i,*)=polar(0,i*512:i*512+511)
radial = p_r(0,*,*)+180

radiallimb=radial
radiallimb(notinsidelimb)=-1

tvscl,radiallimb

radial_lat=fltarr(721)
blank=fltarr(512,512)
radial_lat2=fltarr(512,512)

        radialcount=histogram(radiallimb,loc=loc2,min=0,max=360,rev=radi,bin=0.5)
        for i=0,720 do begin
                if radi[i] lt radi[i+1] then begin
                	print,i,radi[i+1]-radi[i]
                	radial_lat(i)=median(latitude[radi[radi[i]:radi[i+1]-1]])
                endif  
        endfor

        radialcount=histogram(radial,loc=loc2,min=0,max=360,rev=radi,bin=0.5)
        for i=0,720 do begin
                if radi[i] lt radi[i+1] then begin
                	print,i,radi[i+1]-radi[i]
                	radial_lat2[radi[radi[i]:radi[i+1]-1]]=radial_lat(i)
                endif  
        endfor

		radial_lat=smooth(radial_lat2,10)


;;;;


radial_lat(notlimb)=-100

tvscl,radial_lat
reasd

fi_dawn=fullint*dawnside
fi_dusk=fullint*(1-dawnside)
fc_dawn=intcount*dawnside
fc_dusk=intcount*(1-dawnside)

;fc2=intcount

fi_dawn(notlimb)=0
fc_dawn(notlimb)=0
fi_dusk(notlimb)=0
fc_dusk(notlimb)=0

tvscl,fi_dawn
tvscl,fi_dusk,512,0

countprofile=histogram(radial_lat,loc=loc,min=-90,max=90,rev=ri)
        fiprofile_dawn=fltarr(181)
        fcprofile_dawn=fltarr(181)
        fiprofile_dusk=fltarr(181)
        fcprofile_dusk=fltarr(181)

        for i=0,179 do begin
                if ri[i] lt ri[i+1] then begin
                        
            ;                    print,i,ri[i+1]-ri[i]

                ;       print, ri[ri[i]:ri[i+1]-1]
                ;       print,i,(ri[ri[i]:ri[i+1]-1])
                fiprofile_dawn(i)=total(fi_dawn[ri[ri[i]:ri[i+1]-1]])
                fcprofile_dawn(i)=total(fc_dawn[ri[ri[i]:ri[i+1]-1]])
                fiprofile_dusk(i)=total(fi_dusk[ri[ri[i]:ri[i+1]-1]])
                fcprofile_dusk(i)=total(fc_dusk[ri[ri[i]:ri[i+1]-1]])
                        
                        
                endif 

                
                
;               intprofile(i)=total(ints(r(i)))
;               
;               
        endfor
        
        latprofile=findgen(181)-90

		plot,latprofile,fiprofile_dawn/fcprofile_dawn>0,xstyle=1
		oplot,latprofile,fiprofile_dusk/fcprofile_dusk,col=150


	return
end
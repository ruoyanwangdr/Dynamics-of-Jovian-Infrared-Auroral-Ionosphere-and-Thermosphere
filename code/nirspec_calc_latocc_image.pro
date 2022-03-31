pro nirspec_calc_latocc_image,x,y,jup_pixel_radius,jup_seangle,jup_posangle,jup_cml,flattening,latit,longit,phase,verbose=verbose

jup_posangle2=(720-jup_posangle) mod 360.

	xsize=n_elements(x) ;; both x and y are a string of position values from the image, centred on the planet

	latit=fltarr(4,xsize)
	longit=fltarr(4,xsize) 
	phase=fltarr(4,xsize) 
		
R=jup_pixel_radius
	
	for corner=0,3 do begin
	
	
		;;; do a lat and long for each corner of pixel
		case corner of 
		0: begin
			x2=x+0.5
			y2=y+0.5
		end
		1: begin
			x2=x+0.5
			y2=y-0.5
		end
		2: begin
			x2=x-0.5
			y2=y-0.5
		end
		3: begin
			x2=x-0.5
			y2=y+0.5
		end
	
		endcase
		;;; rotate the pixels into jovian rotational coordinates
		
		x_y=fltarr(2,xsize)
		x_y(0,*)=x2
		x_y(1,*)=y2
		
		polar=cv_coord(/to_polar,from_rect=x_y,/deg)
;		print,[x2,y2],polar,jup_posangle
		polar(0,*)=jup_posangle2+polar(0,*)
		x_y2=cv_coord(/to_rec,from_pol=polar,/deg)
		
;		print,rect2,polar,jup_posangle2
;		reasd
		
		xx=x_y2(0,*)
		
		;;; stretch yy to become a sphere
		flattening=0.06487
		losflattening=flattening*(1-sin(deg_to_rad(jup_seangle)))
		eq_po_ratio=1-losflattening
		
		yy=x_y2(1,*)/eq_po_ratio
	
		pp = sqrt (xx^2 + yy^2)  ;;; proper distance from centre
	
	
	
		;;;limit calculations
		
		goodvalues= where(pp/R gt 0.0,gvcount)
		
;		print,max(pp),min(pp),R,max(pp/R)
;		help,pp,pp/R,gvcount
		
		if gvcount gt 0 then begin
		
		lats=fltarr(gvcount)
		lons=fltarr(gvcount)
		
			cc = asin (pp(goodvalues)/R)  ;;; angular distance from centre
			cc=asin(1)
;			lats = asin ( ( cos(cc) * sin(deg_to_rad(jup_seangle)) ) + ( ( yy(goodvalues) * sin(cc) * cos(deg_to_rad(jup_seangle)) / pp(goodvalues) ) )   )

			lats = atan(yy/abs(xx)) * cos(deg_to_rad(jup_seangle)) 

			xxzz=(xx*1e8>(-1)<1)*(-1)


			lons=(jup_cml+  ( ((rad_to_deg(atan(yy/abs(xx)))*sin(deg_to_rad(jup_seangle)))+90) * xxzz )+360) mod 360.
			
			pha=xx 
			pha(where (pha gt 0))=1
			pha(where (pha le 0))=-1 

		;	lons=(pha*(-90.))+jup_cml

		;	lons = deg_to_rad(jup_cml) - atan( ( xx(goodvalues) * sin(cc) ) / ( ( pp(goodvalues) * cos(deg_to_rad(jup_seangle)) * cos(cc) ) -  ( yy(goodvalues) * sin (deg_to_rad(jup_seangle)) * sin (cc))  ) )

		;if rad_to_deg(latit(corner)) eq 0 then print,x,y,xx,yy,polar,pp,R,cc,pp/R,latit(corner),longit(corner),rad_to_deg(latit(corner)),rad_to_deg(longit(corner))
;		reasd
		
;		print,min(lats),max(lats)
;		reasd
		
latit(corner,goodvalues)=lats
longit(corner,goodvalues)=lons
phase(corner,goodvalues)=pha

;print,lons
;	stop

		endif
		

		
		
	endfor

;	zzz=where(longit ne 0.,zzzcount)

;	if zzzcount gt 3 then if rad_to_deg(max(longit)-min(longit)) gt 15 then print,'longit',ccc,ppp,ppp/R,xxx,yyy,rad_to_deg(longit),rad_to_deg(latit),rad_to_deg(max(longit)-min(longit))


return
end
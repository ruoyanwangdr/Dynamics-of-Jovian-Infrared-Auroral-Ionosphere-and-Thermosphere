pro nirspec_calc_lat_long,x,y,jup_pixel_radius,jup_seangle,jup_posangle,jup_cml,flattening,latit,longit,verbose=verbose

jup_posangle2=(720-jup_posangle) mod 360.
	latit=fltarr(4)
	longit=fltarr(4)
	
	ccc=fltarr(4)
	ppp=fltarr(4)
	xxx=fltarr(4)
	yyy=fltarr(4)
	xxx=fltarr(4)
	
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
		
		polar=cv_coord(/to_polar,from_rect=[x2,y2],/deg)
;		print,[x2,y2],polar,jup_posangle
		polar(0)=jup_posangle2+polar(0)
		rect2=cv_coord(/to_rec,from_pol=polar,/deg)
		
;		print,rect2,polar,jup_posangle2
;		reasd
		
		xx=rect2(0)
		
		;;; stretch yy to become a sphere
		flattening=0.06487
		losflattening=flattening*(1-sin(deg_to_rad(jup_seangle)))
		eq_po_ratio=1-losflattening
		
		yy=rect2(1)/eq_po_ratio
	
		pp = sqrt (xx^2 + yy^2)  ;;; proper distance from centre
	
		if pp/R lt 0.998 then begin
	
			cc = asin (pp/R)  ;;; angular distance from centre

			ccc(corner)=cc
			ppp(corner)=pp
			xxx(corner)=xx
			yyy(corner)=yy
			
			latit(corner) = asin ( ( cos(cc) * sin(deg_to_rad(jup_seangle)) ) + ( ( yy * sin(cc) * cos(deg_to_rad(jup_seangle)) / pp ) )   )

			longit(corner) = deg_to_rad(jup_cml) - atan( ( xx * sin(cc) ) / ( ( pp * cos(deg_to_rad(jup_seangle)) * cos(cc) ) -  ( yy * sin (deg_to_rad(jup_seangle)) * sin (cc))  ) )

		;if rad_to_deg(latit(corner)) eq 0 then print,x,y,xx,yy,polar,pp,R,cc,pp/R,latit(corner),longit(corner),rad_to_deg(latit(corner)),rad_to_deg(longit(corner))
;		reasd
		
		endif
		
	endfor

	zzz=where(longit ne 0.,zzzcount)

;	if zzzcount gt 3 then if rad_to_deg(max(longit)-min(longit)) gt 15 then print,'longit',ccc,ppp,ppp/R,xxx,yyy,rad_to_deg(longit),rad_to_deg(latit),rad_to_deg(max(longit)-min(longit))


return
end
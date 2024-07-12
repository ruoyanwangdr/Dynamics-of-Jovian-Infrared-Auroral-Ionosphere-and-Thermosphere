PRO nirspec_red_order,directory,order,min=min,max=max

	;;;use rectify to save data into correct order directory...

; NAME: RECTIFY1
; PURPOSE: Read fits.gz file from specified directory, rectify it via RECTIFY procedure, then save it 
; as .fits file via WRITEFITS procedure in /spec/reduced/uranus/order19 directory
; NOTE: Procedure can be executed inside loop running from 1 to n, n being the number of 
; fits.gz files to be rectified and saved. In this case loop provides value of n1 argument.

cd, directory

spawn,'ls *.fits',files
rows=n_elements(files)


if not keyword_set(min) then min=0
if not keyword_set(max) then max=rows-1

for i=min,max do begin


filesplit=strsplit(files(i),'.',/extr)

readfilename=directory+'/'+files(i)
writefilename=directory+'/'+order+'/'+filesplit(0)+'_'+order+'.fits'

print,i,": '"+readfilename+"'"
rectify, readfilename, output, waverange;,/verb
;cd, directory+'/'+order+'/'
writefits, writefilename, output
;cd, directory
endfor


writefits,directory+'/'+order+'/waverange.fits',waverange



END

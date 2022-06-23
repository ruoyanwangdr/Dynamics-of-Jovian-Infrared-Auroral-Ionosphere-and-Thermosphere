#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 16 16:42:14 2022

@author: RuoyanWang
"""

import numpy as np

# convert cartesian to polar
def cart2pol(x, y):
    rho = np.sqrt(x**2 + y**2)
    phi = np.degrees(np.arctan2(y, x))
    return(rho, phi)

# convert polar to cartesian
def pol2cart(rho, phi):
    x = rho * np.cos(np.radians(phi))
    y = rho * np.sin(np.radians(phi))
    return(x, y)

# calculate latitude and longitude for Jupiter spec taken by NirSpec
def nirspec_calc_lat_long(x,y,jup_pixel_radius,jup_seangle,jup_posangle,jup_cml):
    """
    x = horizontal axis of spectra, eg. np.linspace(-150, 150, 301)
    y = vertical axis of spectra, eg. np.linspace(187, 187-43, 44)
    jup_pixel_radius = jupiter radius in pixels, ie. angular diameter / arcsec per pixel / 2
    jup_seangle = jupiter seeing angle, ie. sub earth latitude, eg. sel = -3.098 degrees
    jup_posangle = jupiter position angle, ie. 0 for facing north pole
    jup_cml = central meridian longitude, ie. cml = 180
    
    """
    
    jup_posangle2 = (720-jup_posangle) % 360.
    
    latit = np.zeros(5)
    longit = np.zeros(5)
    
    ccc = np.zeros(5)
    ppp = np.zeros(5)
    xxx = np.zeros(5)
    yyy = np.zeros(5)
    xxx = np.zeros(5)
    
    R = jup_pixel_radius
    
    # do a lat and long for each corner of pixel
    for corner in range(5):
        if corner == 0:
            x2 = x + 0.5
            y2 = y + 0.5
        if corner == 1:
            x2 = x + 0.5
            y2 = y - 0.5
        if corner == 2:
            x2 = x - 0.5
            y2 = y - 0.5
        if corner == 3:
            x2 = x - 0.5
            y2 = y + 0.5
        if corner == 4:
            x2 = x
            y2 = y
            
        # rotate the pixels into jovian rotational coordinates
        polar = cart2pol(x2,y2)
        new_polar = jup_posangle2 + polar[1]
        rect2 = pol2cart(polar[0], new_polar)

        xx = rect2[0]

        # stretch yy to become a sphere
        flattening = 0.06487
        losflattening = flattening * (1 - np.sin(np.radians(jup_seangle)))
        eq_po_ratio = 1 - losflattening

        yy = rect2[1] / eq_po_ratio

        pp = np.sqrt(xx**2 + yy**2) # proper distance from centre

        if pp/R < 0.998 and pp >= 1e-5:
            cc = np.arcsin(pp/R) # angular distance from centre

            ccc[corner] = cc
            ppp[corner] = pp
            xxx[corner] = xx
            yyy[corner] = yy

            latit[corner] = np.arcsin((np.cos(cc) * np.sin(np.radians(jup_seangle))) + ((yy * np.sin(cc) * np.cos(np.radians(jup_seangle))) / pp))
            longit[corner] = ((np.radians(jup_cml) - np.arctan2((xx * np.sin(cc)), ((pp * np.arccos(np.radians(jup_seangle)) * np.cos(cc)) - (yy * np.sin(np.radians(jup_seangle)) * np.sin(cc))))) + (2*np.pi)) % (2*np.pi)
    
    return np.degrees(latit), np.degrees(longit)
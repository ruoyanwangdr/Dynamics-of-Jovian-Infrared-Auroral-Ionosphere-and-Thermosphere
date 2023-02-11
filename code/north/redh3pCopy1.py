#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 16 21:00:18 2022

@author: RuoyanWang
"""

import numpy as np
from astropy.io import fits
import glob
from lmfit import Model


# define guassian function, credit to pen and pants IDL's Gaussfit in Python
def gaussian_fit(x, a0, a1, a2, a3, a4, a5):
    """
    x = data array
    a0 = height of guassian
    a1 = pixel position of Gaussian peak
    a2 = width of Gaussian
    a3 = constant term
    a4 = linear term
    a5 = quadratic term

    note: fwhm = a2 * np.sqrt(2 * np.log(2)) * 2
    """
    z = (x - a1) / a2
    y = a0 * np.exp(-z**2 / a2) + a3 + a4 * x + a5 * x**2
    return y


# read in fits files
def read_fits(path):
    """
    eg. path = '..../spec/order36/new_frame/*.fits' for all fits files
    """

    data_list = []

    data = sorted(glob.glob(path))

    for i in range(len(data)):
        hdu = fits.getdata(data[i])
        data_list.append(hdu)

    data_array = np.array(data_list)

    return data_array


# calculate average of data frames
def calc_avg(fits_data, start, stop, init):
    """
    Calculate the average of data frames.

    data: echelle order of spectrograph to be processed
    start: index of first fits file to process
    stop: index of last fits file to process
    init: index of first fits file of all

    return: the average of ranged fits files in the same shape as individual.

    An example: a folder contains fits files from order 36 ranging from 22 to 111 and
        the files to be processed are 32 to 41. In this case, order = order36, start = 32,
        stop = 41, init = 22. The order is a self defined variable name,
        typically an array of 2d spectra data, eg. order.shape = (90, 264, 1024).
        The returned result would be a single 2d data frame in a shape of (264, 1024),
        with each pixel an average of the input fits files at the same pixel position.
    """
    
    data = read_fits(fits_data)
    
    avg = np.mean((data[start - init:stop - init + 1]), axis=0)

    return avg


# convert utc in fits header to seconds
def fits_header_utc_to_second(path, fn):
    """
    eg. path = '..../spec/jun02s*' for all firles contains 'jun02s'
    """

    data = sorted(glob.glob(path))

    hdu_header = fits.open(data[fn - 1], ignore_missing_end=True)[0].header

    h = float(hdu_header['UTC'].split(':')[0])
    m = float(hdu_header['UTC'].split(':')[1])
    s = float(hdu_header['UTC'].split(':')[2])

    seconds = h * 3600 + m * 60 + s

    return seconds


# scale the sky frame
def scale_sky_frame(data, datfn, skyfn, init, path):
    """
    Scale sky frames linearly to account for change of sky brightness during observation.
    Refer to equation on page 9 of Stallard_et_al_2019,
    DOI:https://doi.org/10.1098/rsta.2018.0405
    """

    for i in range(len(skyfn) - 1):
        if datfn > skyfn[i] and datfn < skyfn[i + 1]:
            skyfn1, skyfn2 = skyfn[i], skyfn[i + 1]

            sky1, sky2 = data[skyfn1 - init], data[skyfn2 - init]

            t1 = fits_header_utc_to_second(path, skyfn1)
            t2 = fits_header_utc_to_second(path, skyfn2)
            td = fits_header_utc_to_second(path, datfn)

            sky_scaled = sky1 * ((t2 - td) / (t2 - t1)) + \
                sky2 * ((td - t1) / (t2 - t1))

            return sky_scaled


# reduce spec
def reduce_spec(fits_data, avg_flat, avg_dark, data_start, spec_start, spec_stop, fits_header, skyframe):
    
    data = read_fits(fits_data)
    
    spec_reduce_list = []
    
    for fn in range(spec_start, spec_stop+1):
        if fn in skyframe:
            continue
        else:
            sky = scale_sky_frame(data, fn, skyframe, data_start, fits_header)
            
            reduce_spec = (data[fn-data_start] - sky) / (avg_flat - avg_dark)
            reduce_spec[reduce_spec<0] = 0
            
            spec_reduce_list.append(reduce_spec)
            
    spec_reduced = np.array(spec_reduce_list)
    
    return spec_reduced


# ABBA mode subtraction
def ABBA_subtraction(fits_data, modeA_set, modeB_set, data_start, avg_flat, avg_dark, exp_star):
    
    data = read_fits(fits_data)
    
    A1 = data[modeA_set[0] - data_start]
    A2 = data[modeA_set[1] - data_start]
    A3 = data[modeA_set[2] - data_start]
    A4 = data[modeA_set[3] - data_start]
    
    B1 = data[modeB_set[0] - data_start]
    B2 = data[modeB_set[1] - data_start]
    B3 = data[modeB_set[2] - data_start]
    B4 = data[modeB_set[3] - data_start]
    
    modeA = np.sum((A1, A2, A3, A4), axis=0)
    modeB = np.sum((B1, B2, B3, B4), axis=0)
    
    modeAB = ((modeA - modeB)/len(modeA_set))/(avg_flat - avg_dark)/exp_star
    
    return modeAB

def cali_spec(lambda_aw, T, F_alpha_lyrae, m_lambda, wavelength_data):
    
    wave = read_fits(wavelength_data)
    
    hc_kb = 14388 # mu m K
    
    F_a0 = F_alpha_lyrae * 10**(-0.4*m_lambda)
    
    Fbb = F_a0 * ((lambda_aw/wave)**5) * ((np.exp(hc_kb/(lambda_aw*T)) - 1)/(np.exp(hc_kb/(wave*T)) - 1))
    
    return Fbb
    

def obs_spec(fit_set, star_spec):
    
    flux_model = Model(gaussian_fit)
    
    flux_params = flux_model.make_params()
    flux_params.add('a0', value=fit_set[0])
    flux_params.add('a1', value=fit_set[1])
    flux_params.add('a2', value=fit_set[2])
    flux_params.add('a3', value=fit_set[3])
    flux_params.add('a4', value=fit_set[4])
    flux_params.add('a5', value=fit_set[5])
    
    star_a0 = np.zeros(np.size(star_spec,1))
    star_a2 = np.zeros(np.size(star_spec,1))
    
    spat_ax = np.linspace(0, star_spec.shape[0]-1, star_spec.shape[0])
    
    for i in range(len(star_spec.T)):
        try:
            flux_fit_result = flux_model.fit(star_spec.T[i], flux_params, x=spat_ax)
        except Exception:
            pass
            
        star_a0[i] = flux_fit_result.params['a0'].value
        star_a2[i] = flux_fit_result.params['a2'].value

    star_fwhm = star_a2*(np.sqrt(2*np.log(2))*2)
    Fobs = star_a0 * star_fwhm
    
    return Fobs


def flux_cal(spec_reduced, Fbb, Fobs, arcsec_pix_w, arcsec_pix_l, exp_spec)

    Fc = Fbb/Fobs

    width = spec_reduced.shape[1]
    length = spec_reduced.shape[2]
    
    slit_area = arcsec_pix_w * width * arcsec_pix_l * length
    
    fjc_list = []
    
    for i in range(len(spec_reduced)):
        fjc_list.append(spec_reduced[i] / exp_spec * Fc * 4.2535e10 / slit_area)
        
    fjc = np.array(fjc_list)
    
    return fjc
    
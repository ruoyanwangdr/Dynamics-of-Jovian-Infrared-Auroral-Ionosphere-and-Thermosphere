#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 16 21:00:18 2022

@author: RuoyanWang
"""

import numpy as np
from astropy.io import fits
import glob

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


def read_file(path):
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


def calc_avg(data, start, stop, init):
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

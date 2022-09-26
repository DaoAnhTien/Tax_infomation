import os

import cv2
import numpy
# import pytesseract
from robot.api import logger
from DOP.RPA.Ocr import DopRpaOcr
import RequestCaptcha
from libraries.RequestCaptcha import get_text_img_ocr


def read_image(file_path):
    original = cv2.imread(file_path, cv2.IMREAD_UNCHANGED)
    trans_mask = original[:, :, 3] == 0
    original[trans_mask] = [255, 255, 255, 255]
    converted_image = cv2.cvtColor(original, cv2.COLOR_BGR2GRAY)
    return converted_image


def thresholding(image):
    return cv2.threshold(image, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]


def dilate(image):
    kernel = numpy.ones((3, 3), numpy.uint8)
    return cv2.dilate(image, kernel, iterations=1)


def erode(image):
    kernel = numpy.ones((2, 2), numpy.uint8)
    return cv2.erode(image, kernel, iterations=1)


def opening(image):
    kernel = numpy.ones((1, 1), numpy.uint8)
    return cv2.morphologyEx(image, cv2.MORPH_OPEN, kernel)


def remove_noise(image):
    return cv2.medianBlur(image, 3)

def pre_process_captcha(img_path):
    converted_image = read_image(img_path)
    thresholding_image = thresholding(converted_image)
    dilate_image = dilate(thresholding_image)
    erode_image = erode(dilate_image)
    opening_image = opening(erode_image)
    remove_noise_image = remove_noise(opening_image)
    return remove_noise_image

def resolve_captcha(img_path,domainCaptcha):
    processed_img = pre_process_captcha(img_path)
    processed_image_path = img_path
    cv2.imwrite(processed_image_path, processed_img)

    # raw_captcha = pytesseract.image_to_string(
    #     processed_img, config=' -c tessedit_char_whitelist=0123456789abcdefghijklmnopqrstuvwxyz')
    try:
        raw_captcha = get_text_img_ocr(img_path=processed_image_path,domainCaptcha=domainCaptcha)
        raw_captcha = raw_captcha.replace("\u2029", "")
        return raw_captcha.strip()

    except Exception as exc:
        print(exc)

def is_captcha_valid( captcha_text):
    if captcha_text and (len(captcha_text) == 5):
        return True
    else:
        return False

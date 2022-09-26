import json
import requests
import os as os


def get_text_img_ocr(img_path, domainCaptcha):
    url = "https://" + domainCaptcha + "/services/dopocr/api/v1/ocr/captcha"
    ocr_command = {"modelCode": "MODLE-1", "language": "English"}

    files = {
        "ocrCommand": (None, json.dumps(ocr_command), "application/json"),
        "file": (
            os.path.basename(img_path),
            open(img_path, "rb"),
            "application/octet-stream",
        ),
    }
    response = requests.post(url, files=files)
    textCaptcha = json.loads(response.text)
    return textCaptcha["plainText"]

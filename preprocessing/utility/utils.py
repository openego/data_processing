import os


DOWNLOADDIR = os.path.join(os.path.expanduser("~"), ".egon-pre-processing-cached/")


def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file), arcname=file)


def wkb_hexer(line):
    return line.wkb_hex
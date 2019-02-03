import sys
import qrcode

FRONTEND = "https://moonstone.seium.org/user/"
if sys.argv[2] == "stg":
    FRONTEND = "https://stg-moonstone.seium.org/user/"


with open(sys.argv[1]) as f:
    content = f.readlines()
    content = [x.strip() for x in content]
    for line in content:
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,
            box_size=10,
            border=4,
            )
        qr.add_data(FRONTEND + line)
        qr.make(fit=True)

        # Create an image from the QR Code instance
        img = qr.make_image()

        img.save("out/"+line+".png")


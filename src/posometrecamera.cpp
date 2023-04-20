#include "posometrecamera.h"

PosometreCamera::PosometreCamera(QObject *parent)
    : QObject{parent}
{

}

PosometreCamera::~PosometreCamera()
{
}

float PosometreCamera::getGamma(QQuickItemGrabResult *data)
{
    QImage im = data->image();
    float x = 0, y = 0, r, g, b, c = 0, gamma = 0;
    QRgb rgb;

    while (x < im.width())
    {
        y = 0;
        while (y < im.height()) {
            if (im.pixelColor(x, y) == QColor::Invalid)
            {
                x = 10000;
                break;
            }
            rgb = im.pixel(x, y);
            r = qRed(rgb) / 255.0;
            g = qGreen(rgb) / 255.0;
            b = qBlue(rgb) / 255.0;
            gamma += (r + g + b) / 3;
            y += 1;
            c += 1;
        }
        x += 1;
    }
    emit this->lighnessValue((gamma / c) * 6);
    return 1.0;
}

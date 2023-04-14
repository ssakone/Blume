#include "posometrecamera.h"

PosometreCamera::PosometreCamera(QObject *parent)
    : QObject{parent}
{

}

PosometreCamera::~PosometreCamera()
{
    emit imageCapture->destroyed();
}

void PosometreCamera::takeValue()
{
    QMediaCaptureSession *captureSession = new QMediaCaptureSession();
    QCamera *camera = new QCamera;
    captureSession->setCamera(camera);

    camera->start();
    //on shutter button pressed
    imageCapture = new QImageCapture();
    captureSession->setImageCapture(imageCapture);
    setMute(true);
    imageCapture->capture();

    connect(imageCapture, &QImageCapture::imageCaptured, this, &PosometreCamera::getImageGamma);
}

float PosometreCamera::getGamma(QQuickItemGrabResult *data)
{
    QImage im = data->image();
    qDebug() << im.width() << "x" << im.height();
    getImageGamma(1, im);
    float x = 0, y = 0, r, g, b, c = 0, gamma = 0, lightness = 0;
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
            lightness += im.pixelColor(x, y).lightnessF();
            y += 1;
            c += 1;
        }
        x += 1;
    }
    qDebug() << ((lightness / c) * 6) / 255 << (gamma / c) * 6;
    emit this->lighnessValue((gamma / c) * 6);
    this->setMute(false);
    qDebug() << "sending to gama";
    return 1.0;
}

void PosometreCamera::setMute(bool mute)
{
    QAudioOutput *output = nullptr;

    if (!output) {
        output = new QAudioOutput;
        output->setDevice(QMediaDevices::defaultAudioOutput());
    }

    output->setMuted(mute);
}

void PosometreCamera::getImageGamma(int id, QImage im)
{
    Q_UNUSED(id);
    float x = 0, y = 0, r, g, b, c = 0, gamma = 0, lightness = 0;
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
            lightness += im.pixelColor(x, y).lightnessF();
            y += 1;
            c += 1;
        }
        x += 1;
    }
    qDebug() << ((lightness / c) * 6) / 255 << (gamma / c) * 6;
    emit this->lighnessValue((gamma / c) * 6);
    this->setMute(false);
}

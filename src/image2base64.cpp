#include "image2base64.h"
#include <QFile>

Image2Base64::Image2Base64(QObject *parent)
    : QObject{parent}
{

}

QString Image2Base64::getBase64(QString imgSource)
{
    QFile file(imgSource);
    if (!file.open(QIODevice::ReadOnly))
        return "";

    // Lire le contenu du fichier dans un QByteArray
    QByteArray data = file.readAll();
    file.close();

    // Convertir le QByteArray en base64
    QByteArray base64Data = data.toBase64();
    return base64Data;
}

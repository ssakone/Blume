#ifndef IMAGE2BASE64_H
#define IMAGE2BASE64_H

#include <QObject>
#include <QString>

class Image2Base64 : public QObject
{
    Q_OBJECT
public:
    explicit Image2Base64(QObject *parent = nullptr);
    Q_INVOKABLE QString getBase64(QString imgSource);
signals:

};

#endif // IMAGE2BASE64_H

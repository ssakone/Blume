#ifndef POSOMETRECAMERA_H
#define POSOMETRECAMERA_H

#include <QObject>
#include <QtMultimedia>
#include <QQuickItemGrabResult>

class PosometreCamera : public QObject
{
    Q_OBJECT
public:
    explicit PosometreCamera(QObject *parent = nullptr);
    ~PosometreCamera();
    Q_INVOKABLE void takeValue();
    Q_INVOKABLE float getGamma(QQuickItemGrabResult *data = nullptr);
    static void setMute(bool mute);

public slots:
    void getImageGamma(int id, QImage im);
private:
    QImageCapture *imageCapture;

signals:
    void lighnessValue(float);

};

#endif // POSOMETRECAMERA_H

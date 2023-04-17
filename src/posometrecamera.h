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
    Q_INVOKABLE float getGamma(QQuickItemGrabResult *data = nullptr);

signals:
    void lighnessValue(float);

};

#endif // POSOMETRECAMERA_H

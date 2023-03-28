#ifndef IMAGEPICKER_H
#define IMAGEPICKER_H

#include <QObject>
#include <QQuickItem>
#include <QDateTime>
#define DEBUG if(1) qDebug() << QDateTime::currentDateTime().toString("dd/MM/yyyy hh:mm:ss:zzz") <<  __PRETTY_FUNCTION__

class ImagePicker : public QQuickItem
{
    Q_OBJECT
public:
    explicit ImagePicker(QQuickItem *parent = 0);
    Q_INVOKABLE void openPicker();
    Q_INVOKABLE void openCamera();
    QString imagePath() const
    {
        return m_imagePath;
    }

signals:
    void capturedImage(QString imagePath);

private:
    void *m_delegate;
    QString m_imagePath;
};

#endif // IMAGEPICKER_H

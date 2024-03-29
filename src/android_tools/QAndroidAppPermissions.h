/*
 *	MIT License
 *
 *	Copyright (c) 2018 Fabio Falsini <falsinsoft@gmail.com>
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in all
 *	copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *	SOFTWARE.
 */
#pragma once

#include <QtCore/private/qandroidextras_p.h>
#include <QQmlEngine>
#include <QVariant>

class QAndroidAppPermissions : public QObject, QAndroidActivityResultReceiver
{
	Q_OBJECT
	Q_DISABLE_COPY(QAndroidAppPermissions)

    typedef QHash<QString, QtAndroidPrivate::PermissionResult> PermissionResultMap;

    QAndroidAppPermissions() : QAndroidAppPermissions(nullptr) {}

public:
    QAndroidAppPermissions(QObject *parent);

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);
    static QAndroidAppPermissions* instance();


    Q_INVOKABLE void requestPermissions(const QStringList &permissionsNameList);
    Q_INVOKABLE void requestPermission(const QString &permissionName);
    Q_INVOKABLE bool shouldShowRequestPermissionInfo(const QString &permissionName);
    Q_INVOKABLE bool isPermissionGranted(const QString &permissionName);
    Q_INVOKABLE void openCamera();
    Q_INVOKABLE void openImageGallery();
    Q_INVOKABLE void openGallery();
    static void done(JNIEnv *env, jobject thiz, jstring path);

Q_SIGNALS:
    void requestPermissionsResults(const QVariantList &results);
signals:
    void cool();
    void imageSelected(QVariant imagePath);
private:
    static QAndroidAppPermissions *m_pInstance;
    void handleActivityResult(int receiverRequestCode, int resultCode, const QJniObject &data) override;
    QJniObject takePhotoSavedUri;
    QString filePath;
    QVariantList convertToVariantList(const PermissionResultMap &resultMap) const;
};

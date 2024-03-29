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
#include "QAndroidAppPermissions.h"
#include "qdatetime.h"
#include <QtCore>
#include <QtCore/private/qandroidextras_p.h>


QAndroidAppPermissions *QAndroidAppPermissions::m_pInstance = nullptr;

QAndroidAppPermissions::QAndroidAppPermissions(QObject *parent) : QObject(parent)
{
    m_pInstance = this;
}

QObject* QAndroidAppPermissions::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new QAndroidAppPermissions();
}

QAndroidAppPermissions* QAndroidAppPermissions::instance()
{
    return m_pInstance;
}

void QAndroidAppPermissions::requestPermissions(const QStringList &permissionsNameList)
{
    PermissionResultMap resultMap;

    if(QNativeInterface::QAndroidApplication::sdkVersion() >= 23)
    {
        QStringList permissionsNotGrantedList;

        for(int i = 0; i < permissionsNameList.count(); i++)
        {
            if(isPermissionGranted(permissionsNameList[i]) == false)
            {
                resultMap[permissionsNameList[i]] = QtAndroidPrivate::requestPermission(permissionsNameList[i]).result();
            }
            else
            {
                resultMap[permissionsNameList[i]] = QtAndroidPrivate::PermissionResult::Authorized;
            }
        }
    }
    else
    {
        for(int i = 0; i < permissionsNameList.count(); i++)
        {
            resultMap[permissionsNameList[i]] = QtAndroidPrivate::PermissionResult::Authorized;
        }
    }

    if(resultMap.size() > 0)
    {
        Q_EMIT requestPermissionsResults(convertToVariantList(resultMap));
    }
}

void QAndroidAppPermissions::requestPermission(const QString &permissionName)
{
    PermissionResultMap resultMap;

    if(QNativeInterface::QAndroidApplication::sdkVersion() >= 23
    && isPermissionGranted(permissionName) == false)
    {
        resultMap[permissionName] = QtAndroidPrivate::requestPermission(permissionName).result();
    }
    else
    {
        resultMap[permissionName] = QtAndroidPrivate::PermissionResult::Authorized;
    }

    Q_EMIT requestPermissionsResults(convertToVariantList(resultMap));
}

bool QAndroidAppPermissions::shouldShowRequestPermissionInfo(const QString &permissionName)
{
    if(QNativeInterface::QAndroidApplication::sdkVersion() >= 23)
    {
        const QJniObject activity = QNativeInterface::QAndroidApplication::context();

        return activity.callMethod<jboolean>("shouldShowRequestPermissionRationale",
                                             "(Ljava/lang/String;)Z",
                                             QJniObject::fromString(permissionName).object<jstring>()
                                             );
    }

    return false;
}

bool QAndroidAppPermissions::isPermissionGranted(const QString &permissionName)
{
    return (QtAndroidPrivate::checkPermission(permissionName).result() == QtAndroidPrivate::PermissionResult::Authorized) ? true : false;
}


void QAndroidAppPermissions::openCamera()
{
    const QJniObject activity = QNativeInterface::QAndroidApplication::context();

    QAndroidIntent activityIntent(activity.object(),
                                  "com/mahoutech/blume/ImagePicker");
    const JNINativeMethod methods[] =
        {{"done", "(Ljava/lang/String;)V", reinterpret_cast<void *>(&QAndroidAppPermissions::done)}};
    QJniEnvironment env;
    env.registerNativeMethods("com/mahoutech/blume/ImagePicker", methods, 1);

    QtAndroidPrivate::startActivity(activityIntent.handle(), 100, this);
}

void QAndroidAppPermissions::openImageGallery()
{
    const QJniObject activity = QNativeInterface::QAndroidApplication::context();

    QAndroidIntent activityIntent(activity.object(),
                                  "com/mahoutech/blume/GalleryImagePicker");
    const JNINativeMethod methods[] =
        {{"done", "(Ljava/lang/String;)V", reinterpret_cast<void *>(&QAndroidAppPermissions::done)}};
    QJniEnvironment env;
    env.registerNativeMethods("com/mahoutech/blume/GalleryImagePicker", methods, 1);

    QtAndroidPrivate::startActivity(activityIntent.handle(), 100, this);
}

void QAndroidAppPermissions::openGallery()
{
    const QJniObject activity = QNativeInterface::QAndroidApplication::context();

    QAndroidIntent activityIntent(activity.object(),
                                  "com/mahoutech/blume/GalleryPicker");
    const JNINativeMethod methods[] =
        {{"done", "(Ljava/lang/String;)V", reinterpret_cast<void *>(&QAndroidAppPermissions::done)}};
    QJniEnvironment env;
    env.registerNativeMethods("com/mahoutech/blume/GalleryPicker", methods, 1);

    QtAndroidPrivate::startActivity(activityIntent.handle(), 100, this);
}


void QAndroidAppPermissions::done(JNIEnv *env, jobject thiz, jstring path)
{
    Q_UNUSED(env);
    Q_UNUSED(thiz);
    QString qstr(env->GetStringUTFChars(path, 0));
    Q_EMIT m_pInstance->imageSelected(QVariant(qstr));
}

void QAndroidAppPermissions::handleActivityResult(int receiverRequestCode, int resultCode, const QJniObject &data)
{
    if (resultCode == -1 && data.isValid()) {
        // l'image a été capturée ou sélectionnée avec succès
        if (receiverRequestCode == 101) {

        } else if (receiverRequestCode == 102) {
            // traiter l'image sélectionnée
        }
    } else {
        // l'opération a été annulée ou a échoué
    }
}

QVariantList QAndroidAppPermissions::convertToVariantList(const PermissionResultMap &resultMap) const
{
    auto permissionItem = resultMap.constBegin();
    QVariantList permissionsList;

    while(permissionItem != resultMap.constEnd())
    {
        QVariantMap permissionResult;

        permissionResult["name"] = permissionItem.key();
        permissionResult["granted"] = (permissionItem.value() == QtAndroidPrivate::PermissionResult::Authorized) ? true : false;
        permissionsList << permissionResult;

        ++permissionItem;
    }

    return permissionsList;
}

/*!
 * This file is part of Blume.
 * Copyright (c) 2022 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "DatabaseManager.h"
#include "SettingsManager.h"
#include "SystrayManager.h"
#include "MenubarManager.h"
#include "NotificationManager.h"
#include "DeviceManager.h"
#include "PlantDatabase.h"
#include "Journal.h"

#include "utils_app.h"
#include "utils_screen.h"
#include "utils_language.h"
#include "image2base64.h"
#include "posometrecamera.h"
#include "database/sqlplugin.h"
#if defined(Q_OS_MACOS)
#include "utils_os_macosdock.h"
#endif

#if defined(Q_OS_IOS)
#include "imagepicker.h"
#endif

#if defined(Q_OS_ANDROID)
#include "android_tools/QtAndroidTools.h"
#endif

#include <MobileUI/MobileUI.h>
#include <MobileSharing/MobileSharing.h>
#include <SingleApplication/SingleApplication.h>

#include <QtGlobal>
#include <QLibraryInfo>
#include <QVersionNumber>

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>
#include <QQuickStyle>
#include <HotWatch.h>
#include <Qaterial/Qaterial.hpp>
#include <QtWebView>

#if defined(Q_OS_ANDROID)
#include "AndroidService.h"
#include "private/qandroidextras_p.h" // for QAndroidService
#endif

/* ************************************************************************** */

int main(int argc, char *argv[])
{
    // Arguments parsing ///////////////////////////////////////////////////////

    bool start_minimized = false;
    bool refresh_only = false;
    bool background_service = false;
    for (int i = 1; i < argc; i++)
    {
        if (argv[i])
        {
            //qDebug() << "> arg >" << argv[i];

            if (QString::fromLocal8Bit(argv[i]) == "--start-minimized")
                start_minimized = true;
            if (QString::fromLocal8Bit(argv[i]) == "--service")
                background_service = true;
            if (QString::fromLocal8Bit(argv[i]) == "--refresh")
                refresh_only = true;
        }
    }

    // Background service application //////////////////////////////////////////

    // Refresh data in the background, without starting the UI, then exit
    if (refresh_only)
    {
        QCoreApplication app(argc, argv);
        app.setApplicationName("Blume");
        app.setOrganizationName("Blume");
        app.setOrganizationDomain("Blume");

        SettingsManager *sm = SettingsManager::getInstance();
        DatabaseManager *db = DatabaseManager::getInstance();
        NotificationManager *nm = NotificationManager::getInstance();
        DeviceManager *dm = new DeviceManager();
        if (!sm || !db || !nm || !dm) return EXIT_FAILURE;

        if (dm->areDevicesAvailable())
        {
            dm->refreshDevices_listen();
        }

        return app.exec();
    }
#if defined(Q_OS_MACOS) || defined (Q_OS_IOS)
     QQuickStyle::setStyle("Material");
#endif

    // Android daemon
    if (background_service)
    {
#if defined(Q_OS_ANDROID)
        QAndroidService app(argc, argv);
        app.setApplicationName("Blume");
        app.setOrganizationName("Blume");
        app.setOrganizationDomain("Blume");

        SettingsManager *sm = SettingsManager::getInstance();
        if (sm && sm->getSysTray())
        {
            AndroidService *as = new AndroidService();
            if (!as) return EXIT_FAILURE;

            return app.exec();
        }

        return EXIT_SUCCESS;
#endif
    }


    // GUI application /////////////////////////////////////////////////////////

#if defined(Q_OS_ANDROID)
    // Set navbar color, same as the loading screen
    MobileUI::setNavbarColor("white");
#endif

#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    // NVIDIA suspend&resume hack
    auto format = QSurfaceFormat::defaultFormat();
    format.setOption(QSurfaceFormat::ResetNotification);
    QSurfaceFormat::setDefaultFormat(format);
#endif

    SingleApplication app(argc, argv);

    // Application name
    app.setApplicationName("Blume");
    app.setApplicationDisplayName("Blume");
    app.setOrganizationName("Blume");
    app.setOrganizationDomain("Blume");

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    QIcon appIcon(":/assets/logos/blume.svg");
    app.setWindowIcon(appIcon);
#endif

    // Init components
    SettingsManager *sm = SettingsManager::getInstance();
    SystrayManager *st = SystrayManager::getInstance();
    MenubarManager *mb = MenubarManager::getInstance();
    NotificationManager *nm = NotificationManager::getInstance();
    DeviceManager *dm = new DeviceManager;
    if (!sm || !st || !mb || !nm || !dm)
    {
        qWarning() << "Cannot init Blume components!";
        return EXIT_FAILURE;
    }

    // Plant database
    PlantDatabase *pdb = PlantDatabase::getInstance();

    // Init generic utils
    UtilsApp *utilsApp = UtilsApp::getInstance();
    UtilsScreen *utilsScreen = UtilsScreen::getInstance();
    UtilsLanguage *utilsLanguage = UtilsLanguage::getInstance();
    if (!utilsScreen || !utilsApp || !utilsLanguage)
    {
        qWarning() << "Cannot init Blume utils!";
        return EXIT_FAILURE;
    }

    // Translate the application
    utilsLanguage->loadLanguage(sm->getAppLanguage());
#if defined(Q_OS_ANDROID)
    QtAndroidTools::initializeQmlTools();
#else
    qmlRegisterSingletonType(QUrl("qrc:/qml/ThemeEngine.qml"), "QtAndroidTools", 1, 0, "Theme");
#endif

    // ThemeEngine
    qmlRegisterSingletonType(QUrl("qrc:/qml/ThemeEngine.qml"), "ThemeEngine", 1, 0, "Theme");
    qmlRegisterType<Image2Base64>("ImageTools", 1, 0, "Image2Base64");
    qmlRegisterType<PosometreCamera>("PosometreCalculator", 1, 0, "PosometreCamera");
    qmlRegisterSingletonType(QUrl("qrc:/qml/components/Icons.qml"), "MaterialIcons", 1, 0, "MaterialIcons");


    MobileUI::registerQML();
    DeviceUtils::registerQML();
    JournalUtils::registerQML();

    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QtWebView::initialize();
    // Then we start the UI
    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/qml/");
    QQmlContext *engine_context = engine.rootContext();
    HotWatch::registerSingleton();

    engine.addImportPath("qrc:///");
    qaterial::registerQmlTypes();
    qaterial::loadQmlResources();

    engine_context->setContextProperty("notificationManagers", nm);
    engine_context->setContextProperty("deviceManager", dm);
    engine_context->setContextProperty("settingsManager", sm);
    engine_context->setContextProperty("systrayManager", st);
    engine_context->setContextProperty("menubarManager", mb);
    engine_context->setContextProperty("plantDatabase", pdb);
    engine_context->setContextProperty("utilsApp", utilsApp);
    engine_context->setContextProperty("utilsLanguage", utilsLanguage);
    engine_context->setContextProperty("utilsScreen", utilsScreen);
    engine_context->setContextProperty("startMinimized", (start_minimized || sm->getMinimized()));
#if defined(Q_OS_IOS)
    qmlRegisterType<ImagePicker>("ImagePicker", 1, 0, "ImagePicker");
#else
    qmlRegisterType<Image2Base64>("ImagePicker", 1, 0, "ImagePicker");
#endif
    // Load the main view
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(FORCE_MOBILE_UI)
    ShareUtils *utilsShare = new ShareUtils();
    engine_context->setContextProperty("utilsShare", utilsShare);
    engine.load(QUrl(QStringLiteral("qrc:/qml/Loadere.qml")));
    //engine.load(QUrl(QStringLiteral("qrc:/qml/MobileApplication.qml")));
#else
    engine.load(QUrl(QStringLiteral("qrc:/qml/DesktopApplication.qml")));
#endif
//    if (engine.rootObjects().isEmpty())
//    {
//        qWarning() << "Cannot init QmlApplicationEngine!";
//        return EXIT_FAILURE;
//    }

    // For i18n retranslate
    utilsLanguage->setQmlEngine(&engine);

    // Notch handling // QQuickWindow must be valid at this point
    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));
    engine_context->setContextProperty("quickWindow", window);

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS) // desktop section

    // React to secondary instances
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::show);
    QObject::connect(&app, &SingleApplication::instanceStarted, window, &QQuickWindow::raise);

    // Systray?
    st->setupSystray(&app, window);
    if (sm->getSysTray()) st->installSystray();

    // Menu bar
    mb->setupMenubar(window, dm);

#if defined(Q_OS_LINUX)
    // GNOME hack for the mysterious disappearences of the tray icon with TopIcon Plus
    // gnome-shell-extension-appindicator is recommanded instead of TopIcon Plus
    //QObject::connect(&app, &SingleApplication::instanceStarted, st, &SystrayManager::REinstallSystray);
#endif

#if defined(Q_OS_MACOS)
    // dock
    MacOSDockHandler *dockIconHandler = MacOSDockHandler::getInstance();
    dockIconHandler->setupDock(window);
    engine_context->setContextProperty("utilsDock", dockIconHandler);
#endif

#endif // desktop section

#if defined(Q_OS_ANDROID)
    QNativeInterface::QAndroidApplication::hideSplashScreen(333);
    if (sm->getSysTray()) AndroidService::service_start();
#endif

    return app.exec();
}

/* ************************************************************************** */

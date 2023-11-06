cmake_minimum_required(VERSION 3.19)

# On n'utilise plus la version 5.0 de WatchFlower
# On recommence le projet à la version 0.1
project(Blume VERSION 1.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(BLUME_PROJECT "Blume" CACHE STRING "Blume Project")


find_package(Qt6 COMPONENTS Core Bluetooth Network Sql Multimedia Xml REQUIRED)
find_package(Qt6 COMPONENTS Gui Qml Quick QuickControls2 Svg Widgets Charts WebView REQUIRED)
find_library(UIKIT_LIBRARY UIKit)
find_library(MOBILE_CORE_SERVICES_LIBRARY MobileCoreServices)


################################################################################
include(FetchContent)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON)
FetchContent_Declare(
  Qaterial
  GIT_REPOSITORY https://github.com/ssakone/Qaterial.git
  GIT_TAG        qt6_update
)
FetchContent_MakeAvailable(Qaterial)

add_subdirectory(HotWatch)

set(android_sources)
if (ANDROID)
    set(android_sources
        src/android_tools/QAndroidAppPermissions.cpp
        src/android_tools/QtAndroidTools.cpp
        src/android_tools/QAndroidAppPermissions.h
        src/android_tools/QtAndroidTools.h
    )
endif()

set(ios_sources)

if (IOS)
    set(ios_sources
        src/imagepicker.mm
        src/imagepicker.h
    )
endif()

qt_generate_qrc(MahoudQML
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qml
  DEST_DIR ${CMAKE_CURRENT_SOURCE_DIR}
  NAME "blume.qrc"
  PREFIX "qml/"
  RECURSE
  ALWAYS_OVERWRITE
  GLOB_EXPRESSION "*.qml" "qmldir" "*.frag" "*.vert" "*.js"
)

qt6_add_resources(MahoudQML_UI_QML_RES ${MahoudQML})
qt_generate_qmldir(BUMA_QML_DIR
 SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qml
 MODULE "Blume"
 RECURSE)

###############################################################################

qt_add_executable(Blume
    src/AndroidService.cpp src/AndroidService.h
    src/DatabaseManager.cpp src/DatabaseManager.h
    src/SettingsManager.cpp src/SettingsManager.h
    src/SystrayManager.cpp src/SystrayManager.h
    src/MenubarManager.cpp src/MenubarManager.h
    src/NotificationManager.cpp src/NotificationManager.h
    src/PlantDatabase.cpp src/PlantDatabase.h
    src/Plant.cpp src/Plant.h
    src/Journal.cpp src/Journal.h
    src/device.cpp src/device.h
    src/device_infos.cpp src/device_infos.h
    src/device_sensor.cpp src/device_sensor.h
    src/device_plantsensor.cpp src/device_plantsensor.h
    src/device_thermometer.cpp src/device_thermometer.h
    src/device_environmental.cpp src/device_environmental.h
    src/DeviceManager.cpp src/DeviceManager.h
    src/DeviceManager_advertisement.cpp
    src/DeviceManager_nearby.cpp
    src/DeviceManager_export.cpp
    src/DeviceFilter.cpp src/DeviceFilter.h
    src/device_utils.h src/device_firmwares.h
    src/devices/device_esp32_airqualitymonitor.cpp src/devices/device_esp32_airqualitymonitor.h
    src/devices/device_esp32_geigercounter.cpp src/devices/device_esp32_geigercounter.h
    src/devices/device_esp32_higrow.cpp src/devices/device_esp32_higrow.h
    src/devices/device_ess_generic.cpp src/devices/device_ess_generic.h
    src/devices/device_flowercare.cpp src/devices/device_flowercare.h
    src/devices/device_flowercare_tuya.cpp src/devices/device_flowercare_tuya.h
    src/devices/device_flowerpower.cpp src/devices/device_flowerpower.h
    src/devices/device_hygrotemp_cgd1.cpp src/devices/device_hygrotemp_cgd1.h
    src/devices/device_hygrotemp_cgdk2.cpp src/devices/device_hygrotemp_cgdk2.h
    src/devices/device_hygrotemp_cgg1.cpp src/devices/device_hygrotemp_cgg1.h
    src/devices/device_hygrotemp_cgp1w.cpp src/devices/device_hygrotemp_cgp1w.h
    src/devices/device_hygrotemp_clock.cpp src/devices/device_hygrotemp_clock.h
    src/devices/device_hygrotemp_lywsdcgq.cpp src/devices/device_hygrotemp_lywsdcgq.h
    src/devices/device_hygrotemp_square.cpp src/devices/device_hygrotemp_square.h
    src/devices/device_jqjcy01ym.cpp src/devices/device_jqjcy01ym.h
    src/devices/device_parrotpot.cpp src/devices/device_parrotpot.h
    src/devices/device_ropot.cpp src/devices/device_ropot.h
    src/devices/device_cgdn1.cpp src/devices/device_cgdn1.h
    src/devices/device_thermobeacon.cpp src/devices/device_thermobeacon.h
    src/devices/device_wp6003.cpp src/devices/device_wp6003.h
    src/thirdparty/RC4/rc4.cpp src/thirdparty/RC4/rc4.h
    ${android_sources}
    ${ios_sources}
    
    src/database/sqlplugin.cpp src/database/sqlplugin.h
    src/main.cpp
    src/posometrecamera.cpp src/posometrecamera.h
    src/image2base64.cpp src/image2base64.h
    i18n/i18n.qrc
    assets/assets.qrc
    assets/devices.qrc
    assets/plants.qrc
    ${MahoudQML_UI_QML_RES}
)

add_subdirectory(SortFilterProxyModel)

target_include_directories(Blume PRIVATE src/)
target_include_directories(Blume PRIVATE src/thirdparty/)

################################################################################

## Android
if(ANDROID)
    #set(QT_ANDROID_ABIS "armeabi-v7a;arm64-v8a;x86;x86_64")
    #set(QT_ANDROID_BUILD_ALL_ABIS "ON")
    set(QT_ANDROID_ABIS "arm64-v8a;armeabi-v7a")
    set(QT_ANDROID_BUILD_ALL_ABIS "ON")

    set_target_properties(Blume PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/assets/android"
    )

    #target_compile_definitions(Blume PRIVATE QT_CONNECTIVITY_PATCHED)

    target_link_libraries(Blume PRIVATE Qt::CorePrivate)

    FetchContent_Declare(
      android_openssl
      DOWNLOAD_EXTRACT_TIMESTAMP true
      URL      https://github.com/KDAB/android_openssl/archive/refs/heads/master.zip
    )
    FetchContent_MakeAvailable(android_openssl)
    include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)
endif()

## macOS
if(APPLE AND NOT IOS)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.14")

    set_property(GLOBAL PROPERTY USE_FOLDERS ON)

endif()

macro(qt_ios_set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE XCODE_RELVERSION)
  set(XCODE_RELVERSION_I "${XCODE_RELVERSION}")
  if(XCODE_RELVERSION_I STREQUAL "All")
    set_property(TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY} "${XCODE_VALUE}")
  else()
    set_property(TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY}[variant=${XCODE_RELVERSION_I}] "${XCODE_VALUE}")
  endif()
endmacro() # qt_ios_set_xcode_property

## iOS
if(IOS)
    set(BLUNE_VERSION_MAJOR 1)
    set(BLUNE_VERSION_MINOR 2)
    if(NOT BLUNE_VERSION_TAG)
        set(BLUNE_VERSION_TAG 0520000)
    endif()
    set(BLUME_TARGET "Blume")
    set(BLUME_PLATFORMS_DIR ${PROJECT_SOURCE_DIR}/platforms)
    set(BLUNE_VERSION_TAG_HEX 0x${BLUNE_VERSION_TAG})
    set(BLUNE_VERSION_TAG ${BLUNE_VERSION_TAG} CACHE STRING "Git Tag of Qaterial")
    set(BLUNE_VERSION ${BLUNE_VERSION_MAJOR}.${BLUNE_VERSION_MINOR})

    set(BLUNE_TARGET ${BLUME_PROJECT} CACHE STRING "Qaterial Gallery Target Name")
    set(asset_catalog_path "${BLUME_PLATFORMS_DIR}/ios/Images.xcassets")
    target_sources(Blume PRIVATE "${asset_catalog_path}")
    set_source_files_properties(
        ${asset_catalog_path}
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

    set(launchscreen_storyboard "${BLUME_PLATFORMS_DIR}/ios/AppLaunchScreen.storyboard")
    target_sources(Blume PRIVATE ${launchscreen_storyboard})
    set_source_files_properties(
        ${launchscreen_storyboard}
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    set_target_properties(Blume PROPERTIES
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS
        "${BLUME_PLATFORMS_DIR}/ios/blume.entitlements")

    get_filename_component(STORYBOARD_FILE_NAME ${launchscreen_storyboard} NAME_WE)
    set(MACOSX_BUNDLE_LAUNCHSCREEN_STORYBOARD ${STORYBOARD_FILE_NAME} PARENT_SCOPE)
    set_target_properties(Blume
            PROPERTIES MACOSX_BUNDLE_INFO_PLIST "${BLUME_PLATFORMS_DIR}/ios/Info.plist")
    set_target_properties(Blume PROPERTIES MACOSX_BUNDLE_GUI_IDENTIFIER "com.mahoutech.blume")
    set_target_properties(Blume PROPERTIES MACOSX_BUNDLE_IDENTIFIER "com.mahoutech.blume")
    qt_ios_set_xcode_property("Blume" ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon" "All")

    target_compile_options(Blume PRIVATE
    -x objective-c++
    -fobjc-arc)
    target_link_libraries(Blume PRIVATE
        Qt::GuiPrivate
        ${UIKIT_LIBRARY}
        ${MOBILE_CORE_SERVICES_LIBRARY}
    )

endif()

## Windows
if(WIN32)
    target_compile_definitions(Blume PRIVATE _USE_MATH_DEFINES)
endif()

################################################################################

# AppUtils
set(APP_NAME ${CMAKE_PROJECT_NAME})
set(APP_VERSION ${CMAKE_PROJECT_VERSION})
add_subdirectory(src/thirdparty/AppUtils)
target_link_libraries(Blume PRIVATE AppUtils)

# MobileUI
add_subdirectory(src/thirdparty/MobileUI)
target_link_libraries(Blume PRIVATE MobileUI)

# MobileSharing
add_subdirectory(src/thirdparty/MobileSharing)
target_link_libraries(Blume PRIVATE MobileSharing)

# SingleApplication
set(QAPPLICATION_CLASS QApplication)
add_subdirectory(src/thirdparty/SingleApplication)
target_link_libraries(Blume PRIVATE SingleApplication)

# Qt
target_link_libraries(Blume PRIVATE
    Qt::Core
    Qt::Bluetooth
    Qt::Network
    Qt::Sql
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    Qt::Widgets
    Qt::Charts
    Qt::Multimedia
    Qt::Xml
    Qt::WebView
    SortFilterProxyModel
    HotWatch
    HotWatchplugin
    Qaterial
)

################################################################################

if(lupdate_only)
    target_sources(Blume PUBLIC
        qml/*.js qml/*.qml
        qml/components/*.qml
        qml/components_generic/*.qml
        qml/components_js/*.js
    )
endif()

if(CMAKE_BUILD_TYPE STREQUAL Release)
    target_compile_definitions(Blume PRIVATE
        NDEBUG
        QT_NO_DEBUG
        QT_NO_DEBUG_OUTPUT
    )
endif()

set_target_properties(Blume PROPERTIES
    WIN32_EXECUTABLE ON
    MACOSX_BUNDLE ON
)

install(TARGETS Blume
    BUNDLE DESTINATION .    # used by macOS
    ARCHIVE DESTINATION .
    LIBRARY DESTINATION .   # used by Android
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

#qt_generate_deploy_qml_app_script(
#    TARGET Blume
#    FILENAME_VARIABLE deploy_script
#    NO_UNSUPPORTED_PLATFORM_ERROR
#    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
#    MACOS_BUNDLE_POST_BUILD
#)
#install(SCRIPT ${deploy_script})

################################################################################

message(STATUS "[PROJECT] CMAKE_VERSION                = ${CMAKE_VERSION}")
message(STATUS "[PROJECT] CMAKE_PREFIX_PATH            = ${CMAKE_PREFIX_PATH}")
message(STATUS "[PROJECT] CMAKE_TOOLCHAIN_FILE         = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "[DEFINE] SOURCE_DIR                    = ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "[DEFINE] BUILD_TYPE                    = ${CMAKE_BUILD_TYPE}")
message(STATUS "[SYSTEM] HOST SYSTEM NAME              = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM NAME          = ${CMAKE_SYSTEM_NAME}")


if(IOS)
    include(platforms/Deploy.cmake)
endif()






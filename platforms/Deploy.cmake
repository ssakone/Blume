MESSAGE(STATUS "Platform deploy to ${CMAKE_SYSTEM_NAME}")

include(FetchContent)

set(QTIOSCMAKE_REPOSITORY "https://github.com/ssakone/QtIosCMake.git" CACHE STRING "QtIosCMake repository, can be a local URL")
set(QTIOSCMAKE_TAG all_qt_compat CACHE STRING "QtIosCMake git tag")

FetchContent_Declare(
  QtIosCMake
  GIT_REPOSITORY ${QTIOSCMAKE_REPOSITORY}
  GIT_TAG        ${QTIOSCMAKE_TAG}
)

FetchContent_MakeAvailable(QtIosCMake)

if(${CMAKE_SYSTEM_NAME} STREQUAL "iOS")

  add_qt_ios_app(Blume
    Blume
    BUNDLE_IDENTIFIER "com.mahoutech.blume"
    LONG_VERSION ${BLUME_VERSION}.${BLUME_VERSION_TAG}
    COPYRIGHT "Copyright Mahoudev 2022-2023"
    ASSET_DIR "${BLUME_PLATFORMS_DIR}/ios/Images.xcassets"
    LAUNCHSCREEN_STORYBOARD "${BLUME_PLATFORMS_DIR}/ios/AppLaunchScreen.storyboard"
    ORIENTATION_PORTRAIT
    ORIENTATION_PORTRAIT_UPDOWN
    ORIENTATION_LANDSCAPE_LEFT
    ORIENTATION_LANDSCAPE_RIGHT
    IPA
    UPLOAD_SYMBOL
    VERBOSE
  )
endif()

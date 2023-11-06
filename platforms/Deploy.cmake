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

  include(${PROJECT_SOURCE_DIR}/cmake/FetchQtIosCMake.cmake)

  add_qt_ios_app(${BLUME_TARGET}
    NAME "Qaterial"
    BUNDLE_IDENTIFIER "com.qaterial.gallery"
    LONG_VERSION ${QATERIALGALLERY_VERSION}.${QATERIALGALLERY_VERSION_TAG}
    COPYRIGHT "Copyright Mahoudev 2012-2023"
    ASSET_DIR "${BLUME_PLATFORMS_DIR}/ios/Assets.xcassets"
    LAUNCHSCREEN_STORYBOARD "${BLUME_PLATFORMS_DIR}/ios/LaunchScreen.storyboard"
    ORIENTATION_PORTRAIT
    ORIENTATION_PORTRAIT_UPDOWN
    ORIENTATION_LANDSCAPE_LEFT
    ORIENTATION_LANDSCAPE_RIGHT
    IPA
    UPLOAD_SYMBOL
    VERBOSE
  )
endif()

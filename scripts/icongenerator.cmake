cmake_minimum_required(VERSION 3.14)

include(GenerateQmldir.cmake)
include(GenerateQrc.cmake)
include(GenerateQrcAliasQtObject.cmake)

qt_generate_qrc_alias_qt_object(GENERATED_ALIAS_QML_FILENAME
  SOURCE_DIR ../assets/icons/svg
  NAME ../qml/components/Icons.qml
  PREFIX "assets/icons/svg"
  GLOB_EXPRESSION "*.svg"
  SINGLETON
  ALWAYS_OVERWRITE
  VERBOSE)

qt_generate_qrc(BUMA_QML_QRC
  SOURCE_DIR ../qml
  DEST_DIR ../
  NAME "blume.qrc"
  PREFIX "qml/"
  RECURSE
  ALWAYS_OVERWRITE
  GLOB_EXPRESSION "*.qml" "qmldir" "*.frag" "*.vert" "*.js"
)

qt_generate_qmldir(BUMA_QML_DIR
 SOURCE_DIR ../qml
 MODULE "qml"
 RECURSE)


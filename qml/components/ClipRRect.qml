import QtQuick
import Qt5Compat.GraphicalEffects as QGE

Item
{
  id: root

  property real radius: 8

  layer.enabled: radius > 0
  layer.effect: QGE.OpacityMask
  {
    maskSource: Rectangle
    {
      width: root.width
      height: root.height
      radius: root.radius
    }
  }
}

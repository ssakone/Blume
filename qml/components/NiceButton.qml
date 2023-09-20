// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl

import ThemeEngine

T.Button {
    id: control

    property color backgroundColor: $Colors.colorPrimary
    property color foregroundColor: $Colors.colorHeaderContent
    property int radius: 18
    property color backgroundBorderColor: "black"
    property int backgroundBorderWidth: 0
    property Gradient bgGradient

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topInset: 6
    bottomInset: 6
    padding: 12
    horizontalPadding: padding - 4
    spacing: 6

    opacity: !enabled ? .4 : 1

    font.weight: Font.Medium

    icon.width: 24
    icon.height: 24
    icon.color: foregroundColor

    Material.elevation: flat ? control.down
                               || (enabled
                                   && control.hovered) ? 2 : 0 : control.down ? 8 : 2
    Material.background: flat ? "transparent" : undefined

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: foregroundColor
    }

    background: Rectangle {
        implicitWidth: 64
        implicitHeight: control.Material.buttonHeight

        radius: control.radius
        color: backgroundColor
        gradient: bgGradient
        layer.enabled: control.enabled && control.Material.buttonColor.a > 0
        layer.effect: ElevationEffect {
            elevation: control.Material.elevation
        }

        border.color: backgroundBorderColor
        border.width: backgroundBorderWidth

        Ripple {
            clipRadius: 2
            width: parent.width
            height: parent.height
            pressed: control.pressed
            anchor: control
            active: enabled && (control.down || control.visualFocus
                                || control.hovered)
            color: control.flat
                   && control.highlighted ? control.Material.highlightedRippleColor : control.Material.rippleColor
        }
    }
}

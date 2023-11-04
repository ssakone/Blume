import QtQuick
import QtQuick.Controls
import Qaterial as Qaterial

import "../components"

Popup {
    id: actionMenu
    width: 200

    padding: 0
    margins: 0

    parent: Overlay.overlay
    modal: true
    dim: false
    focus: isMobile
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 133
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 133
        }
    }

    property int layoutDirection: Qt.RightToLeft

    signal menuSelected(var index)

    ////////////////////////////////////////////////////////////////////////////
    background: Rectangle {
        color: Qaterial.Colors.gray50
        radius: 5
        border.color: Qaterial.Colors.gray100
        border.width: 1
    }

    ////////////////////////////////////////////////////////////////////////////
    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        topPadding: 8
        bottomPadding: 8
        spacing: 4

        ////////
        ActionMenuItem {
            id: actionListBloackedUsers

            index: 0
            text: qsTr("List blocked users")
            source: Qaterial.Icons.accountAlertOutline
            layoutDirection: actionMenu.layoutDirection
            onClicked: view.replace(listBlockedUsersPage)
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qaterial.Colors.gray100
        }

        ////////
        ActionMenuItem {
            id: actionLogout

            index: 0
            text: qsTr("Logout")
            source: Qaterial.Icons.logout
            layoutDirection: actionMenu.layoutDirection
            onClicked: {
                wipeAll()
                logout()
            }
        }


        ////////
        Rectangle {
            width: parent.width
            height: 1
            color: Qaterial.Colors.gray100
        }

        ActionMenuItem {
            id: actionDeleteAccount

            index: 0
            text: qsTr("Delete my account")
            source: Qaterial.Icons.deleteOutline
            layoutDirection: actionMenu.layoutDirection
            onClicked: {
                actionMenu.close()
                view.push(closeAccountPage)
            }
        }


    }
}

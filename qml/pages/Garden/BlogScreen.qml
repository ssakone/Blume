import QtQuick
import QtQuick.Controls
import QtWebView

import "../../components_generic"
import "../../components"

BPage {
    objectName: "blogpage"
    header: AppBar {
        title: webView.canGoBack ? qsTr("Back") : qsTr("Le blog")
        shouldPreventDefaultBackPress: true
        backgroundColor: $Colors.colorPrimary
        foregroundColor: $Colors.white
        leading {
            icon {
                source: webView.canGoBack ? Icons.chevronLeft : Icons.close
            }

            onClicked: {
                if(webView.canGoBack) webView.goBack()
                else page_view.pop()
            }
        }
    }

    property alias web: webView

    FocusScope {
        focus: true
        Keys.onBackPressed: {
            if(webView.canGoBack) webView.goBack()
            else page_view.pop()
        }
        anchors.fill: parent

        Component.onCompleted: {
            forceActiveFocus()
        }

        WebView {
            id: webView
            url: "https://blume.mahoufarm.bio"
            anchors.fill: parent

            onLoadingChanged: function(loadRequest) {
                if (loadRequest.errorString)
                    console.error(loadRequest.errorString);
            }

        }
    }

}

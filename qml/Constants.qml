import QtQuick

QtObject {
    property ListModel cbAppLanguage: ListModel {
        ListElement {
            text: qsTr("auto", "short for automatic");
            code: "en"
        }
        ListElement { text: "Chinese (traditional)"; code: "en"}
        ListElement { text: "Chinese (simplified)"; code: "en" }
        ListElement { text: "Dansk"; code: "en" }
        ListElement { text: "Deutsch"; code: "de" }
        ListElement { text: "English"; code: "en" }
        ListElement { text: "Español"; code: "es" }
        ListElement { text: "Français"; code: "fr" }
        ListElement { text: "Frysk"; code: "en" }
        ListElement { text: "Nederlands"; code: "en" }
        ListElement { text: "Norsk (Bokmål)"; code: "en" }
        ListElement { text: "Norsk (Nynorsk)"; code: "en" }
        ListElement { text: "Pусский"; code: "en" }
    }
}

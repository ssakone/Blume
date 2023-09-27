import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

BOutlineTextField {
    id: _control
    property bool valid: !error
    property string name
    property string inputType: 'string'
    objectName: 'form-input'
    errorText: ' '
    function isValid() {
        submitInput()
        if(!valid) {
            forceActiveFocus()
        }
        return valid
    }

    function clear() {
        autoSubmit = false
        text = ''
        _errorText = ''
        autoSubmit = true
    }

    height: 50
    leadingIconColor: titleTextColor
    leadingIconInline: true
}

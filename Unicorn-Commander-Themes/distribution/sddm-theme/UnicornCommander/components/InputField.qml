import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2

QQC2.TextField {
    id: customInput
    
    property color backgroundColor: "#1a1a2e"
    property color borderColor: "#8b5cf6"
    property color textColor: "#ffffff"
    property color placeholderColor: "#a0a0a0"
    property color focusBorderColor: "#a855f7"
    
    color: textColor
    placeholderTextColor: placeholderColor
    font.pixelSize: 14
    leftPadding: 15
    rightPadding: 15
    
    background: Rectangle {
        color: Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.8)
        border.color: customInput.activeFocus ? focusBorderColor : 
                     Qt.rgba(placeholderColor.r, placeholderColor.g, placeholderColor.b, 0.3)
        border.width: 2
        radius: 10
        
        Behavior on border.color {
            ColorAnimation { duration: 200 }
        }
    }
}
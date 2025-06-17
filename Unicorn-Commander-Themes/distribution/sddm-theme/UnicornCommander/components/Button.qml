import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import Qt5Compat.GraphicalEffects

QQC2.Button {
    id: customButton
    
    property color primaryColor: "#8b5cf6"
    property color hoverColor: Qt.lighter(primaryColor, 1.1)
    property color pressedColor: Qt.darker(primaryColor, 1.2)
    property bool glowEffect: true
    
    background: Rectangle {
        color: customButton.pressed ? pressedColor : 
               customButton.hovered ? hoverColor : primaryColor
        radius: 10
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        
        // Glow effect when enabled
        DropShadow {
            anchors.fill: parent
            source: parent
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 17
            color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.5)
            visible: glowEffect
        }
    }
    
    contentItem: Text {
        text: customButton.text
        font: customButton.font
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
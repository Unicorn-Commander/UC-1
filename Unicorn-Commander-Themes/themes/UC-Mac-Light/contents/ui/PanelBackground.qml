import QtQuick 6.2
import QtQuick.Effects
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: panelBackground
    anchors.fill: parent
    
    property bool isDock: false
    property bool isTopPanel: false
    property real blurRadius: isDock ? 40 : 25
    property real backgroundOpacity: isDock ? 0.85 : 0.75
    property color backgroundColor: isDock ? "#F5F5F5" : "#FFFFFF"
    
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Qt.rgba(panelBackground.backgroundColor.r, 
                      panelBackground.backgroundColor.g, 
                      panelBackground.backgroundColor.b, 
                      panelBackground.backgroundOpacity)
        radius: isDock ? 12 : 0
        
        border.width: isDock ? 1 : 0
        border.color: Qt.rgba(1, 1, 1, 0.1)
        
        Rectangle {
            id: innerGlow
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            radius: parent.radius
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)
            visible: isDock
        }
        
        Rectangle {
            id: highlight
            anchors.fill: parent
            anchors.margins: 0
            color: "transparent"
            radius: parent.radius
            border.width: 1
            border.color: Qt.rgba(0.54, 0.36, 0.96, 0.3)
            visible: false
            opacity: 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
        }
    }
    
    MultiEffect {
        id: blurEffect
        anchors.fill: backgroundRect
        source: backgroundRect
        blurEnabled: true
        blur: blurRadius / 64.0
        blurMax: 64
        blurMultiplier: 1.0
        
        shadowEnabled: isDock
        shadowBlur: isDock ? 0.8 : 0
        shadowOpacity: isDock ? 0.3 : 0
        shadowColor: "#000000"
        shadowVerticalOffset: isDock ? 2 : 0
        shadowHorizontalOffset: 0
    }
    
    function setHighlight(enabled) {
        highlight.visible = true
        highlight.opacity = enabled ? 1.0 : 0.0
    }
    
    Component.onCompleted: {
        if (isDock) {
            console.log("Dock panel background with blur loaded")
        } else if (isTopPanel) {
            console.log("Top panel background with blur loaded")
        }
    }
}

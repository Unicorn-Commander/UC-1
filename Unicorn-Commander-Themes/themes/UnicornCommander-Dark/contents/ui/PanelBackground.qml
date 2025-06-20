import QtQuick 6.2
import QtQuick.Effects
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: panelBackground
    anchors.fill: parent
    
    property bool isTaskbar: false
    property bool isTopPanel: false
    property real blurRadius: isTaskbar ? 30 : 20
    property real backgroundOpacity: isTaskbar ? 0.90 : 0.80
    property color backgroundColor: isTaskbar ? "#1E1E1E" : "#252525"
    
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Qt.rgba(panelBackground.backgroundColor.r, 
                      panelBackground.backgroundColor.g, 
                      panelBackground.backgroundColor.b, 
                      panelBackground.backgroundOpacity)
        radius: 0
        
        border.width: isTaskbar ? 1 : 0
        border.color: Qt.rgba(1, 1, 1, 0.08)
        
        Rectangle {
            id: accentLine
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Qt.rgba(0.54, 0.36, 0.96, 0.6)
            visible: isTaskbar
            opacity: 0.8
        }
        
        Rectangle {
            id: highlight
            anchors.fill: parent
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(0.54, 0.36, 0.96, 0.4)
            visible: false
            opacity: 0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
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
        
        shadowEnabled: isTaskbar
        shadowBlur: isTaskbar ? 0.5 : 0
        shadowOpacity: isTaskbar ? 0.2 : 0
        shadowColor: "#000000"
        shadowVerticalOffset: isTaskbar ? -1 : 0
        shadowHorizontalOffset: 0
    }
    
    function setHighlight(enabled) {
        highlight.visible = true
        highlight.opacity = enabled ? 1.0 : 0.0
    }
    
    Component.onCompleted: {
        if (isTaskbar) {
            console.log("Windows taskbar background with blur loaded")
        } else if (isTopPanel) {
            console.log("Windows top panel background with blur loaded")
        }
    }
}
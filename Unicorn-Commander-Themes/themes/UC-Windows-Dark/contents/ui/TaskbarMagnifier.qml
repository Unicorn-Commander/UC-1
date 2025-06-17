import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Effects

Item {
    id: taskbarMagnifier
    
    property real maxScale: 1.3
    property real normalScale: 1.0
    property int animationDuration: 100
    property real hoverRadius: 60
    property bool enableMagnification: true
    
    signal itemHovered(int index, bool hovered)
    signal itemClicked(int index)
    
    function calculateScale(mouseX, itemX, itemWidth) {
        if (!enableMagnification) return normalScale
        
        var itemCenter = itemX + itemWidth / 2
        var distance = Math.abs(mouseX - itemCenter)
        
        if (distance > hoverRadius) {
            return normalScale
        }
        
        var proximityFactor = 1 - (distance / hoverRadius)
        var scale = normalScale + (maxScale - normalScale) * proximityFactor
        return Math.max(normalScale, Math.min(maxScale, scale))
    }
    
    function calculateAdjacentScale(distance) {
        if (!enableMagnification || distance > hoverRadius * 1.2) return normalScale
        
        var proximityFactor = 1 - (distance / (hoverRadius * 1.2))
        var adjacentMaxScale = normalScale + (maxScale - normalScale) * 0.2
        return normalScale + (adjacentMaxScale - normalScale) * proximityFactor
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: animationDuration
            easing.type: Easing.OutQuad
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        property bool isHovered: false
        property point lastMousePos: Qt.point(0, 0)
        
        onEntered: {
            isHovered = true
            enableMagnification = true
        }
        
        onExited: {
            isHovered = false
            enableMagnification = false
        }
        
        onPositionChanged: {
            lastMousePos = Qt.point(mouse.x, mouse.y)
            taskbarMagnifier.itemHovered(-1, true)
        }
        
        onClicked: {
            var clickedIndex = calculateClickedItem(mouse.x, mouse.y)
            if (clickedIndex >= 0) {
                taskbarMagnifier.itemClicked(clickedIndex)
            }
        }
        
        function calculateClickedItem(x, y) {
            return -1
        }
    }
    
    Rectangle {
        id: hoverIndicator
        width: 3
        height: 3
        radius: 1.5
        color: "#8B5CF6"
        opacity: mouseArea.isHovered ? 0.5 : 0
        visible: enableMagnification
        
        x: mouseArea.lastMousePos.x - width / 2
        y: 2
        
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }
    
    Component.onCompleted: {
        console.log("Windows taskbar magnifier loaded")
    }
}
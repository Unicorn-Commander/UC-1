import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Effects

Item {
    id: dockMagnifier
    
    property real maxScale: 1.8
    property real normalScale: 1.0
    property int animationDuration: 150
    property real hoverRadius: 80
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
        if (!enableMagnification || distance > hoverRadius * 1.5) return normalScale
        
        var proximityFactor = 1 - (distance / (hoverRadius * 1.5))
        var adjacentMaxScale = normalScale + (maxScale - normalScale) * 0.3
        return normalScale + (adjacentMaxScale - normalScale) * proximityFactor
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: animationDuration
            easing.type: Easing.OutCubic
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
            dockMagnifier.itemHovered(-1, true)
        }
        
        onClicked: {
            var clickedIndex = calculateClickedItem(mouse.x, mouse.y)
            if (clickedIndex >= 0) {
                dockMagnifier.itemClicked(clickedIndex)
            }
        }
        
        function calculateClickedItem(x, y) {
            return -1
        }
    }
    
    Rectangle {
        id: magnificationIndicator
        width: 4
        height: 4
        radius: 2
        color: "#8B5CF6"
        opacity: mouseArea.isHovered ? 0.6 : 0
        visible: enableMagnification
        
        x: mouseArea.lastMousePos.x - width / 2
        y: parent.height - height - 5
        
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }
    
    Component.onCompleted: {
        console.log("Enhanced dock magnifier loaded")
    }
}

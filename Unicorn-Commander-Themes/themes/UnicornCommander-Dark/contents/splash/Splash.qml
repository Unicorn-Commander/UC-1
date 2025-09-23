import QtQuick 2.5

Rectangle {
    id: root
    color: "#0d1117"
    
    property int stage
    
    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }
    
    Item {
        id: content
        anchors.fill: parent
        opacity: 0
        
        Rectangle {
            anchors.centerIn: parent
            width: 200
            height: 200
            radius: 100
            color: "#7c3aed"
            
            Text {
                anchors.centerIn: parent
                text: "🦄"
                font.pixelSize: 80
                color: "white"
            }
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 120
            text: "UnicornCommander Dark"
            color: "#f0f6fc"
            font.pixelSize: 24
            font.bold: true
        }
    }
    
    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 1000
        easing.type: Easing.InOutQuad
    }
}
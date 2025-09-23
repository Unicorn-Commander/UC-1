import QtQuick 2.5

Rectangle {
    id: root
    color: "#1e1e2e"
    
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
            text: "Magic Unicorn Dark"
            color: "#cdd6f4"
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
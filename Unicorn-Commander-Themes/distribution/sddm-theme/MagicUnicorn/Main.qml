import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    
    property int sessionIndex: session.index
    property string defaultUser: userModel.lastUser
    
    // macOS inspired color palette
    readonly property color primaryColor: "#007AFF"
    readonly property color secondaryColor: "#5856D6" 
    readonly property color backgroundColor: "#F2F2F7"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color textColor: "#1C1C1E"
    readonly property color textSecondaryColor: "#8E8E93"
    readonly property color accentColor: "#FF3B30"
    readonly property color successColor: "#34C759"
    
    // Dynamic wallpaper background
    Image {
        id: backgroundImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        
        // Dynamic resolution selection based on screen size
        source: {
            var screenWidth = container.width
            var screenHeight = container.height
            var aspectRatio = screenWidth / screenHeight
            
            // Choose wallpaper based on resolution and aspect ratio
            if (screenWidth >= 7680) return "../../../../assets/wallpapers/unicorncommander_7680x4320.jpg"
            else if (screenWidth >= 6144) return "../../../../assets/wallpapers/unicorncommander_6144x3456.jpg"
            else if (screenWidth >= 5120) return "../../../../assets/wallpapers/unicorncommander_5120x2880.jpg"
            else if (screenWidth >= 4320) return "../../../../assets/wallpapers/unicorncommander_4320x7680.jpg"
            else if (screenWidth >= 3840 && aspectRatio > 2.0) return "../../../../assets/wallpapers/unicorncommander_3840x1600.jpg"
            else if (screenWidth >= 3840) return "../../../../assets/wallpapers/unicorncommander_3840x2160.jpg"
            else if (screenWidth >= 3440) return "../../../../assets/wallpapers/unicorncommander_3440x1440.jpg"
            else if (screenWidth >= 2880) return "../../../../assets/wallpapers/unicorncommander_2880x5120.jpg"
            else if (screenWidth >= 2560 && aspectRatio > 2.0) return "../../../../assets/wallpapers/unicorncommander_2560x1080.jpg"
            else if (screenWidth >= 2560) return "../../../../assets/wallpapers/unicorncommander_2560x1440.jpg"
            else if (screenWidth >= 2160) return "../../../../assets/wallpapers/unicorncommander_2160x3840.jpg"
            else if (screenWidth >= 1920) return "../../../../assets/wallpapers/unicorncommander_1920x1080.jpg"
            else if (screenWidth >= 1600) return "../../../../assets/wallpapers/unicorncommander_1600x900.jpg"
            else if (screenWidth >= 1536) return "../../../../assets/wallpapers/unicorncommander_1536x864.jpg"
            else if (screenWidth >= 1440 && aspectRatio > 2.0) return "../../../../assets/wallpapers/unicorncommander_1440x2560.jpg"
            else if (screenWidth >= 1440) return "../../../../assets/wallpapers/unicorncommander_1440x900.jpg"
            else if (screenWidth >= 1366) return "../../../../assets/wallpapers/unicorncommander_1366x768.jpg"
            else if (screenWidth >= 1080) return "../../../../assets/wallpapers/unicorncommander_1080x1920.jpg"
            else return "../../../../assets/wallpapers/unicorncommander_900x1600.jpg"
        }
        
        // Fallback to config background or gradient
        Component.onCompleted: {
            if (config.background && config.background !== "") {
                source = config.background
            }
        }
    }
    
    // Subtle overlay for better text readability
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(255, 255, 255, 0.15)
        opacity: 0.8
    }
    
    // Subtle floating orbs (macOS style)
    Repeater {
        model: 8
        
        Rectangle {
            id: orb
            width: 60 + Math.random() * 40
            height: width
            radius: width / 2
            color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.1 + Math.random() * 0.15)
            x: Math.random() * container.width
            y: Math.random() * container.height
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 3000 + Math.random() * 4000 }
                NumberAnimation { to: 0.8; duration: 3000 + Math.random() * 4000 }
            }
            
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { 
                    to: orb.x + (Math.random() - 0.5) * 200
                    duration: 8000 + Math.random() * 4000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation { 
                    to: orb.x + (Math.random() - 0.5) * 200
                    duration: 8000 + Math.random() * 4000
                    easing.type: Easing.InOutSine
                }
            }
            
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { 
                    to: orb.y + (Math.random() - 0.5) * 150
                    duration: 6000 + Math.random() * 6000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation { 
                    to: orb.y + (Math.random() - 0.5) * 150
                    duration: 6000 + Math.random() * 6000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
    
    // Main login card (macOS inspired design)
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: 380
        height: 520
        radius: 20
        color: surfaceColor
        
        // macOS style shadow
        DropShadow {
            anchors.fill: loginCard
            source: loginCard
            horizontalOffset: 0
            verticalOffset: 8
            radius: 24
            samples: 49
            color: Qt.rgba(0, 0, 0, 0.12)
        }
        
        // Inner border for depth
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.06)
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 28
            
            // Magic Unicorn branding
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                
                // Subtle glow ring
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 20
                    height: parent.height + 20
                    radius: width / 2
                    color: "transparent"
                    border.color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.2)
                    border.width: 2
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.4; duration: 2500 }
                        NumberAnimation { to: 0.8; duration: 2500 }
                    }
                }
                
                // Unicorn logo with subtle animation
                Text {
                    anchors.centerIn: parent
                    text: "🦄"
                    font.pixelSize: 64
                    
                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.05; duration: 4000; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 4000; easing.type: Easing.InOutSine }
                    }
                }
            }
            
            // Welcome text
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: config.welcomeText || "Welcome to Magic Unicorn"
                font.pixelSize: 20
                font.weight: Font.Medium
                color: textColor
                horizontalAlignment: Text.AlignHCenter
            }
            
            // User selection
            QQC2.ComboBox {
                id: userBox
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                model: userModel
                currentIndex: userModel.lastIndex
                textRole: "display"
                
                background: Rectangle {
                    color: backgroundColor
                    border.color: userBox.activeFocus ? primaryColor : Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3)
                    border.width: userBox.activeFocus ? 2 : 1
                    radius: 8
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    Behavior on border.width {
                        NumberAnimation { duration: 200 }
                    }
                }
                
                contentItem: Text {
                    text: userBox.displayText
                    font.pixelSize: 15
                    color: textColor
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                }
                
                delegate: QQC2.ItemDelegate {
                    width: userBox.width
                    height: 40
                    
                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.1) : "transparent"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: display
                        color: textColor
                        font.pixelSize: 15
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                    }
                }
                
                popup: QQC2.Popup {
                    y: userBox.height + 4
                    width: userBox.width
                    
                    background: Rectangle {
                        color: surfaceColor
                        border.color: Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.2)
                        border.width: 1
                        radius: 8
                        
                        DropShadow {
                            anchors.fill: parent
                            source: parent
                            horizontalOffset: 0
                            verticalOffset: 4
                            radius: 12
                            samples: 25
                            color: Qt.rgba(0, 0, 0, 0.15)
                        }
                    }
                }
            }
            
            // Password field
            QQC2.TextField {
                id: passwordBox
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                echoMode: TextInput.Password
                placeholderText: "Password"
                placeholderTextColor: textSecondaryColor
                color: textColor
                font.pixelSize: 15
                
                background: Rectangle {
                    color: backgroundColor
                    border.color: passwordBox.activeFocus ? primaryColor : Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3)
                    border.width: passwordBox.activeFocus ? 2 : 1
                    radius: 8
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    Behavior on border.width {
                        NumberAnimation { duration: 200 }
                    }
                }
                
                leftPadding: 12
                rightPadding: 12
                
                Keys.onReturnPressed: loginButton.clicked()
                Keys.onEnterPressed: loginButton.clicked()
                
                Component.onCompleted: {
                    if (userModel.count === 1) {
                        forceActiveFocus()
                    }
                }
            }
            
            // Login button (macOS style)
            QQC2.Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "Sign In"
                font.pixelSize: 16
                font.weight: Font.Medium
                
                background: Rectangle {
                    color: loginButton.pressed ? Qt.darker(primaryColor, 1.1) : 
                           loginButton.hovered ? Qt.lighter(primaryColor, 1.05) : primaryColor
                    radius: 8
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    // Subtle inner shadow for depth
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 1
                        color: "transparent"
                        border.color: Qt.rgba(255, 255, 255, 0.2)
                        border.width: 1
                        radius: parent.radius
                    }
                }
                
                contentItem: Text {
                    text: loginButton.text
                    font: loginButton.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    sddm.login(userBox.currentText, passwordBox.text, sessionBox.currentIndex)
                }
            }
            
            // Error message
            Text {
                id: errorMessage
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                text: ""
                color: accentColor
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: text.length > 0
            }
        }
    }
    
    // Session selector (bottom left, macOS style)
    Rectangle {
        id: sessionContainer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 24
        width: 180
        height: 36
        radius: 8
        color: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.9)
        border.color: Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.2)
        border.width: 1
        
        QQC2.ComboBox {
            id: sessionBox
            anchors.fill: parent
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            textRole: "file"
            
            background: Rectangle {
                color: "transparent"
                radius: 8
            }
            
            contentItem: Text {
                text: sessionBox.displayText
                font.pixelSize: 13
                color: textColor
                verticalAlignment: Text.AlignVCenter
                leftPadding: 8
            }
        }
    }
    
    // System controls (bottom right, macOS style)
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 12
        
        QQC2.Button {
            width: 40
            height: 40
            text: "↻"
            font.pixelSize: 16
            enabled: sddm.canReboot
            
            background: Rectangle {
                color: parent.pressed ? Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.2) :
                       parent.hovered ? Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.1) :
                       Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.9)
                radius: 20
                border.color: Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.2)
                border.width: 1
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
            
            contentItem: Text {
                text: parent.text
                font: parent.font
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: sddm.reboot()
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Restart"
            QQC2.ToolTip.delay: 1000
        }
        
        QQC2.Button {
            width: 40
            height: 40
            text: "⏻"
            font.pixelSize: 14
            enabled: sddm.canPowerOff
            
            background: Rectangle {
                color: parent.pressed ? Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.2) :
                       parent.hovered ? Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.1) :
                       Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.9)
                radius: 20
                border.color: Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.2)
                border.width: 1
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
            
            contentItem: Text {
                text: parent.text
                font: parent.font
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: sddm.powerOff()
            
            QQC2.ToolTip.visible: hovered 
            QQC2.ToolTip.text: "Shut Down"
            QQC2.ToolTip.delay: 1000
        }
    }
    
    // Handle login events
    Connections {
        target: sddm
        
        function onLoginFailed() {
            errorMessage.text = "Incorrect password. Please try again."
            passwordBox.text = ""
            passwordBox.forceActiveFocus()
            
            // Clear error after 4 seconds
            errorTimer.restart()
        }
        
        function onLoginSucceeded() {
            errorMessage.text = ""
        }
    }
    
    Timer {
        id: errorTimer
        interval: 4000
        onTriggered: errorMessage.text = ""
    }
    
    // Initialize focus
    Component.onCompleted: {
        if (userModel.count === 1) {
            passwordBox.forceActiveFocus()
        } else {
            userBox.forceActiveFocus()
        }
    }
}
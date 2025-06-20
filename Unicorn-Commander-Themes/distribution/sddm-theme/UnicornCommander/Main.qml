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
    
    property int sessionIndex: sessionModel.lastIndex
    property string defaultUser: userModel.lastUser
    
    // Windows 11 inspired color palette
    readonly property color primaryColor: "#0078d4"
    readonly property color secondaryColor: "#106ebe" 
    readonly property color backgroundColor: "#202020"
    readonly property color surfaceColor: "#2c2c2c"
    readonly property color textColor: "#ffffff"
    readonly property color textSecondaryColor: "#a0a0a0"
    readonly property color accentColor: "#0078d4"
    
    // Dynamic wallpaper background
    Image {
        id: backgroundImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        
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
        
        // Fallback to config background
        Component.onCompleted: {
            if (config.background && config.background !== "") {
                source = config.background
            }
        }
        
        // Subtle blur overlay for better text readability
        Rectangle {
            anchors.fill: parent
            color: backgroundColor
            opacity: 0.3
        }
    }
    
    // Animated cosmic particles effect
    Repeater {
        model: 20
        
        Rectangle {
            id: particle
            width: Math.random() * 4 + 1
            height: width
            radius: width / 2
            color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, Math.random() * 0.8 + 0.2)
            x: Math.random() * container.width
            y: Math.random() * container.height
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.2; duration: 2000 + Math.random() * 2000 }
                NumberAnimation { to: 1.0; duration: 2000 + Math.random() * 2000 }
            }
            
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { 
                    to: particle.y - 50 - Math.random() * 100
                    duration: 5000 + Math.random() * 5000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation { 
                    to: particle.y + 50 + Math.random() * 100
                    duration: 5000 + Math.random() * 5000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
    
    // Main login interface (Windows 11 style)
    Rectangle {
        id: loginPanel
        anchors.centerIn: parent
        width: 400
        height: 550
        radius: 8
        color: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.95)
        border.color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.4)
        border.width: 1
        
        // Windows 11 style shadow
        DropShadow {
            anchors.fill: loginPanel
            source: loginPanel
            horizontalOffset: 0
            verticalOffset: 4
            radius: 16
            samples: 33
            color: Qt.rgba(0, 0, 0, 0.3)
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            // UnicornCommander logo
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 120
                Layout.preferredHeight: 120
                
                // Cosmic glow behind logo
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 40
                    height: parent.height + 40
                    radius: width / 2
                    color: "transparent"
                    border.color: primaryColor
                    border.width: 2
                    opacity: 0.6
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 2000 }
                        NumberAnimation { to: 0.9; duration: 2000 }
                    }
                }
                
                // Logo placeholder (cosmic unicorn symbol)
                Text {
                    anchors.centerIn: parent
                    text: "🦄"
                    font.pixelSize: 80
                    color: primaryColor
                    
                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.1; duration: 3000; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 3000; easing.type: Easing.InOutSine }
                    }
                }
            }
            
            // Welcome text
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: config.welcomeText || "Welcome to Unicorn Commander"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: textColor
                horizontalAlignment: Text.AlignHCenter
            }
            
            // User selection dropdown
            QQC2.ComboBox {
                id: userBox
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                model: userModel
                currentIndex: userModel.lastIndex
                textRole: "display"
                
                background: Rectangle {
                    color: Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.8)
                    border.color: userBox.activeFocus ? accentColor : Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3)
                    border.width: userBox.activeFocus ? 2 : 1
                    radius: 4
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    Behavior on border.width {
                        NumberAnimation { duration: 200 }
                    }
                }
                
                contentItem: Text {
                    text: userBox.displayText
                    font.pixelSize: 14
                    color: textColor
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 15
                }
                
                delegate: QQC2.ItemDelegate {
                    width: userBox.width
                    height: 40
                    
                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15) : "transparent"
                        radius: 3
                    }
                    
                    contentItem: Text {
                        text: display
                        color: textColor
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 15
                    }
                }
                
                popup: QQC2.Popup {
                    y: userBox.height
                    width: userBox.width
                    
                    background: Rectangle {
                        color: surfaceColor
                        border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                        border.width: 1
                        radius: 4
                    }
                }
            }
            
            // Password field
            QQC2.TextField {
                id: passwordBox
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                echoMode: TextInput.Password
                placeholderText: "Password"
                placeholderTextColor: textSecondaryColor
                color: textColor
                font.pixelSize: 14
                
                background: Rectangle {
                    color: Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.8)
                    border.color: passwordBox.activeFocus ? accentColor : Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3)
                    border.width: passwordBox.activeFocus ? 2 : 1
                    radius: 4
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    Behavior on border.width {
                        NumberAnimation { duration: 200 }
                    }
                }
                
                leftPadding: 15
                rightPadding: 15
                
                Keys.onReturnPressed: loginButton.clicked()
                Keys.onEnterPressed: loginButton.clicked()
                
                Component.onCompleted: {
                    if (userModel.count === 1) {
                        forceActiveFocus()
                    }
                }
            }
            
            // Login button
            QQC2.Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: "Sign In"
                font.pixelSize: 16
                font.weight: Font.Medium
                
                background: Rectangle {
                    color: loginButton.pressed ? Qt.darker(accentColor, 1.1) : 
                           loginButton.hovered ? Qt.lighter(accentColor, 1.05) : accentColor
                    radius: 4
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    // Windows 11 style subtle shadow
                    DropShadow {
                        anchors.fill: parent
                        source: parent
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 4
                        samples: 9
                        color: Qt.rgba(0, 0, 0, 0.2)
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
            
            // Error message area
            Text {
                id: errorMessage
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: ""
                color: "#ef4444"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: text.length > 0
            }
        }
    }
    
    // Session selection (bottom left)
    QQC2.ComboBox {
        id: sessionBox
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 30
        width: 200
        height: 40
        model: sessionModel
        currentIndex: sessionModel.lastIndex
        textRole: "file"
        
        background: Rectangle {
            color: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.9)
            border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
            border.width: 1
            radius: 4
        }
        
        contentItem: Text {
            text: sessionBox.displayText
            font.pixelSize: 12
            color: textColor
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
        }
    }
    
    // System actions (bottom right)
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 30
        spacing: 15
        
        QQC2.Button {
            width: 50
            height: 50
            text: "⟲"
            font.pixelSize: 20
            enabled: sddm.canReboot
            
            background: Rectangle {
                color: parent.pressed ? Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3) :
                       parent.hovered ? Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.2) :
                       Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.7)
                radius: 25
                border.color: Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3)
                border.width: 1
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
            QQC2.ToolTip.text: "Reboot"
            QQC2.ToolTip.delay: 1000
        }
        
        QQC2.Button {
            width: 50
            height: 50
            text: "⏻"
            font.pixelSize: 18
            enabled: sddm.canPowerOff
            
            background: Rectangle {
                color: parent.pressed ? Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3) :
                       parent.hovered ? Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.2) :
                       Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.7)
                radius: 25
                border.color: Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3)
                border.width: 1
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
            QQC2.ToolTip.text: "Shutdown"
            QQC2.ToolTip.delay: 1000
        }
    }
    
    // Handle login events
    Connections {
        target: sddm
        
        function onLoginFailed() {
            errorMessage.text = "Login failed. Please try again."
            passwordBox.text = ""
            passwordBox.forceActiveFocus()
            
            // Clear error message after 3 seconds
            errorTimer.restart()
        }
        
        function onLoginSucceeded() {
            errorMessage.text = ""
        }
    }
    
    Timer {
        id: errorTimer
        interval: 3000
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
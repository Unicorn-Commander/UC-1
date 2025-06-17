import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.sessions 2.0

Rectangle {
    id: root
    anchors.fill: parent
    
    // Color palette for Magic Unicorn Dark
    readonly property color primaryColor: "#8b5cf6"
    readonly property color backgroundColor: "#0f0f23"
    readonly property color surfaceColor: "#1a1a2e"
    readonly property color textColor: "#ffffff"
    readonly property color textSecondaryColor: "#a0a0a0"
    
    // Background with cosmic wallpaper
    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file:///home/ucadmin/.local/share/wallpapers/MagicUnicorn/unicorncommander_1920x1080.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        
        // Blur overlay for better text readability
        FastBlur {
            anchors.fill: parent
            source: wallpaper
            radius: 32
            opacity: 0.8
        }
    }
    
    // Dark overlay for better contrast
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        opacity: 0.4
    }
    
    // Animated cosmic particles
    Repeater {
        model: 15
        
        Rectangle {
            id: particle
            width: Math.random() * 3 + 1
            height: width
            radius: width / 2
            color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, Math.random() * 0.6 + 0.2)
            x: Math.random() * root.width
            y: Math.random() * root.height
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.2; duration: 3000 + Math.random() * 2000 }
                NumberAnimation { to: 0.8; duration: 3000 + Math.random() * 2000 }
            }
            
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { 
                    to: particle.y - 30 - Math.random() * 50
                    duration: 8000 + Math.random() * 4000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation { 
                    to: particle.y + 30 + Math.random() * 50
                    duration: 8000 + Math.random() * 4000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
    
    // Main lock screen interface
    Rectangle {
        id: lockPanel
        anchors.centerIn: parent
        width: 400
        height: Math.max(450, contentColumn.implicitHeight + 80)
        radius: 20
        color: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.95)
        border.color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.3)
        border.width: 1
        
        // Panel glow effect
        DropShadow {
            anchors.fill: lockPanel
            source: lockPanel
            horizontalOffset: 0
            verticalOffset: 0
            radius: 40
            samples: 81
            color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.5)
        }
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 40
            spacing: 25
            
            // Clock display
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 5
                
                Text {
                    id: timeDisplay
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatTime(timeSource.data["Local"]["DateTime"], "hh:mm")
                    font.pixelSize: 48
                    font.weight: Font.Light
                    color: textColor
                }
                
                Text {
                    id: dateDisplay
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(timeSource.data["Local"]["DateTime"], "dddd, MMMM d")
                    font.pixelSize: 16
                    color: textSecondaryColor
                }
            }
            
            // Cosmic separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.4)
                radius: 1
            }
            
            // User info
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 15
                
                // User avatar placeholder
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 80
                    height: 80
                    radius: 40
                    color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.2)
                    border.color: primaryColor
                    border.width: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "🦄"
                        font.pixelSize: 40
                        color: primaryColor
                    }
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: kuser.loginName || "User"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: textColor
                }
            }
            
            // Password input
            QQC2.TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                echoMode: TextInput.Password
                placeholderText: "Enter password"
                placeholderTextColor: textSecondaryColor
                color: textColor
                font.pixelSize: 14
                
                background: Rectangle {
                    color: Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.8)
                    border.color: passwordField.activeFocus ? primaryColor : Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3)
                    border.width: 2
                    radius: 10
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                leftPadding: 15
                rightPadding: 15
                
                Keys.onReturnPressed: unlockButton.clicked()
                Keys.onEnterPressed: unlockButton.clicked()
                
                onTextChanged: {
                    if (authenticator.graceLocked) {
                        return
                    }
                    authenticator.respond(text)
                }
            }
            
            // Unlock button
            QQC2.Button {
                id: unlockButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: "Unlock"
                font.pixelSize: 16
                font.weight: Font.Medium
                enabled: !authenticator.graceLocked
                
                background: Rectangle {
                    color: unlockButton.pressed ? Qt.darker(primaryColor, 1.2) : 
                           unlockButton.hovered ? Qt.lighter(primaryColor, 1.1) : primaryColor
                    radius: 10
                    opacity: unlockButton.enabled ? 1.0 : 0.5
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    DropShadow {
                        anchors.fill: parent
                        source: parent
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 8
                        samples: 17
                        color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.5)
                    }
                }
                
                contentItem: Text {
                    text: unlockButton.text
                    font: unlockButton.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    if (passwordField.text.length > 0) {
                        authenticator.respond(passwordField.text)
                    }
                }
            }
            
            // Status message
            Text {
                id: statusMessage
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                text: authenticator.infoMessage || ""
                color: authenticator.infoMessage.includes("failed") ? "#ef4444" : textSecondaryColor
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: text.length > 0
            }
        }
    }
    
    // Time data source
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }
    
    // Authentication handling
    Connections {
        target: authenticator
        
        function onPromptForSecretChanged() {
            passwordField.forceActiveFocus()
        }
        
        function onPromptChanged() {
            if (authenticator.prompt) {
                passwordField.placeholderText = authenticator.prompt
            }
        }
        
        function onInfoMessageChanged() {
            if (authenticator.infoMessage) {
                statusMessage.text = authenticator.infoMessage
            }
        }
        
        function onErrorMessageChanged() {
            if (authenticator.errorMessage) {
                statusMessage.text = authenticator.errorMessage
                passwordField.text = ""
                passwordField.forceActiveFocus()
            }
        }
        
        function onSucceeded() {
            Qt.quit()
        }
        
        function onFailed() {
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }
    
    Component.onCompleted: {
        passwordField.forceActiveFocus()
    }
}
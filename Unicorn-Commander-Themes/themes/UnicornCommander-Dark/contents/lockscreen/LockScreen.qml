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
    
    // Color palette for UnicornCommander Dark (Windows-style)
    readonly property color primaryColor: "#0078d4"
    readonly property color accentColor: "#8b5cf6"
    readonly property color backgroundColor: "#1a1a1a"
    readonly property color surfaceColor: "#2d2d30"
    readonly property color textColor: "#ffffff"
    readonly property color textSecondaryColor: "#cccccc"
    
    // Background with cosmic wallpaper
    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file:///home/ucadmin/.local/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        
        // Acrylic-style blur overlay
        FastBlur {
            anchors.fill: parent
            source: wallpaper
            radius: 48
            opacity: 0.9
        }
    }
    
    // Windows-style dark overlay
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        opacity: 0.6
    }
    
    // Subtle cosmic particles
    Repeater {
        model: 10
        
        Rectangle {
            id: particle
            width: Math.random() * 3 + 1
            height: width
            radius: width / 2
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, Math.random() * 0.5 + 0.2)
            x: Math.random() * root.width
            y: Math.random() * root.height
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 4000 + Math.random() * 3000 }
                NumberAnimation { to: 0.7; duration: 4000 + Math.random() * 3000 }
            }
            
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { 
                    to: particle.y - 25 - Math.random() * 40
                    duration: 12000 + Math.random() * 6000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation { 
                    to: particle.y + 25 + Math.random() * 40
                    duration: 12000 + Math.random() * 6000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
    
    // Windows-style lock screen layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 60
        spacing: 40
        
        // Top section with time
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 40
            spacing: 10
            
            Text {
                id: timeDisplay
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(timeSource.data["Local"]["DateTime"], "h:mm")
                font.pixelSize: 72
                font.weight: Font.Light
                color: textColor
            }
            
            Text {
                id: dateDisplay
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(timeSource.data["Local"]["DateTime"], "dddd, MMMM d")
                font.pixelSize: 20
                color: textSecondaryColor
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
        
        // Bottom section with login
        Rectangle {
            id: loginPanel
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 80
            width: 420
            height: Math.max(300, loginContent.implicitHeight + 60)
            radius: 8
            color: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.95)
            border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
            border.width: 1
            
            // Windows-style subtle shadow
            DropShadow {
                anchors.fill: loginPanel
                source: loginPanel
                horizontalOffset: 0
                verticalOffset: 5
                radius: 20
                samples: 41
                color: Qt.rgba(0, 0, 0, 0.4)
            }
            
            ColumnLayout {
                id: loginContent
                anchors.fill: parent
                anchors.margins: 40
                spacing: 20
                
                // User section
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    // User avatar
                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        radius: 4
                        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2)
                        border.color: accentColor
                        border.width: 2
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🦄"
                            font.pixelSize: 28
                            color: accentColor
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: kuser.loginName || "User"
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            color: textColor
                        }
                        
                        Text {
                            text: "UnicornCommander"
                            font.pixelSize: 12
                            color: textSecondaryColor
                        }
                    }
                }
                
                // Password input section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    QQC2.TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        echoMode: TextInput.Password
                        placeholderText: "Password"
                        placeholderTextColor: textSecondaryColor
                        color: textColor
                        font.pixelSize: 14
                        
                        background: Rectangle {
                            color: Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.7)
                            border.color: passwordField.activeFocus ? primaryColor : Qt.rgba(textSecondaryColor.r, textSecondaryColor.g, textSecondaryColor.b, 0.3)
                            border.width: 2
                            radius: 4
                            
                            Behavior on border.color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                        
                        leftPadding: 12
                        rightPadding: 12
                        
                        Keys.onReturnPressed: unlockButton.clicked()
                        Keys.onEnterPressed: unlockButton.clicked()
                        
                        onTextChanged: {
                            if (authenticator.graceLocked) {
                                return
                            }
                            authenticator.respond(text)
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Item {
                            Layout.fillWidth: true
                        }
                        
                        QQC2.Button {
                            id: unlockButton
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            text: "Sign in"
                            font.pixelSize: 14
                            enabled: !authenticator.graceLocked
                            
                            background: Rectangle {
                                color: unlockButton.pressed ? Qt.darker(primaryColor, 1.2) : 
                                       unlockButton.hovered ? Qt.lighter(primaryColor, 1.1) : primaryColor
                                radius: 4
                                opacity: unlockButton.enabled ? 1.0 : 0.5
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
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
                    }
                    
                    // Status message
                    Text {
                        id: statusMessage
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        text: authenticator.infoMessage || ""
                        color: authenticator.infoMessage.includes("failed") ? "#ff6b6b" : textSecondaryColor
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.Wrap
                        visible: text.length > 0
                    }
                }
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
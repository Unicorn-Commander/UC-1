import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    
    property int sessionIndex: session.index
    property string defaultUser: userModel.lastUser
    
    // Unicorn Commander color palette - dark theme
    readonly property color primaryColor: "#8B5CF6"      // Purple
    readonly property color secondaryColor: "#A855F7"    // Lighter purple
    readonly property color backgroundColor: "#1C1C1E"    // Dark background
    readonly property color surfaceColor: "#2D2D30"      // Card background
    readonly property color textColor: "#F8FAFC"         // Light text
    readonly property color textSecondaryColor: "#94A3B8" // Secondary text
    readonly property color accentColor: "#F59E0B"       // Orange accent
    readonly property color successColor: "#10B981"      // Green
    readonly property color errorColor: "#EF4444"        // Red
    
    // Background wallpaper
    Image {
        id: backgroundImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: "unicorncommander_1920x1080.jpg"
        
        // Overlay for better contrast
        Rectangle {
            anchors.fill: parent
            color: backgroundColor
            opacity: 0.4
        }
    }
    
    // Main login panel
    Rectangle {
        id: loginPanel
        width: 400
        height: 520
        anchors.centerIn: parent
        color: surfaceColor
        radius: 16
        opacity: 0.95
        
        // Subtle glow effect
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 32
            samples: 64
            color: "#40000000"
            horizontalOffset: 0
            verticalOffset: 8
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 24
            
            // Logo and welcome text
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16
                
                Image {
                    id: logo
                    Layout.alignment: Qt.AlignHCenter
                    source: "unicorn-logo.svg"
                    sourceSize: Qt.size(120, 120)
                    fillMode: Image.PreserveAspectFit
                }
                
                Text {
                    id: welcomeText
                    Layout.alignment: Qt.AlignHCenter
                    text: "🦄 Unicorn Commander"
                    font.family: "SF Pro Display, Inter, system-ui"
                    font.pixelSize: 24
                    font.weight: Font.Medium
                    color: textColor
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Welcome back!"
                    font.family: "SF Pro Display, Inter, system-ui"
                    font.pixelSize: 16
                    color: textSecondaryColor
                }
            }
            
            // User selection
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "User:"
                    font.family: "SF Pro Display, Inter, system-ui"
                    font.pixelSize: 14
                    color: textColor
                    Layout.preferredWidth: 60
                }
                
                ComboBox {
                    id: userCombo
                    Layout.fillWidth: true
                    model: userModel
                    currentIndex: userModel.lastIndex
                    textRole: "realName"
                    
                    delegate: ItemDelegate {
                        width: userCombo.width
                        text: model.realName
                        highlighted: userCombo.highlightedIndex === index
                    }
                    
                    background: Rectangle {
                        color: backgroundColor
                        border.color: primaryColor
                        border.width: userCombo.activeFocus ? 2 : 1
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: userCombo.displayText
                        font: userCombo.font
                        color: textColor
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                    }
                }
            }
            
            // Password field
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "Password:"
                    font.family: "SF Pro Display, Inter, system-ui"
                    font.pixelSize: 14
                    color: textColor
                    Layout.preferredWidth: 60
                }
                
                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: "Enter your password"
                    font.family: "SF Pro Display, Inter, system-ui"
                    font.pixelSize: 14
                    selectByMouse: true
                    
                    background: Rectangle {
                        color: backgroundColor
                        border.color: passwordField.activeFocus ? primaryColor : textSecondaryColor
                        border.width: passwordField.activeFocus ? 2 : 1
                        radius: 8
                    }
                    
                    color: textColor
                    selectionColor: primaryColor
                    placeholderTextColor: textSecondaryColor
                    
                    Keys.onReturnPressed: login()
                    Keys.onEnterPressed: login()
                    
                    onTextChanged: {
                        if (text.length > 0) {
                            loginButton.enabled = true
                        }
                    }
                }
            }
            
            // Session selection (optional)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: sessionModel.rowCount() > 1
                
                Text {
                    text: "Session:"
                    font.family: "SF Pro Display, Inter, system-ui"
                    font.pixelSize: 14
                    color: textColor
                    Layout.preferredWidth: 60
                }
                
                ComboBox {
                    id: sessionCombo
                    Layout.fillWidth: true
                    model: sessionModel
                    currentIndex: sessionModel.lastIndex
                    textRole: "name"
                    
                    background: Rectangle {
                        color: backgroundColor
                        border.color: sessionCombo.activeFocus ? primaryColor : textSecondaryColor
                        border.width: sessionCombo.activeFocus ? 2 : 1
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: sessionCombo.displayText
                        font: sessionCombo.font
                        color: textColor
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                    }
                }
            }
            
            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                text: "Sign In"
                enabled: passwordField.text.length > 0
                
                background: Rectangle {
                    color: loginButton.enabled ? (loginButton.pressed ? "#7C3AED" : primaryColor) : textSecondaryColor
                    radius: 8
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: loginButton.text
                    font.family: "SF Pro Display, Inter, system-ui"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: login()
            }
            
            // Spacer
            Item { Layout.fillHeight: true }
        }
    }
    
    // Power buttons
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 32
        spacing: 16
        
        Button {
            id: rebootButton
            width: 48
            height: 48
            
            background: Rectangle {
                color: rebootButton.pressed ? "#4B5563" : "#374151"
                radius: 24
                opacity: 0.9
            }
            
            contentItem: Text {
                text: "⟲"
                font.pixelSize: 20
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: sddm.reboot()
            
            ToolTip.visible: hovered
            ToolTip.text: "Restart"
        }
        
        Button {
            id: shutdownButton
            width: 48
            height: 48
            
            background: Rectangle {
                color: shutdownButton.pressed ? "#7F1D1D" : "#DC2626"
                radius: 24
                opacity: 0.9
            }
            
            contentItem: Text {
                text: "⏻"
                font.pixelSize: 20
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: sddm.powerOff()
            
            ToolTip.visible: hovered
            ToolTip.text: "Shutdown"
        }
    }
    
    // Functions
    function login() {
        sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
    }
    
    // Initialize
    Component.onCompleted: {
        if (defaultUser) {
            userCombo.currentIndex = userModel.findIndex(defaultUser)
        }
        passwordField.forceActiveFocus()
    }
    
    // Handle authentication
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.clear()
            passwordField.forceActiveFocus()
            
            // Show error animation
            errorAnimation.start()
        }
    }
    
    // Error animation
    PropertyAnimation {
        id: errorAnimation
        target: loginPanel
        property: "x"
        from: loginPanel.x
        to: loginPanel.x + 10
        duration: 100
        loops: 3
        easing.type: Easing.InOutQuad
        
        onFinished: {
            loginPanel.x = (container.width - loginPanel.width) / 2
        }
    }
}
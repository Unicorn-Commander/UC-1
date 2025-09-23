import QtQuick 6.2
import org.kde.plasma.core 2.0 as PlasmaCore
import "PanelBackground.qml" as PanelBg

Item {
    id: root
    
    property string name: "UnicornCommander Windows Dark"
    property string description: "Windows-style layout with dark theme and UnicornCommander branding"
    property string author: "UnicornCommander Team"
    property string version: "1.0"
    property string license: "GPL-3.0"
    
    // Theme configuration
    property bool darkTheme: true
    property string colorScheme: "UCWindowsDark"
    property string windowDecorationTheme: "org.kde.breeze"
    property string cursorTheme: "KDE_Classic"
    property string iconTheme: "breeze-dark"
    property string plasmaTheme: "breeze-dark"
    
    Component.onCompleted: {
        console.log("UnicornCommander Windows Dark theme loaded")
    }
}
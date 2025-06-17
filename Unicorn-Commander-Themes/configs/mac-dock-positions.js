// Mac-style dock positioning configurations for UC-Mac-Dark theme
// This file provides different dock alignment options

const dockConfigurations = {
    center: {
        alignment: "center",
        offset: 0,
        maximumLength: 60,
        minimumLength: 40
    },
    
    left: {
        alignment: "left", 
        offset: 10,
        maximumLength: 60,
        minimumLength: 40
    },
    
    right: {
        alignment: "right",
        offset: 10, 
        maximumLength: 60,
        minimumLength: 40
    }
};

// Function to generate dock panel configuration
function createDockPanel(position = "center") {
    const config = dockConfigurations[position] || dockConfigurations.center;
    
    return {
        "alignment": config.alignment,
        "applets": [
            {
                "config": {
                    "/": {
                        "immutability": "1"
                    },
                    "/General": {
                        "icon": "file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg"
                    }
                },
                "plugin": "org.kde.plasma.kickoff"
            },
            {
                "config": {
                    "/": {
                        "immutability": "1"
                    },
                    "/General": {
                        "launchers": "applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop,applications:org.kde.kate.desktop,applications:org.kde.systemsettings.desktop"
                    }
                },
                "plugin": "org.kde.plasma.icontasks"
            },
            {
                "config": {
                    "/": {
                        "immutability": "1"
                    }
                },
                "plugin": "org.kde.plasma.trash"
            }
        ],
        "config": {
            "/": {
                "formfactor": "2",
                "immutability": "1",
                "lastScreen": "0",
                "wallpaperplugin": "org.kde.image"
            },
            "/ConfigDialog": {
                "DialogHeight": "480",
                "DialogWidth": "640"
            }
        },
        "height": 3.5,
        "hiding": "dodgewindows",
        "location": "bottom",
        "maximumLength": config.maximumLength,
        "minimumLength": config.minimumLength,
        "offset": config.offset
    };
}

module.exports = { dockConfigurations, createDockPanel };
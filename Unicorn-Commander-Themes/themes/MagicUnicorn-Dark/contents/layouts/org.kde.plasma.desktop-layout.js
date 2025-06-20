// Layout script for UC-Mac-Dark theme
// Creates macOS-style layout with top menu bar and bottom dock

var plasma = getApiVersion(1);

var layout = {
    "desktops": [
        {
            "applets": [
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        }
                    },
                    "plugin": "org.kde.plasma.folder"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "0",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/Wallpaper/org.kde.image/General": {
                    "Image": "file:///home/ucadmin/UC-1/assets/wallpapers/unicorncommander_1920x1080.jpg",
                    "SlidePaths": "/home/ucadmin/UC-1/assets/wallpapers/"
                }
            },
            "wallpaperPlugin": "org.kde.image"
        },
        {
            "applets": [
                {
                    "config": {
                        "/": {"immutability": "1"},
                        "/General": {"icon": "file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg"}
                    },
                    "plugin": "org.kde.plasma.kickoff"
                },
                {
                    "config": {
                        "/": {"immutability": "1"}
                    },
                    "plugin": "org.kde.plasma.appmenu"
                },
                {
                    "config": {
                        "/": {"immutability": "1"}
                    },
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                        "/": {"immutability": "1"}
                    },
                    "plugin": "org.kde.plasma.systemtray"
                },
                {
                    "config": {
                        "/": {"immutability": "1"}
                    },
                    "plugin": "org.kde.plasma.digitalclock"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "2",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                }
            },
            "height": 28,
            "location": "top",
            "maximumLength": -1,
            "minimumLength": -1,
            "offset": 0
        },
        {
            "alignment": "center",
            "applets": [
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/General": {
                            "launchers": "applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop,applications:org.kde.kate.desktop,applications:org.kde.systemsettings.desktop",
                            "iconSize": 60
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
                }
            },
            "height": 80,
            "hiding": "windowsGoBelow",
            "location": "bottom",
            "maximumLength": 40,
            "minimumLength": 25,
            "offset": 0
        }
    ],
    "serializationFormatVersion": "1"
};
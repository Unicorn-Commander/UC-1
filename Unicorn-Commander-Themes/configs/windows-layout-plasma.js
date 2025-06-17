// Windows-style Layout for KDE Plasma 6
// Single bottom taskbar with start menu, tasks, system tray, and clock

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
                    "geometry.height": 0,
                    "geometry.width": 0,
                    "geometry.x": 0,
                    "geometry.y": 0,
                    "plugin": "org.kde.plasma.folder",
                    "title": "Folder"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "0",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/ConfigDialog": {
                    "DialogHeight": "540",
                    "DialogWidth": "720"
                },
                "/Wallpaper/org.kde.image/General": {
                    "Image": "file:///home/ucadmin/UC-1/KDE-Themes/assets/wallpapers/unicorncommander_1920x1080.jpg",
                    "SlidePaths": "/home/ucadmin/UC-1/KDE-Themes/assets/wallpapers/"
                }
            },
            "wallpaperPlugin": "org.kde.image"
        }
    ],
    "panels": [
        {
            "alignment": "left",
            "applets": [
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/General": {
                            "icon": "file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg",
                            "useCustomButtonImage": "true"
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
                            "launchers": "applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop,applications:org.kde.kate.desktop",
                            "groupingStrategy": "0",
                            "groupPopups": "true",
                            "onlyGroupWhenFull": "true",
                            "showOnlyCurrentScreen": "false",
                            "showOnlyCurrentDesktop": "false",
                            "showOnlyMinimized": "false"
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
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/General": {
                            "scaleIconsToFit": "true"
                        }
                    },
                    "plugin": "org.kde.plasma.systemtray"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/Appearance": {
                            "showDate": "true",
                            "showSeconds": "false",
                            "dateFormat": "shortDate"
                        }
                    },
                    "plugin": "org.kde.plasma.digitalclock"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        }
                    },
                    "plugin": "org.kde.plasma.showdesktop"
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
            "height": 2,
            "hiding": "normal",
            "location": "bottom",
            "maximumLength": -1,
            "minimumLength": -1,
            "offset": 0
        }
    ],
    "serializationFormatVersion": "1"
};
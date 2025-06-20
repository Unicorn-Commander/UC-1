// UnicornCommander Light - Windows-style Layout
// Based on default KDE panel with minimal customizations

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
                    "Image": "file:///usr/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg",
                    "SlidePaths": "/usr/share/wallpapers/UnicornCommander/"
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
                            "icon": "file:///usr/share/plasma/look-and-feel/org.unicorncommander.light/contents/assets/menu-button/unicorn.svg",
                            "useCustomButtonImage": true,
                            "customButtonImage": "file:///usr/share/plasma/look-and-feel/org.unicorncommander.light/contents/assets/menu-button/unicorn.svg"
                        }
                    },
                    "plugin": "org.kde.plasma.kickoff"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        }
                    },
                    "plugin": "org.kde.plasma.icontasks"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        },
                        "/General": {
                            "useCustomButtonImage": true,
                            "customButtonImage": "file:///usr/share/plasma/look-and-feel/org.unicorncommander.light/contents/assets/menu-button/rainbow-grid.svg",
                            "icon": "file:///usr/share/plasma/look-and-feel/org.unicorncommander.light/contents/assets/menu-button/rainbow-grid.svg"
                        }
                    },
                    "plugin": "org.kde.plasma.kickerdash"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
                        }
                    },
                    "plugin": "org.kde.plasma.marginsseparator"
                },
                {
                    "config": {
                        "/": {
                            "immutability": "1"
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
                            "showDate": true
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
            "hiding": "none",
            "location": "bottom",
            "maximumLength": -1,
            "minimumLength": -1,
            "offset": 0
        }
    ],
    "serializationFormatVersion": "1"
};
// macOS-style Layout Configuration for KDE Plasma 6
// Top menu bar + bottom dock

const macLayout = {
    panels: [
        {
            id: "top-menubar",
            location: "top",
            height: 28,
            alignment: "fill",
            floating: false,
            widgets: [
                {
                    type: "org.kde.plasma.appmenu",
                    config: {
                        compactView: false
                    }
                },
                {
                    type: "org.kde.plasma.panelspacer"
                },
                {
                    type: "org.kde.plasma.digitalclock",
                    config: {
                        showDate: false,
                        showSeconds: false
                    }
                },
                {
                    type: "org.kde.plasma.systemtray"
                }
            ]
        },
        {
            id: "bottom-dock",
            location: "bottom", 
            height: 60,
            alignment: "center",
            floating: true,
            margin: 8,
            widgets: [
                {
                    type: "org.kde.plasma.kickoff",
                    config: {
                        icon: "file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg",
                        showButtonText: false
                    }
                },
                {
                    type: "org.kde.plasma.icontasks",
                    config: {
                        launchers: [
                            "applications:org.kde.dolphin.desktop",
                            "applications:org.kde.konsole.desktop", 
                            "applications:firefox.desktop",
                            "applications:org.kde.kate.desktop"
                        ],
                        showOnlyCurrentScreen: false,
                        showOnlyCurrentDesktop: false,
                        showOnlyMinimized: false,
                        groupPopups: true,
                        iconSize: 40
                    }
                },
                {
                    type: "org.kde.plasma.trash"
                }
            ]
        }
    ],
    settings: {
        removeDefaultPanel: true,
        menuStyle: "appmenu-gtk-module",
        windowDecorations: {
            titlebarButtons: "close,minimize,maximize",
            titlebarButtonsLeft: "",
            titlebarButtonsRight: "minimize,maximize,close"
        }
    }
};
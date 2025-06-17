// Windows-style Layout Configuration for KDE Plasma 6  
// Bottom taskbar with start menu

const windowsLayout = {
    panels: [
        {
            id: "bottom-taskbar",
            location: "bottom",
            height: 44,
            alignment: "fill", 
            floating: false,
            widgets: [
                {
                    type: "org.kde.plasma.kickoff",
                    config: {
                        icon: "file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg",
                        showButtonText: false,
                        useCustomButtonImage: true
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
                        iconSize: 32,
                        spacing: 4
                    }
                },
                {
                    type: "org.kde.plasma.panelspacer"
                },
                {
                    type: "org.kde.plasma.systemtray",
                    config: {
                        scaleIconsToFit: true
                    }
                },
                {
                    type: "org.kde.plasma.digitalclock",
                    config: {
                        showDate: true,
                        showSeconds: false,
                        dateFormat: "shortDate"
                    }
                },
                {
                    type: "org.kde.plasma.showdesktop"
                }
            ]
        }
    ],
    settings: {
        removeDefaultPanel: true,
        menuStyle: "plasma",
        windowDecorations: {
            titlebarButtons: "close,minimize,maximize",  
            titlebarButtonsLeft: "",
            titlebarButtonsRight: "minimize,maximize,close"
        }
    }
};
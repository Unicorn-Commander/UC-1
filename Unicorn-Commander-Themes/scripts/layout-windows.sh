#!/bin/bash
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var desktops = desktops();
for (var i = 0; i < desktops.length; i++) {
    var d = desktops[i];
    var panels = d.panels ? d.panels() : [];
    for (var j = 0; j < panels.length; j++) {
        d.removePanel(panels[j]);
    }
    var bottomPanel = d.addPanel('org.kde.panel', 0);
    bottomPanel.location = 'bottom';
    bottomPanel.height = 36;
    // Add application launcher
    var launcher = bottomPanel.addWidget('org.kde.plasma.kickoff');
    // Set custom icon for launcher (rainbow dot)
    launcher.currentConfigGroup = ['General'];
    launcher.writeConfig('icon', '/home/ucadmin/UC-1/Unicorn-Commander-Themes/assets/menu-button/rainbow-grid.svg');
}
"

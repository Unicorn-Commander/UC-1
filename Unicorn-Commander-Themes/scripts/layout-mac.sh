#!/bin/bash
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var desktops = desktops();
for (var i = 0; i < desktops.length; i++) {
    var d = desktops[i];
    var panels = d.panels();
    for (var j = 0; j < panels.length; j++) {
        d.removePanel(panels[j]);
    }
    var topPanel = d.addPanel('org.kde.panel', 0);
    topPanel.location = 'top';
    topPanel.height = 28;
    var bottomDock = d.addPanel('org.kde.panel', 1);
    bottomDock.location = 'bottom';
    bottomDock.height = 60;
}
"

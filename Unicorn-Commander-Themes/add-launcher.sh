#\!/bin/bash

echo "Adding Windows start menu launcher..."

# First, let's check what we have
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
print('Current panels:');
var panels = panels();
for (var i = 0; i < panels.length; i++) {
    print('Panel ' + i + ': ' + panels[i].location);
}
"

# Add the launcher
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var panels = panels();
for (var i = 0; i < panels.length; i++) {
    if (panels[i].location == 'bottom') {
        var launcher = panels[i].addWidget('org.kde.plasma.kickoff');
        if (launcher) {
            launcher.index = 0;
            print('Added launcher to bottom panel');
        }
        break;
    }
}
"

echo "Configuring launcher with unicorn icon..."

# Configure the launcher
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var panels = panels();
for (var i = 0; i < panels.length; i++) {
    if (panels[i].location == 'bottom') {
        var widgets = panels[i].widgets();
        for (var j = 0; j < widgets.length; j++) {
            if (widgets[j].type == 'org.kde.plasma.kickoff') {
                widgets[j].currentConfigGroup = ['General'];
                widgets[j].writeConfig('icon', 'file:///home/ucadmin/UC-1/Unicorn-Commander-Themes/assets/menu-button/unicorn.svg');
                widgets[j].reloadConfig();
                print('Applied unicorn icon to launcher');
                break;
            }
        }
        break;
    }
}
"

echo "Done\!"

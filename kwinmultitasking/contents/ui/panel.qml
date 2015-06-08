/********************************************************************
 This file is part of the KDE project.

Copyright (C) 2015 Marco MArtin <mart@kde.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/
import QtQuick 2.0
import QtQuick.Window 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kwin 2.0

PlasmaCore.Dialog {
    id: panel
    y: workspace.virtualScreenSize.height - height
    flags: Qt.X11BypassWindowManagerHint
    type: PlasmaCore.Dialog.Dock
    
    mainItem: Item {
        width: workspace.virtualScreenSize.width
        height: units.iconSizes.medium
        PlasmaComponents.ToolButton {
            anchors.left: parent.left
            iconSource: "applications-other"
            onClicked: root.showWindowList();
        }

        PlasmaComponents.ToolButton {
            anchors.horizontalCenter: parent.horizontalCenter
            iconSource: "go-home"
            onClicked: root.closeWindowList();
        }
    }
    Component.onCompleted: {
        KWin.registerWindow(panel);
        panel.visible = true;

        panel.y = workspace.virtualScreenSize.height - height
    }
}
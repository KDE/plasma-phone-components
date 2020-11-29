/*
 *   Copyright 2014 Marco Martin <notmart@gmail.com>
 *             2020 Devin Lin <espidev@gmail.com
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.12
import QtGraphicalEffects 1.15
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.kirigami 2.11 as Kirigami
import "quicksettings"

ColumnLayout {
    id: notifShadeContent
    
    // 0 - closed, 1 - pinned settings visible, 2 - all settings visible
    property double stateGradient
    
    property alias notificationView: fullRepresentationView
    
    spacing: 0
    
    // top quicksettings panel
    QuickSettingsPanel {
        id: quickSettingsPanel
        y: stateGradient >= 1 ? 0 : (-height - Kirigami.Units.gridUnit) + stateGradient * (height + Kirigami.Units.gridUnit)
        stateGradient: notifShadeContent.stateGradient
    }
    
    // TODO doesn't seem to display
    DropShadow {
        source: quickSettingsPanel
        color: Qt.darker(PlasmaCore.Theme.backgroundColor, 1.2)
        radius: 4
        samples: 6
        horizontalOffset: 0
        verticalOffset: 1
    }
    
    // notifications list
    ListView {
        id: fullRepresentationView
        opacity: stateGradient > 1 ? 1 : stateGradient
        
        Layout.preferredWidth: parent.width
        height: Math.min(plasmoid.screenGeometry.height - quickSettingsPanel.height - bottomBar.height, implicitHeight)
        implicitHeight: units.gridUnit * 20
        
        cacheBuffer: width * 100
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: units.longDuration
        snapMode: ListView.SnapOneItem
        model: ObjectModel {
            id: fullRepresentationModel
        }
        orientation: ListView.Horizontal

        MouseArea {
            parent: fullRepresentationView.contentItem
            anchors.fill: parent
            z: -1
            onClicked: window.close()
        }
    }
    
    // track swiping
    MouseArea {
        z: 1
        property int oldMouseY: 0
        anchors.fill: parent
            
        propagateComposedEvents: true
        onPressed: {
            shadeOverlay.cancelAnimations();
            oldMouseY = mouse.y;
        }
        onReleased: {
            window.updateState();
        }
        onPositionChanged: {
            window.direction = oldMouseY > mouse.y ? NotificationShadeOverlay.MovementDirection.Up : NotificationShadeOverlay.MovementDirection.Down;
            window.offset += mouse.y - oldMouseY;
            oldMouseY = mouse.y;
        }
    }
}

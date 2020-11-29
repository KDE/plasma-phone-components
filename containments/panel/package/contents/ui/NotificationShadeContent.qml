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
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.kirigami 2.11 as Kirigami
import "quicksettings"

ColumnLayout {
    id: notifShadeContent
    property required double stateGradient // 0 - closed, 1 - pinned settings visible, 2 - all settings visible
    property alias var notificationView: fullRepresentationView
    
    spacing: Kirigami.Units.smallSpacing
    
    // top quicksettings panel
    QuickSettingsPanel {
        id: quickSettingsPanel
        y: stateGradient >= 1 ? 0 : stateGradient * (-height - Kirigami.Units.gridUnit)
        stateGradient: notifShadeContent.stateGradient
    }
    
    // notifications list
    ListView {
        id: fullRepresentationView
        z: 1
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
}

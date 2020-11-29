/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
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

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.kde.taskmanager 0.1 as TaskManager

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "LayoutManager.js" as LayoutManager

import "quicksettings"
import "indicators" as Indicators

// screen top panel
PlasmaCore.ColorScope {
    z: 1
    colorGroup: root.showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
    //parent: slidingPanel.visible && !slidingPanel.wideScreen ? panelContents : root
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }
    height: root.height
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 1.0
                color: showingApp ? root.backgroundColor : "transparent"
            }
            GradientStop {
                position: 0.0
                color: showingApp ? root.backgroundColor : Qt.rgba(0, 0, 0, 0.1)
            }
        }
    }

    Loader {
        id: strengthLoader
        height: parent.height
        width: item ? item.width : 0
        source: Qt.resolvedUrl("indicators/SignalStrength.qml")
    }

    Row {
        id: sniRow
        anchors.left: strengthLoader.right
        height: parent.height
        Repeater {
            id: statusNotifierRepeater
            model: PlasmaCore.SortFilterModel {
                id: filteredStatusNotifiers
                filterRole: "Title"
                sourceModel: PlasmaCore.DataModel {
                    dataSource: statusNotifierSource
                }
            }

            delegate: TaskWidget {
            }
        }
    }

    PlasmaComponents.Label {
        id: clock
        property bool is24HourTime: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") === -1
        
        anchors.fill: parent
        text: Qt.formatTime(timeSource.data.Local.DateTime, is24HourTime ? "h:mm" : "h:mm ap")
        color: PlasmaCore.ColorScope.textColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        font.pixelSize: height / 2
    }

    RowLayout {
        id: appletIconsRow
        anchors {
            bottom: parent.bottom
            right: simpleIndicatorsLayout.left
        }
        height: parent.height
    }

    //TODO: pluggable
    RowLayout {
        id: simpleIndicatorsLayout
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: units.smallSpacing
        }
        Indicators.Bluetooth {}
        Indicators.Wifi {}
        Indicators.Volume {}
        Indicators.Battery {}
    }
}

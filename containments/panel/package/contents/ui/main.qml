/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
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


Item {
    id: root
    width: 480
    height: 30

    Plasmoid.backgroundHints: showingApp ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false
    property var layoutManager: LayoutManager

    readonly property color backgroundColor: NanoShell.StartupFeedback.visible ? NanoShell.StartupFeedback.backgroundColor : topPanel.backgroundColor
    readonly property bool showingApp: !MobileShell.HomeScreenControls.homeScreenVisible

    readonly property bool hasTasks: tasksModel.count > 0

    // TODO CAUSES SEGFAULTS
//     Containment.onAppletAdded: {
//         addApplet(applet, x, y);
//         LayoutManager.save();
//     }

    function addApplet(applet, x, y) {
        var compactContainer = compactContainerComponent.createObject(appletIconsRow)
        print("Applet added: " + applet + " " + applet.title)

        applet.parent = compactContainer;
        compactContainer.applet = applet;
        applet.anchors.fill = compactContainer;
        applet.visible = true;

        //FIXME: make a way to instantiate fullRepresentationItem without the open/close dance
        applet.expanded = true
        applet.expanded = false

        var fullContainer = null;
        if (applet.pluginName == "org.kde.plasma.notifications") {
            fullContainer = fullNotificationsContainerComponent.createObject(shadeOverlay.notificationView.contentItem, {"fullRepresentationModel": fullRepresentationModel, "fullRepresentationView": shadeOverlay.notificationView});
        } else {
            fullContainer = fullContainerComponent.createObject(shadeOverlay.notificationView.contentItem, {"fullRepresentationModel": fullRepresentationModel, "fullRepresentationView": shadeOverlay.notificationView});
        }

        applet.fullRepresentationItem.parent = fullContainer;
        fullContainer.applet = applet;
        fullContainer.contentItem = applet.fullRepresentationItem;
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsLayout;
        LayoutManager.restore();
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        filterByScreen: plasmoid.configuration.showForCurrentScreenOnly
        //FIXME: workaround
        Component.onCompleted: tasksModel.countChanged();
    }

    PlasmaCore.DataSource {
        id: statusNotifierSource
        engine: "statusnotifieritem"
        interval: 0
        onSourceAdded: {
            connectSource(source)
        }
        Component.onCompleted: {
            connectedSources = sources
        }
    }

    RowLayout {
        id: appletsLayout
        Layout.minimumHeight: Math.max(root.height, Math.round(Layout.preferredHeight / root.height) * root.height)
    }
 
    //todo: REMOVE?
    Component {
        id: compactContainerComponent
        Item {
            property Item applet
            visible: applet && (applet.status != PlasmaCore.Types.HiddenStatus && applet.status != PlasmaCore.Types.PassiveStatus)
            Layout.fillHeight: true
            Layout.minimumWidth: applet && applet.compactRepresentationItem ? Math.max(applet.compactRepresentationItem.Layout.minimumWidth, appletIconsRow.height) : appletIconsRow.height
            Layout.maximumWidth: Layout.minimumWidth
        }
    }

    Component {
        id: fullContainerComponent
        FullContainer {
        }
    }

    Component {
        id: fullNotificationsContainerComponent
        FullNotificationsContainer {
        }
    }

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    TopPanel {
        id: topPanel
    }
    
    // screen top panel background
    Rectangle {
        anchors.fill: parent
        color: PlasmaCore.Theme.backgroundColor
        opacity: shadeOverlay.stateGradient > 1 ? 0.6 : 0.6 * shadeOverlay.stateGradient
    }
    
    DropShadow {
        anchors.fill: topPanel
        visible: !showingApp
        cached: true
        horizontalOffset: 0
        verticalOffset: 1
        radius: 4.0
        samples: 7
        color: Qt.rgba(0,0,0,0.8)
        source: topPanel
    }
    
    // track initial gesture from top
    MouseArea {
        z: 99
        property int oldMouseY: 0

        anchors.fill: parent
        onPressed: {
            shadeOverlay.cancelAnimations();
            oldMouseY = mouse.y;
            shadeOverlay.offset = 0;
            shadeOverlay.showFullScreen();
        }
        onPositionChanged: {
            shadeOverlay.direction = oldMouseY > mouse.y ? NotificationShadeOverlay.MovementDirection.Up : NotificationShadeOverlay.MovementDirection.Down
            
            let diff = mouse.y - oldMouseY;
            if (shadeOverlay.offset + diff > shadeOverlay.pinnedPanelHeight) {
                shadeOverlay.offset = shadeOverlay.pinnedPanelHeight;
            } else {
                shadeOverlay.offset += diff;
            }
            oldMouseY = mouse.y;
        }
        onReleased: shadeOverlay.updateState()
    }

    // quicksettings, notifications list, etc.
    NotificationShadeOverlay {
        id: shadeOverlay
        headerHeight: root.height
        width: plasmoid.availableScreenRect.width
        height: plasmoid.availableScreenRect.height
    }
}

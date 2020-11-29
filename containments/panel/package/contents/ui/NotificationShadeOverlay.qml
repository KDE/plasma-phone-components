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

NanoShell.FullScreenOverlay {
    id: window

    property property offset
    
    property double stateGradient: 0 // 0 - closed, 1 - pinned settings visible, 2 - all settings visible
    
    readonly property bool wideScreen: width > height || width > units.gridUnit * 45
    readonly property int drawerWidth: wideScreen ? contentItem.implicitWidth : width
    property alias fixedArea: mainScope
    property alias flickable: mainFlickable

    property alias var notificationView: contentArea.contentItem.notificationView
    property alias pinnedPanelHeight: contentArea.contentItem.pinnedPanelHeight
    property alias fullPanelHeight: contentArea.contentItem.fullPanelHeight
    property int headerHeight

    signal closed

    enum PanelState {
        Closed = 0,
        PinnedSettingsVisible, // only the top row is fully open
        AllSettingsVisible // quicksettings is fully open
    }
    property int panelState: NotificationShadeOverlay.PanelState.Closed
    
    enum MovementDirection {
        None = 0,
        Up,
        Down
    }
    property int direction: NotificationShadeOverlay.MovementDirection.None
    
    function open() {
        window.showFullScreen();
        openAnim.restart();
    }
    function close() {
        closeAnim.restart();
    }
    // update state when nothing is open
    function updateState() {
        if (window.direction === NotificationShadeOverlay.MovementDirection.None) {
            closeAnim.restart();
        } else if (window.direction === NotificationShadeOverlay.MovementDirection.Down) {
            if (stateGradient <= 1) {
                toPinnedAnim.restart();
            } else {
                toFullOpenAnim.restart();
            }
        } else if (window.direction === NotificationShadeOverlay.MovementDirection.Up) {
            closeAnim.restart();
        }
    }
    Component.onCompleted: updateState()

    onActiveChanged: {
        if (!active) {
            close();
        }
    }

    SequentialAnimation {
        id: closeAnim
        PropertyAnimation {
            target: window
            duration: units.longDuration
            easing.type: Easing.InOutQuad
            properties: "stateGradient"
            from: window.stateGradient
            to: 0
        }
        ScriptAction {
            script: {
                window.visible = false;
                window.closed();
            }
        }
    }
    PropertyAnimation {
        id: toPinnedAnim
        target: window
        duration: units.longDuration
        easing.type: Easing.InOutQuad
        properties: "stateGradient"
        from: window.stateGradient
        to: 1
    }
    PropertyAnimation {
        id: toFullOpenAnim
        target: window
        duration: units.longDuration
        easing.type: Easing.InOutQuad
        properties: "stateGradient"
        from: window.stateGradient
        to: 2
    }

    // background rectangle
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: parent.height - headerHeight // don't layer on top panel indicators (area is darkened separately)
        color: "black"
        opacity: window.stateGradient > 1 ? 0.6 : 0.6 * window.gradient
    }
    
    // notification shade panel
    PlasmaCore.ColorScope {
        id: mainScope
        anchors.fill: parent
        
        // shade overlay content
        MouseArea {
            id: dismissArea
            z: 2
            width: parent.width
            height: mainFlickable.contentHeight
            onClicked: window.close();
            
            property int oldMouseY: 0
            
            onPressed: oldMouseY = mouse.y
            onReleased: slidingPanel.updateState()
            onPositionChanged: {
                slidingPanel.direction = oldMouseY > mouse.y ? NotificationShadeOverlay.MovementDirection.Up : NotificationShadeOverlay.MovementDirection.Down;
                slidingPanel.stateGradient = Math.max(0, Math.min(2, slidingPanel.stateGradient + (mouse.y - oldMouseY) / shadeOverlay.pinnedPanelHeight));
                oldMouseY = mouse.y;
            }
            
            PlasmaComponents.Control {
                id: contentArea
                z: 1
                y: 0
                width: drawerWidth
                contentItem: NotificationShadeContent {
                    width: parent
                    stateGradient: window.stateGradient
                }
            }
        }
        
    }
}

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

    property int offset: 0
    property double stateGradient: {
        if (offset > pinnedPanelHeight) {
            return Math.min(2, 1 + (offset - pinnedPanelHeight) / (fullPanelHeight - pinnedPanelHeight));
        } else {
            return Math.max(0, offset / pinnedPanelHeight);
        }
    } // 0 - closed, 1 - pinned settings visible, 2 - all settings visible
    
    readonly property bool wideScreen: width > height || width > units.gridUnit * 45
    readonly property int drawerWidth: width
    
    property alias closeAnimation: closeAnim

    //TODO CAUSES SEGFAULT property alias notificationView: contentArea.contentItem.notificationView
    
    // TODO calculate, not hardcode
    property int pinnedPanelHeight: units.iconSizes.large + units.smallSpacing * 5
    property int fullPanelHeight: 4 * (units.iconSizes.large + units.smallSpacing) + units.smallSpacing * 2
    
    property int headerHeight
    
    color: "transparent"

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
    function cancelAnimations() {
        closeAnim.stop();
        toPinnedAnim.stop();
        toFullOpenAnim.stop();
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
            if (stateGradient <= 1) {
                closeAnim.restart();
            } else {
                toPinnedAnim.restart();
            }
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
            properties: "offset"
            from: window.offset
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
        properties: "offset"
        from: window.offset
        to: window.pinnedPanelHeight
    }
    PropertyAnimation {
        id: toFullOpenAnim
        target: window
        duration: units.longDuration
        easing.type: Easing.InOutQuad
        properties: "offset"
        from: window.offset
        to: window.fullPanelHeight
    }

    // background rectangle
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: parent.height - headerHeight // don't layer on top panel indicators (area is darkened separately)
        color: PlasmaCore.Theme.backgroundColor
        opacity: window.stateGradient > 1 ? 0.6 : 0.6 * window.stateGradient
    }
    
    // notification shade panel
    PlasmaCore.ColorScope {
        id: mainScope
        anchors.fill: parent
        anchors.topMargin: window.headerHeight
        
        // shade overlay content
        MouseArea {
            id: dismissArea
            z: 2
            width: parent.width
            height: parent.height
            onClicked: window.close();
            
            property int oldMouseY: 0
            
            onPressed: {
                cancelAnimations();
                oldMouseY = mouse.y;
            }
            onReleased: window.updateState()
            onPositionChanged: {
                window.direction = oldMouseY > mouse.y ? NotificationShadeOverlay.MovementDirection.Up : NotificationShadeOverlay.MovementDirection.Down;
                window.offset += mouse.y - oldMouseY;
                oldMouseY = mouse.y;
            }
            
            PlasmaComponents.Control {
                id: contentArea
                z: 1
                y: 0
                width: drawerWidth
                implicitWidth: drawerWidth
                contentItem: NotificationShadeContent {
                    width: parent
                    stateGradient: window.stateGradient
                }
            }
        }
        
    }
}

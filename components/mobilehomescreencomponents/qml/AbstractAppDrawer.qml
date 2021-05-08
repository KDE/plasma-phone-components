/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.extras 2.0 as PlasmaExtra
//import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.10 as Kirigami

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

import "private"

Item {
    id: root

    enum Status {
        Closed,
        Peeking,
        Open
    }

    enum MovementDirection {
        None = 0,
        Up,
        Down
    }

    readonly property int status: {
        if (flickable.contentY >= -flickable.originY - view.height) {
            return AbstractAppDrawer.Status.Open;
        } else if (flickable.contentY > -flickable.originY - view.height*2 + closedPositionOffset*2) {
            return AbstractAppDrawer.Status.Peeking;
        } else {
            return AbstractAppDrawer.Status.Closed;
        }
    }

    property real offset: 0
    property real closedPositionOffset: 0

    property real leftPadding: 0
    property real topPadding: 0
    property real bottomPadding: 100
    property real rightPadding: 0

    property alias flickable: view.contentItem
    property alias flickableParent: view
    
    signal launched
    signal dragStarted

    readonly property int reservedSpaceForLabel: metrics.height
    property int availableCellHeight: units.iconSizes.huge + reservedSpaceForLabel

    readonly property real openFactor: Math.min(1, Math.max(0, Math.min(1, (flickable.contentY + flickable.originY + view.height*2 - root.closedPositionOffset*2) / (units.gridUnit * 10))))

    function open() {
        if (root.status === AbstractAppDrawer.Status.Open) {
            flickable.flick(0,1);
        } else {
            scrollAnim.to = 0
            scrollAnim.restart();
        }
    }

    function close() {
        if (root.status !== AbstractAppDrawer.Status.Closed) {
            scrollAnim.to = -view.height + closedPositionOffset;
            scrollAnim.restart();
        }
    }

    function snapDrawerStatus() {
        if (root.status !== AbstractAppDrawer.Status.Peeking) {
            return;
        }

        if (flickable.movementDirection === AbstractAppDrawer.MovementDirection.Up) {
            if (flickable.contentY > 7 * -view.height / 8) { // over one eighth of the screen
                open();
            } else {
                close();
            }
        } else {
            if (flickable.contentY < -view.height / 8) { // over one eighth of the screen 
                close();
            } else {
                open();
            }
        }
    }

    Drag.dragType: Drag.Automatic

    onOffsetChanged: {
        if (!flickable.moving) {
            flickable.offsetUpdatedContentY = true;
            flickable.contentY = Math.max(0, offset) - flickable.originY - view.height*2 + closedPositionOffset*2
        }
    }

    NumberAnimation {
        id: scrollAnim
        target: flickable
        properties: "contentY"
        duration: units.longDuration * 2
        easing.type: Easing.OutQuad
        easing.amplitude: 2.0
    }

    PC3.Label {
        id: metrics
        text: "M\nM"
        visible: false
        font.pointSize: theme.defaultFont.pointSize * 0.9
    }

    OpenDrawerButton {
        id: openDrawerButton
        anchors {
            left: parent.left
            right: parent.right
            bottom: scrim.top
        }
        factor: root.openFactor
        flickable: root.flickable
        onOpenRequested: root.open();
        onCloseRequested: root.close();
    }

    Rectangle {
        id: scrim
        anchors {
            left: view.left
            right: view.right
            leftMargin: -1
            rightMargin: -1
        }
        border.color: Qt.rgba(1, 1, 1, 0.5)
        radius: units.gridUnit
        color: "black"
        opacity: 0.4 * root.openFactor
        height: root.height + radius * 2
        y: Math.min(view.height, Math.max(-radius, -flickable.contentY - flickable.originY - root.height + root.topPadding + root.bottomPadding + root.closedPositionOffset))
    }

    Timer {
        id: closeTimer
        interval: 1000
        onTriggered: root.close();
    }
    
    
    Controls.Control {
        id: view
        anchors {
            fill: parent
            leftMargin: root.leftPadding
            topMargin: root.topPadding
            rightMargin: root.rightPadding
            bottomMargin: root.bottomPadding
        }
        padding: 0
        opacity: {
            if (root.status == AbstractAppDrawer.Status.Open) {
                return 1;
            } else if (root.status == AbstractAppDrawer.Status.Closed) {
                return 0;
            } else { // peeking
                return root.openFactor;
            }
        }
        visible: root.status !== AbstractAppDrawer.Status.Closed
        
        // the view flickable is the child of this element
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: units.gridUnit + root.leftPadding
            rightMargin: units.gridUnit + root.rightPadding
            bottomMargin: root.bottomPadding - height
        }
        height: 1
        visible: root.bottomPadding > 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.15; color: Qt.rgba(1, 1, 1, 0.5) }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 1) }
            GradientStop { position: 0.85; color: Qt.rgba(1, 1, 1, 0.5) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }
        opacity: root.status !== AbstractAppDrawer.Status.Closed ? 0.6 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }
    }
}


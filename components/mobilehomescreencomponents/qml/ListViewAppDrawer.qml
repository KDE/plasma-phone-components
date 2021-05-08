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
import org.kde.kirigami 2.10 as Kirigami

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

import "private"

AbstractAppDrawer {
    id: root
    required property int headerHeight
    required property var headerItem
    
    flickable: ListView {
        id: listView
        anchors.fill: parent
        
        header: Item {
            id: offsetRect
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.height - root.topPadding - root.bottomPadding - root.closedPositionOffset
            property real oldHeight: height
            onHeightChanged: {
                if (root.status !== AppDrawer.Status.Open) {
                    listView.contentY = -root.flickableParent.height + root.closedPositionOffset;
                }
                oldHeight = height;
            }
            
            Controls.Control {
                id: headerControl
                padding: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.bottom
                contentItem: root.headerItem
            }
        }
        footer: Item { height: root.headerHeight } // account for header translate
        
        clip: true
        reuseItems: true
        cacheBuffer: model.count * delegateHeight // delegate height
        
        property int delegateHeight: PlasmaCore.Units.gridUnit * 3
        
        property bool offsetUpdatedContentY: false
        property real oldContentY: contentY
        property int movementDirection: AppDrawer.MovementDirection.None
        onContentYChanged: {
            if (contentY > oldContentY) {
                movementDirection = AppDrawer.MovementDirection.Up;
            } else {
                movementDirection = AppDrawer.MovementDirection.Down;
            }

            oldContentY = contentY;
            let newOffset = contentY + listView.originY + root.flickableParent.height*2 - root.closedPositionOffset*2;
            if (offsetUpdatedContentY && newOffset !== root.offset) { // prevent infinite loop of constantly updating offsets and contentY
                root.offset = newOffset;
            }
            offsetUpdatedContentY = false;
        }
        onMovementEnded: root.snapDrawerStatus()
        onFlickEnded: movementEnded()

        model: HomeScreenComponents.ApplicationListModel

        delegate: DrawerListDelegate {
            id: delegate
            // offset for header
            transform: Translate { y: root.headerHeight }
            
            width: listView.width
            height: listView.delegateHeight
            reservedSpaceForLabel: root.reservedSpaceForLabel

            onDragStarted: (imageSource, x, y, mimeData) => {
                root.Drag.imageSource = imageSource;
                root.Drag.hotSpot.x = x;
                root.Drag.hotSpot.y = y;
                root.Drag.mimeData = { "text/x-plasma-phone-homescreen-launcher": mimeData };

                root.close()

                root.dragStarted()
                root.Drag.active = true;
            }
            onLaunch: (x, y, icon, title, storageId) => {
                if (icon !== "") {
                    NanoShell.StartupFeedback.open(
                            icon,
                            title,
                            delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                            delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                            Math.min(delegate.iconItem.width, delegate.iconItem.height));
                }

                HomeScreenComponents.ApplicationListModel.setMinimizedDelegate(index, delegate);
                HomeScreenComponents.ApplicationListModel.runApplication(storageId);
                root.launched();
                closeTimer.restart();
            }
        }
        
        PC3.ScrollBar.vertical: PC3.ScrollBar {
            id: scrollBar
            opacity: root.flickable.moving
            interactive: false
            enabled: false
            Behavior on opacity {
                OpacityAnimator {
                    duration: PlasmaCore.Units.longDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
            implicitWidth: Math.round(PlasmaCore.Units.gridUnit/3)
            contentItem: Rectangle {
                radius: width/2
                color: Qt.rgba(1, 1, 1, 0.3)
                border.color: Qt.rgba(0, 0, 0, 0.4)
            }
        }
    }
}

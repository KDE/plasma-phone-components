/***************************************************************************
 *   Copyright 2011 Davide Bettio <davide.bettio@kdemail.net>              *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.mobilecomponents 0.1 as PlasmaComponents

Item {
    id: notificationsApplet
    state: "default"
    width: 32
    height: 32

    Component.onCompleted: {
        //plasmoid.popupIcon = QIcon("preferences-desktop-notification")
        plasmoid.aspectRatioMode = "ConstrainedSquare"
    }

    states: [
        State {
            name: "default"
            PropertyChanges {
                target: notificationSvgItem
                elementId: "notification-disabled"
            }
            PropertyChanges {
                target: countText
                visible: false
            }
        },
        State {
            name: "new-notifications"
            PropertyChanges {
                target: notificationSvgItem
                elementId: "notification-empty"
            }
            PropertyChanges {
                target: countText
                visible: true
            }
        }
    ]

    PlasmaCore.Svg {
        id: notificationSvg
        imagePath: "icons/notification"
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }

    Item {
        id: lastNotificationClip
        x: notificationsApplet.width/2
        width: 420
        height: parent.height
        clip: true
        visible: false
        PlasmaCore.FrameSvgItem {
            id: lastNotificationRectangle
            imagePath: "widgets/frame"
            prefix: "plain"
            x: -width
            width: parent.width
            height: parent.height
            Text {
                id: lastNotificationText
                anchors {
                    left: parent.left
                    leftMargin: notificationsApplet.width/2
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                textFormat: Text.PlainText
                color: theme.textColor
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }

    SequentialAnimation {
        id: lastNotificationAnimation
        PropertyAction {
            target: lastNotificationClip
            property: "visible"
            value: true
        }
        NumberAnimation {
            target: lastNotificationRectangle
            duration: 300
            property: "x"
            to: 0
        }
        PauseAnimation {
            duration: 8000
        }
        NumberAnimation {
            target: lastNotificationRectangle
            duration: 300
            property: "x"
            to: -lastNotificationRectangle.width
        }
        PropertyAction {
            target: lastNotificationClip
            property: "visible"
            value: false
        }
    }

    PlasmaCore.SvgItem {
        id: notificationSvgItem
        svg: notificationSvg
        elementId: "notification-disabled"
        anchors.fill: parent
        Text {
            id: countText
            text: notificationsList.count
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (popup.visible) {
                    popup.visible = false
                } else if (notificationsList.count > 0) {
                    var pos = popup.popupPosition(notificationsApplet, Qt.AlignCenter)
                    popup.x = pos.x
                    popup.y = pos.y
                    popup.visible = true
                }
            }
        }
    }

    ListModel {
        id: notificationsModel
    }

    PlasmaCore.DataSource {
        id: notificationsSource
        engine: "notifications"
        interval: 0

        onSourceAdded: {
            connectSource(source);
        }

        onNewData: {
            notificationsModel.append({"appIcon" : notificationsSource.data[sourceName]["appIcon"],
                                "appName" : notificationsSource.data[sourceName]["appName"],
                                "summary" : notificationsSource.data[sourceName]["summary"],
                                "body" : notificationsSource.data[sourceName]["body"],
                                "expireTimeout" : notificationsSource.data[sourceName]["expireTimeout"],
                                "urgency": notificationsSource.data[sourceName]["urgency"]});
        }

        onConnectedSourcesChanged: {
            if (connectedSources.length > 0) {
                notificationsApplet.state = "new-notifications"
            } else {
                notificationsApplet.state = "default"
            }
        }
        onDataChanged: {
            var i = connectedSources[connectedSources.length-1]
            lastNotificationText.text = String(data[i]["body"]).replace("\n", " ")

            lastNotificationAnimation.running = true
        }
    }

    PlasmaCore.Dialog {
        id: popup
        location: plasmoid.location
        windowFlags: Qt.Popup
        mainItem: ListView {
            id: notificationsList
            width: 400
            height: Math.min(350, contentHeight)
            model: notificationsModel
            anchors.fill: parent
            clip: true
            onCountChanged: {
                if (count == 0) {
                    popup.visible = false
                }
            }
            delegate: ListItem {
                id: notificationItem
                width: notificationsList.width
                ListView.onRemove: SequentialAnimation {
                    PropertyAction {
                        target: notificationItem
                        property: "ListView.delayRemove"
                        value: true
                    }
                    NumberAnimation {
                        target: notificationItem
                        property: "scale"
                        to: 0
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                    PropertyAction {
                        target: notificationItem
                        property: "ListView.delayRemove"
                        value: false
                    }
                }
                Column {
                    spacing: 8
                    width: notificationsList.width
                    Text {
                        text: appName
                        font.bold: true
                        color: theme.textColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Row {
                        spacing: 6
                        PlasmaWidgets.IconWidget {
                            icon: QIcon(appIcon)
                            width: 32
                            height: 32
                        }

                        Text {
                            text: body
                            color: theme.textColor
                            width: notificationsList.width - 24 - 32 - 12
                        }
                        PlasmaCore.SvgItem {
                            svg: configIconsSvg
                            elementId: "close"
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                onClicked: {
                                    notificationsModel.remove(index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

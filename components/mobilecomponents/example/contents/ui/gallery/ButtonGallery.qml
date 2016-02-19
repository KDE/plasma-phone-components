/*
 *   Copycontext 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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
import QtQuick.Controls 1.2 as Controls
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2

ScrollablePage {
    id: page
    Layout.fillWidth: true
    title: "Buttons"
    contextualActions: [
        Action {
            text:"Action for buttons"
            iconName: "bookmarks"
            onTriggered: print("Action 1 clicked")
        },
        Action {
            text:"Action 2"
            iconName: "folder"
            enabled: false
        }
    ]
    mainAction: Action {
        iconName: sheet.opened ? "dialog-cancel" : "document-edit"
        onTriggered: {
            print("Action button in buttons page clicked");
            if (sheet.opened) {
                sheet.close();
            } else {
                sheet.open();
            }
        }
    }

    //Close the drawer with the back button
    onBackRequested: {
        if (sheet.opened) {
            event.accepted = true;
            sheet.close();
        }
    }

    OverlayDrawer {
        id: sheet
        anchors.fill: parent
        edge: Qt.BottomEdge
        contentItem: Item {
            implicitWidth: Units.gridUnit * 8
            implicitHeight: Units.gridUnit * 8
            ColumnLayout {
                anchors.centerIn: parent
                Controls.Button {
                    text: "Button1"
                    onClicked: print(root)
                }
                Controls.Button {
                    text: "Button2"
                }
            }
        }
    }

    ColumnLayout {
        width: page.width
        spacing: Units.smallSpacing

        Controls.Button {
            text: "Open Sheet"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: sheet.open()
        }
        Controls.Button {
            text: "Push another"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: pageStack.push(Qt.resolvedUrl("ButtonGallery.qml"));
        }
        Controls.Button {
            text: "Toggle Action Button"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: mainAction.visible = !mainAction.visible;
        }
        Controls.Button {
            text: "Show Passive Notification"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: showPassiveNotification("This is a passive message", 3000);
        }
        Controls.Button {
            text: "Passive Notification Action"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: showPassiveNotification("This is a passive message", "long", "Action", function() {print("Passive notification action clicked")});
        }
        Controls.Button {
            text: "Disabled Button"
            enabled: false
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Controls.ToolButton {
            text: "Tool Button"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Controls.ToolButton {
            text: "Tool Button non flat"
            property bool flat: false
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Controls.ToolButton {
            iconName: "go-previous"
            property bool flat: false
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Row {
            spacing: 0
            anchors.horizontalCenter: parent.horizontalCenter
            Controls.ToolButton {
                iconName: "edit-cut"
                property bool flat: false
                onClicked: print("clicked")
            }
            Controls.ToolButton {
                iconName: "edit-copy"
                property bool flat: false
                onClicked: print("clicked")
            }
            Controls.ToolButton {
                iconName: "edit-paste"
                property bool flat: false
                onClicked: print("clicked")
            }
        }
    }
 
    
}

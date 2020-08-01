/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2014 Marco Martin <mart@kde.org>
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
import QtQuick.Controls 2.5 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import MeeGo.QOfono 0.2
import "../components"

PlasmaCore.ColorScope {
    id: root

    anchors.fill: parent
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    visible: simManager.pinRequired != OfonoSimManager.NoPin
    property OfonoSimManager simManager: ofonoSimManager

    property string pin

    function addNumber(number) {
        pinLabel.text = pinLabel.text + number
    }

    Rectangle {
        id: pinScreen
        anchors.fill: parent
        
        color: PlasmaCore.ColorScope.backgroundColor
        opacity: 0.9
    }

    OfonoManager {
        id: ofonoManager
        onAvailableChanged: {
        console.log("Ofono is " + available)
        }
        onModemAdded: {
            console.log("modem added " + modem)
        }
        onModemRemoved: console.log("modem removed")
    }

    OfonoConnMan {
        id: ofono1
        Component.onCompleted: {
            console.log(ofonoManager.modems)
        }
        modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
    }

    OfonoModem {
        id: modem1
        modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""

    }

    OfonoContextConnection {
        id: context1
        contextPath : ofono1.contexts.length > 0 ? ofono1.contexts[0] : ""
        Component.onCompleted: {
            print("Context Active: " + context1.active)
        }
        onActiveChanged: {
            print("Context Active: " + context1.active)
        }
    }

    OfonoSimManager {
        id: ofonoSimManager
        modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
    }

    OfonoNetworkOperator {
        id: netop
    }

    MouseArea {
        anchors.fill: parent
    }

    Connections {
        target: simManager
        onEnterPinComplete: {
            print("Enter Pin complete: " + error + " " + errorString)
        }
    }

    ColumnLayout {
        id: passwordLayout
        anchors.bottom: parent.bottom

        width: parent.width
        spacing: units.gridUnit * 2

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: {
                switch (simManager.pinRequired) {
                    case OfonoSimManager.NoPin: return i18n("No pin (error)");
                    case OfonoSimManager.SimPin: return i18n("Enter Sim PIN");
                    case OfonoSimManager.SimPin2: return i18n("Enter Sim PIN 2");
                    case OfonoSimManager.SimPuk: return i18n("Enter Sim PUK");
                    case OfonoSimManager.SimPuk2: return i18n("Enter Sim PUK 2");
                    default: return i18n("Unknown PIN type: %1", simManager.pinRequired);
                }
            }
            font.pointSize: 12
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: simManager.pinRetries && simManager.pinRetries[simManager.pinRequired] ? i18np("%1 attempt left", "%1 attempts left", simManager.pinRetries[simManager.pinRequired]) : "";
        }

        Row {
            id: dotDisplay
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Layout.minimumHeight: units.gridUnit
            Layout.maximumWidth: parent.width

            Repeater {
                model: root.pin.length
                delegate: Rectangle {
                    width: units.gridUnit
                    height: width
                    radius: width
                    color: Qt.rgba(255, 255, 255, 0.3)
                }
            }
        }

        GridLayout {
            id: numBlock
            property string thePw

            Layout.fillWidth: true
            Layout.minimumHeight: units.gridUnit * 16
            Layout.maximumWidth: root.width
            Layout.bottomMargin: units.gridUnit * 2
            Layout.leftMargin: units.gridUnit * 2
            Layout.rightMargin: units.gridUnit * 2
            rowSpacing: units.gridUnit

            columns: 3

            Repeater {
                model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "R", "0", "E"]
                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.centerIn: parent
                        width: units.gridUnit * 3
                        height: width
                        radius: 12
                        color: Qt.rgba(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b, ma.pressed ? 0.8 : 0.3)
                        visible: modelData.length > 0

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            onClicked: {
                                if (modelData === "R") {
                                    root.pin = root.pin.substr(0, root.pin.length - 1);
                                } else if (modelData === "E") {
                                    simManager.enterPin(simManager.pinRequired, root.pin)
                                    root.pin = ""
                                } else {
                                    root.pin += modelData
                                }
                            }
                        }
                    }

                    PlasmaComponents.Label {
                        visible: modelData !== "R" && modelData !== "E"
                        text: modelData
                        anchors.centerIn: parent
                        font.pointSize: 16
                    }

                    PlasmaCore.IconItem {
                        visible: modelData === "R"
                        anchors.centerIn: parent
                        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                        source: "edit-clear"
                    }

                    PlasmaCore.IconItem {
                        visible: modelData === "E"
                        anchors.centerIn: parent
                        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                        source: "go-next"
                    }
                }
            }
        }
    }
}

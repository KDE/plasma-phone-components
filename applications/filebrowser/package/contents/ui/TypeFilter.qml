/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

import QtQuick 1.1
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Column {

    property string currentType


    PlasmaComponents.Label {
        text: "<b>"+i18n("File types")+"</b>"
    }
    PlasmaComponents.ButtonColumn {
        spacing: 4
        anchors {
            left: parent.left
            leftMargin: theme.defaultFont.mSize.width
        }

        Repeater {
            model: PlasmaCore.SortFilterModel {
                id:sortmod
                sourceModel: MetadataModels.MetadataCloudModel {
                    id: typesCloudModel
                    cloudCategory: "rdf:type"
                    resourceType: "nfo:FileDataObject"
                    minimumRating: metadataModel.minimumRating
                    allowedCategories: userTypes.userTypes
                }
                sortRole: "count"
                sortOrder: Qt.DescendingOrder
            }
            delegate: PlasmaComponents.RadioButton {
                text: i18n("%1 (%2)", userTypes.typeNames[model["label"]], model["count"])
                //FIXME: more elegant way to remove applications?
                visible: model["label"] != undefined && model["label"] != "nfo:Application"
                onCheckedChanged: {
                    if (checked) {
                        categoryCheckedTimer.restart()
                    }
                }
                onClicked: currentType = model["label"]
                //FIXME: is there a better way that a timer?
                Timer {
                    id: categoryCheckedTimer
                    running: true
                    onTriggered: {
                        if (currentType == model["label"] || !currentType) {
                            checked = true
                            metadataModel.resourceType = model["label"]
                        }
                    }
                }
            }
            Component.onCompleted: {
                children[0].checked = true
                currentType = children[0].model["label"]
            }
        }
    }
}

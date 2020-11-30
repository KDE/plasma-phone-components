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

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.kirigami 2.12 as Kirigami

Control {
    id: quickSettingsPanel
    
    // 0 - closed, 1 - pinned settings visible, 2 - all settings visible
    property double stateGradient
    
    property int quickSettingSize: Kirigami.Units.gridUnit * 3
    property double allSettingsOpacity: stateGradient > 1 ? stateGradient - 1 : 0
    
    property int pinnedColumns: 6 // number of columns when pinned settings are visible
    property int columns: 4 // number of columns when all settings are visible
    // TODO cap the number of rows
    
    implicitWidth: parent.implicitWidth
    height: {
        let baseHeight = quickSettingSize + Kirigami.Units.gridUnit * 2;
        if (stateGradient <= 1) {
            return baseHeight;
        } else {
            return baseHeight + (quickSettingSize * 8.5 - baseHeight) * (stateGradient - 1);
        }
    }
    implicitHeight: height
    clip: true
    
    leftPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing

    // panel background
    background: Rectangle {
        id: container
        color: Kirigami.ColorUtils.adjustColor(PlasmaCore.Theme.backgroundColor, {"alpha": 0.9*255})
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.rightMargin: Kirigami.Units.largeSpacing
        radius: PlasmaCore.Units.smallSpacing
    }
    
    QuickSettings {
        id: quickSettings
        onCloseRequested: {
            slidingPanel.hide()
        }
    }
    
    // actual panel contents
    contentItem: ColumnLayout {
        id: panelContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Kirigami.Units.largeSpacing * 2
        property int iconSpacing: {
            if (quickSettingsPanel.stateGradient <= 1) {
                return (panelContent.width - quickSettingsPanel.quickSettingSize * quickSettingsPanel.pinnedColumns) / quickSettingsPanel.pinnedColumns;
            } else {
                let columnNum = quickSettingsPanel.pinnedColumns + (stateGradient - 1) * (quickSettingsPanel.columns - quickSettingsPanel.pinnedColumns);
                return (panelContent.width - quickSettingsPanel.quickSettingSize * columnNum) / quickSettingsPanel.pinnedColumns;
            }
        }
        spacing: iconSpacing
        
        // pinned row of delegates
        RowLayout {
            spacing: panelContent.iconSpacing
            Repeater {
                model: quickSettings.model
                delegate: QuickSettingsDelegate {
                    id: delegateItem
                    size: quickSettingsPanel.quickSettingSize
                    // TODO FIGURE OUT WHY VIEWINDEX DOESNT WORK
                    visible: index < quickSettingsPanel.pinnedColumns // ignore elements after
                    opacity: index >= quickSettingsPanel.columns ? (1 - (quickSettingsPanel.stateGradient - 1)) : 1
                    textVisibility: quickSettingsPanel.allSettingsOpacity
                    
                    Connections {
                        target: delegateItem
                        onCloseRequested: quickSettings.closeRequested();
                    }
                    Connections {
                        target: quickSettings
                        onClosed: delegateItem.panelClosed();
                    }
                }
            }
        }
        
        // rest of the delegates
        GridLayout {
            Layout.fillWidth: true
            columnSpacing: panelContent.iconSpacing
            rowSpacing: panelContent.iconSpacing
            columns: quickSettingsPanel.columns
            opacity: quickSettingsPanel.allSettingsOpacity
            
            Repeater {
                visible: quickSettingsPanel.stateGradient > 1
                
                model: quickSettings.model
                delegate: QuickSettingsDelegate {
                    id: delegateItem
                    size: quickSettingsPanel.quickSettingSize
                    visible: index >= quickSettingsPanel.columns // ignore first row (already rendered above)
                    textVisibility: quickSettingsPanel.allSettingsOpacity

                    Connections {
                        target: delegateItem
                        onCloseRequested: quickSettings.closeRequested();
                    }
                    Connections {
                        target: quickSettings
                        onClosed: delegateItem.panelClosed();
                    }
                }
            }
        }

        // brightness slider
        BrightnessItem {
            visible: stateGradient > 1
            opacity: quickSettingsPanel.allSettingsOpacity
            id: brightnessSlider
            width: quickSettingsPanel.implicitWidth
            icon: "video-display-brightness"
            label: i18n("Display Brightness")
            value: quickSettings.screenBrightness
            maximumValue: quickSettings.maximumScreenBrightness
            Connections {
                target: quickSettings
                onScreenBrightnessChanged: brightnessSlider.value = quickSettings.screenBrightness
            }
        }
    }
}

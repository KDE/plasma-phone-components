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
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.kirigami 2.11 as Kirigami

Control {
    id: quickSettingsPanel
    
    // 0 - closed, 1 - pinned settings visible, 2 - all settings visible
    property double stateGradient
    
    property int quickSettingSize: units.iconSizes.large + units.smallSpacing
    property double allSettingsOpacity: stateGradient > 1 ? stateGradient - 1 : 0
    
    property int pinnedColumns: 6 // number of columns when pinned settings are visible
    property int columns: 4 // number of columns when all settings are visible
    // TODO cap the number of rows
    
    implicitWidth: parent.implicitWidth
    implicitHeight: {
        let baseHeight = quickSettingSize + Kirigami.Units.smallSpacing * 2;
        if (stateGradient <= 1) {
            return baseHeight;
        } else {
            return baseHeight + (panelContent.height - baseHeight) * (stateGradient - 1);
        }
    }
    
    leftPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing

    // panel background
    background: Rectangle {
        id: container
        color: Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.backgroundColor, {"alpha": 0.85*255})
        anchors {
            fill: parent
            leftMargin: PlasmaCore.Units.smallSpacing
            rightMargin: PlasmaCore.Units.smallSpacing
            topMargin: PlasmaCore.Units.smallSpacing
            bottomMargin: PlasmaCore.Units.smallSpacing
        }
        radius: PlasmaCore.Units.smallSpacing
        
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 5
            samples: 6
            verticalOffset: 1
        }
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
        anchors.fill: parent
        anchors.margins: PlasmaCore.units.smallSpacing
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
            spacing: iconSpacing
            Repeater {
                model: quickSettings.model
                delegate: QuickSettingsDelegate {
                    id: delegateItem
                    size: quickSettingsPanel.quickSettingSize
                    visible: index < quickSettingsPanel.pinnedColumns // ignore elements after
                    opacity: index >= quickSettingsPanel.columns ? (1 - (quickSettingsPanel.stateGradient - 1)) : 1
                    textVisibility: quickSettingsPanel.allSettingsOpacity
                    
                    Connections {
                        target: delegateItem
                        onCloseRequested: root.closeRequested();
                    }
                    Connections {
                        target: root
                        onClosed: delegateItem.panelClosed();
                    }
                }
            }
        }
        
        // rest of the delegates
        GridLayout {
            columnSpacing: iconSpacing
            rowSpacing: iconSpacing
            
            columns: quickSettingsPanel.columns
            
            Repeater {
                visible: quickSettingsPanel.stateGradient > 1
                opacity: quickSettingsPanel.allSettingsOpacity
                
                model: quickSettings.model
                delegate: QuickSettingsDelegate {
                    id: delegateItem
                    size: quickSettingsPanel.quickSettingSize
                    visible: index >= columns // ignore first row (already rendered above)
                    textVisibility: quickSettingsPanel.allSettingsOpacity

                    Connections {
                        target: delegateItem
                        onCloseRequested: root.closeRequested();
                    }
                    Connections {
                        target: root
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
            width: panelContent.width
            icon: "video-display-brightness"
            label: i18n("Display Brightness")
            value: root.screenBrightness
            maximumValue: root.maximumScreenBrightness
            Connections {
                target: root
                onScreenBrightnessChanged: brightnessSlider.value = root.screenBrightness
            }
        }
    }
}

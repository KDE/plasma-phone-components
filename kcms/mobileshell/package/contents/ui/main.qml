/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.3 as KCM

KCM.SimpleKCM {
    id: root

    title: i18n("Shell")

    Flickable {
        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right

            Kirigami.FormLayout {
                id: form
                wideMode: false
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing
                Layout.maximumWidth: root.width - Layout.leftMargin - Layout.rightMargin
                
                QQC2.CheckBox {
                    Kirigami.FormData.label: i18n("Vibrations:")
                    Layout.maximumWidth: form.width
                    text: checked ? i18n("On") : i18n("Off")
                    checked: kcm.vibrationsEnabled
                    onCheckStateChanged: {
                        if (checked != kcm.vibrationsEnabled) {
                            kcm.vibrationsEnabled = checked;
                        }
                    }
                }
            }
        }
    }
}

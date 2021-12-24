/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtFeedback 5.0

import org.kde.kirigami 2.19 as Kirigami

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

QtObject {
    id: root

    function vibrate() {
        if (MobileShell.MobileShellSettings.vibrationsEnabled) {
            hapticsEffect.start();
        }
    }
    
    property var hapticsEffect: HapticsEffect {
        intensity: 0.5
        duration: Kirigami.Units.shortDuration
    }
}

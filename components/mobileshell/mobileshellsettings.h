/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>
#include <QObject>

class MobileShellSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool vibrationsEnabled READ vibrationsEnabled NOTIFY vibrationsEnabledChanged)

public:
    static MobileShellSettings *self();

    MobileShellSettings(QObject *parent = nullptr);

    bool vibrationsEnabled() const;

Q_SIGNALS:
    void vibrationsEnabledChanged();

private:
    KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};

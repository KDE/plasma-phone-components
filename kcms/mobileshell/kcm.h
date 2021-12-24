/**
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KQuickAddons/ManagedConfigModule>

#include "mobileshellsettings.h"

class KCMMobileShell : public KQuickAddons::ManagedConfigModule
{
    Q_OBJECT
    Q_PROPERTY(bool vibrationsEnabled READ vibrationsEnabled WRITE setVibrationsEnabled NOTIFY vibrationsEnabledChanged)

public:
    KCMMobileShell(QObject *parent, const KPluginMetaData &data, const QVariantList &args);
    virtual ~KCMMobileShell() override = default;

    bool vibrationsEnabled() const;
    void setVibrationsEnabled(bool vibrationsEnabled);

Q_SIGNALS:
    void vibrationsEnabledChanged();

private:
    KSharedConfig::Ptr m_config;
};

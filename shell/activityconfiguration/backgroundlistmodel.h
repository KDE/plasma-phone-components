/*
  Copyright (c) 2007 Paolo Capriotti <p.capriotti@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
*/

#ifndef BACKGROUNDLISTMODEL_H
#define BACKGROUNDLISTMODEL_H

#include <QAbstractListModel>
#include <QPixmap>
#include <QRunnable>
#include <QThread>

#include <KDirWatch>
#include <KFileItem>

#include <Plasma/Wallpaper>

class QEventLoop;
class KProgressDialog;

namespace Plasma
{
    class Package;
} // namespace Plasma

class ImageSizeFinder : public QObject, public QRunnable
{
    Q_OBJECT
    public:
        explicit ImageSizeFinder(const QString &path, QObject *parent = 0);
        void run();

    Q_SIGNALS:
        void sizeFound(const QString &path, const QSize &size);

    private:
        QString m_path;
};

class BackgroundListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum {
        AuthorRole = Qt::UserRole,
        ScreenshotRole,
        ResolutionRole
    };
    static const int BLUR_INCREMENT = 9;
    static const int MARGIN = 6;
    BackgroundListModel(Plasma::Wallpaper *listener, QObject *parent);
    virtual ~BackgroundListModel();

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    Plasma::Package *package(int index) const;

    void reload();
    void reload(const QStringList &selected);
    void addBackground(const QString &path);
    QModelIndex indexOf(const QString &path) const;
    virtual bool contains(const QString &bg) const;

    void setScreenshotSize(const QSize &size);
    QSize screenshotSize() const;
    int count() const {return m_packages.size();}

    void setTargetSizeHint(const QSize &size);

Q_SIGNALS:
    void countChanged();

protected Q_SLOTS:
    void removeBackground(const QString &path);
    void showPreview(const KFileItem &item, const QPixmap &preview);
    void previewFailed(const KFileItem &item);
    void sizeFound(const QString &path, const QSize &s);
    void backgroundsFound(const QStringList &paths, const QString &token);
    void processPaths(const QStringList &paths);

private:
    QSize bestSize(Plasma::Package *package) const;

    QWeakPointer<Plasma::Wallpaper> m_structureParent;
    QList<Plasma::Package *> m_packages;
    QHash<Plasma::Package *, QSize> m_sizeCache;
    QHash<Plasma::Package *, QPixmap> m_previews;
    QHash<KUrl, QPersistentModelIndex> m_previewJobs;
    KDirWatch m_dirwatch;

    QSize m_screenshotSize;
    QString m_findToken;
    QPixmap m_previewUnavailablePix;
};

class BackgroundFinder : public QThread
{
    Q_OBJECT

public:
    BackgroundFinder(Plasma::Wallpaper *structureParent, const QStringList &p);
    ~BackgroundFinder();

    QString token() const;

signals:
    void backgroundsFound(const QStringList &paths, const QString &token);

protected:
    void run();

private:
    Plasma::PackageStructure::Ptr m_structure;
    QStringList m_paths;
    QString m_token;
};

#endif // BACKGROUNDLISTMODEL_H

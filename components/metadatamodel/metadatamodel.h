/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef METADATAMODEL_H
#define METADATAMODEL_H

#include "abstractmetadatamodel.h"

#include <QDate>

#include <KFileItem>

#include <Nepomuk2/Query/Query>
#include <Nepomuk2/Query/Result>
#include <Nepomuk2/Query/QueryServiceClient>
#include <Nepomuk2/Resource>
#include <Nepomuk2/Variant>

namespace Nepomuk2 {
    class ResourceWatcher;
}



class QTimer;

class KImageCache;

class BasicQueryProvider;
class QueryThread;

/**
 * This is the main class of the Nepomuk model bindings: given a query built by assigning its properties such as queryString, resourceType, startDate etc, it constructs a model with a resource per row, with direct access of its main properties as roles.
 *
 * @author Marco Martin <mart@kde.org>
 */
class MetadataModel : public AbstractMetadataModel
{
    Q_OBJECT

    /**
     * @property int optional limit to cut off the results
     */
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)

    /**
     * load as less resources as possible from Nepomuk (only load when asked from the view)
     * default is true, you shouldn't need to change it.
     * if lazyLoading is false the results are live-updating, but will take a lot more system resources
     */
    Q_PROPERTY(bool lazyLoading READ lazyLoading WRITE setLazyLoading NOTIFY lazyLoadingChanged)

    /**
     * Use this property to specify the size of thumbnail which the model should attempt to generate for the thumbnail role.
     */
    Q_PROPERTY(QSize thumbnailSize READ thumbnailSize WRITE setThumbnailSize NOTIFY thumbnailSizeChanged)

    Q_PROPERTY(BasicQueryProvider *queryProvider READ queryProvider WRITE setQueryProvider NOTIFY queryProviderChanged)

public:
    enum Roles {
        Label = Qt::UserRole+1,
        Description,
        Types,
        ClassName,
        GenericClassName,
        HasSymbol,
        Icon,
        Thumbnail,
        IsFile,
        Exists,
        Rating,
        NumericRating,
        ResourceUri,
        ResourceType,
        MimeType,
        Url,
        Tags,
        TagsNames
    };

    MetadataModel(QObject *parent = 0);
    ~MetadataModel();

    void setQuery(const Nepomuk2::Query::Query &query);
    Nepomuk2::Query::Query query() const;

    void setQueryProvider(BasicQueryProvider *provider);
    BasicQueryProvider *queryProvider() const;

    virtual int count() const {return m_resources.count();}

    void setLazyLoading(bool size);
    bool lazyLoading() const;

    void setLimit(int limit);
    int limit() const;

    void setThumbnailSize(const QSize &size);
    QSize thumbnailSize() const;

    //Reimplemented
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    /**
     * Reimplemented
     * Just signal QSortFilterProxyModel to do the real sorting.
     * Use this class as parameter to QSortFilterProxyModel->setSourceModel (C++) or
     * PlasmaCore.SortFilterModel.sourceModel (QML) to get the real sorting.
     * WARNING: avoid putting this model into SortFilterModel if possible:
     * it would cause loading every single item of the model,
     * while for big models we want lazy loading.
     * rely on its internal sorting feature instead.
     * @see sortBy
     */
    Q_INVOKABLE void sort(int column, Qt::SortOrder order = Qt::AscendingOrder);

    /**
     * Compatibility with ListModel
     * @returns an Object that represents the item with all roles as properties
     */
    Q_INVOKABLE QVariantHash get(int row) const;

Q_SIGNALS:
    void queryProviderChanged();
    void limitChanged();
    void lazyLoadingChanged();
    void thumbnailSizeChanged();

protected Q_SLOTS:
    void countQueryResult(const QList< Nepomuk2::Query::Result > &entries);
    void newEntries(const QList< Nepomuk2::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    virtual void doQuery();
    void newEntriesDelayed();
    void finishedListing();
    void propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val);
    void showPreview(const KFileItem &item, const QPixmap &preview);
    void previewFailed(const KFileItem &item);
    void delayedPreview();

protected:
    void fetchResultsPage(int page);

private:
    QueryThread *m_queryThread;

    Nepomuk2::Query::Query m_query;
    //mapping page->query client
    QHash<int, Nepomuk2::Query::QueryServiceClient *> m_queryClients;
    //mapping query client->page
    QHash<Nepomuk2::Query::QueryServiceClient *, int> m_pagesForClient;
    //where is the last valid (already populated) index for a given page
    QHash<int, int> m_validIndexForPage;
    //keep always running at most 10 clients, get rid of the old ones
    //won't be possible to monitor forresources going away, but is too heavy
    QList<Nepomuk2::Query::QueryServiceClient *> m_queryClientsHistory;
    //how many service clients are running now?
    int m_runningClients;
    //client that only knows how much results there are
    Nepomuk2::Query::QueryServiceClient *m_countQueryClient;

    Nepomuk2::ResourceWatcher* m_watcher;
    QVector<Nepomuk2::Resource> m_resources;
    QHash<int, QList<Nepomuk2::Resource> > m_resourcesToInsert;
    QHash<QUrl, int> m_uriToResourceIndex;
    QTimer *m_newEntriesTimer;
    QTime m_elapsedTime;

    //pieces to build m_query
    int m_limit;
    int m_pageSize;

    //previews
    QTimer *m_previewTimer;
    QHash<KUrl, QPersistentModelIndex> m_filesToPreview;
    QSize m_thumbnailSize;
    QHash<KUrl, QPersistentModelIndex> m_previewJobs;
    KImageCache* m_imageCache;
    QStringList* m_thumbnailerPlugins;

    QHash<Nepomuk2::Resource, QHash<int, QVariant> > m_cachedResources;

    QWeakPointer<BasicQueryProvider> m_queryProvider;
};

#endif

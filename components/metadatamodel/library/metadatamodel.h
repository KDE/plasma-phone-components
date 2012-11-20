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

#include "nepomukdatamodel_export.h"

#include <QAbstractListModel>
#include <QDate>

#include <Nepomuk2/Query/Query>
#include <Nepomuk2/Query/Result>
#include <Nepomuk2/Query/QueryServiceClient>
#include <Nepomuk2/Resource>
#include <Nepomuk2/Variant>

namespace Nepomuk2 {
    class ResourceWatcher;
}


class QDBusServiceWatcher;
class QTimer;

class AbstractQueryProvider;
class QueryThread;

class MetadataModelPrivate;

/**
 * This is the main class of the Nepomuk model bindings: given a query built by assigning its properties such as queryString, resourceType, startDate etc, it constructs a model with a resource per row, with direct access of its main properties as roles.
 *
 * @author Marco Martin <mart@kde.org>
 */
class NEPOMUKDATAMODEL_EXPORT MetadataModel : public QAbstractListModel
{
    Q_OBJECT

    /**
     * @property int the total number of rows in this model
     */
    Q_PROPERTY(int count READ count NOTIFY countChanged)

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
     * @property int Total count of resource items: this is not the number of rows of the result, but the aggregate of how many items there are for each separate item. Available when a query has a column count (integer)
     */
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)

    /**
     * @property bool running: true when queries are in execution
     */
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)

    /**
     * @property QueryProvider queryProvider: this is the class that will provide the Nepomuk query to the model and format the data of the results to obtain the final model data to be disaplayed to the user.
     */
    Q_PROPERTY(AbstractQueryProvider *queryProvider READ queryProvider WRITE setQueryProvider NOTIFY queryProviderChanged)

public:
    MetadataModel(QObject *parent = 0);
    ~MetadataModel();

    bool isRunning() const;

    void setQueryProvider(AbstractQueryProvider *provider);
    AbstractQueryProvider *queryProvider() const;

    virtual int count() const;
    int totalCount() const;

    void setLazyLoading(bool size);
    bool lazyLoading() const;

    void setLimit(int limit);
    int limit() const;

    /**
     * Request the query to be executed again refreshing the results.
     * This should be needed only when Sparql queries are used, avoid to call it when possible.
     * This methos is Asynchronous and uses event compression, so the query won't be executed immediately.
     */
    Q_INVOKABLE void requestRefresh();

    /**
     * Compatibility with the api of the primitive QML ListModel component
     * @returns an Object that represents the item with all roles as properties
     */
    Q_INVOKABLE QVariantHash get(int row) const;


    //Reimplementations of QAbstractListModel
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
    void sort(int column, Qt::SortOrder order = Qt::AscendingOrder);

    //Reimplemented
    int rowCount(const QModelIndex &parent) const;

Q_SIGNALS:
    void countChanged();
    void runningChanged(bool running);
    void totalCountChanged();
    void queryProviderChanged();
    void limitChanged();
    void lazyLoadingChanged();

protected Q_SLOTS:
    void countRetrieved(int count);
    void newEntries(const QList< Nepomuk2::Query::Result > &entries, int page);
    void entriesRemoved(const QList<QUrl> &urls);
    void doQuery();
    void newEntriesDelayed();
    void propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val);
    void dataFormatChanged(const QPersistentModelIndex &index);
    void serviceRegistered(const QString &service);

protected:
    void fetchResultsPage(int page);

private:
    MetadataModelPrivate *const d;
};

#endif

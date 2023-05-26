/*
 * This file is part of harbour-laundry.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import io.thp.pyotherside 1.5
import "pages"

ApplicationWindow {
    id: main
    readonly property string appName: qsTr("Laundry")

    readonly property string dateFormat: qsTr("d M yyyy")
    readonly property alias dataModel: _sortedModel
    readonly property alias rawModel: _sourceModel
    readonly property string currentFilter: _sortedModel.currentFilter

    property bool hideUnused: false
    property var currentFilterRegex: new RegExp('', 'i')
    onCurrentFilterChanged: {
        var search = currentFilter.replace(/([-.[\](){}\\*?*^$|])/g, "\\$1")
        currentFilterRegex = new RegExp(search, 'i')
    }

    property string todayBatchDate
    property bool loading: true  // only true during startup
    property var defaultItemsModel: ListModel {}

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ListModel {
        id: _sourceModel
    }

    SortFilterProxyModel {
        id: _sortedModel
        sourceModel: _sourceModel

        property string currentFilter

        sorters: [
            RoleSorter {
                roleName: "batchDate"
                ascendingOrder: false
            },
            RoleSorter {
                roleName: "batchId"
                ascendingOrder: false
            },
            StringSorter {
                roleName: "label"
            },
            ExpressionSorter {
                expression: {
                    modelLeft.fetched >= modelLeft.out && modelLeft.out > 0
                }
            }
        ]

        filters: [
            ExpressionFilter {
                enabled: hideUnused
                expression: model.out === 0 && model.fetched === 0
                inverted: true
            },
            AnyOf {
                enabled: _sortedModel.currentFilter !== ''

                RegExpFilter {
                    roleName: "label"
                    pattern: _sortedModel.currentFilter
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: RegExpFilter.Wildcard
                }
                RegExpFilter {
                    roleName: "batchDate"
                    pattern: _sortedModel.currentFilter
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: RegExpFilter.Wildcard
                }
                RegExpFilter {
                    roleName: "batchLabel"
                    pattern: _sortedModel.currentFilter
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: RegExpFilter.Wildcard
                }
            }
        ]
    }

    Python {
        id: py

        onReceived: {
            console.log(data)
        }

        onError: {
            loading = false
            console.error("an error occurred in the Python backend, traceback:")
            console.error(traceback)
        }

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('py'));

            setHandler('batch-items', function(result) {
                if (result.length > 0) loading = false

                for (var i = 0; i < result.length; i++) {
                    _sourceModel.append(result[i]);
                }

                print("adding", result.length, "item(s) to the list")
            })

            setHandler('default-items', function(result){
                defaultItemsModel.clear()

                for (var i in result) {
                    defaultItemsModel.append({'label': result[i]})
                }
            })

            setHandler('today-batch-date', function(result) {
                todayBatchDate = result
            })

            importModule('laundry', function () {
                py.call('laundry.get_items', [StandardPaths.data], function(result) {
                    loading = false
                });
            });
        }
    }

    function filter(text) {
        _sortedModel.currentFilter = text
    }

    function addNewBatch() {
        py.call('laundry.get_new_batch', [StandardPaths.data])
    }

    function addNewItem(item) {
        py.call('laundry.add_item', [StandardPaths.data, item])
    }

    function setOutCount(batchDate, batchId, item, count) {
        // "~~" to convert float to int: https://stackoverflow.com/a/34077466
        // even though the value is an integer, SortFilterProxyModel.get converts it to float
        py.call('laundry.set_out_count', [StandardPaths.data, batchDate, ~~batchId, item, ~~count])
    }

    function setFetchedCount(batchDate, batchId, item, count) {
        py.call('laundry.set_fetched_count', [StandardPaths.data, batchDate, ~~batchId, item, ~~count])
    }

    function setMissing(batchDate, batchId, item, missing) {
        py.call('laundry.set_missing', [StandardPaths.data, batchDate, ~~batchId, item, missing])
    }

    function fetchDefaultItems() {
        py.call('laundry.get_default_items', [StandardPaths.data])
    }

    function removeItem(batchDate, batchId, item) {
        py.call('laundry.remove_item', [StandardPaths.data, batchDate, ~~batchId, item])
    }

    function renameItem(batchDate, batchId, item, newName) {
        py.call('laundry.rename_item', [StandardPaths.data, batchDate, ~~batchId, item, newName])
    }

    Component.onCompleted: {
        console.log("Version:", APP_VERSION, APP_RELEASE)
    }
}

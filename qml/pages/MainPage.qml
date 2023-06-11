/*
 * This file is part of harbour-laundry.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    readonly property int outerButtonWidth: Math.floor(parent.width / 3)
    readonly property int innerButtonWidth: Math.ceil(parent.width / 6)

    TextMetrics {
        id: metrics
        text: "99"
        font.pixelSize: Theme.fontSizeExtraLarge
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        property real textLeftMargin: Theme.horizontalPageMargin

        VerticalScrollDecorator { flickable: listView }

        PullDownMenu {
            flickable: listView

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: main.hideUnused ? qsTr("Show unused items") : qsTr("Hide unused items")
                visible: main.rawModel.count > 0 && main.dataModel.get(0)['batchDate'] == main.todayBatchDate
                onClicked: main.hideUnused = !main.hideUnused
            }
            MenuItem {
                text: qsTr("New item")
                onClicked: {
                    var initialText = ''

                    if (listView.model.count === 0 && main.currentFilter !== '') {
                        initialText = main.currentFilter
                    }

                    pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), {'initialText': initialText})
                }
            }
            MenuItem {
                text: qsTr("New batch")
                visible: main.defaultItemsModel.count > 0
                onDelayedClick: {
                    main.addNewBatch()
                    main.hideUnused = false
                }
            }
        }

        PushUpMenu {
            flickable: listView
            enabled: visible
            visible: main.rawModel.count > 0

            // TODO find a way to enable the menu only if there actually are
            //      old entries; below method doesn't work because adding a new
            //      batch will add it at the and of the model
            // visible: main.rawModel.count > 0 &&
            //          main.rawModel.get(main.rawModel.count - 1)['batchDate'] !== main.todayBatchDate

            MenuItem {
                text: main.hideOld ? qsTr("Show archived entries") : qsTr("Hide archived entries")
                onClicked: {
                    listView.scrollToTop()
                    main.hideOld = !main.hideOld
                    listView.scrollToTop()
                }
            }
        }

        header: Item {
            anchors {
                left: parent.left
                right: parent.right
            }

            height: header.height + searchField.height

            PageHeader {
                id: header
                title: main.appName
            }

            SearchField {
                id: searchField
                anchors.top: header.bottom
                width: parent.width
                placeholderText: qsTr("Filter")
                inputMethodHints: Qt.ImhNoPredictiveText
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: main.filter(searchField.text)
                onTextChanged: main.filter(searchField.text)
                Component.onCompleted: listView.textLeftMargin = textLeftMargin

                Connections {
                    target: main
                    onCurrentFilterChanged: {
                        if (main.currentFilter != searchField.text) {
                            searchField.text = main.currentFilter
                        }
                    }
                }
            }
        }

        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }

        ViewPlaceholder {
            id: filterPlaceholder
            enabled: listView.model.count === 0 && main.currentFilter !== ''
            text: qsTr("No match")
            hintText: qsTr("Pull down to add a new item to the list.")
            verticalOffset: -listView.originY - height
        }

        ViewPlaceholder {
            id: emptyPlaceholder
            enabled: listView.model.count === 0 && !filterPlaceholder.enabled && !busyPlaceholder.enabled
            text: qsTr("No laundry")
            hintText: main.defaultItemsModel.count === 0 ?
                          qsTr("Pull down to add items.") :
                          qsTr("Pull down to add a batch.")
            verticalOffset: -listView.originY - height
        }

        ViewPlaceholder {
            id: busyPlaceholder
            enabled: main.loading
            verticalOffset: -listView.originY - height

            BusyIndicator {
                anchors.centerIn: parent
                running: parent.enabled
                size: BusyIndicatorSize.Large
            }
        }

        // prevent newly added list delegates from stealing focus away from the search field
        currentIndex: -1

        model: main.dataModel

        section.property: "section"
        section.delegate: ListSectionHeader {}

        delegate: ListItem {
            id: item
            contentHeight: Theme.itemSizeSmall

            property string label: model.label
            property int out: model.out
            property int fetched: model.fetched
            property bool missing: model.missing

            property string batchDate: model.batchDate
            property int batchId: model.batchId

            highlighted: false
            _backgroundColor: 'transparent'

            menu: ContextMenu {
                Row {
                    height: Theme.itemSizeMedium
                    width: parent.width

                    MenuCounter { relatedCounter: btnOutPlus }
                    MenuCounter { relatedCounter: btnOutMinus }
                    MenuCounter { relatedCounter: btnInMinus }
                    MenuCounter { relatedCounter: btnInPlus }
                }
                MenuItem {
                    text: missing ? qsTr("Found!") : qsTr("Missing!")
                    onDelayedClick: {
                        main.rawModel.setProperty(main.dataModel.mapToSource(index), "missing", !missing)
                        main.setMissing(item.batchDate, item.batchId, item.label, item.missing)
                    }
                }
                MenuItem {
                    text: qsTr("Rename")
                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl("AddItemDialog.qml"), {
                            'initialText': item.label,
                            'doRename': true,
                            'renameBatchDate': item.batchDate,
                            'renameBatchId': item.batchId
                        })

                        dialog.accepted.connect(function() {
                            if (!dialog.finalText) return
                            main.rawModel.setProperty(main.dataModel.mapToSource(index), "label", dialog.finalText)
                            main.filter(dialog.finalText)
                        })
                    }
                }
                MenuItem {
                    text: qsTr("Remove")
                    onClicked: {
                        main.removeItem(item.batchDate, item.batchId, item.label)
                        main.rawModel.remove(main.dataModel.mapToSource(index))
                    }
                }
            }

            Row {
                id: labelRow

                spacing: Theme.paddingMedium
                anchors {
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                    topMargin: Theme.paddingMedium
                    bottomMargin: Theme.paddingMedium
                    fill: parent
                }

                Label {
                    id: outLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: String(out) + (missing ? "<small> ⚠</small>" : "")
                    textFormat: Text.RichText
                    color: missing ? Theme.errorColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraLarge
                    width: Math.max(implicitWidth, metrics.width)
                    opacity: {
                        /*if (btnOutPlus.highlighted) 0.0
                        else */if (btnOutMinus.highlighted ||
                                 item.fetched >= item.out) Theme.opacityLow
                        else 1.0
                    }
                }

                Label {
                    id: itemLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: Theme.highlightText(item.label, main.currentFilterRegex, Theme.highlightColor)

                    width: parent.width - 2*parent.spacing - outLabel.width - inLabel.width
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    opacity: (btnOutPlus.highlighted ||
                              btnOutMinus.highlighted ||
                              btnInMinus.highlighted ||
                              btnInPlus.highlighted ||
                              item.fetched >= item.out) ? Theme.opacityLow : 1.0
                }

                Label {
                    id: inLabel
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: String(fetched)
                    font.pixelSize: Theme.fontSizeExtraLarge
                    width: Math.max(implicitWidth, metrics.width)

                    opacity: {
                        /*if (btnInPlus.highlighted) 0.0
                        else */if (btnInMinus.highlighted ||
                                 item.out == 0 ||
                                 item.fetched >= item.out) Theme.opacityLow
                        else 1.0
                    }
                }
            }

            Counter {
                id: btnOutPlus
                anchors.left: parent.left
                width: outerButtonWidth
                iconSource: "image://theme/icon-m-add"
                onPressAndHold: item.openMenu()

                onClicked: {
                    main.rawModel.setProperty(main.dataModel.mapToSource(index), "out", item.out + 1)
                    main.setOutCount(item.batchDate, item.batchId, item.label, item.out)
                }
            }

            Counter {
                id: btnOutMinus
                enabled: item.out > 0
                anchors.left: btnOutPlus.right
                width: innerButtonWidth
                iconSource: "image://theme/icon-m-remove"
                onPressAndHold: item.openMenu()

                onClicked: {
                    main.rawModel.setProperty(main.dataModel.mapToSource(index), "out", Math.max(0, item.out - 1))
                    main.setOutCount(item.batchDate, item.batchId, item.label, item.out)
                }
            }

            Counter {
                id: btnInMinus
                enabled: item.fetched > 0
                anchors.right: btnInPlus.left
                width: innerButtonWidth
                iconSource: "image://theme/icon-m-remove"
                onPressAndHold: item.openMenu()

                onClicked: {
                    main.rawModel.setProperty(main.dataModel.mapToSource(index), "fetched", Math.max(0, item.fetched - 1))
                    main.setFetchedCount(item.batchDate, item.batchId, item.label, item.fetched)
                }
            }

            Counter {
                id: btnInPlus
                enabled: item.fetched + 1 <= item.out
                anchors.right: parent.right
                width: outerButtonWidth
                iconSource: "image://theme/icon-m-add"
                onPressAndHold: item.openMenu()

                onClicked: {
                    main.rawModel.setProperty(main.dataModel.mapToSource(index), "fetched", item.fetched + 1)
                    main.setFetchedCount(item.batchDate, item.batchId, item.label, item.fetched)
                }
            }
        }
    }
}

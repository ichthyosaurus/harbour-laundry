/*
 * This file is part of harbour-laundry.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2

CoverBackground {
    SilicaListView {
        id: coverListView
        anchors {
            fill: parent
            margins: Theme.paddingLarge
            topMargin: Theme.paddingMedium
            bottomMargin: Theme.paddingMedium
        }

        model: SortFilterProxyModel {
            sourceModel: main.rawModel

            filters: AllOf {
                ValueFilter {
                    roleName: "out"
                    value: 0
                    inverted: true
                }
                ExpressionFilter {
                    expression: model.out > model.fetched
                }
            }

            sorters: [
                ExpressionSorter {
                    expression: !modelLeft.missing && modelRight.missing
                },
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
                }
            ]
        }

        header: Label {
            color: Theme.highlightColor
            width: coverListView.width
            text: qsTr("Laundry")
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeMedium
            visible: coverListView.count > 0
        }

        delegate: ListItem {
            anchors {
                topMargin:  Theme.paddingMedium
            }

            width: coverListView.width
            height: infoRow.height + Theme.paddingSmall
            opacity: index < 6 ? 1.0 - index * 0.15 : 0.0

            Row {
                id: infoRow
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    id: numberLabel
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    text: model.out - model.fetched
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    id: missingLabel
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeTiny
                    text: "⚠"
                    visible: model.missing
                    anchors.baseline: numberLabel.baseline
                }

                Label {
                    width: infoRow.width - numberLabel.width - missingLabel.width
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: model.label
                    truncationMode: TruncationMode.Fade
                    anchors.baseline: numberLabel.baseline
                }
            }
        }

        Label {
            visible: coverListView.count === 0
            color: Theme.secondaryHighlightColor
            font.pixelSize: Theme.fontSizeLarge
            text: qsTr("No laundry today")
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }

    CoverActionList {
        enabled: coverListView.count > 0

        CoverAction {
            iconSource: "../images/icon-cover-mark-ok.png"
            onTriggered: {
                var item = coverListView.model.get(0)

                if (item['missing'] && item['fetched'] + 1 >= item['out']) {
                    main.rawModel.setProperty(coverListView.model.mapToSource(0), "missing", !item['missing'])
                    main.setMissing(item['batchDate'], item['batchId'], item['label'], !item['missing'])
                }

                main.rawModel.setProperty(coverListView.model.mapToSource(0), "fetched", item['fetched'] + 1)
                main.setFetchedCount(item['batchDate'], item['batchId'], item['label'], item['fetched'] + 1)
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: {
                var item = coverListView.model.get(0)
                main.rawModel.setProperty(coverListView.model.mapToSource(0), "missing", !item['missing'])
                main.setMissing(item['batchDate'], item['batchId'], item['label'], !item['missing'])
            }
        }
    }
}

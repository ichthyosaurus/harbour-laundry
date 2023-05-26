/*
 * This file is part of harbour-laundry.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2

Dialog {
    id: root
    allowedOrientations: Orientation.All

    property bool doRename: false
    property string renameBatchDate
    property int renameBatchId

    property string initialText
    property var _suggestionRegex: new RegExp('', 'i')
    readonly property string finalText: input.text.trim()

    canAccept: finalText.length > 0
    onAccepted: {
        if (doRename) {
            main.renameItem(renameBatchDate, renameBatchId, initialText, finalText)
            // filter after renaming the item in the model
        } else {
            main.addNewItem(finalText)
            main.filter(finalText)
        }

        if (main.rawModel.count === 0) {
            main.addNewBatch()
            main.fetchDefaultItems()
        }
    }

    SortFilterProxyModel {
        id: suggestionsModel
        sourceModel: finalText != '' ? main.defaultItemsModel : null
        Component.onCompleted: main.fetchDefaultItems()

        sorters: StringSorter {
            roleName: "label"
        }
        filters: RegExpFilter {
            roleName: "label"
            pattern: finalText
            caseSensitivity: Qt.CaseInsensitive
            syntax: RegExpFilter.Wildcard
        }
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: flickable }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.paddingLarge

            DialogHeader {
                id: dialogHeader
                acceptText: doRename ? qsTr("Rename") : qsTr("Add")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: doRename ? qsTr("Rename a laundry item:") : qsTr("Add a new laundry item:")
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
            }

            TextField {
                id: input
                width: parent.width
                text: initialText
                placeholderText: qsTr("Pants (dark)")
                label: qsTr("Descriptive name")
                // inputMethodHints: Qt.ImhNoPredictiveText

                EnterKey.enabled: finalText.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: if (root.canAccept) accept()

                onTextChanged: {
                    var search = text.replace(/([-.[\](){}\\*?*^$|])/g, "\\$1")
                    root._suggestionRegex = new RegExp(search, 'i')
                }

                rightItem: IconButton {
                    width: icon.width + 2*Theme.paddingMedium
                    height: icon.height
                    enabled: input.text != ''
                    onClicked: input.text = ''
                    icon.source: "image://theme/icon-splus-clear"
                }

                Component.onCompleted: forceActiveFocus()
            }

            SilicaListView {
                id: suggestionsView
                width: parent.width
                height: Math.min(limitResults + 1, count) * Theme.itemSizeSmall

                readonly property int defaultLimit: 3
                property int limitResults: defaultLimit

                onCountChanged: {
                    if (count != limitResults) {
                        limitResults = defaultLimit
                    }
                }

                clip: true
                quickScroll: false
                interactive: false  // prevent scrolling

                model: suggestionsModel

                delegate: ListItem {
                    contentHeight: Theme.itemSizeSmall
                    onClicked: input.text = model.label
                    visible: index < suggestionsView.limitResults

                    Label {
                        anchors {
                            margins: Theme.horizontalPageMargin
                            fill: parent
                        }
                        text: Theme.highlightText(model.label, root._suggestionRegex, Theme.highlightColor)
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                footerPositioning: ListView.OverlayFooter
                footer: BackgroundItem {
                    width: parent.width
                    height: Theme.itemSizeSmall

                    property int remaining: Math.max(0, suggestionsView.count - suggestionsView.limitResults)
                    visible: remaining > 0

                    onClicked: suggestionsView.limitResults = suggestionsView.count

                    Label {
                        anchors {
                            fill: parent
                            margins: Theme.horizontalPageMargin
                        }

                        text: qsTr("... and %n more", "", remaining)
                        truncationMode: TruncationMode.Fade
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: qsTr("Note: as the laundry list is sorted alphabetically, " +
                           "it is recommended to group items by type and add " +
                           "details in brackets." +
                           "\n\n\tExample:" +
                           "\n\t\tPants (dark)" +
                           "\n\t\tPants (light)" +
                           "\n\n\tinstead of:" +
                           "\n\t\tdark pants" +
                           "\n\t\tlight pants")
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}

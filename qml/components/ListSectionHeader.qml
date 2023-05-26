/*
 * This file is part of harbour-laundry.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

Column {
    spacing: Theme.paddingSmall
    x: Theme.horizontalPageMargin
    topPadding: Theme.paddingMedium
    bottomPadding: Theme.paddingMedium
    width: (parent ? parent.width : Screen.width) - 2*x
    height: Theme.itemSizeMedium

    Label {
        width: parent.width
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignTop
        font.pixelSize: Theme.fontSizeSmall
        truncationMode: TruncationMode.Fade
        color: Theme.highlightColor

        property var parts: String(section).split('|')
        property string date: new Date(parts[0]).toLocaleString(Qt.locale(), main.dateFormat)
        property string label: parts.slice(2).join('|')
        text: date + (label != '' ? ('\n' + label) : '')
    }

    Row {
        id: columnHeaders
        width: parent.width

        Label {
            width: parent.width / 2
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryHighlightColor
            text: qsTr("Out")
        }

        Label {
            width: parent.width / 2
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryHighlightColor
            text: qsTr("Fetched")
        }
    }
}

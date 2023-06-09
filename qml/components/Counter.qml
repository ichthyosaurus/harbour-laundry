/*
 * This file is part of harbour-laundry.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

SilicaControl {
    id: root
    height: parent.height
    width: icon.width
    highlighted: button.highlighted

    property alias iconSource: icon.source
    property bool forceHighlight: false
    property int bottomMargin: Theme.paddingMedium +
                               (root.forceHighlight ? 0 : root.height)

    signal pressAndHold(var mouse)
    signal clicked(var mouse)

    BackgroundItem {
        id: button
        anchors.fill: parent
        highlighted: root.forceHighlight || down
        contentItem.anchors.bottom: button.bottom
        contentHeight: root.forceHighlight
                       ? root.height : 2 * root.height

        onPressAndHold: root.pressAndHold(mouse)
        onClicked: root.clicked(mouse)
    }

    HighlightImage {
        id: icon
        source: "image://theme/icon-m-add"
        opacity: button.highlighted ? 1.0 : 0.0
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: button.bottom
            bottomMargin: root.bottomMargin
        }
    }
}

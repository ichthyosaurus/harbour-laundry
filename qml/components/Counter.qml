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

    property int iconPosition
    property alias iconSource: icon.source
    property bool forceHighlight: false

    signal pressAndHold(var mouse)
    signal clicked(var mouse)

    BackgroundItem {
        id: button
        anchors.fill: parent
        highlighted: root.forceHighlight || down

        onPressAndHold: root.pressAndHold(mouse)
        onClicked: root.clicked(mouse)
    }

    HighlightImage {
        id: icon
        source: "image://theme/icon-m-add"
        opacity: button.highlighted ? 1.0 : 0.0
        anchors {
            verticalCenter: parent.verticalCenter
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }

        states: [
            State {
                when: iconPosition == Qt.LeftToRight
                AnchorChanges {
                    target: icon
                    anchors.left: parent.left
                    anchors.right: undefined
                }
            },
            State {
                when: iconPosition == Qt.RightToLeft
                AnchorChanges {
                    target: icon
                    anchors.left: undefined
                    anchors.right: parent.right
                }
            }
        ]
    }
}

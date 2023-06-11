import QtQuick 2.6
import Sailfish.Silica 1.0

IconButton {
    property Counter relatedCounter

    width: parent.width / 4
    height: parent.height
    icon.source: relatedCounter.iconSource
    onClicked: relatedCounter.clicked(null)
    enabled: relatedCounter.enabled
}

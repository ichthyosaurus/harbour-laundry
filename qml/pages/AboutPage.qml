/*
 * This file is part of harbour-laundry.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * Translators:
 * Please add yourself to the list of translators in TRANSLATORS.json.
 * If your language is already in the list, add your name to the 'entries'
 * field. If you added a new translation, create a new section in the 'extra' list.
 *
 * Other contributors:
 * Please add yourself to the relevant list of contributors below.
 *
*/

import QtQuick 2.0
import Sailfish.Silica 1.0 as S
import Opal.About 1.0 as A

A.AboutPageBase {
    id: root

    appName: appWindow.appName
    appIcon: Qt.resolvedUrl("../images/%1.png".arg(Qt.application.name))
    appVersion: APP_VERSION
    appRelease: APP_RELEASE

    allowDownloadingLicenses: false
    sourcesUrl: "https://github.com/ichthyosaurus/%1".arg(Qt.application.name)
    homepageUrl: "https://forum.sailfishos.org/t/apps-by-ichthyosaurus/15753"
    translationsUrl: "https://hosted.weblate.org/projects/%1".arg(Qt.application.name)
    changelogList: Qt.resolvedUrl("../Changelog.qml")
    licenses: A.License { spdxId: "GPL-3.0-or-later" }

    donations.text: donations.defaultTextCoffee
    donations.services: [
        A.DonationService {
            name: "Liberapay"
            url: "https://liberapay.com/ichthyosaurus"
        }
    ]

    description: qsTr("A simple app to keep track of your laundry.")
    mainAttributions: ["2023 Mirian Margiani"]

    attributions: [
        A.Attribution {
            name: "SortFilterProxyModel"
            entries: ["2016 Pierre-Yves Siret"]
            licenses: A.License { spdxId: "MIT" }
            sources: "https://github.com/oKcerG/SortFilterProxyModel"
        },
        A.OpalAboutAttribution {}
    ]

    extraSections: [
        A.InfoSection {
            title: qsTr("Why this app?")
            text: qsTr("This app fills a very specific niche.")
            smallPrint: qsTr("If you live in an apartment building that has " +
                             "shared washing machines and a common drying room " +
                             "for everyone, then this app may be for you. " +
                             "If sometimes laundry happens to mysteriously disappear " +
                             "from these places, then this app helps you keep track of " +
                             "questions like “How many items have I washed?” and " +
                             "“How many pieces did I already fetch from the dryer?”.")
        },
        A.InfoSection {
            title: qsTr("Grocery list")
            text: qsTr("This app can be used for different purposes.")
            smallPrint: qsTr("Apart from its original use-case, this app proved to " +
                             "be quite useful as a grocery list. I am currently planning " +
                             "a new version for shopping with mostly cosmetic changes.")
        }

    ]

    contributionSections: [
        A.ContributionSection {
            title: qsTr("Development")
            groups: [
                A.ContributionGroup {
                    title: qsTr("Programming")
                    entries: ["Mirian Margiani"]
                }
            ]
        },

        //>>> GENERATED LIST OF TRANSLATION CREDITS
        //<<< GENERATED LIST OF TRANSLATION CREDITS
    ]
}

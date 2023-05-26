/*
 * This file is part of harbour-laundry.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0 as S
import "../modules/Opal/About" as A

A.AboutPageBase {
    id: page
    allowedOrientations: S.Orientation.All

    appName: main.appName
    appIcon: Qt.resolvedUrl("../images/harbour-laundry.png")
    appVersion: APP_VERSION
    appRelease: APP_RELEASE
    description: qsTr("A simple app to keep track of your laundry.")
    allowDownloadingLicenses: false

    mainAttributions: ["2023 Mirian Margiani"]
    sourcesUrl: "https://github.com/ichthyosaurus/harbour-laundry"
    homepageUrl: "https://forum.sailfishos.org/t/apps-by-ichthyosaurus/15753"
    // translationsUrl: "https://github.com/ichthyosaurus/harbour-laundry"  // TODO move to Weblate

    licenses: A.License { spdxId: "GPL-3.0-or-later" }

    attributions: [
        A.Attribution {
            name: "SortFilterProxyModel"
            entries: ["2016 Pierre-Yves Siret"]
            licenses: A.License { spdxId: "MIT" }
            sources: "https://github.com/oKcerG/SortFilterProxyModel"
        },
        A.OpalAboutAttribution {}
    ]

    donations.text: donations.defaultTextCoffee
    donations.services: [
        A.DonationService {
            name: "LiberaPay"
            url: "https://liberapay.com/ichthyosaurus/"
        }
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

    // contributionSections: [
    //     A.ContributionSection {
    //         title: qsTr("Development")
    //         groups: [
    //             A.ContributionGroup {
    //                 title: qsTr("Programming")
    //                 entries: ["Mirian Margiani"]
    //             },
    //             A.ContributionGroup {
    //                 title: qsTr("Icon Design")
    //                 entries: ["Mirian Margiani"]
    //             }
    //         ]
    //     },
    //     A.ContributionSection {
    //         title: qsTr("Translations")
    //         groups: [
    //             A.ContributionGroup {
    //                 title: qsTr("English")
    //                 entries: ["Mirian Margiani"]
    //             },
    //             A.ContributionGroup {
    //                 title: qsTr("German")
    //                 entries: ["Mirian Margiani"]
    //             }
    //         ]
    //     }
    // ]
}

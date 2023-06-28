dnl/// SPDX-FileCopyrightText: 2023 Mirian Margiani
dnl/// SPDX-License-Identifier: GFDL-1.3-or-later

dnl///
dnl/// Notes:
dnl/// - remove unused definitions unless they must not change when the template changes
dnl/// - use ifdef(${__X_*}) with one of store, summary, description, readme, or, harbour
dnl///   to include sections conditionally
dnl///

dnl/// [PRETTY PROJECT NAME](required): set to the human-readable name of the project, e.g. "Example App"
define(${__name}, ${Laundry List})

dnl/// [PROJECT SLUG](required): set to the computer-readable name used in URLs, e.g. "harbour-example"
define(${__slug}, ${harbour-laundry})

dnl/// [PROJECT's FIRST COPYRIGHT YEAR](required)
define(${__copyright_start}, ${2023})

dnl/// [FORUM THREAD](required)
define(${__forum}, ${https://forum.sailfishos.org/t/apps-by-ichthyosaurus/15753})

dnl/// [ABOUT PAGE FILE PATH](required)
define(${__about_page}, ${qml/pages/AboutPage.qml})

dnl/// [WEBLATE PROJECT](optional): set to __slug for most apps
dnl/// define(${__weblate_project}, __slug)
define(${__weblate_project}, ${})dnl/// disable for now: projects must be at least 3 months old for Weblate

dnl/// [WEBLATE COMPONENT](required if using Weblate): ignored if Weblate is disabled
define(${__weblate_component}, ${translations})

dnl/// [SUBMODULES](optional): set to "true" to enable docs for cloning with submodules
define(${__have_submodules}, ${true})

dnl/// [PATCHES](optional): set to "true" to enable docs for applying patches
define(${__have_patches}, ${true})

dnl/// [PROJECT STATUS](optional): string for the "development" badge, either "active" or "stable"
define(${__devel_status}, ${stable})

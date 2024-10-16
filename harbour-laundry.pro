# This file is part of harbour-laundry.
# SPDX-FileCopyrightText: 2023-2024 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later

# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-laundry
CONFIG += sailfishapp c++11

# Note: version number is configured in yaml
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_RELEASE=\\\"$$RELEASE\\\"
include(libs/opal-cached-defines.pri)

QML_IMPORT_PATH += qml/modules

SOURCES += src/harbour-laundry.cpp

DISTFILES += qml/harbour-laundry.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    qml/py/laundry.py \
    qml/images/*.png \
    qml/modules/Opal/About/*.qml \
    qml/modules/Opal/About/private/*.qml \
    qml/modules/Opal/About/private/*.js \
    rpm/harbour-laundry.changes \
    rpm/harbour-laundry.spec \
    rpm/harbour-laundry.yaml \
    translations/*.ts \
    harbour-laundry.desktop \

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-laundry-*.ts

# Build submodules
include(libs/SortFilterProxyModel/SortFilterProxyModel.pri)

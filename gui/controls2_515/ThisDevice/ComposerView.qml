/*
 * Copyright (C) 2019
 *      Jean-Luc Barriere <jlbarriere68@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import NosonApp 1.0
import NosonMediaScanner 1.0
import "../components"
import "../components/Delegates"
import "../components/Flickables"

MusicPage {
    id: composerViewPage
    objectName: "composerViewPage"
    visible: false
    pageFlickable: composerAlbumView

    property string composer: ""
    property var covers: []

    property bool isFavorite: false

    BlurredBackground {
        id: blurredBackground
        height: parent.height
    }

    AlbumList {
        id: albums
        composer: composerViewPage.composer
        Component.onCompleted: init()
    }

    function makeFileCoverSource(hasArt, filePath, artist, album) {
        var art = "";
        if (hasArt)
            art = player.makeFilePictureLocalURL(filePath);
        return makeCoverSource(art, artist, album);
    }

    MusicGridView {
        id: composerAlbumView
        itemWidth: units.gu(15)
        heightOffset: units.gu(7)

        header: MusicHeader {
            id: blurredHeader
            height: contentHeight
            noCover: "qrc:/images/none.png"
            coverSources: composerViewPage.covers
            titleColumn: Item {}
            rightColumn: Item {
                height: units.gu(9)

                Row {
                    id: r1
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    Label {
                        id: composerLabel
                        color: styleMusic.view.primaryColor
                        elide: Text.ElideRight
                        font.pointSize: units.fs("x-large")
                        maximumLineCount: 1
                        text: (composer !== "<Undefined>" ? composer : tr_undefined)
                        wrapMode: Text.NoWrap
                    }
                }

                Row {
                    id: r2
                    anchors {
                        topMargin: units.gu(0.5)
                        top: r1.bottom
                        left: parent.left
                        right: parent.right
                    }

                    Label {
                        id: albumCount
                        color: styleMusic.view.secondaryColor
                        elide: Text.ElideRight
                        font.pointSize: units.fs("small")
                        maximumLineCount: 1
                        text: qsTr("%n album(s)", "", albums.count)
                    }

                    Label {
                        id: separator
                        color: styleMusic.view.secondaryColor
                        elide: Text.ElideRight
                        font.pointSize: units.fs("small")
                        maximumLineCount: 1
                        text: " , "
                        visible: songComposerModel.count > 0
                    }

                    Label {
                        id: songCount
                        color: styleMusic.view.secondaryColor
                        elide: Text.ElideRight
                        font.pointSize: units.fs("small")
                        maximumLineCount: 1
                        text: qsTr("%n song(s)", "", songComposerModel.count)
                        visible: songComposerModel.count > 0
                    }
                }

                Row {
                    id: r3
                    anchors {
                        topMargin: units.gu(0.5)
                        top: r2.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(-1)
                    }

                    Icon {
                        height: units.gu(5)
                        width: height
                        source: "qrc:/images/view-list-symbolic.svg"
                        onClicked: {
                            stackView.push("qrc:/controls2/ThisDevice/SongsView.qml",
                                               {
                                                   "covers": composerViewPage.covers,
                                                   "album": undefined,
                                                   "artist": "",
                                                   "genre": "",
                                                   "composer": composerViewPage.composer,
                                                   "pageTitle": pageTitle,
                                                   "line1": "",
                                                   "line2": (composerViewPage.composer !== "<Undefined>" ? composerViewPage.composer : tr_undefined)
                                               })
                        }
                    }
                }
            }

            onFirstSourceChanged: {
                blurredBackground.art = firstSource
            }
        }

        model: SortFilterModel {
            model: albums
            sort.property: "album"
            sort.order: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
        }

        delegate: Card {
            id: albumCard
            height: composerAlbumView.cellHeight
            width: composerAlbumView.cellWidth
            coverSources: makeFileCoverSource(model.hasArt, model.filePath, model.artist, model.album)
            primaryText: (model.album !== "<Undefined>" ? model.album : tr_undefined)
            secondaryTextVisible: false

            onImageError: model.art = "" // reset invalid url from model
            onClicked: {
                stackView.push("qrc:/controls2/ThisDevice/SongsView.qml",
                                   {
                                       "album": model.album,
                                       "artist": model.artist,
                                       "covers": albumCard.imageSource != "" ? [{art: albumCard.imageSource}] : coverSources,
                                       "isAlbum": true,
                                       "genre": "",
                                       "composer": composerViewPage.composer,
                                       "pageTitle": pageTitle,
                                       "line1": (model.artist !== "<Undefined>" ? model.artist : tr_undefined),
                                       "line2": (model.album !== "<Undefined>" ? model.album : tr_undefined)
                                   })
            }
        }
    }

    // Query total count of composer's songs
    TrackList {
        id: songComposerModel
        composer: composerViewPage.composer
        Component.onCompleted: init()
    }
}

import QtQuick 2.0
import QtMultimedia 5.4
import Sailfish.Silica 1.0
import org.nemomobile.notifications 1.0
import harbour.foilauth 1.0

import "harbour"

Page {
    id: thisPage

    property Item viewFinder
    property Item hint

    readonly property bool canShowViewFinder: Qt.application.active && thisPage.status === PageStatus.Active
    readonly property bool canScan: viewFinder && viewFinder.source.cameraState === Camera.ActiveState

    function done(token) {
        var parentPage = pageStack.previousPage(thisPage) // Must be EditAuthTokenDialog
        if (token.valid) {
            var existingPage = pageStack.previousPage(parentPage)
            var newPage = pageStack.replaceAbove(existingPage, Qt.resolvedUrl("EditAuthTokenDialog.qml"), {
                allowedOrientations: thisPage.allowedOrientations,
                //: Dialog button
                //% "Save"
                acceptText: qsTrId("foilauth-edit_token-save"),
                //: Dialog title
                //% "Add token"
                dialogTitle: qsTrId("foilauth-add_token-title"),
                canScan: true,
                type: token.type,
                label: token.label,
                issuer: token.issuer,
                secret: token.secret,
                digits: token.digits,
                counter: token.counter,
                timeShift: token.timeshift,
                algorithm: token.algorithm
            })
            parentPage.replacedWith(newPage)
        } else {
            pageStack.pop(parentPage)
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            markImage.visible = false
        }
    }

    onCanShowViewFinderChanged: {
        if (canShowViewFinder) {
            viewFinder = viewFinderComponent.createObject(viewFinderContainer, {
                viewfinderResolution: viewFinderContainer.viewfinderResolution,
                digitalZoom: FoilAuthSettings.scanZoom,
                orientation: orientationAngle()
            })

            if (viewFinder.source.availability === Camera.Available) {
                console.log("created viewfinder")
                viewFinder.source.start()
            } else {
                console.log("oops, couldn't create viewfinder...")
            }
        } else {
            viewFinder.source.stop()
            viewFinder.destroy()
            viewFinder = null
        }
    }

    onCanScanChanged: {
        if (canScan) {
            scanner.start()
        } else {
            scanner.stop()
        }
    }

    function orientationAngle() {
        switch (orientation) {
        case Orientation.Landscape: return 90
        case Orientation.PortraitInverted: return 180
        case Orientation.LandscapeInverted: return 270
        case Orientation.Portrait: default: return  0
        }
    }

    onOrientationChanged: {
        if (viewFinder) {
            viewFinder.orientation = orientationAngle()
        }
    }

    Component {
        id: hintComponent
        Hint { }
    }

    function showHint(text) {
        if (!hint) {
            hint = hintComponent.createObject(thisPage)
        }
        hint.text = text
        hint.opacity = 1.0
    }

    function hideHint() {
        if (hint) {
            hint.opacity = 0.0
        }
    }

    QrCodeScanner {
        id: scanner

        property string lastInvalidCode
        viewFinderItem: viewFinderContainer
        rotation: orientationAngle()

        onScanFinished: {
            if (result.valid) {
                var token = FoilAuth.parseUri(result.text)
                if (token.valid) {
                    markImageProvider.image = image
                    markImage.visible = true
                    unsupportedCodeNotification.close()
                    pageStackPopTimer.token = token
                    pageStackPopTimer.start()
                } else {
                    var tokens = FoilAuth.parseMigrationUri(result.text)
                    if (tokens.length === 1) {
                        markImageProvider.image = image
                        markImage.visible = true
                        unsupportedCodeNotification.close()
                        pageStackPopTimer.token = tokens[0]
                        pageStackPopTimer.start()
                    } else if (tokens.length > 1) {
                        markImageProvider.image = image
                        markImage.visible = true
                        unsupportedCodeNotification.close()
                        var page = pageStack.push(Qt.resolvedUrl("SelectTokenPage.qml"), {
                            allowedOrientations: thisPage.allowedOrientations,
                            tokens: tokens
                        })
                        page.tokenSelected.connect(function(token) {
                            thisPage.done(token)
                        })
                    } else if (lastInvalidCode !== result.text) {
                        lastInvalidCode = result.text
                        markImageProvider.image = image
                        markImage.visible = true
                        unsupportedCodeNotification.publish()
                        restartScanTimer.start()
                    } else {
                        if (thisPage.canScan) {
                            scanner.start()
                        }
                    }
                }
            } else if (thisPage.canScan) {
                scanner.start()
            }
        }
    }

    Timer {
        id: pageStackPopTimer

        property var token

        interval: 1000
        onTriggered: thisPage.done(token)
    }

    Timer {
        id: restartScanTimer

        interval:  1000
        onTriggered: {
            markImage.visible = false
            markImageProvider.clear()
            if (thisPage.canScan) {
                scanner.start()
            }
        }
    }

    Notification {
        id: unsupportedCodeNotification

        //: Warning notification
        //% "Invalid or unsupported QR code"
        previewBody: qsTrId("foilauth-notification-unsupported_qrcode")
        expireTimeout: 2000
        Component.onCompleted: {
            if ("icon" in unsupportedCodeNotification) {
                unsupportedCodeNotification.icon = "icon-s-high-importance"
            }
        }
    }

    Component {
        id: viewFinderComponent

        ViewFinder {
            onMaximumDigitalZoom: FoilAuthSettings.maxZoom = value
        }
    }

    HarbourFitLabel {
        id: titleLabel

        x: Theme.horizontalPageMargin
        width: parent.width - 2 * x
        height: isPortrait ? Theme.itemSizeLarge : Theme.itemSizeSmall
        maxFontSize: isPortrait ? Theme.fontSizeExtraLarge : Theme.fontSizeLarge
        //: Page title (suggestion to scan QR code)
        //% "Scan QR code"
        text: qsTrId("foilauth-scan-title")
    }

    Item {
        anchors {
            top: titleLabel.bottom
            topMargin: Theme.paddingMedium
            bottom: toooBar.top
            bottomMargin: Theme.paddingLarge
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }

        onXChanged: viewFinderContainer.updateViewFinderPosition()
        onYChanged: viewFinderContainer.updateViewFinderPosition()
        onWidthChanged: viewFinderContainer.updateViewFinderPosition()
        onHeightChanged: viewFinderContainer.updateViewFinderPosition()

        Rectangle {
            id: viewFinderContainer

            readonly property real ratio_4_3: 4./3.
            readonly property real ratio_16_9: 16./9.
            readonly property bool canSwitchResolutions: typeof ViewfinderResolution_4_3 !== "undefined" &&
                typeof ViewfinderResolution_16_9 !== "undefined"
            readonly property size viewfinderResolution: canSwitchResolutions ?
                (FoilAuthSettings.scanWideMode ? ViewfinderResolution_4_3 : ViewfinderResolution_16_9) :
                Qt.size(0,0)
            readonly property real ratio: canSwitchResolutions ? (FoilAuthSettings.scanWideMode ? ratio_4_3 : ratio_16_9) :
                typeof ViewfinderResolution_4_3 !== "undefined" ? ratio_4_3 : ratio_16_9

            readonly property int portraitWidth: Math.floor((parent.height/parent.width > ratio) ? parent.width : parent.height/ratio)
            readonly property int portraitHeight: Math.floor((parent.height/parent.width > ratio) ? (parent.width * ratio) : parent.height)
            readonly property int landscapeWidth: Math.floor((parent.width/parent.height > ratio) ? (parent.height * ratio) : parent.width)
            readonly property int landscapeHeight: Math.floor((parent.width/parent.height > ratio) ? parent.height : (parent.width / ratio))

            anchors.centerIn: parent
            width: thisPage.isPortrait ? portraitWidth : landscapeWidth
            height: thisPage.isPortrait ? portraitHeight : landscapeHeight
            color: "#20000000"

            onWidthChanged: updateViewFinderPosition()
            onHeightChanged: updateViewFinderPosition()
            onXChanged: updateViewFinderPosition()
            onYChanged: updateViewFinderPosition()

            onViewfinderResolutionChanged: {
                if (viewFinder && viewfinderResolution && canSwitchResolutions) {
                    viewFinder.viewfinderResolution = viewfinderResolution
                }
            }

            function updateViewFinderPosition() {
                scanner.viewFinderRect = Qt.rect(x + parent.x, y + parent.y, viewFinder ? viewFinder.width : width, viewFinder ? viewFinder.height : height)
            }
        }
    }

    Item {
        id: toooBar

        height: Math.max(flashButton.height, zoomSlider.height, aspectButton.height)
        width: parent.width

        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }

        HarbourHintIconButton {
            id: flashButton

            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
            }

            visible: TorchSupported
            icon.source: (viewFinder && viewFinder.flashOn) ? "images/flash-on.svg" : "images/flash-off.svg"
            //: Hint label
            //% "Toggle flashlight"
            hint: qsTrId("foilauth-scan-hint_toggle_flash")
            onShowHint: thisPage.showHint(hint)
            onHideHint: thisPage.hideHint()
            onClicked: if (viewFinder) viewFinder.toggleFlash()
        }

        Slider {
            id: zoomSlider

            anchors {
                left: parent.left
                leftMargin: 2 * Theme.horizontalPageMargin + Theme.itemSizeSmall
                right: parent.right
                rightMargin: 2 * Theme.horizontalPageMargin + Theme.itemSizeSmall
            }

            //: Slider label
            //% "Zoom"
            label: qsTrId("foilauth-scan-zoom_label")
            leftMargin: 0
            rightMargin: 0
            minimumValue: 1.0
            maximumValue: FoilAuthSettings.maxZoom
            value: 1.0
            stepSize: (maximumValue - minimumValue)/100
            onValueChanged: {
                FoilAuthSettings.scanZoom = value
                if (viewFinder) {
                    viewFinder.digitalZoom = value
                }
            }
            Component.onCompleted: {
                value = FoilAuthSettings.scanZoom
                if (viewFinder) {
                    viewFinder.digitalZoom = value
                }
            }
        }

        HarbourHintIconButton {
            id: aspectButton

            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
            }
            visible: viewFinderContainer.canSwitchResolutions
            icon.source: FoilAuthSettings.scanWideMode ? "images/resolution_4_3.svg" : "images/resolution_16_9.svg"
            //: Hint label
            //% "Switch the aspect ratio between 9:16 and 3:4"
            hint: qsTrId("foilauth-scan-hint_aspect_ratio")
            onShowHint: thisPage.showHint(hint)
            onHideHint: thisPage.hideHint()
            onClicked: FoilAuthSettings.scanWideMode = !FoilAuthSettings.scanWideMode
        }
    }

    Image {
        id: markImage

        z: 2
        x: scanner.viewFinderRect.x
        y: scanner.viewFinderRect.y
        width: scanner.viewFinderRect.width
        height: scanner.viewFinderRect.height
        visible: false
        source: markImageProvider.source
        fillMode: Image.PreserveAspectCrop
    }

    HarbourSingleImageProvider {
        id: markImageProvider
    }
}

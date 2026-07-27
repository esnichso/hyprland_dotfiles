// Login screen. Hand-written; no colour appears in this file.
//
// SDDM exposes every key of the theme's theme.conf on a global `config`
// object, so the palette arrives the same way it does everywhere else in this
// repo: a generated file the hand-written config reads. install/set-theme.py
// writes theme.conf, this file never changes when you switch themes.
//
// IMPORTANT: config values are STRINGS, always. `config.ClockScale` is "0.13",
// not 0.13 — QML will coerce it when assigning to a real number property, but
// arithmetic on it concatenates instead of adding. Number() everywhere it is
// used in an expression.
//
// The SDDM QML API used below, all verified against a shipped theme rather
// than remembered:
//   sddm.login(user, password, sessionIndex)   sessionIndex is an INDEX
//   sddm.powerOff() / reboot() / suspend()
//   sddm.loginFailed / loginSucceeded         signals, via Connections
//   userModel.lastUser                        string
//   sessionModel, sessionModel.lastIndex      model for the session combo
//
// Preview without logging out:
//   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypersetup

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Item {
    id: root
    width: Screen.width
    height: Screen.height

    readonly property color cBg: config.ColorBackground
    readonly property color cText: config.ColorText
    readonly property color cSubtext: config.ColorSubtext
    readonly property color cMuted: config.ColorMuted
    readonly property color cSurface: config.ColorSurface
    readonly property color cSurfaceHi: config.ColorSurfaceHi
    readonly property color cAccent: config.ColorAccent
    readonly property color cOnAccent: config.ColorOnAccent
    readonly property color cUrgent: config.ColorUrgent

    readonly property string uiFont: config.Font
    readonly property int uiSize: Number(config.FontSize)

    // Sizes are fractions of screen height so the layout holds at 2560x1600
    // and in a 1024x768 test-mode window alike. A fixed pixel size that looks
    // right on the panel is a postage stamp in --test-mode, and vice versa.
    readonly property int clockSize: Math.round(height * Number(config.ClockScale))
    readonly property int fieldWidth: Math.min(Math.round(width * 0.22), 420)
    readonly property int fieldHeight: Math.max(Math.round(height * 0.038), 38)

    // Blank colour. No image, no logo, no cat.
    Rectangle {
        anchors.fill: parent
        color: cBg
    }

    // --- Clock ----------------------------------------------------------
    // Plain QtQuick rather than SddmComponents' Clock, which is fixed at a
    // small size in the top-right corner and cannot be made the centrepiece.
    Column {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * 0.24)
        spacing: Math.round(root.height * 0.005)

        Text {
            id: timeLabel
            anchors.horizontalCenter: parent.horizontalCenter
            color: cText
            font.family: uiFont
            font.pixelSize: clockSize
            font.weight: Font.DemiBold
            // Tighter than default at this size; large type needs less air
            // between characters, not more.
            font.letterSpacing: -clockSize * 0.02
            renderType: Text.NativeRendering
            text: "--:--"
        }

        Text {
            id: dateLabel
            anchors.horizontalCenter: parent.horizontalCenter
            color: cSubtext
            font.family: uiFont
            font.pixelSize: Math.round(clockSize * 0.16)
            renderType: Text.NativeRendering
            text: ""
        }
    }

    function tick() {
        var now = new Date()
        timeLabel.text = Qt.formatDateTime(now, config.ClockFormat)
        dateLabel.text = Qt.formatDateTime(now, config.DateFormat)
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.tick()
    }

    // --- Login ----------------------------------------------------------
    Column {
        id: login
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(root.height * 0.58)
        spacing: 10
        width: fieldWidth

        TextField {
            id: userField
            width: parent.width
            height: fieldHeight
            text: userModel.lastUser
            placeholderText: "Benutzer"
            color: cText
            selectionColor: cAccent
            selectedTextColor: cOnAccent
            horizontalAlignment: TextInput.AlignHCenter
            renderType: Text.NativeRendering
            font.family: uiFont
            font.pointSize: uiSize
            background: Rectangle {
                radius: 8
                color: cSurface
                border.width: 1
                border.color: userField.activeFocus ? cAccent : "transparent"
            }
            onAccepted: passwordField.forceActiveFocus()
        }

        TextField {
            id: passwordField
            width: parent.width
            height: fieldHeight
            focus: true
            placeholderText: "Passwort"
            echoMode: TextInput.Password
            passwordCharacter: "•"
            passwordMaskDelay: Number(config.PasswordShowLastLetter)
            color: cText
            selectionColor: cAccent
            selectedTextColor: cOnAccent
            horizontalAlignment: TextInput.AlignHCenter
            renderType: Text.NativeRendering
            font.family: uiFont
            font.pointSize: uiSize
            background: Rectangle {
                radius: 8
                color: cSurface
                border.width: 1
                border.color: passwordField.activeFocus ? cAccent : "transparent"
            }
            onAccepted: root.doLogin()
        }

        // Failure message. Occupies its row whether or not it has text, so a
        // failed login does not shift the fields upward under the cursor.
        Text {
            id: message
            width: parent.width
            height: Math.round(fieldHeight * 0.6)
            horizontalAlignment: Text.AlignHCenter
            color: cUrgent
            font.family: uiFont
            font.pointSize: uiSize - 1
            renderType: Text.NativeRendering
            text: ""
        }
    }

    function doLogin() {
        if (userField.text === "" || passwordField.text === "")
            return
        message.text = ""
        sddm.login(userField.text, passwordField.text, sessionBox.currentIndex)
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            message.text = "Falsches Passwort"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }

        function onLoginSucceeded() {
            message.text = ""
        }
    }

    // --- Session, bottom left -------------------------------------------
    ComboBox {
        id: sessionBox
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 28
        }
        width: Math.min(Math.round(root.width * 0.16), 300)
        height: fieldHeight
        model: sessionModel
        // "name" is the role sessionModel exposes for the human-readable
        // session name; index is what sddm.login() wants.
        textRole: "name"
        currentIndex: sessionModel.lastIndex
        font.family: uiFont
        font.pointSize: uiSize - 1

        contentItem: Text {
            leftPadding: 12
            text: sessionBox.displayText
            color: cSubtext
            font: sessionBox.font
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
        }
        background: Rectangle {
            radius: 8
            color: sessionBox.hovered ? cSurfaceHi : cSurface
        }
    }

    // --- Power, bottom right --------------------------------------------
    Row {
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 28
        }
        spacing: 8

        Repeater {
            model: [
                { label: "Suspend", act: "suspend" },
                { label: "Neustart", act: "reboot" },
                { label: "Aus", act: "poweroff" }
            ]

            Button {
                required property var modelData
                height: fieldHeight
                width: Math.max(implicitContentWidth + 28, 84)
                hoverEnabled: true

                contentItem: Text {
                    text: modelData.label
                    color: parent.hovered ? cText : cSubtext
                    font.family: uiFont
                    font.pointSize: uiSize - 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                }
                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? cSurfaceHi : cSurface
                }
                onClicked: {
                    if (modelData.act === "suspend") sddm.suspend()
                    else if (modelData.act === "reboot") sddm.reboot()
                    else sddm.powerOff()
                }
            }
        }
    }

    // Land on the password field with the username already filled in, which
    // is the case every time on a single-user machine.
    Component.onCompleted: {
        if (userField.text === "") userField.forceActiveFocus()
        else passwordField.forceActiveFocus()
    }
}

import QtQuick
import QtQuick.Layouts

// ── RingGauge ────────────────────────────────────────────────────────────────
// A circular arc progress gauge matching the screenshot aesthetic.
// Properties:
//   value     – 0.0 to 1.0
//   label     – "session" / "weekly"
//   accent    – arc color
//   ringBg    – background ring color
//   resetIn   – reset time string
//   errMode   – show dashes instead of value
//   subColor  – dim text color
//   textColor – main text color

Item {
    id: gauge

    property real   value:     0.0
    property string label:     ""
    property color  accent:    "#38bdf8"
    property color  ringBg:    "#1e2535"
    property string resetIn:   "–"
    property bool   errMode:   false
    property color  subColor:  "#64748b"
    property color  textColor: "#e2e8f0"

    // smooth value animation
    property real animValue: 0.0
    Behavior on animValue { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
    onValueChanged: animValue = value

    // ring geometry
    readonly property real strokeW:   8
    readonly property real startAngle: -220   // degrees, top-left start (like screenshot)
    readonly property real sweepTotal: 260    // degrees of arc total

    ColumnLayout {
        anchors.fill: parent
        spacing: 2

        // ── Canvas ring ──────────────────────────────────────────────────────
        Canvas {
            id: canvas
            Layout.fillWidth:  true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.shadowBlur = 0   // reset state from previous paint

                var cx = width  / 2
                var cy = height / 2
                var r  = Math.min(width, height) * 0.5 - gauge.strokeW / 2 - 4
                var sw = gauge.strokeW
                var toRad = Math.PI / 180

                // degrees → radians offset (canvas 0° = 3-o'clock)
                var startDeg = gauge.startAngle - 90   // rotate so start is top-left
                var sweepDeg = gauge.sweepTotal

                // ── Background ring ──────────────────────────────────────────
                ctx.beginPath()
                ctx.arc(cx, cy,
                        r,
                        startDeg * toRad,
                        (startDeg + sweepDeg) * toRad,
                        false)
                ctx.strokeStyle = gauge.ringBg.toString()
                ctx.lineWidth   = sw
                ctx.lineCap     = "round"
                ctx.stroke()

                // ── Foreground arc ───────────────────────────────────────────
                if (!gauge.errMode && gauge.animValue > 0) {
                    var filledDeg = sweepDeg * gauge.animValue

                    // subtle glow
                    ctx.shadowColor = gauge.accent.toString()
                    ctx.shadowBlur  = 8

                    ctx.beginPath()
                    ctx.arc(cx, cy,
                            r,
                            startDeg * toRad,
                            (startDeg + filledDeg) * toRad,
                            false)
                    ctx.strokeStyle = gauge.accent.toString()
                    ctx.lineWidth   = sw
                    ctx.lineCap     = "round"
                    ctx.stroke()
                }
            }

            // redraw when animated value / color / state changes
            Connections {
                target: gauge
                function onAnimValueChanged() { canvas.requestPaint() }
                function onAccentChanged()    { canvas.requestPaint() }
                function onErrModeChanged()   { canvas.requestPaint() }
            }

            // ── Centre text overlay ──────────────────────────────────────────
            Column {
                anchors.centerIn: parent
                spacing: 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: gauge.errMode ? "–" : Math.round(gauge.animValue * 100) + "%"
                    color: gauge.errMode ? gauge.subColor : gauge.textColor
                    font.pixelSize: Math.min(canvas.width, canvas.height) * 0.22
                    font.weight: Font.Bold
                    font.family: "monospace"

                    Behavior on color { ColorAnimation { duration: 400 } }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: gauge.errMode ? "" : gauge.resetIn
                    color: gauge.subColor
                    font.pixelSize: Math.min(canvas.width, canvas.height) * 0.10
                    font.weight: Font.Normal
                    font.family: "monospace"
                    opacity: 0.9
                }
            }
        }

        // ── Window label (session / weekly) ───────────────────────────────────
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            color: Qt.rgba(1, 1, 1, 0.05)
            radius: 4
            implicitWidth:  labelText.implicitWidth  + 12
            implicitHeight: labelText.implicitHeight + 6

            Text {
                id: labelText
                anchors.centerIn: parent
                text: gauge.label
                color: gauge.subColor
                font.pixelSize: 9
                font.family: "monospace"
                opacity: 0.8
            }
        }
    }
}

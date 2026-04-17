import QtQuick
import QtTest
import "../../package/contents/code/timeUtils.js" as TimeUtils

TestCase {
    name: "TimeUtilsTests"

    // Base timestamp — current time rounded down to the minute
    readonly property var fixedNow: (function() { var d = new Date(); d.setSeconds(0, 0); return d })()

    function test_formatTimeLeft_null() {
        compare(TimeUtils.formatTimeLeft(null), "\u2013")
    }

    function test_formatTimeLeft_past() {
        var past = new Date(fixedNow.getTime() - 1000)
        compare(TimeUtils.formatTimeLeft(past.toISOString(), fixedNow), "now")
    }

    function test_formatTimeLeft_minutes() {
        var future = new Date(fixedNow.getTime() + 5 * 60 * 1000)
        compare(TimeUtils.formatTimeLeft(future.toISOString(), fixedNow), "5m")
    }

    function test_formatTimeLeft_hours_minutes() {
        var future = new Date(fixedNow.getTime() + (1 * 3600 + 20 * 60) * 1000)
        compare(TimeUtils.formatTimeLeft(future.toISOString(), fixedNow), "1h 20m")
    }

    function test_formatTimeLeft_days_hours() {
        var future = new Date(fixedNow.getTime() + (2 * 86400 + 3 * 3600) * 1000)
        compare(TimeUtils.formatTimeLeft(future.toISOString(), fixedNow), "2d 3h")
    }

    function test_formatTimeLeftWeekly_null() {
        compare(TimeUtils.formatTimeLeftWeekly(null), "\u2013")
    }

    function test_formatTimeLeftWeekly_days() {
        var future = new Date(fixedNow.getTime() + (3 * 86400 + 5 * 3600) * 1000)
        compare(TimeUtils.formatTimeLeftWeekly(future.toISOString(), fixedNow), "3d")
    }

    function test_formatTimeLeftWeekly_hours_minutes() {
        var future = new Date(fixedNow.getTime() + (12 * 3600 + 30 * 60) * 1000)
        compare(TimeUtils.formatTimeLeftWeekly(future.toISOString(), fixedNow), "12h 30m")
    }

    function test_formatResetDate_null() {
        compare(TimeUtils.formatResetDate(null, Qt.locale("en_US")), "\u2013")
    }

    function test_formatResetDate() {
        var date = new Date(2026, 3, 20, 10, 0, 0) // April 20
        var result = TimeUtils.formatResetDate(date.toISOString(), Qt.locale("en_US"))
        // Qt toLocaleDateString with "MMM d" should return "Apr 20"
        compare(result, "Apr 20")
    }

    function test_formatResetTime_null() {
        compare(TimeUtils.formatResetTime(null, Qt.locale("en_US")), "\u2013")
    }

    function test_formatResetTime_same_day() {
        // Date is the same day — should return time only (no date)
        var now = new Date()
        var sameDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 0, 0)
        var result = TimeUtils.formatResetTime(sameDay.toISOString(), Qt.locale("en_US"))
        // If the day matches, only time "hh:mm" is returned — no space
        verify(!result.includes(" "), "Should not contain date for today, got: " + result)
    }

    function test_formatResetTime_other_day() {
        // Date is a different day — should contain date (space between date and time)
        var now = new Date()
        var otherDay = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 10, 0, 0)
        var result = TimeUtils.formatResetTime(otherDay.toISOString(), Qt.locale("en_US"))
        verify(result.includes(" "), "Should contain date for a different day, got: " + result)
    }
}

import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.ActivityMonitor;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

//! Main watch face view.
//!
//! Layout:
//!   - Large time in the centre
//!   - Left semi-circle arc  : Body Battery (blue → orange when ≤ 30 %)
//!   - Right semi-circle arc : Stress       (red)
//!   - Small label below-left : BB percentage
//!   - Small label below-right: Stress percentage
//!   - Date string just below the time
//!   - "REST" warning at the bottom when Body Battery ≤ 30 %
class MhBalanceView extends WatchUi.WatchFace {

    // ── Colours ─────────────────────────────────────────────────────────────
    private const COLOR_BB_NORMAL   as Graphics.ColorType = Graphics.COLOR_BLUE;
    private const COLOR_BB_LOW      as Graphics.ColorType = Graphics.COLOR_ORANGE;
    private const COLOR_BB_TRACK    as Graphics.ColorType = 0x00103A as Graphics.ColorType;
    private const COLOR_STRESS      as Graphics.ColorType = Graphics.COLOR_RED;
    private const COLOR_STRESS_TRACK as Graphics.ColorType = 0x3A0000 as Graphics.ColorType;
    private const COLOR_TIME        as Graphics.ColorType = Graphics.COLOR_WHITE;
    private const COLOR_DATE        as Graphics.ColorType = Graphics.COLOR_LT_GRAY;
    private const COLOR_REST_WARN   as Graphics.ColorType = Graphics.COLOR_ORANGE;

    // ── Low-energy threshold ─────────────────────────────────────────────────
    private const LOW_BATTERY_THRESHOLD as Lang.Number = 30;

    // ── Layout cache (set once in onLayout) ─────────────────────────────────
    private var _centerX   as Lang.Number = 0;
    private var _centerY   as Lang.Number = 0;
    private var _arcRadius as Lang.Number = 0;
    private var _arcWidth  as Lang.Number = 0;

    function initialize() {
        WatchFace.initialize();
    }

    //! Pre-compute layout geometry so onUpdate stays cheap.
    function onLayout(dc as Graphics.Dc) as Void {
        _computeLayout(dc);
    }

    function onShow() as Void {}

    function onHide() as Void {}

    //! Called when the watch wakes from sleep — request a full redraw.
    function onExitSleep() as Void {
        WatchUi.requestUpdate();
    }

    //! Called when the watch enters sleep — keep the display updated.
    function onEnterSleep() as Void {
        WatchUi.requestUpdate();
    }

    // ── Main draw ─────────────────────────────────────────────────────────────

    function onUpdate(dc as Graphics.Dc) as Void {
        // Guard: layout may not have been called yet (e.g. partial-update path).
        if (_centerX == 0) {
            _computeLayout(dc);
        }

        // ── Clear background ────────────────────────────────────────────────
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();

        // ── Read metrics ────────────────────────────────────────────────────
        var bodyBattery = _readBodyBattery();
        var stress      = _readStress();

        // ── Draw arc tracks ─────────────────────────────────────────────────
        dc.setPenWidth(_arcWidth);

        // Left-half track (Body Battery)
        dc.setColor(COLOR_BB_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(_centerX, _centerY, _arcRadius,
                   Graphics.ARC_COUNTER_CLOCKWISE, 90, 270);

        // Right-half track (Stress)
        dc.setColor(COLOR_STRESS_TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(_centerX, _centerY, _arcRadius,
                   Graphics.ARC_CLOCKWISE, 90, 270);

        // ── Draw Body Battery arc ────────────────────────────────────────────
        var bbColor = (bodyBattery != null && bodyBattery <= LOW_BATTERY_THRESHOLD)
                      ? COLOR_BB_LOW
                      : COLOR_BB_NORMAL;
        _drawValueArc(dc, bodyBattery, 100, bbColor, Graphics.ARC_COUNTER_CLOCKWISE,  1);

        // ── Draw Stress arc ──────────────────────────────────────────────────
        _drawValueArc(dc, stress, 100, COLOR_STRESS, Graphics.ARC_CLOCKWISE, -1);

        // ── Draw time ────────────────────────────────────────────────────────
        var timeStr = _formatTime();
        dc.setColor(COLOR_TIME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _centerY - (_arcWidth / 2),
                    Graphics.FONT_NUMBER_THAI_HOT, timeStr,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ── Draw date ────────────────────────────────────────────────────────
        var dateStr = _formatDate();
        dc.setColor(COLOR_DATE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _centerY + (_arcWidth + 4),
                    Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        // ── Draw metric labels ───────────────────────────────────────────────
        var labelY = _centerY + _arcRadius / 3;

        // Body Battery label (left)
        var bbText = (bodyBattery != null) ? bodyBattery.format("%d") + "%" : "--";
        dc.setColor(bbColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX - _arcRadius / 2 + 4, labelY,
                    Graphics.FONT_SMALL, bbText, Graphics.TEXT_JUSTIFY_CENTER);

        // Stress label (right)
        var stressText = (stress != null) ? stress.format("%d") : "--";
        dc.setColor(COLOR_STRESS, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX + _arcRadius / 2 - 4, labelY,
                    Graphics.FONT_SMALL, stressText, Graphics.TEXT_JUSTIFY_CENTER);

        // ── Low-energy warning ───────────────────────────────────────────────
        if (bodyBattery != null && bodyBattery <= LOW_BATTERY_THRESHOLD) {
            var warnStr = Application.loadResource(Rez.Strings.LowEnergyWarning) as Lang.String;
            dc.setColor(COLOR_REST_WARN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, _centerY + _arcRadius - _arcWidth - 6,
                        Graphics.FONT_TINY, warnStr,
                        Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    //! Compute and cache layout dimensions from the drawing context.
    private function _computeLayout(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        _centerX   = w / 2;
        _centerY   = h / 2;
        var minDim = (w < h) ? w : h;
        _arcWidth  = (minDim * 0.06 + 0.5).toNumber(); // ~6 % of display size
        _arcRadius = minDim / 2 - _arcWidth - 2;
    }

    //! Draw a value arc starting from the 12-o'clock position.
    //! @param dc         Drawing context.
    //! @param value      Current metric value (or null).
    //! @param maxValue   Maximum possible value (100).
    //! @param color      Arc colour.
    //! @param direction  ARC_CLOCKWISE or ARC_COUNTER_CLOCKWISE.
    //! @param sign       +1 for CCW (BB), -1 for CW (Stress).
    private function _drawValueArc(
        dc        as Graphics.Dc,
        value     as Lang.Number or Null,
        maxValue  as Lang.Number,
        color     as Graphics.ColorType,
        direction as Lang.Number,
        sign      as Lang.Number
    ) as Void {
        if (value == null || value <= 0) {
            return;
        }
        var clipped   = (value > maxValue) ? maxValue : value;
        var spanDeg   = (clipped * 180 / maxValue).toNumber();
        var endAngle  = 90 + sign * spanDeg;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(_centerX, _centerY, _arcRadius, direction, 90, endAngle);
    }

    //! Return the current Body Battery level (0–100) or null if unavailable.
    private function _readBodyBattery() as Lang.Number or Null {
        var info = ActivityMonitor.getInfo();
        if (info == null) { return null; }
        if (!(info has :bodyBatteryChargeLevel)) { return null; }
        return info.bodyBatteryChargeLevel;
    }

    //! Return the current stress score (0–100) or null if unavailable.
    //! Falls back to a recent history sample when the live value is absent.
    private function _readStress() as Lang.Number or Null {
        var info = ActivityMonitor.getInfo();
        if (info != null && (info has :stressScore) && info.stressScore != null) {
            var raw = info.stressScore as Lang.Number;
            // Garmin encodes "rest" as -1 and "not measured" as negative values.
            if (raw >= 0) {
                return raw;
            }
        }

        // Try SensorHistory as a fallback (requires SensorHistory permission).
        if (Toybox has :SensorHistory) {
            var iter = Toybox.SensorHistory.getStressHistory({});
            if (iter != null) {
                var sample = iter.next();
                if (sample != null && sample.data != null) {
                    return sample.data as Lang.Number;
                }
            }
        }

        return null;
    }

    //! Format the current time as "HH:MM" (or "H:MM" in 12-hour mode).
    private function _formatTime() as Lang.String {
        var clock = System.getClockTime();
        var h     = clock.hour;
        var m     = clock.min;

        var settings = System.getDeviceSettings();
        if (!settings.is24Hour) {
            if (h == 0) { h = 12; }
            else if (h > 12) { h -= 12; }
        }

        return h.format("%02d") + ":" + m.format("%02d");
    }

    //! Format today's date as "Mon DD".
    private function _formatDate() as Lang.String {
        var now  = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_MEDIUM);
        return info.month + " " + info.day.format("%d");
    }
}

const fs = require('fs');
const path = require('path');

const jsPath = path.join(__dirname, '../../package/contents/code/timeUtils.js');
let content = fs.readFileSync(jsPath, 'utf8');

// Remove .pragma library for Node.js
content = content.replace('.pragma library', '');

// Create a wrapper object to export functions
const moduleWrapper = { exports: {} };
const script = new Function('module', 'exports', content + '\nmodule.exports = { formatTimeLeft, formatTimeLeftWeekly, formatResetDate, formatResetTime };');
script(moduleWrapper, moduleWrapper.exports);

const TimeUtils = moduleWrapper.exports;

describe('timeUtils.js', () => {
    // Mock Date for consistent tests
    const mockNow = new Date('2026-04-17T20:00:00Z');
    beforeAll(() => {
        jest.useFakeTimers();
        jest.setSystemTime(mockNow);
    });

    afterAll(() => {
        jest.useRealTimers();
    });

    describe('formatTimeLeft', () => {
        test('returns "-" for empty input', () => {
            expect(TimeUtils.formatTimeLeft(null)).toBe('\u2013');
        });

        test('returns "now" for time in the past', () => {
            const past = new Date(mockNow.getTime() - 1000).toISOString();
            expect(TimeUtils.formatTimeLeft(past)).toBe('now');
        });

        test('returns "now" for time less than a minute in the future', () => {
            const soon = new Date(mockNow.getTime() + 30 * 1000).toISOString();
            expect(TimeUtils.formatTimeLeft(soon)).toBe('now');
        });

        test('formats minutes', () => {
            const future = new Date(mockNow.getTime() + 5 * 60 * 1000).toISOString();
            expect(TimeUtils.formatTimeLeft(future)).toBe('5m');
        });

        test('formats hours and minutes', () => {
            const future = new Date(mockNow.getTime() + (1 * 3600 + 20 * 60) * 1000).toISOString();
            expect(TimeUtils.formatTimeLeft(future)).toBe('1h 20m');
        });

        test('formats days and hours', () => {
            const future = new Date(mockNow.getTime() + (2 * 86400 + 3 * 3600) * 1000).toISOString();
            expect(TimeUtils.formatTimeLeft(future)).toBe('2d 3h');
        });
    });

    describe('formatTimeLeftWeekly', () => {
        test('returns "-" for empty input', () => {
            expect(TimeUtils.formatTimeLeftWeekly(null)).toBe('\u2013');
        });

        test('returns "now" for time in the past', () => {
            const past = new Date(mockNow.getTime() - 1000).toISOString();
            expect(TimeUtils.formatTimeLeftWeekly(past)).toBe('now');
        });

        test('formats days (days only if >= 1)', () => {
            const future = new Date(mockNow.getTime() + (3 * 86400 + 5 * 3600) * 1000).toISOString();
            expect(TimeUtils.formatTimeLeftWeekly(future)).toBe('3d');
        });

        test('formats hours and minutes if less than a day', () => {
            const future = new Date(mockNow.getTime() + (12 * 3600 + 30 * 60) * 1000).toISOString();
            expect(TimeUtils.formatTimeLeftWeekly(future)).toBe('12h 30m');
        });

        test('formats minutes if less than an hour', () => {
            const future = new Date(mockNow.getTime() + 45 * 60 * 1000).toISOString();
            expect(TimeUtils.formatTimeLeftWeekly(future)).toBe('45m');
        });
    });

    describe('formatResetDate', () => {
        test('returns "-" for empty input', () => {
            expect(TimeUtils.formatResetDate(null, 'en-US')).toBe('\u2013');
        });

        test('formats date', () => {
            const date = '2026-04-20T10:00:00Z';
            const result = TimeUtils.formatResetDate(date, 'en-US');
            // In Node.js without full ICU, "4/20/2026" may be returned instead of "Apr 20"
            // Accept both variants — Node.js environment limitation
            const isMatch = /Apr/.test(result) || result.includes('4/20');
            expect(isMatch).toBe(true);
        });
    });

    describe('formatResetTime', () => {
        test('returns "-" for empty input', () => {
            expect(TimeUtils.formatResetTime(null, 'en-US')).toBe('\u2013');
        });

        test('returns time only if date matches today', () => {
            // mockNow = 2026-04-17T20:00:00Z, take a time on the same day
            const sameDay = new Date(mockNow.getTime() + 30 * 60 * 1000).toISOString(); // +30 min
            const result = TimeUtils.formatResetTime(sameDay, 'en-US');
            // Should contain time only (no date), format depends on ICU
            // Check that "Apr" is absent (i.e. date was not appended)
            expect(result).not.toMatch(/Apr/);
        });

        test('returns date and time if date differs from today', () => {
            const otherDay = '2026-04-20T10:00:00Z';
            const result = TimeUtils.formatResetTime(otherDay, 'en-US');
            // Should contain date — "Apr" or "4/20"
            const hasDate = /Apr/.test(result) || result.includes('4/20');
            expect(hasDate).toBe(true);
        });
    });
});

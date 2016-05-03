package me.ranmocy.rcaltrain.models;

import android.support.annotation.NonNull;

import java.util.Calendar;
import java.util.Locale;

/**
 * Represents the time since midnight.
 */
public class DayTime implements Comparable<DayTime> {

    public static DayTime now() {
        Calendar calendar = Calendar.getInstance();
        return new DayTime(calendar.get(Calendar.HOUR_OF_DAY), calendar.get(Calendar.MINUTE));
    }

    private final long minutesSinceMidnight;

    public DayTime(long secondsSinceMidnight) {
        this.minutesSinceMidnight = secondsSinceMidnight / 60;
    }

    public DayTime(int hours, int minutes) {
        this.minutesSinceMidnight = hours * 60 + minutes;
    }

    @Override
    public int compareTo(@NonNull DayTime another) {
        return (int) (this.minutesSinceMidnight - another.minutesSinceMidnight);
    }

    @Override
    public String toString() {
        return String.format(Locale.getDefault(), "%02d:%02d",
                minutesSinceMidnight / 60 % 24, minutesSinceMidnight % 60 % 24);
    }

    /**
     * Returns the interval time in minutes from this {@link DayTime} to the given {@link DayTime}.
     */
    public long toInMinutes(@NonNull DayTime another) {
        return another.minutesSinceMidnight - this.minutesSinceMidnight;
    }

    public boolean after(DayTime another) {
        return this.compareTo(another) > 0;
    }
}

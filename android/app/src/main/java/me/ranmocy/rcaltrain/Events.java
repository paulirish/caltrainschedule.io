package me.ranmocy.rcaltrain;

import android.os.Bundle;

/**
 * Events used for FirebaseAnalytics
 */
public final class Events {

    static final String SCHEDULE_EVENT = "event_schedule";

    private static final String PARAM_DEPARTURE = "param_departure";
    private static final String PARAM_DESTINATION = "param_destination";
    private static final String PARAM_SCHEDULE = "param_schedule";

    public static Bundle getScheduleEvent(String departure, String destination, String schedule) {
        Bundle data = new Bundle();
        data.putString(PARAM_DEPARTURE, departure);
        data.putString(PARAM_DESTINATION, destination);
        data.putString(PARAM_SCHEDULE, schedule);
        return data;
    }
}

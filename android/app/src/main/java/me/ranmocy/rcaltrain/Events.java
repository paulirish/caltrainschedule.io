package me.ranmocy.rcaltrain;

import android.os.Bundle;

import me.ranmocy.rcaltrain.models.ScheduleType;

/**
 * Events used for FirebaseAnalytics
 */
public final class Events {

    static final String EVENT_SCHEDULE = "event_schedule";
    static final String EVENT_ON_CLICK = "event_on_click";

    private static final String PARAM_DEPARTURE = "param_departure";
    private static final String PARAM_ARRIVAL = "param_arrival";
    private static final String PARAM_SCHEDULE = "param_schedule";
    private static final String PARAM_CLICKED_ELEM = "param_clicked_elem";
    
    private static final String VALUE_CLICK_DEPARTURE = "value_click_departure";
    private static final String VALUE_CLICK_ARRIVAL = "value_click_arrival";
    private static final String VALUE_CLICK_SWITCH = "value_click_switch";
    private static final String VALUE_CLICK_SCHEDULE = "value_click_schedule";

    public static Bundle getScheduleEvent(String departure, String arrival, ScheduleType schedule) {
        Bundle data = new Bundle();
        data.putString(PARAM_DEPARTURE, departure);
        data.putString(PARAM_ARRIVAL, arrival);
        data.putString(PARAM_SCHEDULE, schedule.name());
        return data;
    }

    public static Bundle getClickDepartureEvent() {
        Bundle data = new Bundle();
        data.putString(PARAM_CLICKED_ELEM, VALUE_CLICK_DEPARTURE);
        return data;
    }

    public static Bundle getClickArrivalEvent() {
        Bundle data = new Bundle();
        data.putString(PARAM_CLICKED_ELEM, VALUE_CLICK_ARRIVAL);
        return data;
    }

    public static Bundle getClickSwitchEvent() {
        Bundle data = new Bundle();
        data.putString(PARAM_CLICKED_ELEM, VALUE_CLICK_SWITCH);
        return data;
    }

    public static Bundle getClickScheduleEvent(ScheduleType scheduleType) {
        Bundle data = new Bundle();
        data.putString(PARAM_CLICKED_ELEM, VALUE_CLICK_SCHEDULE);
        data.putString(PARAM_SCHEDULE, scheduleType.name());
        return data;
    }
}

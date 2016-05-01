package me.ranmocy.rcaltrain;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Preferences manages {@link SharedPreferences}.
 */
public class Preferences {

    private static final String PREFERENCES_NAMESPACE = "rCaltrainPreferences";
    private static final String LAST_DEPARTURE_STATION_NAME = "pref_last_source_station_name";
    private static final String LAST_DESTINATION_STATION_NAME = "pref_last_dest_station_name";
    private static final String LAST_SCHEDULE_TYPE = "pref_last_schedule_type";

    private final SharedPreferences preferences;

    public Preferences(Context context) {
        this.preferences = context.getSharedPreferences(PREFERENCES_NAMESPACE, Context.MODE_PRIVATE);
    }

    public String getLastDepartureStationName() {
        return preferences.getString(LAST_DEPARTURE_STATION_NAME, null);
    }

    public void setLastSourceStationName(String stationName) {
        preferences.edit().putString(LAST_DEPARTURE_STATION_NAME, stationName).apply();
    }

    public String getLastDestinationStationName() {
        return preferences.getString(LAST_DESTINATION_STATION_NAME, null);
    }

    public void setLastDestinationStationName(String stationName) {
        preferences.edit().putString(LAST_DESTINATION_STATION_NAME, stationName).apply();
    }

    public ScheduleType getLastScheduleType() {
        int type = preferences.getInt(LAST_SCHEDULE_TYPE, ScheduleType.NOW.ordinal());
        ScheduleType[] types = ScheduleType.values();
        if (type < 0 || type >= types.length) {
            type = 0;
        }
        return types[type];
    }

    public void setLastScheduleType(ScheduleType type) {
        preferences.edit().putInt(LAST_SCHEDULE_TYPE, type.ordinal()).apply();
    }
}

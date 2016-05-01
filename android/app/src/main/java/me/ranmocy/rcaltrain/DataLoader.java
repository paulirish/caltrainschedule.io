package me.ranmocy.rcaltrain;

import android.content.Context;
import android.content.res.XmlResourceParser;
import android.support.annotation.XmlRes;
import android.util.Log;

import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import static org.xmlpull.v1.XmlPullParser.END_DOCUMENT;
import static org.xmlpull.v1.XmlPullParser.END_TAG;
import static org.xmlpull.v1.XmlPullParser.START_DOCUMENT;
import static org.xmlpull.v1.XmlPullParser.START_TAG;
import static org.xmlpull.v1.XmlPullParser.TEXT;

/**
 * Loader loads scheduling data from xml files.
 */
public class DataLoader {

    private static final String TAG = "DataLoader";
    private static final String MAP = "map";
    private static final String KEY = "key";
    private static final String VALUE = "value";
    private static final String ARRAY = "array";
    private static final String ELEM = "elem";

    private static boolean loaded = false;

    public static void loadDataIfNot(Context context) {
        if (loaded) {
            Log.i(TAG, "Data have loaded, skip.");
            return;
        }

        Log.i(TAG, "Loading data.");
        try {
            new DataLoader(context, R.xml.stops).loadStops();
            new DataLoader(context, R.xml.calendar).loadCalendar();
            new DataLoader(context, R.xml.calendar_dates).loadCalendarDates();
            new DataLoader(context, R.xml.routes).loadRoutes();
        } catch (XmlPullParserException | IOException e) {
            // TODO: show dialog
            throw new RuntimeException(e);
        }

        Log.i(TAG, "Data loaded.");
        loaded = true;
    }

    private final XmlResourceParser parser;

    private DataLoader(Context context, @XmlRes int resId) {
        this.parser = context.getResources().getXml(resId);
    }

    /**
     * stops:
     * stop_name => [stop_id1, stop_id2]
     * "San Francisco" => [70021, 70022]
     */
    private void loadStops() throws XmlPullParserException, IOException {
        startDoc();
        startTag(MAP);
        while (isTag(KEY)) {
            String stationName = getKey();

            startTag(VALUE);
            startTag(ARRAY);
            List<Integer> stationIds = new ArrayList<>();
            while (isTag(ELEM)) {
                stationIds.add(getInt(ELEM));
            }
            endTag(ARRAY);
            endTag(VALUE);

            Station.addStation(stationName, stationIds);
        }
        endTag(MAP);
        endDoc();
    }

    /**
     * calendar:
     * service_id => {weekday: bool, saturday: bool, sunday: bool, start_date: date, end_date: date}
     * CT-16APR-Caltrain-Weekday-01 => {weekday: false, saturday: true, sunday: false, start_date: 20160404, end_date: 20190331}
     */
    private void loadCalendar() throws IOException, XmlPullParserException {
        startDoc();
        startTag(MAP);
        while (isTag(KEY)) {
            String serviceId = getKey();

            startTag(VALUE);
            startTag(MAP);
            if (!"weekday".equals(getKey())) throw new AssertionError();
            boolean weekday = getBoolean(VALUE);
            if (!"saturday".equals(getKey())) throw new AssertionError();
            boolean saturday = getBoolean(VALUE);
            if (!"sunday".equals(getKey())) throw new AssertionError();
            boolean sunday = getBoolean(VALUE);
            if (!"start_date".equals(getKey())) throw new AssertionError();
            Calendar startDate = getDate(VALUE);
            if (!"end_date".equals(getKey())) throw new AssertionError();
            Calendar endDate = getDate(VALUE);
            endTag(MAP);
            endTag(VALUE);

            Service.addService(serviceId, weekday, saturday, sunday, startDate, endDate);
        }
        endTag(MAP);
        endDoc();
    }

    /**
     * calendar_dates:
     * service_id => [[date, exception_type]]
     * CT-16APR-Caltrain-Weekday-01 => [[20160530,2]]
     */
    private void loadCalendarDates() throws IOException, XmlPullParserException {
        startDoc();
        startTag(MAP);
        while (isTag(KEY)) {
            String serviceId = getKey();
            Service service = Service.getService(serviceId);

            startTag(VALUE);
            startTag(ARRAY);
            while (isTag(ELEM)) {
                startTag(ELEM);
                startTag(ARRAY);
                Calendar date = getDate(ELEM);
                int type = getInt(ELEM);
                if (type == 1) {
                    service.addAdditionalDate(date);
                } else if (type == 2) {
                    service.addExceptionDate(date);
                } else {
                    throw new RuntimeException("Unexpected exception dates type:" + type);
                }
                endTag(ARRAY);
                endTag(ELEM);
            }
            endTag(ARRAY);
            endTag(VALUE);
        }
        endTag(MAP);
        endDoc();
    }

    /**
     * routes:
     * { route_id => { service_id => { trip_id => [[stop_id, arrival_time/departure_time(in seconds)]] } } }
     * { "Bullet" => { "CT-14OCT-XXX" => { "650770-CT-14OCT-XXX" => [[70012, 29700], ...] } } }
     */
    private void loadRoutes() throws IOException, XmlPullParserException {
        startDoc();
        startTag(MAP);
        while (isTag(KEY)) {
            getKey(); // routeId

            startTag(VALUE);
            startTag(MAP);
            while (isTag(KEY)) {
                String serviceId = getKey();
                Service service = Service.getService(serviceId);

                startTag(VALUE);
                startTag(MAP);
                while (isTag(KEY)) {
                    String tripId = getKey();
                    Trip trip = service.addTrip(tripId);

                    startTag(VALUE);
                    startTag(ARRAY);
                    while (isTag(ELEM)) {
                        startTag(ELEM);
                        startTag(ARRAY);
                        int stationId = getInt(ELEM);
                        Station station = Station.getStation(stationId);
                        Date stopTime = getTime(ELEM);
                        trip.addStop(station, stopTime);
                        endTag(ARRAY);
                        endTag(ELEM);
                    }
                    endTag(ARRAY);
                    endTag(VALUE);
                }
                endTag(MAP);
                endTag(VALUE);
            }
            endTag(MAP);
            endTag(VALUE);
        }
        endTag(MAP);
        endDoc();
    }

    private boolean isTag(String tagName) throws XmlPullParserException {
        return parser.getEventType() == START_TAG && parser.getName().equals(tagName);
    }

    private void startDoc() throws XmlPullParserException, IOException {
        parser.require(START_DOCUMENT, null, null);
        parser.next();
        parser.next();
    }

    private void endDoc() throws XmlPullParserException, IOException {
        parser.require(END_DOCUMENT, null, null);
        parser.next();
    }

    private void startTag(String tagName) throws IOException, XmlPullParserException {
        parser.require(START_TAG, null, tagName);
        parser.next();
    }

    private void endTag(String tagName) throws IOException, XmlPullParserException {
        parser.require(END_TAG, null, tagName);
        parser.next();
    }

    private String getText(String tagName) throws IOException, XmlPullParserException {
        startTag(tagName);
        parser.require(TEXT, null, null);
        String result = parser.getText().trim();
        parser.next();
        endTag(tagName);
        return result;
    }

    private String getKey() throws IOException, XmlPullParserException {
        return getText(KEY);
    }

    private int getInt(String tagName) throws IOException, XmlPullParserException {
        return Integer.parseInt(getText(tagName));
    }

    private boolean getBoolean(String tagName) throws IOException, XmlPullParserException {
        return Boolean.parseBoolean(getText(tagName));
    }

    private Calendar getDate(String tagName) throws IOException, XmlPullParserException {
        int dateInt = Integer.parseInt(getText(tagName));
        int year = dateInt / 10000;
        int month = dateInt / 100 % 100;
        int day = dateInt % 100;
        Calendar calendar = Calendar.getInstance();
        calendar.set(year, month, day, 0, 0, 0);
        return calendar;
    }

    private Date getTime(String tagName) throws IOException, XmlPullParserException {
        int dayTime = Integer.parseInt(getText(tagName)); // seconds since midnight
        return new Date(dayTime * 1000 /* ms */);
    }
}

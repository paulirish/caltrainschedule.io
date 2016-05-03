package me.ranmocy.rcaltrain.models;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service model.
 */
public class Service {

    private static final Map<String, Service> SERVICE_MAP = new HashMap<>();

    public static Service addService(String serviceId, boolean weekday, boolean saturday, boolean sunday, Calendar startDate, Calendar endDate) {
        Service service = new Service(weekday, saturday, sunday, startDate, endDate);
        SERVICE_MAP.put(serviceId, service);
        return service;
    }

    public static Service getService(String serviceId) {
        return SERVICE_MAP.get(serviceId);
    }

    public static List<Service> getAllValidServices(ScheduleType scheduleType) {
        Calendar current = Calendar.getInstance();
        ArrayList<Service> validServices = new ArrayList<>();
        for (Service service : SERVICE_MAP.values()) {
            if (service.isInServiceOn(current) && service.isUnderScheduleType(scheduleType)) {
                validServices.add(service);
            }
        }
        return validServices;
    }

    private enum ExceptionType {
        ADD,
        REMOVE
    }

    private class ExceptionDate {
        private Calendar date;
        private ExceptionType type;

        ExceptionDate(Calendar date, ExceptionType type) {
            this.date = date;
            this.type = type;
        }
    }

    private final boolean weekday;
    private final boolean saturday;
    private final boolean sunday;
    private final Calendar startDate;
    private final Calendar endDate;
    private final List<ExceptionDate> exceptionDates = new ArrayList<>();
    private final List<Trip> trips = new ArrayList<>();

    private Service(boolean weekday, boolean saturday, boolean sunday, Calendar startDate, Calendar endDate) {
        this.weekday = weekday;
        this.saturday = saturday;
        this.sunday = sunday;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public void addAdditionalDate(Calendar date) {
        exceptionDates.add(new ExceptionDate(date, ExceptionType.ADD));
    }

    public void addExceptionDate(Calendar date) {
        exceptionDates.add(new ExceptionDate(date, ExceptionType.REMOVE));
    }

    public Trip addTrip(String id) {
        Trip trip = new Trip(id, this);
        trips.add(trip);
        return trip;
    }

    public List<Trip> getTrips() {
        return trips;
    }

    public boolean isInServiceOn(Calendar current) {
        // (startDate <= current <= endDate
        // && none(exceptionDate == current, exceptionType == REMOVE)
        // || any(exceptionDate == current, exceptionType == ADD)
        for (ExceptionDate exceptionDate : exceptionDates) {
            if (exceptionDate.date.equals(current)) {
                switch (exceptionDate.type) {
                    case ADD:
                        return true;
                    case REMOVE:
                        return false;
                    default:
                        throw new RuntimeException("Unexpected exception type!");
                }
            }
        }
        return !startDate.after(current) && !endDate.before(current);
    }

    private boolean isUnderScheduleType(ScheduleType scheduleType) {
        switch (scheduleType) {
            case NOW:
                Calendar current = Calendar.getInstance();
                int dayOfWeek = current.get(Calendar.DAY_OF_WEEK);
                switch (dayOfWeek) {
                    case Calendar.SUNDAY:
                        return sunday;
                    case Calendar.SATURDAY:
                        return saturday;
                    case Calendar.MONDAY:
                    case Calendar.TUESDAY:
                    case Calendar.WEDNESDAY:
                    case Calendar.THURSDAY:
                    case Calendar.FRIDAY:
                        return weekday;
                    default:
                        throw new RuntimeException("Unexpected dayOfWeek:" + dayOfWeek);
                }
            case WEEKDAY:
                return weekday;
            case SATURDAY:
                return saturday;
            case SUNDAY:
                return sunday;
            default:
                throw new RuntimeException("Unexpected schedule type:" + scheduleType);
        }
    }
}

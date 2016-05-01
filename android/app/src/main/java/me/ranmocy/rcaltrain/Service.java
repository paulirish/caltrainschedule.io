package me.ranmocy.rcaltrain;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by ranmocy on 4/30/16.
 */
public class Service {

    private class ExceptionDate {
        private Date date;
        private int type;

        ExceptionDate(Date date, int type) {
            this.date = date;
            this.type = type;
        }
    }

    private Date startDate;
    private Date endDate;
    private final List<Trip> trips = new ArrayList<>();

    Service() {

    }
}

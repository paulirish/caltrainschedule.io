package me.ranmocy.rcaltrain;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by ranmocy on 4/30/16.
 */
public class Trip {

    public class Stop {

        private final int id;
        private final Date date;

        Stop(int id, Date date) {

            this.id = id;
            this.date = date;
        }
    }

    private String id;
    private final List<Stop> stops = new ArrayList<>();

    Trip() {

    }
}

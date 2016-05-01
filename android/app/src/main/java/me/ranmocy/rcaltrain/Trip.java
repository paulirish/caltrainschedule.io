package me.ranmocy.rcaltrain;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Trip model.
 */
public class Trip {

    public class Stop {

        private final Station station;
        private final Date time;

        private Stop(Station station, Date time) {
            this.station = station;
            this.time = time;
        }

        public Date getTime() {
            return time;
        }
    }

    private String id;
    private Service service;
    private final List<Stop> stops = new ArrayList<>();

    public Trip(String id, Service service) {
        this.id = id;
        this.service = service;
    }

    public void addStop(Station station, Date time) {
        stops.add(new Stop(station, time));
    }

    public List<Stop> getStopList() {
        return stops;
    }

    public List<Station> getStationList() {
        List<Station> stations = new ArrayList<>();
        for (Stop stop : stops) {
            stations.add(stop.station);
        }
        return stations;
    }
}

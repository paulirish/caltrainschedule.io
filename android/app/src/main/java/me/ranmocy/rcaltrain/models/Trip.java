package me.ranmocy.rcaltrain.models;

import java.util.ArrayList;
import java.util.List;

/**
 * Trip model.
 */
public class Trip {

    public class Stop {

        private final Station station;
        private final DayTime time;

        private Stop(Station station, DayTime time) {
            this.station = station;
            this.time = time;
        }

        public DayTime getTime() {
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

    public void addStop(Station station, DayTime time) {
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

package me.ranmocy.rcaltrain.models;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Station model.
 */
public class Station {

    private static final Map<String, Station> NAME_MAP = new HashMap<>();
    private static final Map<Integer, Station> ID_MAP = new HashMap<>();
    private static final List<Station> ALL_STATIONS = new ArrayList<>();

    public static Station addStation(String name, List<Integer> ids) {
        Station station = new Station(name, ids);
        NAME_MAP.put(name, station);
        for (Integer id : ids) {
            ID_MAP.put(id, station);
        }
        ALL_STATIONS.add(station);
        return station;
    }

    public static Station getStation(String name) {
        return NAME_MAP.get(name);
    }

    public static Station getStation(int id) {
        return ID_MAP.get(id);
    }

    public static List<Station> getAllStation() {
        return ALL_STATIONS;
    }

    private final String name;
    private final List<Integer> ids;

    private Station(String name, List<Integer> ids) {
        this.name = name;
        this.ids = ids;
    }

    public String getName() {
        return name;
    }

    public List<Integer> getIds() {
        return ids;
    }
}

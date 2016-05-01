package me.ranmocy.rcaltrain;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by ranmocy on 4/30/16.
 */
public class Station {

    private static final Map<String, Station> NAME_MAP = new HashMap<>();
    private static final Map<Integer, Station> ID_MAP = new HashMap<>();

    public static Station addStation(String name, List<Integer> ids) {
        Station station = new Station(name, ids);
        NAME_MAP.put(name, station);
        for (Integer id : ids) {
            ID_MAP.put(id, station);
        }
        return station;
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

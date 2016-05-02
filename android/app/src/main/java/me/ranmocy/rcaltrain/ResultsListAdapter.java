package me.ranmocy.rcaltrain;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListAdapter;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

/**
 * ListAdapter that shows scheduling result.
 */
public class ResultsListAdapter extends BaseAdapter implements ListAdapter {

    private static final String TAG = "ResultsListAdapter";

    private final LayoutInflater layoutInflater;
    private final List<Result> resultList = new ArrayList<>();

    public ResultsListAdapter(Context context) {
        this.layoutInflater = LayoutInflater.from(context);
    }

    public void setData(String fromName, String toName, ScheduleType scheduleType) {
        Log.i(TAG, String.format("from:%s, to:%s, type:%s", fromName, toName, scheduleType));

        resultList.clear();

        // check service time
        List<Trip> possibleTrips = new ArrayList<>();
        for (Service service : Service.getAllValidServices(scheduleType)) {
            possibleTrips.addAll(service.getTrips());
        }

        // check station
        Station departureStation = Station.getStation(fromName);
        Station arrivalStation = Station.getStation(toName);
        for (Trip trip : possibleTrips) {
            List<Station> stationList = trip.getStationList();
            int departureIndex = stationList.indexOf(departureStation);
            int arrivalIndex = stationList.indexOf(arrivalStation);

            if (departureIndex >= 0 && arrivalIndex >= 0 && departureIndex < arrivalIndex) {
                List<Trip.Stop> stopList = trip.getStopList();
                DayTime departureTime = stopList.get(departureIndex).getTime();
                DayTime arrivalTime = stopList.get(arrivalIndex).getTime();

                // check current time
                if (scheduleType == ScheduleType.NOW && DayTime.now().after(departureTime)) {
                    continue;
                }
                resultList.add(new Result(departureTime, arrivalTime));
            }
        }

        Collections.sort(resultList);

        notifyDataSetChanged();
    }

    public String getNextTime() {
        if (resultList.isEmpty()) {
            return "";
        }
        long nextTrainInMinutes = DayTime.now().toInMinutes(resultList.get(0).departureTime);
        return String.format(Locale.getDefault(), "Next train in %d min", nextTrainInMinutes);
    }

    @Override
    public int getCount() {
        return resultList.size();
    }

    @Override
    public Result getItem(int position) {
        return resultList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public boolean hasStableIds() {
        return false;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = layoutInflater.inflate(R.layout.result_item, parent, false);
            holder = new ViewHolder();
            holder.departureView = (TextView) convertView.findViewById(R.id.departure_time);
            holder.arrivalView = (TextView) convertView.findViewById(R.id.arrival_time);
            holder.intervalView = (TextView) convertView.findViewById(R.id.interval_time);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        Result result = getItem(position);
        holder.departureView.setText(result.getDepartureTimeString());
        holder.arrivalView.setText(result.getArrivalTimeString());
        holder.intervalView.setText(result.getIntervalTimeString());
        return convertView;
    }

    @Override
    public int getItemViewType(int position) {
        return 0;
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    private static class ViewHolder {
        TextView departureView;
        TextView arrivalView;
        TextView intervalView;
    }

    private static class Result implements Comparable<Result> {
        private final DayTime departureTime;
        private final DayTime arrivalTime;
        private final long interval;

        Result(DayTime departureTime, DayTime arrivalTime) {
            this.departureTime = departureTime;
            this.arrivalTime = arrivalTime;
            this.interval = departureTime.toInMinutes(arrivalTime);
        }

        String getDepartureTimeString() {
            return departureTime.toString();
        }

        String getArrivalTimeString() {
            return arrivalTime.toString();
        }

        String getIntervalTimeString() {
            return String.format(Locale.getDefault(), "%d min", interval);
        }

        @Override
        public int compareTo(@NonNull Result another) {
            return this.departureTime.compareTo(another.departureTime);
        }
    }
}

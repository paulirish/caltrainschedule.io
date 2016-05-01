package me.ranmocy.rcaltrain;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListAdapter;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * ListAdapter that shows scheduling result.
 */
public class ResultsListAdapter extends BaseAdapter implements ListAdapter {

    private final LayoutInflater layoutInflater;
    private final List<Result> resultList = new ArrayList<>();

    public ResultsListAdapter(Context context) {
        this.layoutInflater = LayoutInflater.from(context);
    }

    public void setData(String fromName, String toName, ScheduleType scheduleType) {
        List<Trip> possibleTrips = new ArrayList<>();
        for (Service service : Service.getAllValidServices(scheduleType)) {
            possibleTrips.addAll(service.getTrips());
        }

        resultList.clear();

        Station departureStation = Station.getStation(fromName);
        Station arrivalStation = Station.getStation(toName);
        for (Trip trip : possibleTrips) {
            List<Station> stationList = trip.getStationList();
            int departureIndex = stationList.indexOf(departureStation);
            int arrivalIndex = stationList.indexOf(arrivalStation);

            if (departureIndex >= 0 && arrivalIndex >= 0 && departureIndex < arrivalIndex) {
                List<Trip.Stop> stopList = trip.getStopList();
                Date departureTime = stopList.get(departureIndex).getTime();
                Date arrivalTime = stopList.get(arrivalIndex).getTime();
                resultList.add(new Result(departureTime, arrivalTime));
            }
        }

        // TODO: sort results

        notifyDataSetChanged();
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
            convertView = layoutInflater.inflate(R.layout.result_item, parent);
            holder = new ViewHolder();
            holder.departureView = (TextView) convertView.findViewById(R.id.departure_time);
            holder.arrivalView = (TextView) convertView.findViewById(R.id.arrival_time);
            holder.intervalView = (TextView) convertView.findViewById(R.id.interval_time);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        Result result = getItem(position);
        holder.departureView.setText(result.getDepartureTime());
        holder.arrivalView.setText(result.getArrivalTime());
        holder.intervalView.setText(result.getIntervalTime());
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

    private static class Result {
        private final Date departureTime;
        private final Date arrivalTime;

        Result(Date departureTime, Date arrivalTime) {
            this.departureTime = departureTime;
            this.arrivalTime = arrivalTime;
        }

        String getDepartureTime() {
            return departureTime.toString();
        }

        public String getArrivalTime() {
            return arrivalTime.toString();
        }

        public String getIntervalTime() {
            long intervalMs = arrivalTime.getTime() - departureTime.getTime();
            return String.format(Locale.getDefault(), "%d min", intervalMs / 1000 / 60);
        }
    }
}

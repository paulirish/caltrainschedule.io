package me.ranmocy.rcaltrain;

import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.google.firebase.analytics.FirebaseAnalytics;

import me.ranmocy.rcaltrain.models.ScheduleType;
import me.ranmocy.rcaltrain.models.Station;
import me.ranmocy.rcaltrain.ui.ResultsListAdapter;
import me.ranmocy.rcaltrain.ui.StationListAdapter;

public class HomeActivity extends AppCompatActivity implements View.OnClickListener {

    private static final String TAG = "HomeActivity";

    private Preferences preferences;
    private TextView departureView;
    private TextView arrivalView;
    private RadioGroup scheduleGroup;
    private TextView nextTrainView;
    private ResultsListAdapter resultsAdapter;
    private FirebaseAnalytics firebaseAnalytics;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        firebaseAnalytics = FirebaseAnalytics.getInstance(this);

        setContentView(R.layout.activity_home);
//        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
//        setSupportActionBar(toolbar);

        DataLoader.loadDataIfNot(this);

        // find all views
        departureView = (TextView) findViewById(R.id.input_departure);
        arrivalView = (TextView) findViewById(R.id.input_arrival);
        scheduleGroup = (RadioGroup) findViewById(R.id.schedule_group);
        nextTrainView = (TextView) findViewById(R.id.next_train);

        // Setup result view
        ListView resultsView = (ListView) findViewById(R.id.results);
        assert resultsView != null;
        resultsAdapter = new ResultsListAdapter(this);
        resultsView.setAdapter(resultsAdapter);

        // Load preferences
        preferences = new Preferences(this);
        // TODO: check saved station name, invalid it if it's not in our list.
        departureView.setText(preferences.getLastDepartureStationName());
        arrivalView.setText(preferences.getLastDestinationStationName());
        switch (preferences.getLastScheduleType()) {
            case NOW:
                scheduleGroup.check(R.id.btn_now);
                break;
            case WEEKDAY:
                scheduleGroup.check(R.id.btn_week);
                break;
            case SATURDAY:
                scheduleGroup.check(R.id.btn_sat);
                break;
            case SUNDAY:
                scheduleGroup.check(R.id.btn_sun);
                break;
        }

        // Init schedule
        reschedule();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_home, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View v) {
        Log.v(TAG, "onClick:" + v);
        switch (v.getId()) {
            case R.id.input_departure:
                showStationSelector(true);
                firebaseAnalytics.logEvent(Events.EVENT_ON_CLICK, Events.getClickDepartureEvent());
                return;
            case R.id.input_arrival:
                showStationSelector(false);
                firebaseAnalytics.logEvent(Events.EVENT_ON_CLICK, Events.getClickArrivalEvent());
                return;
            case R.id.switch_btn:
                CharSequence departureViewText = departureView.getText();
                CharSequence arrivalViewText = arrivalView.getText();
                departureView.setText(arrivalViewText);
                arrivalView.setText(departureViewText);
                preferences.setLastSourceStationName(departureViewText.toString());
                preferences.setLastDestinationStationName(arrivalViewText.toString());
                firebaseAnalytics.logEvent(Events.EVENT_ON_CLICK, Events.getClickSwitchEvent());
                break;
            case R.id.btn_now:
                preferences.setLastScheduleType(ScheduleType.NOW);
                firebaseAnalytics.logEvent(Events.EVENT_ON_CLICK, Events.getClickScheduleEvent(ScheduleType.NOW));
                break;
            case R.id.btn_week:
                preferences.setLastScheduleType(ScheduleType.WEEKDAY);
                firebaseAnalytics.logEvent(Events.EVENT_ON_CLICK, Events.getClickScheduleEvent(ScheduleType.WEEKDAY));
                break;
            case R.id.btn_sat:
                preferences.setLastScheduleType(ScheduleType.SATURDAY);
                firebaseAnalytics.logEvent(Events.EVENT_ON_CLICK, Events.getClickScheduleEvent(ScheduleType.SATURDAY));
                break;
            case R.id.btn_sun:
                preferences.setLastScheduleType(ScheduleType.SUNDAY);
                firebaseAnalytics.logEvent(Events.EVENT_ON_CLICK, Events.getClickScheduleEvent(ScheduleType.SUNDAY));
                break;
            case R.id.schedule_group:
                Log.v(TAG, "schedule_group");
                return;
            default:
                return;
        }
        reschedule();
    }

    private void showStationSelector(final boolean isDeparture) {
        new AlertDialog.Builder(this)
                .setAdapter(new StationListAdapter(this), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        String stationName = Station.getAllStation().get(which).getName();
                        if (isDeparture) {
                            preferences.setLastSourceStationName(stationName);
                            departureView.setText(stationName);
                        } else {
                            preferences.setLastDestinationStationName(stationName);
                            arrivalView.setText(stationName);
                        }
                        dialog.dismiss();
                        reschedule();
                    }
                })
                .setCancelable(false)
                .show();
    }

    private void reschedule() {
        String departure = departureView.getText().toString();
        String destination = arrivalView.getText().toString();

        // reschedule, update results data
        ScheduleType scheduleType;
        switch (scheduleGroup.getCheckedRadioButtonId()) {
            case -1:
                Log.v(TAG, "No schedule selected, skip.");
                return;
            case R.id.btn_now:
                scheduleType = ScheduleType.NOW;
                break;
            case R.id.btn_week:
                scheduleType = ScheduleType.WEEKDAY;
                break;
            case R.id.btn_sat:
                scheduleType = ScheduleType.SATURDAY;
                break;
            case R.id.btn_sun:
                scheduleType = ScheduleType.SUNDAY;
                break;
            default:
                throw new RuntimeException("Unexpected schedule selection:" + scheduleGroup.getCheckedRadioButtonId());
        }

        firebaseAnalytics.logEvent(
                Events.EVENT_SCHEDULE,
                Events.getScheduleEvent(departure, destination, scheduleType));

        resultsAdapter.setData(departure, destination, scheduleType);
        if (scheduleGroup.getCheckedRadioButtonId() == R.id.btn_now) {
            nextTrainView.setText(resultsAdapter.getNextTime());
            nextTrainView.setVisibility(View.VISIBLE);
        } else {
            nextTrainView.setVisibility(View.GONE);
        }
    }
}

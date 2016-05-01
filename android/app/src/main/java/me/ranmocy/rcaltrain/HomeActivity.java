package me.ranmocy.rcaltrain;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.RadioGroup;

public class HomeActivity extends AppCompatActivity implements View.OnClickListener {

    private static final String TAG = "HomeActivity";

    private Preferences preferences;
    private ResultsListAdapter resultsAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DataLoader.loadDataIfNot(this);

        preferences = new Preferences(this);
        String departureName = preferences.getLastDepartureStationName();
        String destinationName = preferences.getLastDestinationStationName();
        // TODO: update from/to view

        resultsAdapter = new ResultsListAdapter(this);
        ListView resultsView = (ListView) findViewById(R.id.results);
        assert resultsView != null;
        resultsView.setAdapter(resultsAdapter);

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
        reschedule();
    }

    private void reschedule() {
        // reschedule, update results data
        EditText fromView = (EditText) findViewById(R.id.input_departure);
        assert fromView != null;
        EditText toView = (EditText) findViewById(R.id.input_destination);
        assert toView != null;
        RadioGroup scheduleGroup = (RadioGroup) findViewById(R.id.schedule_group);
        assert scheduleGroup != null;
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
                throw new RuntimeException("Unexpected schedule selection");
        }
        resultsAdapter.setData(fromView.getText().toString(), toView.getText().toString(), scheduleType);
    }
}

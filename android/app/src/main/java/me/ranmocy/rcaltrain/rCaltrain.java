package me.ranmocy.rcaltrain;

import android.app.Application;

import com.squareup.leakcanary.LeakCanary;

/**
 * rCaltrain Application
 */
public final class rCaltrain extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        LeakCanary.install(this);
    }
}

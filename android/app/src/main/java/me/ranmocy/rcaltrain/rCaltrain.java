package me.ranmocy.rcaltrain;

import android.app.Application;

/**
 * rCaltrain Application
 */
public final class rCaltrain extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        DataLoader.loadDataIfNot(this);
    }
}

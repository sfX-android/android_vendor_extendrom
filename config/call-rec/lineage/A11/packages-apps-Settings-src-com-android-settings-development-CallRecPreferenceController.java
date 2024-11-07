/*
 *
 * Copyright (C) 2024 steadfasterX <steadfasterX |AT| binbash #DOT# rocks>
 * LICENSE: GNU General Public License v3.0
 *
 */

package com.android.settings.development;

import android.content.Context;
import android.provider.Settings;

import androidx.annotation.VisibleForTesting;
import androidx.preference.Preference;
import androidx.preference.SwitchPreference;

import com.android.settings.core.PreferenceControllerMixin;
import com.android.settingslib.development.DeveloperOptionsPreferenceController;

public class ER_CallRecPreferenceController extends DeveloperOptionsPreferenceController
        implements Preference.OnPreferenceChangeListener, PreferenceControllerMixin {

    private static final String ER_ALLOW_ANY_CALL_REC_KEY = "extendrom_call_recording";

    @VisibleForTesting
    static final int SETTING_VALUE_ON = 1;
    @VisibleForTesting
    static final int SETTING_VALUE_OFF = 0;

    public ER_CallRecPreferenceController(Context context) {
        super(context);
    }

    @Override
    public String getPreferenceKey() {
        return ER_ALLOW_ANY_CALL_REC_KEY;
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        final boolean isEnabled = (Boolean) newValue;
        Settings.Secure.putInt(mContext.getContentResolver(),
                Settings.Secure.ER_ALLOW_ANY_CALL_REC,
                isEnabled ? SETTING_VALUE_ON : SETTING_VALUE_OFF);
        return true;
    }

    @Override
    public void updateState(Preference preference) {
        final int recMode = Settings.Secure.getInt(mContext.getContentResolver(),
                Settings.Secure.ER_ALLOW_ANY_CALL_REC, SETTING_VALUE_OFF);

        ((SwitchPreference) mPreference).setChecked(recMode != SETTING_VALUE_OFF);
    }

    @Override
    protected void onDeveloperOptionsSwitchDisabled() {
        super.onDeveloperOptionsSwitchDisabled();
        Settings.Secure.putInt(mContext.getContentResolver(),
                Settings.Secure.ER_ALLOW_ANY_CALL_REC, SETTING_VALUE_OFF);
        ((SwitchPreference) mPreference).setChecked(false);
    }
}

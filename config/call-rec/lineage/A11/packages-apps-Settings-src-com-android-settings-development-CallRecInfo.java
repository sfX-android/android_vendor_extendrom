/*
 *
 * Copyright (C) 2024 steadfasterX <steadfasterX |AT| binbash #DOT# rocks>
 * LICENSE: GNU General Public License v3.0
 *
 */

package com.android.settings.development;

import android.content.Context;
import androidx.preference.Preference;
import com.android.settings.core.PreferenceControllerMixin;
import com.android.settingslib.development.DeveloperOptionsPreferenceController;

public class ER_CallRecInfo extends DeveloperOptionsPreferenceController
        implements Preference.OnPreferenceChangeListener, PreferenceControllerMixin {

    private static final String ER_ALLOW_ANY_CALL_REC_KEY_INFO = "extendrom_call_recording_info";

    public ER_CallRecInfo(Context context) {
        super(context);
    }

    @Override
    public String getPreferenceKey() {
        return ER_ALLOW_ANY_CALL_REC_KEY_INFO;
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        return true;
    }
}

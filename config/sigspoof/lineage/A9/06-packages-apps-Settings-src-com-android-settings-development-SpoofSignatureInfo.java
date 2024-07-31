/*
 *
 * Copyright (C) 2019-2024 steadfasterX <steadfasterX |AT| binbash #DOT# rocks>
 * LICENSE: GNU General Public License v3.0
 *
 */

package com.android.settings.development;

import android.content.Context;
import android.support.v7.preference.Preference;
import com.android.settings.core.PreferenceControllerMixin;
import com.android.settingslib.development.DeveloperOptionsPreferenceController;

public class SpoofSignatureInfo extends DeveloperOptionsPreferenceController
        implements Preference.OnPreferenceChangeListener, PreferenceControllerMixin {

    private static final String ALLOW_SIGNATURE_FAKE_KEY_INFO = "allow_signature_fake_info";

    public SpoofSignatureInfo(Context context) {
        super(context);
    }

    @Override
    public String getPreferenceKey() {
        return ALLOW_SIGNATURE_FAKE_KEY_INFO;
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        return true;
    }
}

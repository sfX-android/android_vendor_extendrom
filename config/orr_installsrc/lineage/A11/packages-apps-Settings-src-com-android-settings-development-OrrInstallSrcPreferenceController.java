/*
 *
 * Copyright (C) 2024 steadfasterX <steadfasterX |AT| binbash #DOT# rocks>
 * LICENSE: GNU General Public License v3.0
 *
 */

package com.android.settings.development;

import android.content.Context;
import android.os.SystemProperties;

import androidx.annotation.VisibleForTesting;
import androidx.preference.Preference;
import androidx.preference.SwitchPreference;

import com.android.settings.core.PreferenceControllerMixin;
import com.android.settingslib.development.DeveloperOptionsPreferenceController;

public class ER_OrrInstallSrcPreferenceController extends DeveloperOptionsPreferenceController
        implements Preference.OnPreferenceChangeListener, PreferenceControllerMixin {

    private static final String ER_ORR_INSTALLSRC_KEY = "extendrom_orr_installsrc";
    private static final String PERSIST_PROPERTY_ER_ORR_INSTALLSRC = "persist.vendor.er.orrinstallsrc";

    @VisibleForTesting
    static final String SETTING_VALUE_ENABLED = "enabled";
    @VisibleForTesting
    static final String SETTING_VALUE_DISABLED = "disabled";

    public ER_OrrInstallSrcPreferenceController(Context context) {
        super(context);
    }

    @Override
    public String getPreferenceKey() {
        return ER_ORR_INSTALLSRC_KEY;
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        final boolean isEnabled = (Boolean) newValue;
        SystemProperties.set(PERSIST_PROPERTY_ER_ORR_INSTALLSRC,
                isEnabled ? SETTING_VALUE_ENABLED : SETTING_VALUE_DISABLED);
        return true;
    }

    @Override
    public void updateState(Preference preference) {
        final String recMode = SystemProperties.get(PERSIST_PROPERTY_ER_ORR_INSTALLSRC, SETTING_VALUE_DISABLED);
        ((SwitchPreference) preference).setChecked(SETTING_VALUE_ENABLED.equals(recMode));
    }

    @Override
    protected void onDeveloperOptionsSwitchDisabled() {
        super.onDeveloperOptionsSwitchDisabled();
        SystemProperties.set(PERSIST_PROPERTY_ER_ORR_INSTALLSRC, SETTING_VALUE_DISABLED);
        ((SwitchPreference) mPreference).setChecked(false);
    }
}

/*
 *
 * Copyright (C) 2025 steadfasterX <steadfasterX |AT| binbash #DOT# rocks>
 * LICENSE: GNU General Public License v3.0
 *
 */

package com.android.settings.development;

import android.content.Context;
import androidx.preference.Preference;
import com.android.settings.core.PreferenceControllerMixin;
import com.android.settingslib.development.DeveloperOptionsPreferenceController;

public class ER_OrrInstallSrcInfo extends DeveloperOptionsPreferenceController
        implements Preference.OnPreferenceChangeListener, PreferenceControllerMixin {

    private static final String ER_ORR_INSTALLSRC_KEY_INFO = "extendrom_orr_installsrc_info";

    public ER_OrrInstallSrcInfo(Context context) {
        super(context);
    }

    @Override
    public String getPreferenceKey() {
        return ER_ORR_INSTALLSRC_KEY_INFO;
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        return true;
    }
}

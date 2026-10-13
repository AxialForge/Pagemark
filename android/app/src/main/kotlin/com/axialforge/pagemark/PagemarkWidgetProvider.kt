package com.axialforge.pagemark

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget: what you are reading and your yearly goal. The text is written by Dart (lib/widget_sync.dart) from the main
 * library only; the locked library never reaches it. Tapping it opens Pagemark.
 */
class PagemarkWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.pagemark_widget).apply {
                setTextViewText(R.id.w_goal, widgetData.getString("w_goal", null) ?: context.getString(R.string.widget_empty_goal))
                setTextViewText(R.id.w_reading, widgetData.getString("w_reading", null) ?: context.getString(R.string.widget_empty_reading))
                setOnClickPendingIntent(R.id.w_root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java))
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

package com.example.foodapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            
            // 카운터 값 읽기
            val counter = widgetData.getInt("_counter", 0)
            views.setTextViewText(R.id.counter_text, "Counter: $counter")
            
            // 이미지 리소스 ID 직접 사용
            val imageResId = when (counter) {
                in 0..10 -> R.drawable.cool_fridge
                in 11..20 -> R.drawable.sad
                else -> R.drawable.cool_fridge
            }
            views.setImageViewResource(R.id.image_view, imageResId)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

package com.example.foodapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            
            // SharedPreferences에서 "achievementText" 값을 String으로 불러오기
            val achievementText = widgetData.getString("achievementText", "데이터가 없습니다.")
            // 텍스트 뷰에 성취도 텍스트 설정
            views.setTextViewText(R.id.achievement_text_view, achievementText)

            // SharedPreferences에서 "imagePath" 값을 String으로 불러오고 이미지 리소스 ID 매핑
            val imagePath = widgetData.getString("imagePath", "assets/images/cool_fridge.png") ?: "assets/images/cool_fridge.png"
            val imageResId = when (imagePath) {
                "assets/images/sad.png" -> R.drawable.sad
                "assets/images/soso.png" -> R.drawable.soso
                "assets/images/cool_fridge.png" -> R.drawable.cool_fridge
                else -> R.drawable.cool_fridge // 기본 이미지 설정
            }
            views.setImageViewResource(R.id.image_view, imageResId)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

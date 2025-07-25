package com.naimjae.todo.todo;
import com.naimjae.todo.todo.WidgetUpdateScheduler;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;
import android.widget.RemoteViews;
import android.content.Intent;
import android.app.PendingIntent;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class HomeSmallWidgetProvider extends AppWidgetProvider {
    private final int MAX_TASKS = 5;

    // onEnabled() : 위젯이 처음 홈 화면에 추가될 때 1번 실행
    @Override
    public void onEnabled(Context context) {
        super.onEnabled(context);
        WidgetUpdateScheduler.scheduleDailyUpdate(context);
    }

    // onUpdate() : 위젯이 업데이트될 때마다 실행
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        SimpleDateFormat dateKeyFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        SimpleDateFormat dateTextFormat = new SimpleDateFormat("M월 dd일", Locale.KOREA);
        SimpleDateFormat dayTextFormat = new SimpleDateFormat("EEEE", Locale.KOREA);

        Date today = new Date();
        String todayKey = "flutter.task_list." + dateKeyFormat.format(today);
        String todayJson = prefs.getString(todayKey, "[]");

        try {
            JSONArray todayArray = new JSONArray(todayJson);

            for (int widgetId : appWidgetIds) {
                RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.small_widget_layout);

                // 날짜 텍스트 세팅
                views.setTextViewText(R.id.date_text_today, dateTextFormat.format(today) + " " + dayTextFormat.format(today));

                // 오늘 일정 표시
                for (int i = 0; i < MAX_TASKS; i++) {
                    int viewId = context.getResources().getIdentifier("task1" + (i + 1), "id", context.getPackageName());
                    if (i < todayArray.length()) {
                        JSONObject task = todayArray.getJSONObject(i);
                        String time = task.has("time") && !task.isNull("time") ? task.getString("time") + " " : "";
                        views.setTextViewText(viewId, "✔ " + time + task.getString("title"));
                        views.setViewVisibility(viewId, android.view.View.VISIBLE);
                    } else {
                        views.setViewVisibility(viewId, android.view.View.GONE);
                    }
                }

                // 위젯 클릭 시 앱 실행 코드
                Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                if (launchIntent != null) {
                    PendingIntent pendingIntent = PendingIntent.getActivity(
                            context,
                            0,
                            launchIntent,
                            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                    );
                    // R.id.widget_root는 클릭 영역이 설정된 View의 ID
                    views.setOnClickPendingIntent(R.id.small_widget_layout, pendingIntent);
                }
                // 위젯 클릭 시 앱 실행 코드

                appWidgetManager.updateAppWidget(widgetId, views);
            }
        } catch (JSONException e) {
            Log.e("HomeSmallWidgetProvider", "JSON parsing error", e);
        }
    }
}

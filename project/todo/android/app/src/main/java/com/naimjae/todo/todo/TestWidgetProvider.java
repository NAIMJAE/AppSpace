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
import android.view.View;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.graphics.Color;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class TestWidgetProvider extends AppWidgetProvider {

    private final int MAX_NEXT_EVENTS = 3;

    @Override
    public void onEnabled(Context context) {
        super.onEnabled(context);
        WidgetUpdateScheduler.scheduleDailyUpdate(context);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        SimpleDateFormat keyFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        SimpleDateFormat dateFormat = new SimpleDateFormat("MM.dd (E)", Locale.KOREA);
        SimpleDateFormat dayTextFormat = new SimpleDateFormat("E", Locale.KOREA);

        Date today = new Date();
        Date tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
        Date afterTomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000 * 2);

        String todayKey = "flutter.task_list." + keyFormat.format(today);
        String tomorrowKey = "flutter.task_list." + keyFormat.format(tomorrow);
        String afterTomorrowKey = "flutter.task_list." + keyFormat.format(afterTomorrow);

        String todayJson = prefs.getString(todayKey, "[]");
        String tomorrowJson = prefs.getString(tomorrowKey, "[]");
        String afterTomorrowJson = prefs.getString(afterTomorrowKey, "[]");

        try {
            JSONArray todayArray = new JSONArray(todayJson);
            JSONArray tomorrowArray = new JSONArray(tomorrowJson);
            JSONArray afterTomorrowArray = new JSONArray(afterTomorrowJson);

            for (int widgetId : appWidgetIds) {
                RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.test_widget_layout);

//                // 헤더 날짜 표시
//                String headerText = keyFormat.format(today).replaceFirst("-", "년 ").replaceFirst("-", "월 ") + "일";
//                views.setTextViewText(R.id.date_title, headerText);

                // 오늘 일정 표시
                String todayDateText = dateFormat.format(today);
                views.setTextViewText(R.id.today_date, todayDateText);
                for (int i = 0; i < MAX_NEXT_EVENTS; i++) {
                    int viewId = context.getResources().getIdentifier("today_event1" + (i + 1), "id", context.getPackageName());
                    if (i < todayArray.length()) {
                        JSONObject task = todayArray.getJSONObject(i);
                        String time = task.has("time") && !task.isNull("time") ? task.getString("time") + " " : "";
                        views.setViewVisibility(viewId, View.VISIBLE);
                        views.setTextViewText(viewId, time + task.getString("title"));
                    } else {
                        if (i == 0) {
                            views.setViewVisibility(viewId, View.VISIBLE);
                            views.setTextViewText(viewId, "일정 없음");
                        } else {
                            views.setViewVisibility(viewId, View.GONE); // 숨김 처리
                        }
                    }
                }

                // 내일 일정 표시
                String tomorrowDateText = dateFormat.format(tomorrow);
                views.setTextViewText(R.id.next1_date, tomorrowDateText);
                for (int i = 0; i < MAX_NEXT_EVENTS; i++) {
                    int viewId = context.getResources().getIdentifier("next_event1" + (i + 1), "id", context.getPackageName());
                    if (i < tomorrowArray.length()) {
                        JSONObject task = tomorrowArray.getJSONObject(i);
                        String time = task.has("time") && !task.isNull("time") ? task.getString("time") + " " : "";
                        views.setViewVisibility(viewId, View.VISIBLE);
                        views.setTextViewText(viewId, time + task.getString("title"));
                    } else {
                        if (i == 0) {
                            views.setViewVisibility(viewId, View.VISIBLE);
                            views.setTextViewText(viewId, "일정 없음");
                        } else {
                            views.setViewVisibility(viewId, View.GONE); // 숨김 처리
                        }
                    }
                }

                // 모레 일정 표시
                String afterTomorrowDateText = dateFormat.format(afterTomorrow);
                views.setTextViewText(R.id.next2_date, afterTomorrowDateText);
                for (int i = 0; i < MAX_NEXT_EVENTS; i++) {
                    int viewId = context.getResources().getIdentifier("next_event2" + (i + 1), "id", context.getPackageName());
                    if (i < afterTomorrowArray.length()) {
                        JSONObject task = afterTomorrowArray.getJSONObject(i);
                        String time = task.has("time") && !task.isNull("time") ? task.getString("time") + " " : "";
                        views.setViewVisibility(viewId, View.VISIBLE);
                        views.setTextViewText(viewId, time + task.getString("title"));
                    } else {
                        if (i == 0) {
                            views.setViewVisibility(viewId, View.VISIBLE);
                            views.setTextViewText(viewId, "일정 없음");
                        } else {
                            views.setViewVisibility(viewId, View.GONE); // 숨김 처리
                        }
                    }
                }

                // 클릭 시 앱 실행
                Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                if (launchIntent != null) {
                    PendingIntent pendingIntent = PendingIntent.getActivity(
                            context,
                            0,
                            launchIntent,
                            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                    );
                    views.setOnClickPendingIntent(R.id.test_widget_layout, pendingIntent);
                }

                appWidgetManager.updateAppWidget(widgetId, views);
            }
        } catch (JSONException e) {
            Log.e("TestWidgetProvider", "JSON parsing error", e);
        }
    }
}
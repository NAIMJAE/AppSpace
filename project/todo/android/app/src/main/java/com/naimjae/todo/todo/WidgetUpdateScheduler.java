package com.naimjae.todo.todo;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import java.util.Calendar;

/**
 * 위젯 자동 갱신을 위한 알람 스케줄러 클래스
 * - 매일 자정(00:00)에 위젯이 업데이트되도록 AlarmManager를 설정
 * - HomeLargeWidgetProvider의 onUpdate()를 트리거하여 오늘 날짜에 해당하는 데이터를 새로 반영
 * 
 * - 사용자가 위젯을 등록하면 widgetProvider 클래스 실행
 * - CRUD를 통해 내용을 변경하고 HomeWidget.updateWidget()을 실행하면 widgetProvider 클래스 실행
 * - 매일 밤 00시에 위젯의 내용을 업데이트하기 위해 widgetProvider 클래스를 최초 실행할 때
 *   아래의 WidgetUpdateScheduler를 실행시켜 스케줄러를 등록해 백그라운드 상황에서도 데이터를 업데이트하게 함
 */
public class WidgetUpdateScheduler {
    public static void scheduleDailyUpdate(Context context) {
        scheduleUpdateForWidget(context, HomeLargeWidgetProvider.class, "com.naimjae.todo.APPWIDGET_UPDATE");
        scheduleUpdateForWidget(context, HomeSmallWidgetProvider.class, "com.naimjae.todo.APPWIDGET_UPDATE");
        scheduleUpdateForWidget(context, TestWidgetProvider.class, "com.naimjae.todo.APPWIDGET_UPDATE");
    }

    private static void scheduleUpdateForWidget(Context context, Class<?> widgetClass, String action) {
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);

        int[] appWidgetIds = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(new ComponentName(context, widgetClass));

        // 예외 방지: 위젯이 없으면 스케줄링 건너뜀
        if (appWidgetIds == null || appWidgetIds.length == 0) {
            return;
        }

        Intent intent = new Intent(context, widgetClass);
        intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds);

        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                action.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        calendar.add(Calendar.DAY_OF_MONTH, 1);

        alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                calendar.getTimeInMillis(),
                pendingIntent
        );
    }
}


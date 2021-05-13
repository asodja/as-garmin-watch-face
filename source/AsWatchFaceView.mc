import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.System;
import Toybox.Weather;

class AsWatchFaceView extends WatchUi.WatchFace {

    private var lines = [];
    private var labels = [];
    private var values = [];
    private var meterTypes = [];

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        // Top
        var helper = new LineHelper(dc);
        lines.add(helper.lineOf(0.05, 0.36, 0.95, 0.36));
        lines.add(helper.lineOf(0.37, 0.36, 0.37, 0.14));
        lines.add(helper.lineOf(0.63, 0.36, 0.63, 0.14));
        
        // Bottom
        lines.add(helper.lineOf(0.05, 0.66, 0.95, 0.66));
        lines.add(helper.lineOf(0.37, 0.66, 0.37, 0.88));
        lines.add(helper.lineOf(0.63, 0.66, 0.63, 0.88));
        
        cacheDrawables();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        updateDate();
        updateClock();
        updateFields();
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        drawLines(dc);
    }
    
    hidden function drawLines(dc as Dc) as Void {
        dc.setColor(getApp().getProperty("LinesColor") as Number, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var i = 0; i < lines.size(); i++) {
            dc.drawLine(lines[i][0], lines[i][1], lines[i][2], lines[i][3]);
        }
    }
    
    hidden function updateDate() as Void {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var view = View.findDrawableById("DateLabel") as Text;
        var clockTime = System.getClockTime();
        view.setColor(getApp().getProperty("ValueColor") as Number);
        view.setText(info.day_of_week + "\n" + info.day);
    }
   
    
    hidden function updateClock() as Void {
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var seconds = clockTime.sec;
        var timeFormatSetting = getApp().getProperty("TimeFormat");
        if (timeFormatSetting == MILITARY_TIME_FORMANT) {
            timeFormat = "$1$$2$";
            hours = hours.format("%02d");
        } else if (timeFormatSetting == SYSTEM_TIME_FORMAT && !System.getDeviceSettings().is24Hour || timeFormatSetting == H12_TIME_FORMAT) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var timePrefix = hours < 10 ? "0" : "";
        var timeString = timePrefix + Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        // Hours
        var hoursView = View.findDrawableById("TimeLabel") as Text;
        hoursView.setColor(getApp().getProperty("ValueColor") as Number);
        hoursView.setText(timeString);

        // Seconds
        var secondsView = View.findDrawableById("SecondsLabel") as Text;
        var secondsPrefix = seconds < 10 ? "0" : "";
        secondsView.setColor(getApp().getProperty("ValueColor") as Number);
        secondsView.setText(secondsPrefix + seconds.toString());
    }
    
    hidden function updateFields() {
        for(var i = 0; i < 6; i++) {
            var label = labels[i] as Text;
            label.setColor(getApp().getProperty("LabelColor") as Number);
            var value = values[i] as Text;
            value.setColor(getApp().getProperty("ValueColor") as Number);
            var meterType = meterTypes[i];
            updateMeter(meterType, label, value);
        }
    }
    
    hidden function updateMeter(meterType as MeterType, label as Text, value as Text) as Void {
        var info = ActivityMonitor.getInfo();
        var activityInfo = Activity.getActivityInfo();
        switch(meterType) {
            case METER_OFF:
                label.setText("");
                value.setText("");
                break;
            case METER_BATTERY:
                label.setText("Batt");
                value.setText(System.getSystemStats().battery.toLong() + "%");
                break;
            case METER_CALORIES:
                label.setText("KCal");
                value.setText(info.calories.toString());
                break;
            case METER_HEARTRATE:
                label.setText("Heart");
                var heartRate = getHeartRate();
                if (heartRate == null) {
                    value.setText("--");
                } else {
                    value.setText(heartRate.toString());
                }
                break;
            case METER_ALTITUDE:
                label.setText("Alt");
                if (activityInfo.altitude == null) {
                    value.setText("--");
                } else if (activityInfo.altitude >= 10000) {
                    value.setText((activityInfo.altitude / 1000.0).format("%.1f") + "km");
                } else {
                    value.setText(activityInfo.altitude.toLong() + "m");
                }
                break;
            case METER_TEMPERATURE:
                label.setText("Temp");
                var temperature = Weather.getCurrentConditions().temperature;
                if (temperature == null) {
                    value.setText("--");
                } else {
                    value.setText(temperature.toLong() + "ºC");
                }
                break;
            case METER_NOTIFICATIONS:
                label.setText("Notifs");
                if (System.getDeviceSettings().notificationCount > 0) {
                    value.setText(System.getDeviceSettings().notificationCount.toString());
                } else {
                    value.setText("0");
                }
                break;
        }
    }
    
    hidden function getHeartRate() {
        var heartRate = Activity.getActivityInfo().currentHeartRate;
        if(heartRate == null) {
            var history = ActivityMonitor.getHeartRateHistory(1, true);
            var sample = history.next();
            if(sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE){
                heartRate = sample.heartRate;
            }
        }
        return heartRate;
    }
    
    hidden function getTemperature() {
        var temperature = null;
        var sample = SensorHistory.getTemperatureHistory(1, true).next();
        if (sample != null && sample.data != null) {
            temperature = sample.data;
        }
        return temperature;
    }
    
    function onSettingsChanged() as Void {
        cacheDrawables();
    }
    
    hidden function cacheDrawables() {
        labels = [];
        values = [];
        meterTypes = [];
        var array = ["Top", "Bottom"];
        for (var j = 0; j < array.size(); j++) {
            var position = array[j];
            for( var i = 1; i <= 3; i++) {
                labels.add(View.findDrawableById(position + "Label" + i));
                values.add(View.findDrawableById(position + "Value" + i));
                meterTypes.add(getApp().getProperty(position + "Meter" + i));
            }
        }
    }
    
 
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}

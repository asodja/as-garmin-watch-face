import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class AsWatchFaceApp extends Application.AppBase {

	var view;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
    	view = new AsWatchFaceView();
        return [ view ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
    	view.onSettingsChanged();
        WatchUi.requestUpdate();
    }

}

function getApp() as AsWatchFaceApp {
    return Application.getApp() as AsWatchFaceApp;
}
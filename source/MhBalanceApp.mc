import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

//! Application entry point for the MH Balance Garmin watch face.
class MhBalanceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
    }

    function onStop(state as Lang.Dictionary?) as Void {
    }

    //! Return the initial view and delegate for the watch face.
    function getInitialView() as [ WatchUi.Views ] or [ WatchUi.Views, WatchUi.InputDelegates ] {
        return [ new MhBalanceView() ];
    }
}

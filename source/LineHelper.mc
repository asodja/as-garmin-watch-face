import Toybox.Graphics;

class LineHelper {

    protected var dc as Dc;

    function initialize(aDc as Dc) {
        dc = aDc;
    }

    function lineOf(x1 as Float, y1 as Float, x2 as Float, y2 as Float) as Array {
        return [xAbsolute(x1), yAbsolute(y1), xAbsolute(x2), yAbsolute(y2)];
    }
    
    hidden function yAbsolute(percent as Float) as Integer {
        return Math.ceil(dc.getHeight() * percent);
    }
    
    hidden function xAbsolute(percent as Float) as Integer {
        return Math.ceil(dc.getWidth() * percent);
    }

}
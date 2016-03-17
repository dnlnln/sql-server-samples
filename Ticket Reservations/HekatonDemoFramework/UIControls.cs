using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MediaColor = System.Windows.Media.Color;

namespace DemoWorkload
{
    public class UIControls
    {
        public CircularGauge.CircularGaugeControl speedDial = new CircularGauge.CircularGaugeControl();

        public UIControls()
        {
            SpeedDialInit();
        }
        private void SpeedDialInit()
        {
            // Initialize CircularGauge Control
            speedDial.Radius = 120;
            speedDial.DialBorderThickness = 0;
            speedDial.ScaleRadius = 110;
            speedDial.ScaleStartAngle = 120;
            speedDial.ResetPointerOnStartUp = true;
            speedDial.ScaleSweepAngle = 300;
            speedDial.PointerLength = 85;
            speedDial.PointerCapRadius = 0;
            speedDial.MinValue = 0;
            speedDial.MaxValue = 60;
            speedDial.DialText = "0";            
            speedDial.MajorDivisionsCount = 10;
            speedDial.MinorDivisionsCount = 5;
            speedDial.RangeIndicatorThickness = 0;
            speedDial.RangeIndicatorRadius = 0;
            speedDial.ScaleLabelRadius = 90;
            speedDial.ScaleLabelFontSize = 12;
            speedDial.ScaleLabelForeground = MediaColor.FromRgb(0, 0, 0); // Black
            speedDial.MajorTickColor = MediaColor.FromRgb(169, 169, 169); // DarkGray
            speedDial.MinorTickColor = MediaColor.FromRgb(169, 169, 169); // DarkGray
            speedDial.ImageOffset = -50;
            speedDial.GaugeBackgroundColor = MediaColor.FromRgb(255, 255, 255); // White
            speedDial.PointerThickness = 5;
            speedDial.DialTextOffset = 100;
            speedDial.DialTextColor = MediaColor.FromRgb(0, 0, 0); // Red
            speedDial.DialBorderThickness = 0;
        }
    }
}

{ config, pkgs, ... }: {
  home.file.".config/OpenTabletDriver/settings.json".text = ''
    {
      "OutputMode": {
        "Path": "OpenTabletDriver.Desktop.Output.AbsoluteMode",
        "Settings": [],
        "Enable": true
      },
      "Filters": [],
      "AutoHook": true,
      "LockUsableAreaDisplay": true,
      "LockUsableAreaTablet": true,
      "DisplayWidth": 1920.0,
      "DisplayHeight": 1080.0,
      "DisplayXOffset": 960.0,
      "DisplayYOffset": 540.0,
      "TabletWidth": 60.0,
      "TabletHeight": 33.75,
      "TabletXOffset": 54.0,
      "TabletYOffset": 38.785,
      "TabletRotation": 0.0,
      "EnableClipping": true,
      "EnableAreaLimiting": false,
      "LockAspectRatio": false,
      "XSensitivity": 10.0,
      "YSensitivity": 10.0,
      "RelativeRotation": 0.0,
      "RelativeResetDelay": "00:00:00.1000000",
      "TipActivationPressure": 1.0,
      "TipButton": {
        "Path": "OpenTabletDriver.Desktop.Binding.MouseBinding",
        "Settings": [
          {
            "Property": "Property",
            "Value": "Left",
            "HasValue": true
          }
        ],
        "Enable": true
      },
      "PenButtons": [
        null,
        null
      ],
      "AuxButtons": [
        null,
        null,
        null,
        null,
        null,
        null
      ],
      "Tools": [],
      "Interpolators": []
    }'';
}

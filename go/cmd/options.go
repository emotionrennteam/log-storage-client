package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/plugins/url_launcher"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(1280, 720),
	flutter.AddPlugin(&url_launcher.UrlLauncherPlugin{}),
	flutter.WindowDimensionLimits(1280, 500, 3840, 2160),
}

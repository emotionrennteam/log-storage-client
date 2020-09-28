package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	file_picker "github.com/miguelpruivo/flutter_file_picker/go"
	"github.com/go-flutter-desktop/plugins/url_launcher"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(1200, 800),
	flutter.AddPlugin(&file_picker.FilePickerPlugin{}),
	flutter.AddPlugin(&url_launcher.UrlLauncherPlugin{}),
	flutter.WindowDimensionLimits(1000, 500, 1920, 1080),
}

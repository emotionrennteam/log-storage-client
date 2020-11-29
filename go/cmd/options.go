package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	file_picker "github.com/miguelpruivo/flutter_file_picker/go"
	"github.com/go-flutter-desktop/plugins/url_launcher"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(1280, 720),
	flutter.AddPlugin(&file_picker.FilePickerPlugin{}),
	flutter.AddPlugin(&url_launcher.UrlLauncherPlugin{}),
	flutter.WindowDimensionLimits(1280, 500, 3840, 2160),
}

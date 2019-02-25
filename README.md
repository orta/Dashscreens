<p align="center">
  <img src="https://github.com/orta/dashscreens/blob/master/Dashscreens/Assets.xcassets/AppIcon.appiconset/icon-256.png?raw=true">
</p>

## A CSV-powered Mac App for Dashboards

Aims:

- Move control of what shows on a dashboard to other teams
- Be controlled entirely by a google spreadsheet
- Allow cycling between a few different websites
- Support enhancing a few particular pages for display

## Admin

The admin-facing aspect of the App looks like this:

<p align="center">
  <img src="https://github.com/orta/dashscreens/blob/master/Screenshots/app.png?raw=true">
</p>

You choose a set of tags from the left, which exposes a set of links which will be cycled through on that screen. There 
are three types of windows you can create: Full Screen, Half-Left and Half-Right. Creating a new window will be attached
to the screen where the preferences window is, so move the preferences window to a different screen to work with multiple
displays.

You might need to authenticate for a particular screen, you can do that by double clicking on an active link and it
will pop up a window what you can interact with.

<p align="center">
  <img src="https://github.com/orta/dashscreens/blob/master/Screenshots/app_auth.png?raw=true">
</p>

Tips:

- You can bring the Dashscreen admin window up by pressing <key>cmd</key> + <key>0<key> if the app is active
- You can't interact with the dashboard windows at all right now, so make sure you get it right :P

## The Spreadsheet

The google spreadsheet expects the following headings on line 0: `name`, `type`, `tag`, `href`, `time (hours)`. There is
a public example version of what we [use here](https://docs.google.com/spreadsheets/d/e/2PACX-1vTYE4-OcHZA_mowRExnem0nXfN5ufNi9hM4Jxk6dxAst9D7w5-Rp3LkHRDkvZu438putda4kXYQNpte/pubhtml)

## Dev

```sh
git clone https://github.com/orta/Dashscreens
cd Dashscreens
bundle
bundle exec pod install
```

It will ask you for some keys, the Team Nav one you can ignore. The spreadsheet url you can get by taking your spreadsheet
and clicking the download as CSV menu item in Google Spreadsheets.

## How it Works

There are two main places where stuff happens:

- `PrefsController` - handles requesting the CSV, updating screen layouts etc, and uses Cocoa bindings to handle displaying info on the main window. 
- `ScreenViewController` - handles taking a list of links, and presenting them in webviews (does some fancy work to try skip loading screens.)


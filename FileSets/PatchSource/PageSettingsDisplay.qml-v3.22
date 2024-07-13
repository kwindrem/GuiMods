//////// modified to add GuiMods controls

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	property string bindPrefix: "com.victronenergy.settings/Settings/Gui"

	model: VisibleItemModel {
		MbSwitch {
			id: autoBrightness
			name: qsTr("Adaptive brightness")
			bind: Utils.path(bindPrefix, "/AutoBrightness")
			show: vePlatform.hasAutoBrightness
			onClicked: vePlatform.autoBrightness = checked;
		}

		// note: the backlight is changed during edit, and saved afterwards
		MbItemSlider {
			id: backlight
			show: vePlatform.hasBacklight && !(vePlatform.hasAutoBrightness && autoBrightness.checked)
			icondId: "icon-items-brightness"
			directUpdates: true
			item {
				min: 1
				max: vePlatform.maxBrightness
				step: 1
				value: vePlatform.brightness
				onValueChanged: if (editMode) vePlatform.brightness = item.value;
			}
			writeAccessLevel: User.AccessUser
			onEditModeChanged: if (!editMode) storedBacklight.setValue(item.value)

			VBusItem {
				id: storedBacklight
				bind: Utils.path(bindPrefix, "/Brightness")
			}
		}

		MbItemOptions {
			show: vePlatform.hasScreenSaver
			description: qsTr("Display off time")
			bind: Utils.path(bindPrefix, "/DisplayOff")
			writeAccessLevel: User.AccessUser
			possibleValues: [
				MbOption { description: qsTr("10 sec"); value: 10 },
				MbOption { description: qsTr("30 sec"); value: 30 },
				MbOption { description: qsTr("1 min"); value: 60 },
				MbOption { description: qsTr("10 min"); value: 600 },
				MbOption { description: qsTr("30 min"); value: 1800 },
				MbOption { description: qsTr("Never"); value: 0 }
			]
		}

		////// GuiMods — DarkMode
				MbSwitch
				{
					id: colorScheme
					bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode"
					name: qsTr ("Dark Mode")
					writeAccessLevel: User.AccessUser
				}

		MbSwitch {
			bind: Utils.path(bindPrefix, "/MobileOverview")
			name: qsTr("Show boat & motorhome overview")
			// When enabled set OverviewMobile as default overview
			onClicked: if (checked) defaultOverview.setValue("OverviewMobile")
			VBusItem { id: defaultOverview; bind: "com.victronenergy.settings/Settings/Gui/DefaultOverview" }
		}

		MbSwitch {
			bind: Utils.path(bindPrefix, "/TanksOverview")
			name: qsTr("Show tanks overview")
		}

		//////// add Gui Mods menu
				MbSubMenu {
					id: guiModsMenu
					description: qsTr("Gui Mods")
					subpage: Component {
						PageSettingsGuiMods { }
					}
				}

		MbItemOptions {
			id: languageSelect
			description: qsTr("Language")
			writeAccessLevel: User.AccessUser
			bind: Utils.path(bindPrefix, "/Language")

			// NOTE: do make sure application.cpp returns the correct fontForLanguage.
			// The current font might not be able to display these values / the default
			// font might not be contain the characters required for the selected language.
			possibleValues: [
			MbOptionLang { description: "English"; value: "en" },
			MbOptionLang { description: "Čeština"; value: "cs" },
			MbOptionLang { description: "Dansk"; value: "da" },
			MbOptionLang { description: "Deutsch"; value: "de" },
			MbOptionLang { description: "Español"; value: "es" },
			MbOptionLang { description: "Français"; value: "fr" },
			MbOptionLang { description: "Italiano"; value: "it" },
			MbOptionLang { description: "Nederlands"; value: "nl" },
			MbOptionLang { description: "Polski"; value: "pl" },
			MbOptionLang { description: "Русский"; value: "ru" },
			MbOptionLang { description: "Română"; value: "ro" },
			MbOptionLang { description: "Svenska"; value: "se" },
			MbOptionLang { description: "ไทย"; value: "th" },
			MbOptionLang { description: "Türkçe"; value: "tr" },
			MbOptionLang { description: "Українська"; value: "uk" },
			MbOptionLang { description: "中文"; value: "zh" },
			MbOptionLang { description: "العربية"; value: "ar" }
			]
		}

		MbSubMenu {
			description: qsTr("Units")
			subpage: Component {
				PageSettingsDisplayUnits {
					title: qsTr("Units")
				}
			}
		}
	}
}

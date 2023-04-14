#!/usr/bin/python -u
# -*- coding: utf-8 -*-

#### modified for GuiMods

from dbus.mainloop.glib import DBusGMainLoop
import dbus
import gobject
import argparse
import sys
import os
import json
from itertools import chain

# Victron packages
sys.path.insert(1, os.path.join(os.path.dirname(__file__), 'ext', 'velib_python'))
from vedbus import VeDbusService
from ve_utils import get_vrm_portal_id, exit_on_error
from dbusmonitor import DbusMonitor
from settingsdevice import SettingsDevice
from logger import setup_logging
import delegates
from sc_utils import safeadd as _safeadd, safemax as _safemax

softwareVersion = '2.67'

class SystemCalc:
	STATE_IDLE = 0
	STATE_CHARGING = 1
	STATE_DISCHARGING = 2
	BATSERVICE_DEFAULT = 'default'
	BATSERVICE_NOBATTERY = 'nobattery'
	def __init__(self):
		# Why this dummy? Because DbusMonitor expects these values to be there, even though we don't
		# need them. So just add some dummy data. This can go away when DbusMonitor is more generic.
		dummy = {'code': None, 'whenToLog': 'configChange', 'accessLevel': None}
		dbus_tree = {
			'com.victronenergy.solarcharger': {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Current': dummy,
				'/Load/I': dummy,
				'/FirmwareVersion': dummy},
			'com.victronenergy.pvinverter': {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/Ac/L1/Power': dummy,
				'/Ac/L2/Power': dummy,
				'/Ac/L3/Power': dummy,
				'/Position': dummy,
				'/ProductId': dummy},
			'com.victronenergy.battery': {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/DeviceInstance': dummy,
				'/Dc/0/Voltage': dummy,
				'/Dc/1/Voltage': dummy,
				'/Dc/0/Current': dummy,
				'/Dc/0/Power': dummy,
				'/Soc': dummy,
				'/Sense/Current': dummy,
				'/TimeToGo': dummy,
				'/ConsumedAmphours': dummy,
				'/ProductId': dummy,
				'/CustomName': dummy},
			'com.victronenergy.vebus' : {
				'/Ac/ActiveIn/ActiveInput': dummy,
				'/Ac/ActiveIn/L1/P': dummy,
				'/Ac/ActiveIn/L2/P': dummy,
				'/Ac/ActiveIn/L3/P': dummy,
				'/Ac/Out/L1/P': dummy,
				'/Ac/Out/L2/P': dummy,
				'/Ac/Out/L3/P': dummy,
#### add for GuiMods
				'/Ac/Out/L1/I': dummy,
				'/Ac/Out/L2/I': dummy,
				'/Ac/Out/L3/I': dummy,
				'/Ac/Out/L1/V': dummy,
				'/Ac/Out/L2/V': dummy,
				'/Ac/Out/L3/V': dummy,
				'/Ac/Out/L1/F': dummy,
				'/Ac/Out/L2/F': dummy,
				'/Ac/Out/L3/F': dummy,
				'/Ac/ActiveIn/L1/V': dummy,
				'/Ac/ActiveIn/L2/V': dummy,
				'/Ac/ActiveIn/L3/V': dummy,
				'/Ac/ActiveIn/L1/F': dummy,
				'/Ac/ActiveIn/L2/F': dummy,
				'/Ac/ActiveIn/L3/F': dummy,

				'/Connected': dummy,
				'/ProductId': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/Mode': dummy,
				'/State': dummy,
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Current': dummy,
				'/Dc/0/Power': dummy,
				'/Soc': dummy},
			'com.victronenergy.charger': {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Current': dummy,
				'/Dc/1/Voltage': dummy,
				'/Dc/1/Current': dummy,
				'/Dc/2/Voltage': dummy,
				'/Dc/2/Current': dummy},
			'com.victronenergy.grid' : {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/ProductId' : dummy,
				'/DeviceType' : dummy,
				'/Ac/L1/Power': dummy,
				'/Ac/L2/Power': dummy,
				'/Ac/L3/Power': dummy,
#### add for GuiMods
				'/Ac/L1/Current': dummy,
				'/Ac/L2/Current': dummy,
				'/Ac/L3/Current': dummy,
				'/Ac/L1/Voltage': dummy,
				'/Ac/L2/Voltage': dummy,
				'/Ac/L3/Voltage': dummy,
				'/Ac/L1/Frequency': dummy,
				'/Ac/L2/Frequency': dummy,
				'/Ac/L3/Frequency': dummy},
			'com.victronenergy.genset' : {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/ProductId' : dummy,
				'/DeviceType' : dummy,
				'/Ac/L1/Power': dummy,
				'/Ac/L2/Power': dummy,
				'/Ac/L3/Power': dummy,
#### add for GuiMods
				'/Ac/L1/Current': dummy,
				'/Ac/L2/Current': dummy,
				'/Ac/L3/Current': dummy,
				'/Ac/L1/Voltage': dummy,
				'/Ac/L2/Voltage': dummy,
				'/Ac/L3/Voltage': dummy,
				'/Ac/L1/Frequency': dummy,
				'/Ac/L2/Frequency': dummy,
				'/Ac/L3/Frequency': dummy,

				'/StarterVoltage': dummy},
			'com.victronenergy.settings' : {
				'/Settings/SystemSetup/AcInput1' : dummy,
				'/Settings/SystemSetup/AcInput2' : dummy,
				'/Settings/CGwacs/RunWithoutGridMeter' : dummy,
				'/Settings/System/TimeZone' : dummy},
			'com.victronenergy.temperature': {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy},
			'com.victronenergy.inverter': {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Current': dummy,
				'/Ac/Out/L1/P': dummy,
				'/Ac/Out/L1/V': dummy,
				'/Ac/Out/L1/I': dummy,
#### add for GuiMods
				'/Ac/Out/L1/V': dummy,
				'/Ac/Out/L1/I': dummy,
				'/Ac/Out/L1/F': dummy,

				'/Yield/Power': dummy,
				'/Soc': dummy,
			}
		}

		self._modules = [
			delegates.HubTypeSelect(),
			delegates.VebusSocWriter(),
			delegates.ServiceMapper(),
			delegates.RelayState(),
			delegates.BuzzerControl(),
			delegates.LgCircuitBreakerDetect(),
			delegates.Dvcc(self),
			delegates.BatterySense(self),
			delegates.BatterySettings(self),
			delegates.SystemState(),
			delegates.BatteryLife(),
			delegates.ScheduledCharging(),
			delegates.SourceTimers(),
			#delegates.BydCurrentSense(self),
			delegates.BatteryData(),
			delegates.Gps()]

		for m in self._modules:
			for service, paths in m.get_input():
				s = dbus_tree.setdefault(service, {})
				for path in paths:
					s[path] = dummy

		self._dbusmonitor = self._create_dbus_monitor(dbus_tree, valueChangedCallback=self._dbus_value_changed,
			deviceAddedCallback=self._device_added, deviceRemovedCallback=self._device_removed)

		# Connect to localsettings
		supported_settings = {
			'batteryservice': ['/Settings/SystemSetup/BatteryService', self.BATSERVICE_DEFAULT, 0, 0],
			'hasdcsystem': ['/Settings/SystemSetup/HasDcSystem', 0, 0, 1],
			'useacout': ['/Settings/SystemSetup/HasAcOutSystem', 1, 0, 1]}

		for m in self._modules:
			for setting in m.get_settings():
				supported_settings[setting[0]] = list(setting[1:])

		self._settings = self._create_settings(supported_settings, self._handlechangedsetting)

		self._dbusservice = self._create_dbus_service()

		for m in self._modules:
			m.set_sources(self._dbusmonitor, self._settings, self._dbusservice)

		# This path does nothing except respond with a PropertiesChanged so
		# that round-trip time can be measured.
		self._dbusservice.add_path('/Ping', value=None, writeable=True)

		# At this moment, VRM portal ID is the MAC address of the CCGX. Anyhow, it should be string uniquely
		# identifying the CCGX.
		self._dbusservice.add_path('/Serial', value=get_vrm_portal_id())
		self._dbusservice.add_path(
			'/AvailableBatteryServices', value=None, gettextcallback=self._gettext)
		self._dbusservice.add_path(
			'/AvailableBatteryMeasurements', value=None)
		self._dbusservice.add_path(
			'/AutoSelectedBatteryService', value=None, gettextcallback=self._gettext)
		self._dbusservice.add_path(
			'/AutoSelectedBatteryMeasurement', value=None, gettextcallback=self._gettext)
		self._dbusservice.add_path(
			'/ActiveBatteryService', value=None, gettextcallback=self._gettext)
		self._dbusservice.add_path(
			'/Dc/Battery/BatteryService', value=None)
		self._dbusservice.add_path(
			'/PvInvertersProductIds', value=None)
		self._summeditems = {
			'/Ac/Grid/L1/Power': {'gettext': '%.0F W'},
			'/Ac/Grid/L2/Power': {'gettext': '%.0F W'},
			'/Ac/Grid/L3/Power': {'gettext': '%.0F W'},
			'/Ac/Grid/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/Grid/ProductId': {'gettext': '%s'},
			'/Ac/Grid/DeviceType': {'gettext': '%s'},
			'/Ac/Genset/L1/Power': {'gettext': '%.0F W'},
			'/Ac/Genset/L2/Power': {'gettext': '%.0F W'},
			'/Ac/Genset/L3/Power': {'gettext': '%.0F W'},
			'/Ac/Genset/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/Genset/ProductId': {'gettext': '%s'},
			'/Ac/Genset/DeviceType': {'gettext': '%s'},
			'/Ac/ConsumptionOnOutput/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnOutput/L1/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnOutput/L2/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnOutput/L3/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnInput/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnInput/L1/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnInput/L2/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnInput/L3/Power': {'gettext': '%.0F W'},
			'/Ac/Consumption/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/Consumption/L1/Power': {'gettext': '%.0F W'},
			'/Ac/Consumption/L2/Power': {'gettext': '%.0F W'},
			'/Ac/Consumption/L3/Power': {'gettext': '%.0F W'},
			'/Ac/Consumption/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/PvOnOutput/L1/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnOutput/L2/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnOutput/L3/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnOutput/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/PvOnGrid/L1/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnGrid/L2/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnGrid/L3/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnGrid/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/PvOnGenset/L1/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnGenset/L2/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnGenset/L3/Power': {'gettext': '%.0F W'},
			'/Ac/PvOnGenset/NumberOfPhases': {'gettext': '%d'},
			'/Dc/Pv/Power': {'gettext': '%.0F W'},
			'/Dc/Pv/Current': {'gettext': '%.1F A'},
			'/Dc/Battery/Voltage': {'gettext': '%.2F V'},
			'/Dc/Battery/VoltageService': {'gettext': '%s'},
			'/Dc/Battery/Current': {'gettext': '%.1F A'},
			'/Dc/Battery/Power': {'gettext': '%.0F W'},
			'/Dc/Battery/Soc': {'gettext': '%.0F %%'},
			'/Dc/Battery/State': {'gettext': '%s'},
			'/Dc/Battery/TimeToGo': {'gettext': '%.0F s'},
			'/Dc/Battery/ConsumedAmphours': {'gettext': '%.1F Ah'},
			'/Dc/Battery/ProductId': {'gettext': '0x%x'},
			'/Dc/Charger/Power': {'gettext': '%.0F %%'},
			'/Dc/Vebus/Current': {'gettext': '%.1F A'},
			'/Dc/Vebus/Power': {'gettext': '%.0F W'},
			'/Dc/System/Power': {'gettext': '%.0F W'},
			'/Ac/ActiveIn/Source': {'gettext': '%s'},
			'/VebusService': {'gettext': '%s'},
#### added for GuiMods
			'/Ac/Grid/L1/Current': {'gettext': '%.1F A'},
			'/Ac/Grid/L2/Current': {'gettext': '%.1F A'},
			'/Ac/Grid/L3/Current': {'gettext': '%.1F A'},
			'/Ac/Grid/L1/Voltage': {'gettext': '%.1F A'},
			'/Ac/Grid/L2/Voltage': {'gettext': '%.1F A'},
			'/Ac/Grid/L3/Voltage': {'gettext': '%.1F A'},
			'/Ac/Grid/Frequency': {'gettext': '%.1F Hz'},
			'/Ac/Genset/L1/Current': {'gettext': '%.1F A'},
			'/Ac/Genset/L2/Current': {'gettext': '%.1F A'},
			'/Ac/Genset/L3/Current': {'gettext': '%.1F A'},
			'/Ac/Genset/L1/Voltage': {'gettext': '%.1F A'},
			'/Ac/Genset/L2/Voltage': {'gettext': '%.1F A'},
			'/Ac/Genset/L3/Voltage': {'gettext': '%.1F A'},
			'/Ac/Genset/Frequency': {'gettext': '%.1F Hz'},
			'/Ac/ConsumptionOnOutput/L1/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnOutput/L2/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnOutput/L3/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnOutput/L1/Voltage': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnOutput/L2/Voltage': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnOutput/L3/Voltage': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnOutput/Frequency': {'gettext': '%.1F Hz'},
			'/Ac/ConsumptionOnInput/L1/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/L2/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/L3/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/L1/Voltage': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/L2/Voltage': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/L3/Voltage': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/Frequency': {'gettext': '%.1F Hz'},
			'/Ac/Consumption/L1/Voltage': {'gettext': '%.1F A'},
			'/Ac/Consumption/L2/Voltage': {'gettext': '%.1F A'},
			'/Ac/Consumption/L3/Voltage': {'gettext': '%.1F A'},
			'/Ac/Consumption/Frequency': {'gettext': '%.1F A'},
			'/Ac/ActiveIn/L1/Voltage': {'gettext': '%.1F A'},
			'/Ac/ActiveIn/L2/Voltage': {'gettext': '%.1F A'},
			'/Ac/ActiveIn/L3/Voltage': {'gettext': '%.1F A'},
			'/Ac/ActiveIn/Frequency': {'gettext': '%.1F Hz'},
		}

		for m in self._modules:
			self._summeditems.update(m.get_output())

		for path in self._summeditems.keys():
			self._dbusservice.add_path(path, value=None, gettextcallback=self._gettext)

		self._batteryservice = None
		self._determinebatteryservice()

		if self._batteryservice is None:
			logger.info("Battery service initialized to None (setting == %s)" %
				self._settings['batteryservice'])

		self._changed = True
		for service, instance in self._dbusmonitor.get_service_list().items():
			self._device_added(service, instance, do_service_change=False)

		self._handleservicechange()
		self._updatevalues()

		gobject.timeout_add(1000, exit_on_error, self._handletimertick)

	def _create_dbus_monitor(self, *args, **kwargs):
		raise Exception("This function should be overridden")

	def _create_settings(self, *args, **kwargs):
		raise Exception("This function should be overridden")

	def _create_dbus_service(self):
		raise Exception("This function should be overridden")

	def _handlechangedsetting(self, setting, oldvalue, newvalue):
		self._determinebatteryservice()
		self._changed = True

		# Give our delegates a chance to react on a settings change
		for m in self._modules:
			m.settings_changed(setting, oldvalue, newvalue)

	def _find_device_instance(self, serviceclass, instance):
		""" Gets a mapping of services vs DeviceInstance using
		    get_service_list.  Then searches for the specified DeviceInstance
		    and returns the service name. """
		services = self._dbusmonitor.get_service_list(classfilter=serviceclass)

		# According to https://www.python.org/dev/peps/pep-3106/, dict.keys()
		# and dict.values() always have the same order. This is also much
		# faster than you would expect.
		try:
			return services.keys()[services.values().index(instance)]
		except ValueError: # If instance not in values
			return None

	def _determinebatteryservice(self):
		auto_battery_service = self._autoselect_battery_service()
		auto_battery_measurement = None
		if auto_battery_service is not None:
			services = self._dbusmonitor.get_service_list()
			if auto_battery_service in services:
				auto_battery_measurement = \
					self._get_instance_service_name(auto_battery_service, services[auto_battery_service])
				auto_battery_measurement = auto_battery_measurement.replace('.', '_').replace('/', '_') + '/Dc/0'
		self._dbusservice['/AutoSelectedBatteryMeasurement'] = auto_battery_measurement

		if self._settings['batteryservice'] == self.BATSERVICE_DEFAULT:
			newbatteryservice = auto_battery_service
			self._dbusservice['/AutoSelectedBatteryService'] = (
				'No battery monitor found' if newbatteryservice is None else
				self._get_readable_service_name(newbatteryservice))

		elif self._settings['batteryservice'] == self.BATSERVICE_NOBATTERY:
			self._dbusservice['/AutoSelectedBatteryService'] = None
			newbatteryservice = None

		else:
			self._dbusservice['/AutoSelectedBatteryService'] = None

			s = self._settings['batteryservice'].split('/')
			if len(s) != 2:
				logger.error("The battery setting (%s) is invalid!" % self._settings['batteryservice'])
			serviceclass = s[0]
			instance = int(s[1]) if len(s) == 2 else None

			# newbatteryservice might turn into None if a chosen battery
			# monitor no longer exists. Don't auto change the setting (it might
			# come back) and don't autoselect another.
			newbatteryservice = self._find_device_instance(serviceclass, instance)

		if newbatteryservice != self._batteryservice:
			services = self._dbusmonitor.get_service_list()
			instance = services.get(newbatteryservice, None)
			if instance is None:
				battery_service = None
			else:
				battery_service = self._get_instance_service_name(newbatteryservice, instance)
			self._dbusservice['/ActiveBatteryService'] = battery_service
			logger.info("Battery service, setting == %s, changed from %s to %s (%s)" %
				(self._settings['batteryservice'], self._batteryservice, newbatteryservice, instance))

			# Battery service has changed. Notify delegates.
			for m in self._modules:
				m.battery_service_changed(self._batteryservice, newbatteryservice)
			self._dbusservice['/Dc/Battery/BatteryService'] = self._batteryservice = newbatteryservice

	def _autoselect_battery_service(self):
		# Default setting business logic:
		# first try to use a battery service (BMV or Lynx Shunt VE.Can). If there
		# is more than one battery service, just use a random one. If no battery service is
		# available, check if there are not Solar chargers and no normal chargers. If they are not
		# there, assume this is a hub-2, hub-3 or hub-4 system and use VE.Bus SOC.
		batteries = self._get_connected_service_list('com.victronenergy.battery')

		# Pick the first battery service
		if len(batteries) > 0:
			return sorted(batteries)[0]

		# No battery services, and there is a charger in the system. Abandon
		# hope.
		if self._get_first_connected_service('com.victronenergy.charger') is not None:
			return None

		# Also no Multi, then give up.
		vebus_service = self._get_service_having_lowest_instance('com.victronenergy.vebus')
		if vebus_service is None:
			# No VE.Bus, but maybe there is an inverter with built-in SOC
			# tracking, eg RS Smart.
			inverter = self._get_service_having_lowest_instance('com.victronenergy.inverter')
			if inverter and self._dbusmonitor.get_value(inverter[0], '/Soc') is not None:
				return inverter[0]

			return None

		# There is a Multi, and it supports tracking external charge current
		# from solarchargers. Then use it.
		if self._dbusmonitor.get_value(vebus_service[0], '/ExtraBatteryCurrent') is not None and self._settings['hasdcsystem'] == 0:
			return vebus_service[0]

		# Multi does not support tracking solarcharger current, and we have
		# solar chargers. Then we cannot use it.
		if self._get_first_connected_service('com.victronenergy.solarcharger') is not None:
			return None

		# Only a Multi, no other chargers. Then we can use it.
		return vebus_service[0]

	# Called on a one second timer
	def _handletimertick(self):
		if self._changed:
			self._updatevalues()
		self._changed = False

		return True  # keep timer running

	def _updatepvinverterspidlist(self):
		# Create list of connected pv inverters id's
		pvinverters = self._dbusmonitor.get_service_list('com.victronenergy.pvinverter')
		productids = []

		for pvinverter in pvinverters:
			pid = self._dbusmonitor.get_value(pvinverter, '/ProductId')
			if pid is not None and pid not in productids:
				productids.append(pid)
		self._dbusservice['/PvInvertersProductIds'] = productids

	def _updatevalues(self):
		# ==== PREPARATIONS ====
		newvalues = {}

		# Set the user timezone
		if 'TZ' not in os.environ:
			tz = self._dbusmonitor.get_value('com.victronenergy.settings', '/Settings/System/TimeZone')
			if tz is not None:
				os.environ['TZ'] = tz

		# Determine values used in logic below
		vebusses = self._dbusmonitor.get_service_list('com.victronenergy.vebus')
		vebuspower = 0
		for vebus in vebusses:
			v = self._dbusmonitor.get_value(vebus, '/Dc/0/Voltage')
			i = self._dbusmonitor.get_value(vebus, '/Dc/0/Current')
			if v is not None and i is not None:
				vebuspower += v * i

		# ==== PVINVERTERS ====
		pvinverters = self._dbusmonitor.get_service_list('com.victronenergy.pvinverter')
		pos = {0: '/Ac/PvOnGrid', 1: '/Ac/PvOnOutput', 2: '/Ac/PvOnGenset'}
		for pvinverter in pvinverters:
			# Position will be None if PV inverter service has just been removed (after retrieving the
			# service list).
			position = pos.get(self._dbusmonitor.get_value(pvinverter, '/Position'))
			if position is not None:
				for phase in range(1, 4):
					power = self._dbusmonitor.get_value(pvinverter, '/Ac/L%s/Power' % phase)
					if power is not None:
						path = '%s/L%s/Power' % (position, phase)
						newvalues[path] = _safeadd(newvalues.get(path), power)

		for path in pos.values():
			self._compute_number_of_phases(path, newvalues)

		# ==== SOLARCHARGERS ====
		solarchargers = self._dbusmonitor.get_service_list('com.victronenergy.solarcharger')
		solarcharger_batteryvoltage = None
		solarcharger_batteryvoltage_service = None
		solarchargers_charge_power = 0
		solarchargers_loadoutput_power = None

		for solarcharger in solarchargers:
			v = self._dbusmonitor.get_value(solarcharger, '/Dc/0/Voltage')
			if v is None:
				continue
			i = self._dbusmonitor.get_value(solarcharger, '/Dc/0/Current')
			if i is None:
				continue
			l = self._dbusmonitor.get_value(solarcharger, '/Load/I', 0)

			if l is not None:
				if solarchargers_loadoutput_power is None:
					solarchargers_loadoutput_power = l * v
				else:
					solarchargers_loadoutput_power += l * v

			solarchargers_charge_power += v * i

			# Note that this path is not in the _summeditems{}, making for it to not be
			# published on D-Bus. Which fine. The only one needing it is the vebussocwriter-
			# delegate.
			if '/Dc/Pv/ChargeCurrent' not in newvalues:
				newvalues['/Dc/Pv/ChargeCurrent'] = i
			else:
				newvalues['/Dc/Pv/ChargeCurrent'] += i

			if '/Dc/Pv/Power' not in newvalues:
				newvalues['/Dc/Pv/Power'] = v * _safeadd(i, l)
				newvalues['/Dc/Pv/Current'] = _safeadd(i, l)
				solarcharger_batteryvoltage = v
				solarcharger_batteryvoltage_service = solarcharger
			else:
				newvalues['/Dc/Pv/Power'] += v * _safeadd(i, l)
				newvalues['/Dc/Pv/Current'] += _safeadd(i, l)

		# ==== CHARGERS ====
		chargers = self._dbusmonitor.get_service_list('com.victronenergy.charger')
		charger_batteryvoltage = None
		charger_batteryvoltage_service = None
		for charger in chargers:
			# Assume the battery connected to output 0 is the main battery
			v = self._dbusmonitor.get_value(charger, '/Dc/0/Voltage')
			if v is None:
				continue

			charger_batteryvoltage = v
			charger_batteryvoltage_service = charger

			i = self._dbusmonitor.get_value(charger, '/Dc/0/Current')
			if i is None:
				continue

			if '/Dc/Charger/Power' not in newvalues:
				newvalues['/Dc/Charger/Power'] = v * i
			else:
				newvalues['/Dc/Charger/Power'] += v * i

		# ==== VE.Direct Inverters ====
		_vedirect_inverters = sorted((di, s) for s, di in self._dbusmonitor.get_service_list('com.victronenergy.inverter').items())
		vedirect_inverters = [x[1] for x in _vedirect_inverters]
		vedirect_inverter = None
		if vedirect_inverters:
			vedirect_inverter = vedirect_inverters[0]

			# For RS Smart inverters, add PV to the yield
			for i in vedirect_inverters:
				pv_yield = self._dbusmonitor.get_value(i, "/Yield/Power")
				if pv_yield is not None:
						newvalues['/Dc/Pv/Power'] = newvalues.get('/Dc/Pv/Power', 0) + pv_yield


		# ==== BATTERY ====
		if self._batteryservice is not None:
			batteryservicetype = self._batteryservice.split('.')[2]
			assert batteryservicetype in ('battery', 'vebus', 'inverter')

			newvalues['/Dc/Battery/Soc'] = self._dbusmonitor.get_value(self._batteryservice,'/Soc')
			newvalues['/Dc/Battery/TimeToGo'] = self._dbusmonitor.get_value(self._batteryservice,'/TimeToGo')
			newvalues['/Dc/Battery/ConsumedAmphours'] = self._dbusmonitor.get_value(self._batteryservice,'/ConsumedAmphours')
			newvalues['/Dc/Battery/ProductId'] = self._dbusmonitor.get_value(self._batteryservice, '/ProductId')

			if batteryservicetype in ('battery', 'inverter'):
				newvalues['/Dc/Battery/Voltage'] = self._dbusmonitor.get_value(self._batteryservice, '/Dc/0/Voltage')
				newvalues['/Dc/Battery/VoltageService'] = self._batteryservice
				newvalues['/Dc/Battery/Current'] = self._dbusmonitor.get_value(self._batteryservice, '/Dc/0/Current')
				newvalues['/Dc/Battery/Power'] = self._dbusmonitor.get_value(self._batteryservice, '/Dc/0/Power')

			elif batteryservicetype == 'vebus':
				vebus_voltage = self._dbusmonitor.get_value(self._batteryservice, '/Dc/0/Voltage')
				vebus_current = self._dbusmonitor.get_value(self._batteryservice, '/Dc/0/Current')
				vebus_power = None if vebus_voltage is None or vebus_current is None else vebus_current * vebus_voltage
				newvalues['/Dc/Battery/Voltage'] = vebus_voltage
				newvalues['/Dc/Battery/VoltageService'] = self._batteryservice
				if self._settings['hasdcsystem'] == 1:
					# hasdcsystem will normally disqualify the multi from being
					# auto-selected as battery monitor, so the only way we're
					# here is if the user explicitly selected the multi as the
					# battery service
					newvalues['/Dc/Battery/Current'] = vebus_current
					if vebus_power is not None:
						newvalues['/Dc/Battery/Power'] = vebus_power
				else:
					battery_power = _safeadd(solarchargers_charge_power, vebus_power)
					newvalues['/Dc/Battery/Current'] = battery_power / vebus_voltage if vebus_voltage > 0 else None
					newvalues['/Dc/Battery/Power'] = battery_power


			p = newvalues.get('/Dc/Battery/Power', None)
			if p is not None:
				if p > 30:
					newvalues['/Dc/Battery/State'] = self.STATE_CHARGING
				elif p < -30:
					newvalues['/Dc/Battery/State'] = self.STATE_DISCHARGING
				else:
					newvalues['/Dc/Battery/State'] = self.STATE_IDLE

		else:
			# The battery service is not a BMS/BMV or a suitable vebus. A
			# suitable vebus is defined as one explicitly selected by the user,
			# or one that was automatically selected for SOC tracking.  We may
			# however still have a VE.Bus, just not one that can accurately
			# track SOC. If we have one, use it as voltage source.  Otherwise
			# try a solar charger, a charger, or a vedirect inverter as
			# fallbacks.
			batteryservicetype = None
			vebusses = self._dbusmonitor.get_service_list('com.victronenergy.vebus')
			for vebus in vebusses:
				v = self._dbusmonitor.get_value(vebus, '/Dc/0/Voltage')
				s = self._dbusmonitor.get_value(vebus, '/State')
				if v is not None and s not in (0, None):
					newvalues['/Dc/Battery/Voltage'] = v
					newvalues['/Dc/Battery/VoltageService'] = vebus
					break # Skip the else below
			else:
				# No suitable vebus voltage, try other devices
				if solarcharger_batteryvoltage is not None:
					newvalues['/Dc/Battery/Voltage'] = solarcharger_batteryvoltage
					newvalues['/Dc/Battery/VoltageService'] = solarcharger_batteryvoltage_service
				elif charger_batteryvoltage is not None:
					newvalues['/Dc/Battery/Voltage'] = charger_batteryvoltage
					newvalues['/Dc/Battery/VoltageService'] = charger_batteryvoltage_service
				elif vedirect_inverter is not None:
					v = self._dbusmonitor.get_value(vedirect_inverter, '/Dc/0/Voltage')
					if v is not None:
						newvalues['/Dc/Battery/Voltage'] = v
						newvalues['/Dc/Battery/VoltageService'] = vedirect_inverter

			if self._settings['hasdcsystem'] == 0 and '/Dc/Battery/Voltage' in newvalues:
				# No unmonitored DC loads or chargers, and also no battery monitor: derive battery watts
				# and amps from vebus, solarchargers and chargers.
				assert '/Dc/Battery/Power' not in newvalues
				assert '/Dc/Battery/Current' not in newvalues
				p = solarchargers_charge_power + newvalues.get('/Dc/Charger/Power', 0) + vebuspower
				voltage = newvalues['/Dc/Battery/Voltage']
				newvalues['/Dc/Battery/Current'] = p / voltage if voltage > 0 else None
				newvalues['/Dc/Battery/Power'] = p


		# ==== SYSTEM POWER ====
		if self._settings['hasdcsystem'] == 1 and batteryservicetype == 'battery':
			# Calculate power being generated/consumed by not measured devices in the network.
			# For MPPTs, take all the power, including power going out of the load output.
			# /Dc/System: positive: consuming power
			# VE.Bus: Positive: current flowing from the Multi to the dc system or battery
			# Solarcharger & other chargers: positive: charging
			# battery: Positive: charging battery.
			# battery = solarcharger + charger + ve.bus - system

			battery_power = newvalues.get('/Dc/Battery/Power')
			if battery_power is not None:
				dc_pv_power = newvalues.get('/Dc/Pv/Power', 0)
				charger_power = newvalues.get('/Dc/Charger/Power', 0)

				# If there are VE.Direct inverters, remove their power from the
				# DC estimate. This is done using the AC value when the DC
				# power values are not available.
				inverter_power = 0
				for i in vedirect_inverters:
					inverter_current = self._dbusmonitor.get_value(i, '/Dc/0/Current')
					if inverter_current is not None:
						inverter_power += self._dbusmonitor.get_value(
							i, '/Dc/0/Voltage', 0) * inverter_current
					else:
						inverter_power += self._dbusmonitor.get_value(
							i, '/Ac/Out/L1/V', 0) * self._dbusmonitor.get_value(
							i, '/Ac/Out/L1/I', 0)
				newvalues['/Dc/System/Power'] = dc_pv_power + charger_power + vebuspower - inverter_power - battery_power

		elif self._settings['hasdcsystem'] == 1 and solarchargers_loadoutput_power is not None:
			newvalues['/Dc/System/Power'] = solarchargers_loadoutput_power

		# ==== Vebus ====
		multi = self._get_service_having_lowest_instance('com.victronenergy.vebus')
		multi_path = None
		if multi is not None:
			multi_path = multi[0]
			dc_current = self._dbusmonitor.get_value(multi_path, '/Dc/0/Current')
			newvalues['/Dc/Vebus/Current'] = dc_current
			dc_power = self._dbusmonitor.get_value(multi_path, '/Dc/0/Power')
			# Just in case /Dc/0/Power is not available
			if dc_power == None and dc_current is not None:
				dc_voltage = self._dbusmonitor.get_value(multi_path, '/Dc/0/Voltage')
				if dc_voltage is not None:
					dc_power = dc_voltage * dc_current
			# Note that there is also vebuspower, which is the total DC power summed over all multis.
			# However, this value cannot be combined with /Dc/Multi/Current, because it does not make sense
			# to add the Dc currents of all multis if they do not share the same DC voltage.
			newvalues['/Dc/Vebus/Power'] = dc_power

		newvalues['/VebusService'] = multi_path

		# ===== AC IN SOURCE =====
		ac_in_source = None
		if multi_path is None:
			# Check if we have an non-VE.Bus inverter. If yes, then ActiveInput
			# is disconnected.
			if vedirect_inverter is not None:
				ac_in_source = 240
		else:
			active_input = self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/ActiveInput')
			if active_input == 0xF0:
				# Not connected
				ac_in_source = 240
			elif active_input is not None:
				settings_path = '/Settings/SystemSetup/AcInput%s' % (active_input + 1)
				ac_in_source = self._dbusmonitor.get_value('com.victronenergy.settings', settings_path)
		newvalues['/Ac/ActiveIn/Source'] = ac_in_source

		# ===== GRID METERS & CONSUMPTION ====
		consumption = { "L1" : None, "L2" : None, "L3" : None }
#### added for GuiMods
		currentconsumption = { "L1" : None, "L2" : None, "L3" : None }
		voltageIn = { "L1" : None, "L2" : None, "L3" : None }
		voltageOut = { "L1" : None, "L2" : None, "L3" : None }
		frequencyIn = None
		frequencyOut = None

		for device_type in ['Grid', 'Genset']:
			servicename = 'com.victronenergy.%s' % device_type.lower()
			energy_meter = self._get_first_connected_service(servicename)
			em_service = None if energy_meter is None else energy_meter[0]
			uses_active_input = False
			if multi_path is not None:
				# If a grid meter is present we use values from it. If not, we look at the multi. If it has
				# AcIn1 or AcIn2 connected to the grid, we use those values.
				# com.victronenergy.grid.??? indicates presence of an energy meter used as grid meter.
				# com.victronenergy.vebus.???/Ac/ActiveIn/ActiveInput: decides which whether we look at AcIn1
				# or AcIn2 as possible grid connection.
				if ac_in_source is not None:
					uses_active_input = ac_in_source > 0 and (ac_in_source == 2) == (device_type == 'Genset')
			for phase in consumption:
				p = None
				pvpower = newvalues.get('/Ac/PvOn%s/%s/Power' % (device_type, phase))
#### added for GuiMods
				mc = None
				pvcurrent = newvalues.get('/Ac/PvOn%s/%s/Current' % (device_type, phase))
				if em_service is not None:
					p = self._dbusmonitor.get_value(em_service, '/Ac/%s/Power' % phase)
#### added for GuiMods
					mc = self._dbusmonitor.get_value(em.service, '/Ac/%s/Current' % phase)
					if voltageIn[phase] == None:
						voltageIn[phase] = self._dbusmonitor.get_value(em.service, '/Ac/%s/Voltage' % phase)
					if frequencyIn == None:
						frequencyIn = self._dbusmonitor.get_value(em.service, '/Ac/%s/Frequency' % phase)

					# Compute consumption between energy meter and multi (meter power - multi AC in) and
					# add an optional PV inverter on input to the mix.
					c = None
#### added for GuiMods
					cc = None
					if uses_active_input:
						ac_in = self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/P' % phase)
						if ac_in is not None:
							try:
								c = _safeadd(c, -ac_in)
#### added for GuiMods
								cc = _safeadd(cc, -self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/I' % phase))
								if voltageIn[phase] == None:
									voltageIn[phase] = self._dbusmonitor.get_value(em.service, '/Ac/ActiveIn/%s/V' % phase)
								if frequencyIn == None:
									frequencyIn = self._dbusmonitor.get_value(em.service, '/Ac/ActiveIn/%s/F' % phase)
							except TypeError:
								pass

					# If there's any power coming from a PV inverter in the inactive AC in (which is unlikely),
					# it will still be used, because there may also be a load in the same ACIn consuming
					# power, or the power could be fed back to the net.
					c = _safeadd(c, p, pvpower)
					consumption[phase] = _safeadd(consumption[phase], _safemax(0, c))
#### added for GuiMods
					cc = _safeadd(cc, mc, pvcurrent)
					currentconsumption[phase] = _safeadd(currentconsumption[phase], _safemax(0, cc))
				else:
					if uses_active_input:
						p = self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/P' % phase)
						if p is not None:
							consumption[phase] = _safeadd(0, consumption[phase])
#### added for GuiMods
							currentconsumption[phase] = _safeadd(0, currentconsumption[phase])
							mc = self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/I' % phase)
							if voltageIn[phase] == None:
								voltageIn[phase] = self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/V' % phase)
							if frequencyIn == None:
								freq = self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/F' % phase)
								if freq != None:
									frequencyIn = freq

					# No relevant energy meter present. Assume there is no load between the grid and the multi.
					# There may be a PV inverter present though (Hub-3 setup).
					if pvpower != None:
						p = _safeadd(p, -pvpower)
#### added for GuiMods
						mc = _safeadd(mc, -pvcurrent)
				newvalues['/Ac/%s/%s/Power' % (device_type, phase)] = p
#### added for GuiMods #############
				newvalues['/Ac/%s/%s/Current' % (device_type, phase)] = mc
				if p != None:
					newvalues['/Ac/%s/%s/Voltage' % (device_type, phase)] = voltageIn[phase]
					newvalues['/Ac/%s/Frequency' % (device_type)] = frequencyIn
			self._compute_number_of_phases('/Ac/%s' % device_type, newvalues)
			product_id = None
			device_type_id = None
			if em_service is not None:
				product_id = self._dbusmonitor.get_value(em_service, '/ProductId')
				device_type_id = self._dbusmonitor.get_value(em_service, '/DeviceType')
			if product_id is None and uses_active_input:
				product_id = self._dbusmonitor.get_value(multi_path, '/ProductId')
			newvalues['/Ac/%s/ProductId' % device_type] = product_id
			newvalues['/Ac/%s/DeviceType' % device_type] = device_type_id

		# If we have an ESS system and RunWithoutGridMeter is set, there cannot be load on the AC-In, so it
		# must be on AC-Out. Hence we do calculate AC-Out consumption even if 'useacout' is disabled.
		# Similarly all load are by definition on the output if this is not an ESS system.
		use_ac_out = \
			self._settings['useacout'] == 1 or \
			(multi_path is not None and self._dbusmonitor.get_value(multi_path, '/Hub4/AssistantId') not in (4, 5)) or \
			self._dbusmonitor.get_value('com.victronenergy.settings', '/Settings/CGwacs/RunWithoutGridMeter') == 1
		for phase in consumption:
			c = None
#### added for GuiMods
			a = None
			if use_ac_out:
				c = newvalues.get('/Ac/PvOnOutput/%s/Power' % phase)
#### added for GuiMods
				a = newvalues.get('/Ac/PvOnOutput/%s/Current' % phase)
				if voltageOut[phase] == None:
					voltageOut[phase] = newvalues.get('/Ac/PvOnOutput/%s/Voltage' % phase)
				if frequencyOut == None:
					frequencyOut = newvalues.get('/Ac/PvOnOutput/%s/Frequency' % phase)

				if multi_path is None:
					for inv in vedirect_inverters:
						ac_out = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/P' % phase)
#### added for GuiMods
						i = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/I' % phase)
						if voltageOut[phase] == None:
							voltageOut[phase] = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/V' % phase)
						if frequencyOut == None:
							frequencyOut = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/F' % phase)


						# Some models don't show power, calculate it
						if ac_out is None:
#### modified for GuiMods
								# u = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/V' % phase)
								if None not in (i, voltageOut[phase]):
									ac_out = i * voltageOut[phase]
						c = _safeadd(c, ac_out)
#### modified for GuiMods
						a = _safeadd(a, i)
				else:
					ac_out = self._dbusmonitor.get_value(multi_path, '/Ac/Out/%s/P' % phase)
					c = _safeadd(c, ac_out)
				c = _safemax(0, c)
#### added for GuiMods
				a = _safemax(0, a)
			newvalues['/Ac/ConsumptionOnOutput/%s/Power' % phase] = c
			newvalues['/Ac/ConsumptionOnInput/%s/Power' % phase] = consumption[phase]
			newvalues['/Ac/Consumption/%s/Power' % phase] = _safeadd(consumption[phase], c)
#### added for GuiMods
			newvalues['/Ac/Consumption/%s/Current' % phase] = _safeadd(currentconsumption[phase], a)
			newvalues['/Ac/ConsumptionOnOutput/%s/Voltage' % phase] = voltageOut[phase]
			newvalues['/Ac/ConsumptionOnInput/%s/Voltage' % phase] = voltageIn[phase]
			if voltageOut[phase] != None:
				newvalues['/Ac/Consumption/%s/Voltage' % phase] = voltageOut[phase]
			elif voltageIn[phase] != None:
				newvalues['/Ac/Consumption/%s/Voltage' % phase] = voltageIn[phase]
			if frequencyIn != None:
				newvalues['/Ac/ConsumptionOnInput/Frequency'] = frequencyIn
			if frequencyOut != None:
				newvalues['/Ac/ConsumptionOnOutput/Frequency'] = frequencyOut
			if frequencyOut != None:
				newvalues['/Ac/Consumption/Frequency'] = frequencyOut
			elif frequencyIn != None:
				newvalues['/Ac/Consumption/Frequency'] = frequencyIn

		self._compute_number_of_phases('/Ac/Consumption', newvalues)
		self._compute_number_of_phases('/Ac/ConsumptionOnOutput', newvalues)
		self._compute_number_of_phases('/Ac/ConsumptionOnInput', newvalues)

		for m in self._modules:
			m.update_values(newvalues)

		# ==== UPDATE DBUS ITEMS ====
		for path in self._summeditems.keys():
			# Why the None? Because we want to invalidate things we don't have anymore.
			self._dbusservice[path] = newvalues.get(path, None)

	def _handleservicechange(self):
		# Update the available battery monitor services, used to populate the dropdown in the settings.
		# Below code makes a dictionary. The key is [dbuserviceclass]/[deviceinstance]. For example
		# "battery/245". The value is the name to show to the user in the dropdown. The full dbus-
		# servicename, ie 'com.victronenergy.vebus.ttyO1' is not used, since the last part of that is not
		# fixed. dbus-serviceclass name and the device instance are already fixed, so best to use those.

		services = self._get_connected_service_list('com.victronenergy.vebus')
		services.update(self._get_connected_service_list('com.victronenergy.battery'))
		services.update({k: v for k, v in self._get_connected_service_list(
			'com.victronenergy.inverter').items() if self._dbusmonitor.get_value(k, '/Soc') is not None})

		ul = {self.BATSERVICE_DEFAULT: 'Automatic', self.BATSERVICE_NOBATTERY: 'No battery monitor'}
		for servicename, instance in services.items():
			key = self._get_instance_service_name(servicename, instance)
			ul[key] = self._get_readable_service_name(servicename)
		self._dbusservice['/AvailableBatteryServices'] = json.dumps(ul)

		ul = {self.BATSERVICE_DEFAULT: 'Automatic', self.BATSERVICE_NOBATTERY: 'No battery monitor'}
		# For later: for device supporting multiple Dc measurement we should add entries for /Dc/1 etc as
		# well.
		for servicename, instance in services.items():
			key = self._get_instance_service_name(servicename, instance).replace('.', '_').replace('/', '_') + '/Dc/0'
			ul[key] = self._get_readable_service_name(servicename)
		self._dbusservice['/AvailableBatteryMeasurements'] = ul

		self._determinebatteryservice()
		self._updatepvinverterspidlist()

		self._changed = True

	def _get_readable_service_name(self, servicename):
		return '%s on %s' % (
			self._dbusmonitor.get_value(servicename, '/ProductName'),
			self._dbusmonitor.get_value(servicename, '/Mgmt/Connection'))

	def _get_instance_service_name(self, service, instance):
		return '%s/%s' % ('.'.join(service.split('.')[0:3]), instance)

	def _remove_unconnected_services(self, services):
		# Workaround: because com.victronenergy.vebus is available even when there is no vebus product
		# connected. Remove any that is not connected. For this, we use /State since mandatory path
		# /Connected is not implemented in mk2dbus.
		for servicename in services.keys():
			if ((servicename.split('.')[2] == 'vebus' and self._dbusmonitor.get_value(servicename, '/State') is None)
				or self._dbusmonitor.get_value(servicename, '/Connected') != 1
				or self._dbusmonitor.get_value(servicename, '/ProductName') is None
				or self._dbusmonitor.get_value(servicename, '/Mgmt/Connection') is None):
				del services[servicename]

	def _dbus_value_changed(self, dbusServiceName, dbusPath, dict, changes, deviceInstance):
		self._changed = True

		# Workaround because com.victronenergy.vebus is available even when there is no vebus product
		# connected.
		if (dbusPath in ['/Connected', '/ProductName', '/Mgmt/Connection'] or
			(dbusPath == '/State' and dbusServiceName.split('.')[0:3] == ['com', 'victronenergy', 'vebus'])):
			self._handleservicechange()

		# Track the timezone changes
		if dbusPath == '/Settings/System/TimeZone':
			tz = changes.get('Value')
			if tz is not None:
				os.environ['TZ'] = tz

	def _device_added(self, service, instance, do_service_change=True):
		if do_service_change:
			self._handleservicechange()

		for m in self._modules:
			m.device_added(service, instance, do_service_change)

	def _device_removed(self, service, instance):
		self._handleservicechange()

		for m in self._modules:
			m.device_removed(service, instance)

	def _gettext(self, path, value):
		if path == '/Dc/Battery/State':
			state = {self.STATE_IDLE: 'Idle', self.STATE_CHARGING: 'Charging',
				self.STATE_DISCHARGING: 'Discharging'}
			return state[value]
		item = self._summeditems.get(path)
		if item is not None:
			return item['gettext'] % value
		return str(value)

	def _compute_number_of_phases(self, path, newvalues):
		number_of_phases = None
		for phase in range(1, 4):
			p = newvalues.get('%s/L%s/Power' % (path, phase))
			if p is not None:
				number_of_phases = phase
		newvalues[path + '/NumberOfPhases'] = number_of_phases

	def _get_connected_service_list(self, classfilter=None):
		services = self._dbusmonitor.get_service_list(classfilter=classfilter)
		self._remove_unconnected_services(services)
		return services

	# returns a tuple (servicename, instance)
	def _get_first_connected_service(self, classfilter=None):
		services = self._get_connected_service_list(classfilter=classfilter)
		if len(services) == 0:
			return None
		return services.items()[0]

	# returns a tuple (servicename, instance)
	def _get_service_having_lowest_instance(self, classfilter=None):
		services = self._get_connected_service_list(classfilter=classfilter)
		if len(services) == 0:
			return None

		# sort the dict by value; returns list of tuples: (value, key)
		s = sorted((value, key) for (key, value) in services.items())
		return (s[0][1], s[0][0])


class DbusSystemCalc(SystemCalc):
	def _create_dbus_monitor(self, *args, **kwargs):
		return DbusMonitor(*args, **kwargs)

	def _create_settings(self, *args, **kwargs):
		bus = dbus.SessionBus() if 'DBUS_SESSION_BUS_ADDRESS' in os.environ else dbus.SystemBus()
		return SettingsDevice(bus, *args, timeout=10, **kwargs)

	def _create_dbus_service(self):
		dbusservice = VeDbusService('com.victronenergy.system')
		dbusservice.add_mandatory_paths(
			processname=__file__,
			processversion=softwareVersion,
			connection='data from other dbus processes',
			deviceinstance=0,
			productid=None,
			productname=None,
			firmwareversion=None,
			hardwareversion=None,
			connected=1)
		return dbusservice


if __name__ == "__main__":
	# Argument parsing
	parser = argparse.ArgumentParser(
		description='Converts readings from AC-Sensors connected to a VE.Bus device in a pvinverter ' +
					'D-Bus service.'
	)

	parser.add_argument("-d", "--debug", help="set logging level to debug",
					action="store_true")

	args = parser.parse_args()

	print("-------- dbus_systemcalc, v" + softwareVersion + " is starting up --------")
	logger = setup_logging(args.debug)

	# Have a mainloop, so we can send/receive asynchronous calls to and from dbus
	DBusGMainLoop(set_as_default=True)

	systemcalc = DbusSystemCalc()

	# Start and run the mainloop
	logger.info("Starting mainloop, responding only on events")
	mainloop = gobject.MainLoop()
	mainloop.run()

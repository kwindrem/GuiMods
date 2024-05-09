#!/usr/bin/python3 -u
# -*- coding: utf-8 -*-

from dbus.mainloop.glib import DBusGMainLoop
import dbus
import argparse
import sys
import os
import json
import time
import re
from gi.repository import GLib

# Victron packages
sys.path.insert(1, os.path.join(os.path.dirname(__file__), 'ext', 'velib_python'))
from vedbus import VeDbusService
from ve_utils import get_vrm_portal_id, exit_on_error
from dbusmonitor import DbusMonitor
from settingsdevice import SettingsDevice
from logger import setup_logging
import delegates
from sc_utils import safeadd as _safeadd, safemax as _safemax

softwareVersion = '2.166'

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
				'/CustomName': dummy,
				'/Info/MaxChargeVoltage': dummy},
			'com.victronenergy.vebus' : {
				'/Ac/ActiveIn/ActiveInput': dummy,
				'/Ac/ActiveIn/L1/P': dummy,
				'/Ac/ActiveIn/L2/P': dummy,
				'/Ac/ActiveIn/L3/P': dummy,
				'/Ac/ActiveIn/L1/I': dummy,
				'/Ac/ActiveIn/L2/I': dummy,
				'/Ac/ActiveIn/L3/I': dummy,
				'/Ac/Out/L1/P': dummy,
				'/Ac/Out/L2/P': dummy,
				'/Ac/Out/L3/P': dummy,
				'/Ac/Out/L1/I': dummy,
				'/Ac/Out/L2/I': dummy,
				'/Ac/Out/L3/I': dummy,
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
			'com.victronenergy.fuelcell': {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Current': dummy},
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
				'/Ac/L1/Current': dummy,
				'/Ac/L2/Current': dummy,
				'/Ac/L3/Current': dummy},
			'com.victronenergy.genset' : {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/ProductId' : dummy,
				'/DeviceType' : dummy,
				'/Ac/L1/Power': dummy,
				'/Ac/L2/Power': dummy,
				'/Ac/L3/Power': dummy,
				'/Ac/L1/Current': dummy,
				'/Ac/L2/Current': dummy,
				'/Ac/L3/Current': dummy,
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
				'/Dc/0/Power': dummy,
				'/Ac/Out/L1/P': dummy,
				'/Ac/Out/L1/S': dummy,
				'/Ac/Out/L1/V': dummy,
				'/Ac/Out/L1/I': dummy,
				'/Ac/Out/L2/P': dummy,
				'/Ac/Out/L2/S': dummy,
				'/Ac/Out/L2/V': dummy,
				'/Ac/Out/L2/I': dummy,
				'/Ac/Out/L3/P': dummy,
				'/Ac/Out/L3/S': dummy,
				'/Ac/Out/L3/V': dummy,
				'/Ac/Out/L3/I': dummy,
				'/Yield/Power': dummy,
				'/Soc': dummy},
			'com.victronenergy.multi': {
				'/Connected': dummy,
				'/ProductName': dummy,
				'/Mgmt/Connection': dummy,
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Current': dummy,
				'/Dc/0/Power': dummy,
				'/Ac/ActiveIn/ActiveInput': dummy,
				'/Ac/In/1/Type': dummy,
				'/Ac/In/2/Type': dummy,
				'/Ac/In/1/L1/P': dummy,
				'/Ac/In/1/L1/I': dummy,
				'/Ac/In/2/L1/P': dummy,
				'/Ac/In/2/L1/I': dummy,
				'/Ac/Out/L1/P': dummy,
				'/Ac/Out/L1/V': dummy,
				'/Ac/Out/L1/I': dummy,
				'/Ac/In/1/L2/P': dummy,
				'/Ac/In/1/L2/I': dummy,
				'/Ac/In/2/L2/P': dummy,
				'/Ac/In/2/L2/I': dummy,
				'/Ac/Out/L2/P': dummy,
				'/Ac/Out/L2/V': dummy,
				'/Ac/Out/L2/I': dummy,
				'/Ac/In/1/L3/P': dummy,
				'/Ac/In/1/L3/I': dummy,
				'/Ac/In/2/L3/P': dummy,
				'/Ac/In/2/L3/I': dummy,
				'/Ac/Out/L3/P': dummy,
				'/Ac/Out/L3/V': dummy,
				'/Ac/Out/L3/I': dummy,
				'/Yield/Power': dummy,
				'/Soc': dummy},
			'com.victronenergy.dcsystem': {
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Power': dummy
			},
			'com.victronenergy.alternator': {
				'/Dc/0/Power': dummy
			}
		}

		self._modules = [
			delegates.Multi(),
			delegates.HubTypeSelect(),
			delegates.VebusSocWriter(),
			delegates.ServiceMapper(),
			delegates.RelayState(),
			delegates.BuzzerControl(),
			delegates.LgCircuitBreakerDetect(),
			delegates.BatterySoc(self),
			delegates.Dvcc(self),
			delegates.BatterySense(self),
			delegates.BatterySettings(self),
			delegates.SystemState(self),
			delegates.BatteryLife(),
			delegates.ScheduledCharging(),
			delegates.SourceTimers(),
			delegates.BatteryData(),
			delegates.Gps(),
			delegates.AcInputs(),
			delegates.GensetStartStop(),
			delegates.SocSync(self),
			delegates.PvInverters(),
			delegates.BatteryService(self),
			delegates.CanBatterySense(),
			delegates.InverterCharger(),
			delegates.DynamicEss(),
			delegates.LoadShedding()]

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
			'useacout': ['/Settings/SystemSetup/HasAcOutSystem', 1, 0, 1],
			'gaugeautomax': ['/Settings/Gui/Gauges/AutoMax', 1, 0, 1],
			'acin0min': ['/Settings/Gui/Gauges/Ac/In/0/Current/Min', float(0), -float("inf"), 0],
			'acin1min': ['/Settings/Gui/Gauges/Ac/In/1/Current/Min', float(0), -float("inf"), 0],
			'acin0max': ['/Settings/Gui/Gauges/Ac/In/0/Current/Max', float(0), 0, float("inf")],
			'acin1max': ['/Settings/Gui/Gauges/Ac/In/1/Current/Max', float(0), 0, float("inf")],
			'dcinmax': ['/Settings/Gui/Gauges/Dc/Input/Power/Max', float(0), 0, float("inf")],
			'dcsysmax': ['/Settings/Gui/Gauges/Dc/System/Power/Max', float(0), 0, float("inf")],
			'pvmax': ['/Settings/Gui/Gauges/Pv/Power/Max', float(0), 0, float("inf")],
			'noacinmax': ['/Settings/Gui/Gauges/Ac/NoAcIn/Consumption/Current/Max', float(0), 0, float("inf")],
			'acin1max': ['/Settings/Gui/Gauges/Ac/AcIn1/Consumption/Current/Max', float(0), 0, float("inf")],
			'acin2max': ['/Settings/Gui/Gauges/Ac/AcIn2/Consumption/Current/Max', float(0), 0, float("inf")],
			}

		for m in self._modules:
			for setting in m.get_settings():
				supported_settings[setting[0]] = list(setting[1:])

		self._settings = self._create_settings(supported_settings, self._handlechangedsetting)

		self._dbusservice = self._create_dbus_service()

		for m in self._modules:
			m.set_sources(self._dbusmonitor, self._settings, self._dbusservice)

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
		self._summeditems = {
			'/Ac/Grid/L1/Power': {'gettext': '%.0F W'},
			'/Ac/Grid/L2/Power': {'gettext': '%.0F W'},
			'/Ac/Grid/L3/Power': {'gettext': '%.0F W'},
			'/Ac/Grid/L1/Current': {'gettext': '%.1F A'},
			'/Ac/Grid/L2/Current': {'gettext': '%.1F A'},
			'/Ac/Grid/L3/Current': {'gettext': '%.1F A'},
			'/Ac/Grid/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/Grid/ProductId': {'gettext': '%s'},
			'/Ac/Grid/DeviceType': {'gettext': '%s'},
			'/Ac/Genset/L1/Power': {'gettext': '%.0F W'},
			'/Ac/Genset/L2/Power': {'gettext': '%.0F W'},
			'/Ac/Genset/L3/Power': {'gettext': '%.0F W'},
			'/Ac/Genset/L1/Current': {'gettext': '%.1F A'},
			'/Ac/Genset/L2/Current': {'gettext': '%.1F A'},
			'/Ac/Genset/L3/Current': {'gettext': '%.1F A'},
			'/Ac/Genset/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/Genset/ProductId': {'gettext': '%s'},
			'/Ac/Genset/DeviceType': {'gettext': '%s'},
			'/Ac/ConsumptionOnOutput/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnOutput/L1/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnOutput/L2/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnOutput/L3/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnOutput/L1/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnOutput/L2/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnOutput/L3/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnInput/L1/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnInput/L2/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnInput/L3/Power': {'gettext': '%.0F W'},
			'/Ac/ConsumptionOnInput/L1/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/L2/Current': {'gettext': '%.1F A'},
			'/Ac/ConsumptionOnInput/L3/Current': {'gettext': '%.1F A'},
			'/Ac/Consumption/NumberOfPhases': {'gettext': '%.0F W'},
			'/Ac/Consumption/L1/Power': {'gettext': '%.0F W'},
			'/Ac/Consumption/L2/Power': {'gettext': '%.0F W'},
			'/Ac/Consumption/L3/Power': {'gettext': '%.0F W'},
			'/Ac/Consumption/L1/Current': {'gettext': '%.1F A'},
			'/Ac/Consumption/L2/Current': {'gettext': '%.1F A'},
			'/Ac/Consumption/L3/Current': {'gettext': '%.1F A'},
			'/Ac/Consumption/NumberOfPhases': {'gettext': '%.0F W'},
			'/Dc/Pv/Power': {'gettext': '%.0F W'},
			'/Dc/Pv/Current': {'gettext': '%.1F A'},
			'/Dc/Battery/Voltage': {'gettext': '%.2F V'},
			'/Dc/Battery/VoltageService': {'gettext': '%s'},
			'/Dc/Battery/Current': {'gettext': '%.1F A'},
			'/Dc/Battery/Power': {'gettext': '%.0F W'},
			'/Dc/Battery/State': {'gettext': lambda v: ({
				self.STATE_IDLE: 'Idle',
				self.STATE_CHARGING: 'Charging',
				self.STATE_DISCHARGING: 'Discharging'}.get(v, 'Unknown'))},
			'/Dc/Battery/TimeToGo': {'gettext': '%.0F s'},
			'/Dc/Battery/ConsumedAmphours': {'gettext': '%.1F Ah'},
			'/Dc/Battery/ProductId': {'gettext': '0x%x'},
			'/Dc/Charger/Power': {'gettext': '%.0F %%'},
			'/Dc/FuelCell/Power': {'gettext': '%.0F %%'},
			'/Dc/Alternator/Power': {'gettext': '%.0F W'},
			'/Dc/System/Power': {'gettext': '%.0F W'},
			'/Dc/System/MeasurementType': {'gettext': '%d'},
			'/Ac/ActiveIn/Source': {'gettext': '%s'},
			'/Ac/ActiveIn/L1/Power': {'gettext': '%.0F W'},
			'/Ac/ActiveIn/L2/Power': {'gettext': '%.0F W'},
			'/Ac/ActiveIn/L3/Power': {'gettext': '%.0F W'},
			'/Ac/ActiveIn/L1/Current': {'gettext': '%.1F A'},
			'/Ac/ActiveIn/L2/Current': {'gettext': '%.1F A'},
			'/Ac/ActiveIn/L3/Current': {'gettext': '%.1F A'},
			'/Ac/ActiveIn/NumberOfPhases': {'gettext': '%d'},
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

		GLib.timeout_add(1000, exit_on_error, self._handletimertick)

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

		for k, v in services.items():
			if v == instance:
				return k
		return None

	def _determinebatteryservice(self):
		auto_battery_service = self._autoselect_battery_service()
		auto_battery_measurement = None
		auto_selected = False
		if auto_battery_service is not None:
			services = self._dbusmonitor.get_service_list()
			if auto_battery_service in services:
				auto_battery_measurement = \
					self._get_instance_service_name(auto_battery_service, services[auto_battery_service])
				auto_battery_measurement = auto_battery_measurement.replace('.', '_').replace('/', '_') + '/Dc/0'
		self._dbusservice['/AutoSelectedBatteryMeasurement'] = auto_battery_measurement

		if self._settings['batteryservice'] == self.BATSERVICE_DEFAULT:
			auto_selected = True
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
			self._dbusservice['/Dc/Battery/BatteryService'] = self._batteryservice = newbatteryservice
			for m in self._modules:
				m.battery_service_changed(auto_selected, self._batteryservice, newbatteryservice)

	def _autoselect_battery_service(self):
		# Default setting business logic:
		# first try to use a battery service (BMV or Lynx Shunt VE.Can). If there
		# is more than one battery service, just use a random one. If no battery service is
		# available, check if there are not Solar chargers and no normal chargers. If they are not
		# there, assume this is a hub-2, hub-3 or hub-4 system and use VE.Bus SOC.
		batteries = self._get_connected_service_list('com.victronenergy.battery')

		# Pick the battery service that has the lowest DeviceInstance, giving
		# preference to those with a BMS. Instances of 'lynxparallel' are preferred over regular BMSes.
		if len(batteries) > 0:
			batteries = [
				(not self._dbusmonitor.seen(s, '/Info/MaxChargeVoltage'),
	 			 not s.startswith('com.victronenergy.battery.lynxparallel'), i, s)
				for s, i in batteries.items()]
			return sorted(batteries, key=lambda x: x[:3])[0][3]

		# No battery services, and there is a charger in the system. Abandon
		# hope.
		if self._get_first_connected_service('com.victronenergy.charger') is not None:
			return None

		# Also no Multi, then give up.
		vebus_service = self._get_service_having_lowest_instance('com.victronenergy.vebus')
		if vebus_service is None:
			# No VE.Bus, but maybe there is an inverter with built-in SOC
			# tracking, eg RS Smart or Multi RS.
			inverter = self._get_service_having_lowest_instance('com.victronenergy.multi')
			if inverter and self._dbusmonitor.get_value(inverter[0], '/Soc') is not None:
				return inverter[0]

			inverter = self._get_service_having_lowest_instance('com.victronenergy.inverter')
			if inverter and self._dbusmonitor.get_value(inverter[0], '/Soc') is not None:
				return inverter[0]

			return None

		# There is a Multi, it supports tracking external charge current from
		# solarchargers, and there are no DC loads. Then use it.
		if self._dbusmonitor.get_value(
				vebus_service[0], '/ExtraBatteryCurrent') is not None \
				and self._get_first_connected_service('com.victronenergy.dcsystem') is None \
				and self._settings['hasdcsystem'] == 0:
			return vebus_service[0]

		# Multi does not support tracking solarcharger current, and we have
		# solar chargers. Then we cannot use it.
		if self._get_first_connected_service('com.victronenergy.solarcharger') is not None:
			return None

		# Only a Multi, no other chargers. Then we can use it.
		return vebus_service[0]

	@property
	def batteryservice(self):
		return self._batteryservice

	# Called on a one second timer
	def _handletimertick(self):
		if self._changed:
			self._updatevalues()
		self._changed = False

		return True  # keep timer running

	def _updatevalues(self):
		# ==== PREPARATIONS ====
		newvalues = {}

		# Set the user timezone
		if 'TZ' not in os.environ:
			tz = self._dbusmonitor.get_value('com.victronenergy.settings', '/Settings/System/TimeZone')
			if tz is not None:
				os.environ['TZ'] = tz
				time.tzset()

		# Determine values used in logic below
		vebusses = self._dbusmonitor.get_service_list('com.victronenergy.vebus')
		vebuspower = 0
		for vebus in vebusses:
			v = self._dbusmonitor.get_value(vebus, '/Dc/0/Voltage')
			i = self._dbusmonitor.get_value(vebus, '/Dc/0/Current')
			if v is not None and i is not None:
				vebuspower += v * i

		# ==== PVINVERTERS ====
		# Work is done in pv-inverter delegate. Ideally all of this should
		# happen in update_values in the delegate, but these values are
		# used below in calculating consumption, so until this is less
		# unwieldy this has to stay here.
		# TODO this can go away once consumption below no longer relies
		# on these values, or has moved to its own delegate.
		newvalues.update(delegates.PvInverters.instance.get_totals())
		self._compute_number_of_phases('/Ac/PvOnGrid', newvalues)
		self._compute_number_of_phases('/Ac/PvOnOutput', newvalues)
		self._compute_number_of_phases('/Ac/PvOnGenset', newvalues)

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

		# ==== FUELCELLS ====
		fuelcells = self._dbusmonitor.get_service_list('com.victronenergy.fuelcell')
		fuelcell_batteryvoltage = None
		fuelcell_batteryvoltage_service = None
		for fuelcell in fuelcells:
			# Assume the battery connected to output 0 is the main battery
			v = self._dbusmonitor.get_value(fuelcell, '/Dc/0/Voltage')
			if v is None:
				continue

			fuelcell_batteryvoltage = v
			fuelcell_batteryvoltage_service = fuelcell

			i = self._dbusmonitor.get_value(fuelcell, '/Dc/0/Current')
			if i is None:
				continue

			if '/Dc/FuelCell/Power' not in newvalues:
				newvalues['/Dc/FuelCell/Power'] = v * i
			else:
				newvalues['/Dc/FuelCell/Power'] += v * i

		# ==== ALTERNATOR ====
		alternators = self._dbusmonitor.get_service_list('com.victronenergy.alternator')
		for alternator in alternators:
			# Assume the battery connected to output 0 is the main battery
			p = self._dbusmonitor.get_value(alternator, '/Dc/0/Power')
			if p is None:
				continue

			if '/Dc/Alternator/Power' not in newvalues:
				newvalues['/Dc/Alternator/Power'] = p
			else:
				newvalues['/Dc/Alternator/Power'] += p

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

		# ==== Other Inverters and Inverter/Chargers ====
		_other_inverters = sorted((di, s) for s, di in self._dbusmonitor.get_service_list('com.victronenergy.multi').items()) + \
			sorted((di, s) for s, di in self._dbusmonitor.get_service_list('com.victronenergy.inverter').items())
		non_vebus_inverters = [x[1] for x in _other_inverters]
		non_vebus_inverter = None
		if non_vebus_inverters:
			non_vebus_inverter = non_vebus_inverters[0]

			# For RS Smart and Multi RS, add PV to the yield
			for i in non_vebus_inverters:
				if (pv_yield := self._dbusmonitor.get_value(i, "/Yield/Power")) is not None:
					newvalues['/Dc/Pv/Power'] = newvalues.get('/Dc/Pv/Power', 0) + pv_yield

		# Used lower down, possibly needed for battery values as well
		dcsystems = self._dbusmonitor.get_service_list('com.victronenergy.dcsystem')

		# ==== BATTERY ====
		if self._batteryservice is not None:
			batteryservicetype = self._batteryservice.split('.')[2]
			assert batteryservicetype in ('battery', 'vebus', 'inverter', 'multi')

			newvalues['/Dc/Battery/TimeToGo'] = self._dbusmonitor.get_value(self._batteryservice,'/TimeToGo')
			newvalues['/Dc/Battery/ConsumedAmphours'] = self._dbusmonitor.get_value(self._batteryservice,'/ConsumedAmphours')
			newvalues['/Dc/Battery/ProductId'] = self._dbusmonitor.get_value(self._batteryservice, '/ProductId')

			if batteryservicetype in ('battery', 'inverter', 'multi'):
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
				if self._settings['hasdcsystem'] == 1 or dcsystems:
					# hasdcsystem will normally disqualify the multi from being
					# auto-selected as battery monitor, so the only way we're
					# here is if the user explicitly selected the multi as the
					# battery service
					newvalues['/Dc/Battery/Current'] = vebus_current
					if vebus_power is not None:
						newvalues['/Dc/Battery/Power'] = vebus_power
				else:
					battery_power = _safeadd(solarchargers_charge_power, vebus_power)
					newvalues['/Dc/Battery/Current'] = battery_power / vebus_voltage if vebus_voltage is not None and vebus_voltage > 0 else None
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
			# try a solar charger, a charger, a vedirect inverter or a dcsource
			# as fallbacks.
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
				if non_vebus_inverter is not None and (v := self._dbusmonitor.get_value(non_vebus_inverter, '/Dc/0/Voltage')) is not None:
					newvalues['/Dc/Battery/Voltage'] = v
					newvalues['/Dc/Battery/VoltageService'] = non_vebus_inverter
				elif solarcharger_batteryvoltage is not None:
					newvalues['/Dc/Battery/Voltage'] = solarcharger_batteryvoltage
					newvalues['/Dc/Battery/VoltageService'] = solarcharger_batteryvoltage_service
				elif charger_batteryvoltage is not None:
					newvalues['/Dc/Battery/Voltage'] = charger_batteryvoltage
					newvalues['/Dc/Battery/VoltageService'] = charger_batteryvoltage_service
				elif fuelcell_batteryvoltage is not None:
					newvalues['/Dc/Battery/Voltage'] = fuelcell_batteryvoltage
					newvalues['/Dc/Battery/VoltageService'] = fuelcell_batteryvoltage_service
				elif dcsystems:
					# Get voltage from first dcsystem
					s = next(iter(dcsystems.keys()))
					v = self._dbusmonitor.get_value(s, '/Dc/0/Voltage')
					if v is not None:
						newvalues['/Dc/Battery/Voltage'] = v
						newvalues['/Dc/Battery/VoltageService'] = s

			# We have no suitable battery monitor, so power and current data
			# is not available. We can however calculate it from other values,
			# if we have at least a battery voltage.
			if '/Dc/Battery/Voltage' in newvalues:
				dcsystempower = _safeadd(0, *(self._dbusmonitor.get_value(s,
					'/Dc/0/Power', 0) for s in dcsystems))
				if dcsystems or self._settings['hasdcsystem'] == 0:
					# Either DC loads are monitored, or there are no
					# unmonitored DC loads or chargers: derive battery watts
					# and amps from vebus, solarchargers, chargers and measured
					# loads.
					p = solarchargers_charge_power + newvalues.get('/Dc/Charger/Power', 0) + vebuspower - dcsystempower
					voltage = newvalues['/Dc/Battery/Voltage']
					newvalues['/Dc/Battery/Current'] = p / voltage if voltage > 0 else None
					newvalues['/Dc/Battery/Power'] = p

		# ==== SYSTEM POWER ====
		# Look for dcsytem devices, add them together. Otherwise, if enabled,
		# calculate it
		if dcsystems:
			newvalues['/Dc/System/MeasurementType'] = 1 # measured
			newvalues['/Dc/System/Power'] = 0
			for meter in dcsystems:
				newvalues['/Dc/System/Power'] = _safeadd(newvalues['/Dc/System/Power'],
					self._dbusmonitor.get_value(meter, '/Dc/0/Power'))
		elif self._settings['hasdcsystem'] == 1 and batteryservicetype == 'battery':
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
				fuelcell_power = newvalues.get('/Dc/FuelCell/Power', 0)
				alternator_power = newvalues.get('/Dc/Alternator/Power', 0)

				# If there are VE.Direct inverters, remove their power from the
				# DC estimate. This is done using the AC value when the DC
				# power values are not available.
				inverter_power = 0
				for i in non_vebus_inverters:
					inverter_current = self._dbusmonitor.get_value(i, '/Dc/0/Current')
					if inverter_current is not None:
						inverter_power += self._dbusmonitor.get_value(
							i, '/Dc/0/Voltage', 0) * inverter_current
					else:
						inverter_power -= self._dbusmonitor.get_value(
							i, '/Ac/Out/L1/V', 0) * self._dbusmonitor.get_value(
							i, '/Ac/Out/L1/I', 0)
				newvalues['/Dc/System/MeasurementType'] = 0 # estimated
				# FIXME In future we will subtract alternator power from the
				# calculated DC power, because it will be individually
				# displayed. For now, we leave it out so that in the current
				# version of Venus it does not break user's expectations.
				#newvalues['/Dc/System/Power'] = dc_pv_power + charger_power + fuelcell_power + vebuspower + inverter_power - battery_power - alternator_power
				newvalues['/Dc/System/Power'] = dc_pv_power + charger_power + fuelcell_power + vebuspower + inverter_power - battery_power

		elif self._settings['hasdcsystem'] == 1 and solarchargers_loadoutput_power is not None:
			newvalues['/Dc/System/MeasurementType'] = 0 # estimated
			newvalues['/Dc/System/Power'] = solarchargers_loadoutput_power

		# ===== AC IN SOURCE =====
		multi_path = getattr(delegates.Multi.instance.multi, 'service', None)
		ac_in_source = None
		active_input = None
		if multi_path is None:
			# Check if we have an non-VE.Bus inverter.
			if non_vebus_inverter is not None:
				if (active_input := self._dbusmonitor.get_value(non_vebus_inverter, '/Ac/ActiveIn/ActiveInput')) is not None and \
						active_input in (0, 1) and \
						(active_type := self._dbusmonitor.get_value(non_vebus_inverter, '/Ac/In/{}/Type'.format(active_input + 1))) is not None:
					ac_in_source = active_type
				else:
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
		grid_meter = delegates.AcInputs.instance.gridmeter
		genset_meter = delegates.AcInputs.instance.gensetmeter

		# Make an educated guess as to what is being consumed from an AC source. If ac_in_source
		# indicates grid, genset or shore, we use that. If the Multi is off, or disconnected through
		# a relay assistant or otherwise, then assume the presence of a .grid or .genset service indicates
		# presence of that AC source. If both are available, then give up. This decision making is here
		# so the GUI has something to present even if the Multi is off.
		ac_in_guess = ac_in_source
		if ac_in_guess in (None, 0xF0):
			if genset_meter is None and grid_meter is not None:
				ac_in_guess = 1
			elif grid_meter is None and genset_meter is not None:
				ac_in_guess = 2

		consumption = { "L1" : None, "L2" : None, "L3" : None }
		currentconsumption = { "L1" : None, "L2" : None, "L3" : None }
		for device_type, em, _types in (('Grid', grid_meter, (1, 3)), ('Genset', genset_meter, (2,))):
			# If a grid meter is present we use values from it. If not, we look at the multi. If it has
			# AcIn1 or AcIn2 connected to the grid, we use those values.
			# com.victronenergy.grid.??? indicates presence of an energy meter used as grid meter.
			# com.victronenergy.vebus.???/Ac/ActiveIn/ActiveInput: decides which whether we look at AcIn1
			# or AcIn2 as possible grid connection.
			uses_active_input = ac_in_source in _types
			for phase in consumption:
				p = None
				mc = None
				pvpower = newvalues.get('/Ac/PvOn%s/%s/Power' % (device_type, phase))
				pvcurrent = newvalues.get('/Ac/PvOn%s/%s/Current' % (device_type, phase))
				if em is not None:
					p = self._dbusmonitor.get_value(em.service, '/Ac/%s/Power' % phase)
					mc = self._dbusmonitor.get_value(em.service, '/Ac/%s/Current' % phase)
					# Compute consumption between energy meter and multi (meter power - multi AC in) and
					# add an optional PV inverter on input to the mix.
					c = None
					cc = None
					if uses_active_input:
						if multi_path is not None:
							try:
								c = _safeadd(c, -self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/P' % phase))
								cc = _safeadd(cc, -self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/I' % phase))
							except TypeError:
								pass
						elif non_vebus_inverter is not None and active_input in (0, 1):
							for i in non_vebus_inverters:
								try:
									c = _safeadd(c, -self._dbusmonitor.get_value(i, '/Ac/In/%d/%s/P' % (active_input+1, phase)))
									cc = _safeadd(cc, -self._dbusmonitor.get_value(i, '/Ac/In/%d/%s/I' % (active_input+1, phase)))
								except TypeError:
									pass

					# If there's any power coming from a PV inverter in the inactive AC in (which is unlikely),
					# it will still be used, because there may also be a load in the same ACIn consuming
					# power, or the power could be fed back to the net.
					c = _safeadd(c, p, pvpower)
					cc = _safeadd(cc, mc, pvcurrent)
					consumption[phase] = _safeadd(consumption[phase], _safemax(0, c))
					currentconsumption[phase] = _safeadd(currentconsumption[phase], _safemax(0, cc))
				else:
					if uses_active_input:
						if multi_path is not None  and (
								p := self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/P' % phase)) is not None:
							consumption[phase] = _safeadd(0, consumption[phase])
							currentconsumption[phase] = _safeadd(0, currentconsumption[phase])
							mc = self._dbusmonitor.get_value(multi_path, '/Ac/ActiveIn/%s/I' % phase)
						elif non_vebus_inverter is not None and active_input in (0, 1):
							for i in non_vebus_inverters:
								p = _safeadd(p,
									self._dbusmonitor.get_value(i, '/Ac/In/%d/%s/P' % (active_input + 1, phase)))
								mc = _safeadd(mc,
									self._dbusmonitor.get_value(i, '/Ac/In/%d/%s/I' % (active_input + 1, phase)))
							if p is not None:
								consumption[phase] = _safeadd(0, consumption[phase])
								currentconsumption[phase] = _safeadd(0, currentconsumption[phase])

					# No relevant energy meter present. Assume there is no load between the grid and the multi.
					# There may be a PV inverter present though (Hub-3 setup).
					try:
						p = _safeadd(p, -pvpower)
						mc = _safeadd(mc, -pvcurrent)
					except TypeError:
						pass

				newvalues['/Ac/%s/%s/Power' % (device_type, phase)] = p
				newvalues['/Ac/%s/%s/Current' % (device_type, phase)] = mc
				if ac_in_guess in _types:
					newvalues['/Ac/ActiveIn/%s/Power' % (phase,)] = p
					newvalues['/Ac/ActiveIn/%s/Current' % (phase,)] = mc

			self._compute_number_of_phases('/Ac/%s' % device_type, newvalues)
			self._compute_number_of_phases('/Ac/ActiveIn', newvalues)

			product_id = None
			device_type_id = None
			if em is not None:
				product_id = em.product_id
				device_type_id = em.device_type
			if product_id is None and uses_active_input:
				if multi_path is not None:
					product_id = self._dbusmonitor.get_value(multi_path, '/ProductId')
				elif non_vebus_inverter is not None:
					product_id = self._dbusmonitor.get_value(non_vebus_inverter, '/ProductId')
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
			a = None
			if use_ac_out:
				c = newvalues.get('/Ac/PvOnOutput/%s/Power' % phase)
				a = newvalues.get('/Ac/PvOnOutput/%s/Current' % phase)
				if multi_path is None:
					for inv in non_vebus_inverters:
						ac_out = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/P' % phase)
						i = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/I' % phase)

						# Some models don't show power, try apparent power,
						# else calculate it
						if ac_out is None:
							ac_out = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/S' % phase)
							if ac_out is None:
								u = self._dbusmonitor.get_value(inv, '/Ac/Out/%s/V' % phase)
								if None not in (i, u):
									ac_out = i * u
						c = _safeadd(c, ac_out)
						a = _safeadd(a, i)
				else:
					ac_out = self._dbusmonitor.get_value(multi_path, '/Ac/Out/%s/P' % phase)
					c = _safeadd(c, ac_out)
					i_out = self._dbusmonitor.get_value(multi_path, '/Ac/Out/%s/I' % phase)
					a = _safeadd(a, i_out)
				c = _safemax(0, c)
				a = _safemax(0, a)
			newvalues['/Ac/ConsumptionOnOutput/%s/Power' % phase] = c
			newvalues['/Ac/ConsumptionOnOutput/%s/Current' % phase] = a
			newvalues['/Ac/ConsumptionOnInput/%s/Power' % phase] = consumption[phase]
			newvalues['/Ac/ConsumptionOnInput/%s/Current' % phase] = currentconsumption[phase]
			newvalues['/Ac/Consumption/%s/Power' % phase] = _safeadd(consumption[phase], c)
			newvalues['/Ac/Consumption/%s/Current' % phase] = _safeadd(currentconsumption[phase], a)
		self._compute_number_of_phases('/Ac/Consumption', newvalues)
		self._compute_number_of_phases('/Ac/ConsumptionOnOutput', newvalues)
		self._compute_number_of_phases('/Ac/ConsumptionOnInput', newvalues)

		for m in self._modules:
			m.update_values(newvalues)

		# ==== UPDATE MINIMUM AND MAXIMUM LEVELS ====
		if (self._settings['gaugeautomax']):
			# min/max values are stored and updated in localsettings
			# values are stored under /Settings/Gui/Briefview
			# /Settings/Gui/Gauges/AutoMax:
			#	1-> Automatic: Gauge limits are updated automatically and stored in localsettings
			# 	0-> Manual: Gauge limits are entered manually by the user
			# The gui pulls the gauge limits from localsettings and provides
			# a means for the user to set them if Automax is off.

			# AC output
			# This maximum is maintained for 3 situations:
			# 1: AC input 1 is connected
			# 2: AC input 2 is connected
			# 3: No AC input is connected
			# All 3 scenarios may lead to different maximum values since the capabilities of the system changes.
			# So 3 different maxima are stored and relayed to /Ac/Consumption/Current/Max based on the active scenario.
			activeIn = 'acin1' if (self._dbusservice['/Ac/In/0/Connected'] == 1) else \
						'acin2' if (self._dbusservice['/Ac/In/1/Connected'] == 1) else \
						'noacin'

			# Quattro has 2 AC inputs which cannot be active simultaneously.
			# activeIn needs to 1 when 'Ac/In/1/Connected' is 1 and can be 0 otherwise.
			activeInNr = int(activeIn[-1]) -1 if activeIn != 'noacin' else None

			# AC input
			# Minimum values occur when feeding back to the grid.
			# For the minimum value, make sure it is 0 at its maximum.
			# Update correct '/Ac/In/..' based on the current active input.
			# When no inputs are active, paths '/Ac/In/[0/1]/Current/[Min/Max] will all be invalidated.
			if(activeInNr != None):
				self._settings['acin%smin' % activeInNr] = min(0,
																	self._settings['acin%smin' % activeInNr] or float("inf"),
																	newvalues.get('/Ac/ActiveIn/L1/Current') or float("inf"),
																	newvalues.get('/Ac/ActiveIn/L2/Current') or float("inf"),
																	newvalues.get('/Ac/ActiveIn/L3/Current') or float("inf"))

				self._settings['acin%smax' % activeInNr] = max(self._settings['acin%smax' % activeInNr] or 0,
																	newvalues.get('/Ac/ActiveIn/L1/Current') or 0,
																	newvalues.get('/Ac/ActiveIn/L2/Current') or 0,
																	newvalues.get('/Ac/ActiveIn/L3/Current') or 0)

			self._settings['%smax' % activeIn] = max(self._settings['%smax' % activeIn],
																newvalues.get('/Ac/Consumption/L1/Current') or 0,
																newvalues.get('/Ac/Consumption/L2/Current') or 0,
																newvalues.get('/Ac/Consumption/L3/Current') or 0)

			# DC input
			self._settings['dcinmax'] = max(self._settings['dcinmax'] or 0,
													sum([newvalues.get('/Dc/Charger/Power') or 0,
														newvalues.get('/Dc/FuelCell/Power') or 0,
														newvalues.get('/Dc/Alternator/Power') or 0]))

			# DC output
			self._settings['dcsysmax'] = _safemax(self._settings['dcsysmax'] or 0,
															newvalues.get('/Dc/System/Power') or 0)

			# PV power
			self._settings['pvmax'] = _safemax(self._settings['pvmax'] or 0,
													_safeadd(newvalues.get('/Dc/Pv/Power') or 0,
													self._dbusservice['/Ac/PvOnGrid/L1/Power'],
													self._dbusservice['/Ac/PvOnGrid/L2/Power'],
													self._dbusservice['/Ac/PvOnGrid/L3/Power'],
													self._dbusservice['/Ac/PvOnGenset/L1/Power'],
													self._dbusservice['/Ac/PvOnGenset/L2/Power'],
													self._dbusservice['/Ac/PvOnGenset/L3/Power'],
													self._dbusservice['/Ac/PvOnOutput/L1/Power'],
													self._dbusservice['/Ac/PvOnOutput/L2/Power'],
													self._dbusservice['/Ac/PvOnOutput/L3/Power']))

		# ==== UPDATE DBUS ITEMS ====
		with self._dbusservice as sss:
			for path in self._summeditems.keys():
				# Why the None? Because we want to invalidate things we don't have anymore.
				sss[path] = newvalues.get(path, None)

	def _handleservicechange(self):
		# Update the available battery monitor services, used to populate the dropdown in the settings.
		# Below code makes a dictionary. The key is [dbuserviceclass]/[deviceinstance]. For example
		# "battery/245". The value is the name to show to the user in the dropdown. The full dbus-
		# servicename, ie 'com.victronenergy.vebus.ttyO1' is not used, since the last part of that is not
		# fixed. dbus-serviceclass name and the device instance are already fixed, so best to use those.

		services = self._get_connected_service_list('com.victronenergy.vebus')
		services.update(self._get_connected_service_list('com.victronenergy.battery'))
		services.update({k: v for k, v in self._get_connected_service_list(
			'com.victronenergy.multi').items() if self._dbusmonitor.get_value(k, '/Soc') is not None})
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

		self._changed = True

	def _get_readable_service_name(self, servicename):
		return '%s on %s' % (
			self._dbusmonitor.get_value(servicename, '/ProductName'),
			self._dbusmonitor.get_value(servicename, '/Mgmt/Connection'))

	def _get_instance_service_name(self, service, instance):
		return '%s/%s' % ('.'.join(service.split('.')[0:3]), instance)

	def _remove_unconnected_services(self, services):
		# Workaround: because com.victronenergy.vebus is available even when there is no vebus product
		# connected, remove any service that is not connected. Previously we used
		# /State since mandatory path /Connected is not implemented in mk2dbus,
		# but this has since been resolved.
		for servicename in list(services.keys()):
			if (self._dbusmonitor.get_value(servicename, '/Connected') != 1
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
				time.tzset()

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
		item = self._summeditems.get(path)
		if item is not None:
			try:
				gettext = item['gettext']
			except KeyError:
				pass
			else:
				if callable(gettext):
					return gettext(value)
				return gettext % value
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

	# returns a servicename string
	def _get_first_connected_service(self, classfilter):
		services = self._get_connected_service_list(classfilter=classfilter)
		if len(services) == 0:
			return None
		return next(iter(services.items()), (None,))[0]

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
		venusversion, venusbuildtime = self._get_venus_versioninfo()

		dbusservice = VeDbusService('com.victronenergy.system')
		dbusservice.add_mandatory_paths(
			processname=__file__,
			processversion=softwareVersion,
			connection='data from other dbus processes',
			deviceinstance=0,
			productid=None,
			productname=None,
			firmwareversion=venusversion,
			hardwareversion=None,
			connected=1)
		dbusservice.add_path('/FirmwareBuild', value=venusbuildtime)
		return dbusservice

	def _get_venus_versioninfo(self):
		try:
			with open("/opt/victronenergy/version", "r") as fp:
				version, software, buildtime = fp.read().split('\n')[:3]
			major, minor, _, rev = re.compile('v([0-9]*)\.([0-9]*)(~([0-9]*))?').match(version).groups()
			return (int(major, 16)<<16)+(int(minor, 16)<<8)+(0 if rev is None else int(rev, 16)), buildtime
		except Exception:
			pass
		return 0, '0'

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
	mainloop = GLib.MainLoop()
	mainloop.run()

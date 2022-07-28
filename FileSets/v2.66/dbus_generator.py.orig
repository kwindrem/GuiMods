#!/usr/bin/python -u
# -*- coding: utf-8 -*-

from dbus.mainloop.glib import DBusGMainLoop
import dbus
import gobject
import argparse
import sys
import os
import signal
# Victron packages
sys.path.insert(1, os.path.join(os.path.dirname(__file__), 'ext', 'velib_python'))
from vedbus import VeDbusService
from ve_utils import exit_on_error
from dbusmonitor import DbusMonitor
from settingsdevice import SettingsDevice
from logger import setup_logging
import logging
from gen_utils import dummy
import time
import relay
import fischerpanda

softwareversion = '1.3.11'

class Generator:
	def __init__(self):
		self._exit = False
		self._instances = {}
		self._modules = [relay, fischerpanda]

		# Common dbus services/path
		commondbustree = {
			'com.victronenergy.settings': {
				'/Settings/System/TimeZone': dummy,
				'/Settings/System/AcInput1': dummy,
				'/Settings/System/AcInput2': dummy,
				'/Settings/Relay/Polarity': dummy
				},
			'com.victronenergy.battery': {
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Current': dummy,
				'/Dc/1/Voltage': dummy,
				'/Dc/1/Current': dummy,
				'/Soc': dummy
				},
			'com.victronenergy.vebus': {
				'/Ac/Out/L1/P': dummy,
				'/Ac/Out/L2/P': dummy,
				'/Ac/Out/L3/P': dummy,
				'/Alarms/L1/Overload': dummy,
				'/Alarms/L2/Overload': dummy,
				'/Alarms/L3/Overload': dummy,
				'/Alarms/L1/HighTemperature': dummy,
				'/Alarms/L2/HighTemperature': dummy,
				'/Alarms/L3/HighTemperature': dummy,
				'/Alarms/HighTemperature': dummy,
				'/Alarms/Overload': dummy,
				'/Ac/ActiveIn/ActiveInput': dummy,
				'/Ac/ActiveIn/Connected': dummy,
				'/Dc/0/Voltage': dummy,
				'/Dc/0/Current': dummy,
				'/Dc/1/Voltage': dummy,
				'/Dc/1/Current': dummy,
				'/Soc': dummy
				},
			'com.victronenergy.system': {
				'/Ac/ConsumptionOnInput/L1/Power': dummy,
				'/Ac/ConsumptionOnInput/L2/Power': dummy,
				'/Ac/ConsumptionOnInput/L3/Power': dummy,
				'/Ac/ConsumptionOnOutput/L1/Power': dummy,
				'/Ac/ConsumptionOnOutput/L2/Power': dummy,
				'/Ac/ConsumptionOnOutput/L3/Power': dummy,
				'/Dc/Pv/Power': dummy,
				'/AutoSelectedBatteryMeasurement': dummy,
				'/Ac/ActiveIn/Source': dummy,
				'/VebusService': dummy,
				'/Dc/Battery/Voltage': dummy,
				'/Dc/Battery/Current': dummy,
				'/Dc/Battery/Soc': dummy
				}
			}

		# Settings base
		settingsbase = {
			'autostart': ['/Settings/{0}/AutoStartEnabled', 1, 0, 1],
			'batterymeasurement': ['/Settings/{0}/Service', '', 0, 0],
			'accumulateddaily': ['/Settings/{0}/AccumulatedDaily', '', 0, 0, True],
			'accumulatedtotal': ['/Settings/{0}/AccumulatedTotal', 0, 0, 0, True],
			'batterymeasurement': ['/Settings/{0}/BatteryService', 'default', 0, 0],
			'minimumruntime': ['/Settings/{0}/MinimumRuntime', 0, 0, 86400],  # minutes
			'stoponac1enabled': ['/Settings/{0}/StopWhenAc1Available', 0, 0, 10],
			# On permanent loss of communication: 0 = Stop, 1 = Start, 2 = keep running
			'onlosscommunication': ['/Settings/{0}/OnLossCommunication', 0, 0, 2],
			# Quiet hours
			'quiethoursenabled': ['/Settings/{0}/QuietHours/Enabled', 0, 0, 1],
			'quiethoursstarttime': ['/Settings/{0}/QuietHours/StartTime', 75600, 0, 86400],
			'quiethoursendtime': ['/Settings/{0}/QuietHours/EndTime', 21600, 0, 86400],
			# SOC
			'socenabled': ['/Settings/{0}/Soc/Enabled', 0, 0, 1],
			'socstart': ['/Settings/{0}/Soc/StartValue', 80, 0, 100],
			'socstop': ['/Settings/{0}/Soc/StopValue', 90, 0, 100],
			'qh_socstart': ['/Settings/{0}/Soc/QuietHoursStartValue', 90, 0, 100],
			'qh_socstop': ['/Settings/{0}/Soc/QuietHoursStopValue', 90, 0, 100],
			# Voltage
			'batteryvoltageenabled': ['/Settings/{0}/BatteryVoltage/Enabled', 0, 0, 1],
			'batteryvoltagestart': ['/Settings/{0}/BatteryVoltage/StartValue', 11.5, 0, 150],
			'batteryvoltagestop': ['/Settings/{0}/BatteryVoltage/StopValue', 12.4, 0, 150],
			'batteryvoltagestarttimer': ['/Settings/{0}/BatteryVoltage/StartTimer', 20, 0, 10000],
			'batteryvoltagestoptimer': ['/Settings/{0}/BatteryVoltage/StopTimer', 20, 0, 10000],
			'qh_batteryvoltagestart': ['/Settings/{0}/BatteryVoltage/QuietHoursStartValue', 11.9, 0, 100],
			'qh_batteryvoltagestop': ['/Settings/{0}/BatteryVoltage/QuietHoursStopValue', 12.4, 0, 100],
			# Current
			'batterycurrentenabled': ['/Settings/{0}/BatteryCurrent/Enabled', 0, 0, 1],
			'batterycurrentstart': ['/Settings/{0}/BatteryCurrent/StartValue', 10.5, 0.5, 10000],
			'batterycurrentstop': ['/Settings/{0}/BatteryCurrent/StopValue', 5.5, 0, 10000],
			'batterycurrentstarttimer': ['/Settings/{0}/BatteryCurrent/StartTimer', 20, 0, 10000],
			'batterycurrentstoptimer': ['/Settings/{0}/BatteryCurrent/StopTimer', 20, 0, 10000],
			'qh_batterycurrentstart': ['/Settings/{0}/BatteryCurrent/QuietHoursStartValue', 20.5, 0, 10000],
			'qh_batterycurrentstop': ['/Settings/{0}/BatteryCurrent/QuietHoursStopValue', 15.5, 0, 10000],
			# AC load
			'acloadenabled': ['/Settings/{0}/AcLoad/Enabled', 0, 0, 1],
			# Measuerement, 0 = Total AC consumption, 1 = AC on inverter output, 2 = Single phase
			'acloadmeasuerment': ['/Settings/{0}/AcLoad/Measurement', 0, 0, 100],
			'acloadstart': ['/Settings/{0}/AcLoad/StartValue', 1600, 5, 100000],
			'acloadstop': ['/Settings/{0}/AcLoad/StopValue', 800, 0, 100000],
			'acloadstarttimer': ['/Settings/{0}/AcLoad/StartTimer', 20, 0, 10000],
			'acloadstoptimer': ['/Settings/{0}/AcLoad/StopTimer', 20, 0, 10000],
			'qh_acloadstart': ['/Settings/{0}/AcLoad/QuietHoursStartValue', 1900, 0, 100000],
			'qh_acloadstop': ['/Settings/{0}/AcLoad/QuietHoursStopValue', 1200, 0, 100000],
			# VE.Bus high temperature
			'inverterhightempenabled': ['/Settings/{0}/InverterHighTemp/Enabled', 0, 0, 1],
			'inverterhightempstarttimer': ['/Settings/{0}/InverterHighTemp/StartTimer', 20, 0, 10000],
			'inverterhightempstoptimer': ['/Settings/{0}/InverterHighTemp/StopTimer', 20, 0, 10000],
			# VE.Bus overload
			'inverteroverloadenabled': ['/Settings/{0}/InverterOverload/Enabled', 0, 0, 1],
			'inverteroverloadstarttimer': ['/Settings/{0}/InverterOverload/StartTimer', 20, 0, 10000],
			'inverteroverloadstoptimer': ['/Settings/{0}/InverterOverload/StopTimer', 20, 0, 10000],
			# TestRun
			'testrunenabled': ['/Settings/{0}/TestRun/Enabled', 0, 0, 1],
			'testrunstartdate': ['/Settings/{0}/TestRun/StartDate', 1483228800, 0, 10000000000.1],
			'testrunstarttimer': ['/Settings/{0}/TestRun/StartTime', 54000, 0, 86400],
			'testruninterval': ['/Settings/{0}/TestRun/Interval', 28, 1, 365],
			'testrunruntime': ['/Settings/{0}/TestRun/Duration', 7200, 1, 86400],
			'testrunskipruntime': ['/Settings/{0}/TestRun/SkipRuntime', 0, 0, 100000],
			'testruntillbatteryfull': ['/Settings/{0}/TestRun/RunTillBatteryFull', 0, 0, 1],
			# Alarms
			'nogeneratoratacinalarm': ['/Settings/{0}/Alarms/NoGeneratorAtAcIn', 0, 0, 1]
			}

		settings = {}
		dbus_tree = dict(commondbustree)

		for m in self._modules:
			# Create settings for each module
			# Settings are created under the module prefix, for example:
			# /Settings/Generator0/AcLoad/Enabled
			# /Settings/FischerPanda0/AcLoad/Enabled
			for s in settingsbase:
				v = settingsbase[s][:]  # Copy
				v[0] = v[0].format(m.name)
				settings[s + m.name] = v

			# Get all services/paths that must be monitored
			# There are a base of common services/pathas that must be monitored
			# for the correct function such as battery monitors of vebus devices
			# and a extra ones that is only used by a certain module, these
			# are mainly the "remote switch".
			for i in m.monitoring:
				if i in commondbustree:
					for s in  m.monitoring[i]:
						dbus_tree[i][s] = m.monitoring[i][s]
				else:
					dbus_tree[i] = m.monitoring[i]

		# Create settings device which is shared
		self._settings = self._create_settings(settings, self._handlechangedsetting)

		# Create dbusmonitor, this is shared by all the instances
		self._dbusmonitor = self._create_dbus_monitor(dbus_tree, valueChangedCallback=self._dbus_value_changed,
				deviceAddedCallback=self._device_added, deviceRemovedCallback=self._device_removed)

		# Create dbus service
		# Paths for each instance will be added to this service like:
		# com.victronenergy.generator.startstop0/FischerPanda0/State
		# com.victronenergy.generator.startstop0/Generator0/State
		self._dbusservice = self._create_dbus_service()

		# Call device_added for all existing devices at startup.
		for service, instance in self._dbusmonitor.get_service_list().items():
				self._device_added(service, instance)

		gobject.timeout_add(1000, exit_on_error, self._handletimertick)

	def _handlechangedsetting(self, setting, oldvalue, newvalue):
		for i in self._instances:
			self._instances[i].handlechangedsetting(setting, oldvalue, newvalue)

	def _device_added(self, dbusservicename, instance):
		# If settings check built-in relays
		if dbusservicename == 'com.victronenergy.settings':
			self._handle_builtin_relay('/Settings/Relay/Function')

		self._add_device(dbusservicename)

		for i in self._instances:
			self._instances[i].device_added(dbusservicename, instance)

	def _dbus_value_changed(self, dbusServiceName, dbusPath, options, changes, deviceInstance):
		# Track built-in relays
		if "/Settings/Relay/Function" in dbusPath:
			self._handle_builtin_relay(dbusPath)

		# Some devices like Fischer Panda gensets doesn't disappear from dbus
		# when disconnected so check '/Connected' value to add or remove start/stop
		# for that device
		if dbusPath == "/Connected":
			if self._dbusmonitor.get_value(dbusServiceName, dbusPath) == 0:
				self._remove_device(dbusServiceName)
			else:
				self._add_device(dbusServiceName)

		for i in self._instances:
			self._instances[i].dbus_value_changed(dbusServiceName, dbusPath, options, changes, deviceInstance)

	def _device_removed(self, dbusservicename, instance):
		if dbusservicename == 'com.victronenergy.settings':
			self._handle_builtin_relay('/Settings/Relay/Function')
		for i in self._instances:
			self._instances[i].device_removed(dbusservicename, instance)

	def _create_dbus_monitor(self, *args, **kwargs):
		return DbusMonitor(*args, **kwargs)

	def _create_settings(self, *args, **kwargs):
		bus = dbus.SessionBus() if 'DBUS_SESSION_BUS_ADDRESS' in os.environ else dbus.SystemBus()
		return SettingsDevice(bus, *args, timeout=10, **kwargs)

	def _add_device(self, service):
		for i in self._modules:
			# Check if module can handle this service
			if i.remoteprefix not in service:
				continue
			# Check and create start/stop instance for the device
			if i.check_device(self._dbusmonitor, service):
				self._instances[service] = i.create(self._dbusmonitor,
												self._dbusservice,
												service, self._settings)

	def _handle_builtin_relay(self, dbuspath):
		function = self._dbusmonitor.get_value('com.victronenergy.settings', dbuspath)
		relaynr = 'generator0'
		relayservice = 'com.victronenergy.system'

		# Create a instance if relay function is set to 1 (gen. start/stop)
		# otherwise remove the instance if exists
		if function == 1:
			self._instances[relaynr] = relay.create(self._dbusmonitor,
													self._dbusservice,
													relayservice,
													self._settings)
		elif relaynr in self._instances:
			self._instances[relaynr].remove()
			del self._instances[relaynr]

	def _remove_device(self, servicename):
		if servicename in self._instances:
			if self._instances[servicename] is not None:
				self._instances[servicename].remove()
				del self._instances[servicename]

	def terminate(self, signum, frame):
		# Remove instances before exiting, remote services might need to perform actions before releasing control
		# of the switch
		for i in self._instances:
			self._instances[i].remove()
		os._exit(0)

	def _handletimertick(self):
		# try catch, to make sure that we kill ourselves on an error. Without this try-catch, there would
		# be an error written to stdout, and then the timer would not be restarted, resulting in a dead-
		# lock waiting for manual intervention -> not good!
		try:
			for i in self._instances:
				self._instances[i].tick()
		except:
			self._instances[i].remove()
			import traceback
			traceback.print_exc()
			sys.exit(1)
		return True

	def _create_dbus_service(self):
		dbusservice = VeDbusService("com.victronenergy.generator.startstop0")
		dbusservice.add_mandatory_paths(
			processname=__file__,
			processversion=softwareversion,
			connection='generator',
			deviceinstance=0,
			productid=None,
			productname=None,
			firmwareversion=None,
			hardwareversion=None,
			connected=1)
		return dbusservice

if __name__ == '__main__':
	# Argument parsing
	parser = argparse.ArgumentParser(
		description='Start and stop a generator based on conditions'
	)

	parser.add_argument('-d', '--debug', help='set logging level to debug',
						action='store_true')
	args = parser.parse_args()

	print '-------- dbus_generator, v' + softwareversion + ' is starting up --------'

	logger = setup_logging(args.debug)

	# Have a mainloop, so we can send/receive asynchronous calls to and from dbus
	DBusGMainLoop(set_as_default=True)

	generator = Generator()
	signal.signal(signal.SIGTERM, generator.terminate)

	# Start and run the mainloop
	mainloop = gobject.MainLoop()
	mainloop.run()

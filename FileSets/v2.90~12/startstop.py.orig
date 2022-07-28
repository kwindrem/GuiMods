#!/usr/bin/python -u
# -*- coding: utf-8 -*-

# Function
# dbus_generator monitors the dbus for batteries (com.victronenergy.battery.*) and
# vebus com.victronenergy.vebus.*
# Battery and vebus monitors can be configured through the gui.
# It then monitors SOC, AC loads, battery current and battery voltage,to auto start/stop the generator based
# on the configuration settings. Generator can be started manually or periodically setting a tes trun period.
# Time zones function allows to use different values for the conditions along the day depending on time

import dbus
import datetime
import calendar
import time
import sys
import json
import os
import logging
from os import environ
import monotonic_time
from gen_utils import SettingsPrefix, Errors, States, enum
from gen_utils import create_dbus_service
# Victron packages
sys.path.insert(1, os.path.join(os.path.dirname(__file__), 'ext', 'velib_python'))
from ve_utils import exit_on_error
from settingsdevice import SettingsDevice

RunningConditions = enum(
		Stopped = 0,
		Manual = 1,
		TestRun = 2,
		LossOfCommunication = 3,
		Soc = 4,
		Acload = 5,
		BatteryCurrent = 6,
		BatteryVoltage = 7,
		InverterHighTemp = 8,
		InverterOverload = 9,
		StopOnAc1 = 10)

SYSTEM_SERVICE = 'com.victronenergy.system'
BATTERY_PREFIX = '/Dc/Battery'
HISTORY_DAYS = 30

def safe_max(args):
	try:
		return max(x for x in args if x is not None)
	except ValueError:
		return None

class StartStop(object):
	_driver = None
	def __init__(self, instance):
		self._dbusservice = None
		self._settings = None
		self._dbusmonitor = None
		self._remoteservice = None
		self._name = None
		self._enabled = False
		self._instance = instance

		# One second per retry
		self.RETRIES_ON_ERROR = 300
		self._testrun_soc_retries = 0
		self._last_counters_check = 0

		self._starttime = 0
		self._manualstarttimer = 0
		self._last_runtime_update = 0
		self._timer_runnning = 0

		# Manual battery service selection is deprecated in favour
		# of getting the values directly from systemcalc, we keep
		# manual selected services handling for compatibility reasons.
		self._vebusservice = None
		self._errorstate = 0
		self._battery_service = None
		self._battery_prefix = None

		self._acpower_inverter_input = {
			'timeout': 0,
			'unabletostart': False
			}

		self._condition_stack = {
			'batteryvoltage': {
				'name': 'batteryvoltage',
				'reached': False,
				'boolean': False,
				'timed': True,
				'start_timer': 0,
				'stop_timer': 0,
				'valid': True,
				'enabled': False,
				'retries': 0,
				'monitoring': 'battery'
			},
			'batterycurrent': {
				'name': 'batterycurrent',
				'reached': False,
				'boolean': False,
				'timed': True,
				'start_timer': 0,
				'stop_timer': 0,
				'valid': True,
				'enabled': False,
				'retries': 0,
				'monitoring': 'battery'
			},
			'acload': {
				'name': 'acload',
				'reached': False,
				'boolean': False,
				'timed': True,
				'start_timer': 0,
				'stop_timer': 0,
				'valid': True,
				'enabled': False,
				'retries': 0,
				'monitoring': 'vebus'
			},
			'inverterhightemp': {
				'name': 'inverterhightemp',
				'reached': False,
				'boolean': True,
				'timed': True,
				'start_timer': 0,
				'stop_timer': 0,
				'valid': True,
				'enabled': False,
				'retries': 0,
				'monitoring': 'vebus'
			},
			'inverteroverload': {
				'name': 'inverteroverload',
				'reached': False,
				'boolean': True,
				'timed': True,
				'start_timer': 0,
				'stop_timer': 0,
				'valid': True,
				'enabled': False,
				'retries': 0,
				'monitoring': 'vebus'
			},
			'soc': {
				'name': 'soc',
				'reached': False,
				'boolean': False,
				'timed': False,
				'valid': True,
				'enabled': False,
				'retries': 0,
				'monitoring': 'battery'
			},
			'stoponac1': {
				'name': 'stoponac1',
				'reached': False,
				'boolean': True,
				'timed': False,
				'valid': True,
				'enabled': False,
				'retries': 0,
				'monitoring': 'vebus'
			}
		}

	def set_sources(self, dbusmonitor, settings, name, remoteservice):
		self._settings = SettingsPrefix(settings, name)
		self._dbusmonitor = dbusmonitor
		self._remoteservice = remoteservice
		self._name = name

		self.log_info('Start/stop instance created for %s.' % self._remoteservice)
		self._remote_setup()

	def _create_service(self):
		self._dbusservice = self._create_dbus_service()

		# The driver used for this start/stop service
		self._dbusservice.add_path('/Type', value=self._driver)
		# State: None = invalid, 0 = stopped, 1 = running
		self._dbusservice.add_path('/State', value=None)
		# RunningByConditionCode: Numeric Companion to /RunningByCondition below, but
		# also encompassing a Stopped state.
		self._dbusservice.add_path('/RunningByConditionCode', value=None)
		# Error
		self._dbusservice.add_path('/Error', value=None, gettextcallback=lambda p, v: Errors.get_description(v))
		# Condition that made the generator start
		self._dbusservice.add_path('/RunningByCondition', value=None)
		# Runtime
		self._dbusservice.add_path('/Runtime', value=None, gettextcallback=self._seconds_to_text)
		# Today runtime
		self._dbusservice.add_path('/TodayRuntime', value=None, gettextcallback=self._seconds_to_text)
		# Test run runtime
		self._dbusservice.add_path('/TestRunIntervalRuntime', value=None , gettextcallback=self._seconds_to_text)
		# Next test run date, values is 0 for test run disabled
		self._dbusservice.add_path('/NextTestRun', value=None, gettextcallback=lambda p, v: datetime.datetime.fromtimestamp(v).strftime('%c'))
		# Next test run is needed 1, not needed 0
		self._dbusservice.add_path('/SkipTestRun', value=None)
		# Manual start
		self._dbusservice.add_path('/ManualStart', value=None, writeable=True)
		# Manual start timer
		self._dbusservice.add_path('/ManualStartTimer', value=None, writeable=True)
		# Silent mode active
		self._dbusservice.add_path('/QuietHours', value=None)
		# Alarms
		self._dbusservice.add_path('/Alarms/NoGeneratorAtAcIn', value=None)

		# We need to set the values after creating the paths to trigger the 'onValueChanged' event for the gui
		# otherwise the gui will report the paths as invalid if we remove and recreate the paths without
		# restarting the dbusservice.
		self._dbusservice['/State'] = 0
		self._dbusservice['/RunningByConditionCode'] = RunningConditions.Stopped
		self._dbusservice['/Error'] = 0
		self._dbusservice['/RunningByCondition'] = ''
		self._dbusservice['/Runtime'] = 0
		self._dbusservice['/TodayRuntime'] = 0
		self._dbusservice['/TestRunIntervalRuntime'] = self._interval_runtime(self._settings['testruninterval'])
		self._dbusservice['/NextTestRun'] = None
		self._dbusservice['/SkipTestRun'] = None
		self._dbusservice['/ManualStart'] = 0
		self._dbusservice['/ManualStartTimer'] = 0
		self._dbusservice['/QuietHours'] = 0
		self._dbusservice['/Alarms/NoGeneratorAtAcIn'] = 0



	def enable(self):
		if self._enabled:
			return
		self.log_info('Enabling auto start/stop and taking control of remote switch')
		self._create_service()
		self._determineservices()
		self._update_remote_switch()
		self._enabled = True

	def disable(self):
		if not self._enabled:
			return
		self.log_info('Disabling auto start/stop, releasing control of remote switch')
		self._remove_service()
		self._enabled = False

	def remove(self):
		self.disable()
		self.log_info('Removed from start/stop instances')

	def _remove_service(self):
		self._dbusservice.__del__()
		self._dbusservice = None

	def device_added(self, dbusservicename, instance):
		self._determineservices()

	def device_removed(self, dbusservicename, instance):
		self._determineservices()

	def get_error(self):
		return self._dbusservice['/Error']

	def set_error(self, errorn):
		self._dbusservice['/Error'] = errorn

	def clear_error(self):
		self._dbusservice['/Error'] = Errors.NONE

	def dbus_value_changed(self, dbusServiceName, dbusPath, options, changes, deviceInstance):
		if self._dbusservice is None:
			return
		if dbusPath == '/AutoSelectedBatteryMeasurement' and self._settings['batterymeasurement'] == 'default':
			self._determineservices()

		if dbusPath == '/VebusService':
			self._determineservices()

	def handlechangedsetting(self, setting, oldvalue, newvalue):
		if self._dbusservice is None:
			return
		if self._name not in setting:
			# Not our setting
			return

		s = self._settings.removeprefix(setting)

		if s == 'batterymeasurement':
			self._determineservices()
			# Reset retries and valid if service changes
			for condition in self._condition_stack:
				if self._condition_stack[condition]['monitoring'] == 'battery':
					self._condition_stack[condition]['valid'] = True
					self._condition_stack[condition]['retries'] = 0

		if s == 'autostart':
				self.log_info('Autostart function %s.' % ('enabled' if newvalue == 1 else 'disabled'))

		if self._dbusservice is not None and s == 'testruninterval':
			self._dbusservice['/TestRunIntervalRuntime'] = self._interval_runtime(
															self._settings['testruninterval'])

	def dbus_name_owner_changed(self, name, oldowner, newowner):
		self._determineservices()

	def _seconds_to_text(self, path, value):
			m, s = divmod(value, 60)
			h, m = divmod(m, 60)
			return '%dh, %dm, %ds' % (h, m, s)

	def log_info(self, msg):
		logging.info(self._name + ': %s' % msg)

	def tick(self):
		if not self._enabled:
			return
		self._check_remote_status()
		self._evaluate_startstop_conditions()
		self._detect_generator_at_acinput()

	def _evaluate_startstop_conditions(self):
		if self.get_error() != Errors.NONE:
			# First evaluation after an error, log it
			if self._errorstate == 0:
				self._errorstate = 1
				self._dbusservice['/State'] = States.ERROR
				self.log_info('Error: #%i - %s, stop controlling remote.' %
							(self.get_error(),
							Errors.get_description(self.get_error())))
		elif self._errorstate == 1:
			# Error cleared
			self._errorstate = 0
			self.log_info('Error state cleared, taking control of remote switch.')

		# Conditions will be evaluated in this order
		conditions = ['soc', 'acload', 'batterycurrent', 'batteryvoltage', 'inverterhightemp', 'inverteroverload', 'stoponac1']
		start = False
		startbycondition = None
		activecondition = self._dbusservice['/RunningByCondition']
		today = calendar.timegm(datetime.date.today().timetuple())
		self._timer_runnning = False
		values = self._get_updated_values()
		connection_lost = False

		self._check_quiet_hours()

		# New day, register it
		if self._last_counters_check < today and self._dbusservice['/State'] == States.STOPPED:
			self._last_counters_check = today
			self._update_accumulated_time()

		# Update current and accumulated runtime.
		# By performance reasons, accumulated runtime is only updated
		# once per 60s. When the generator stops is also updated.
		if self._dbusservice['/State'] == States.RUNNING:
			mtime = monotonic_time.monotonic_time().to_seconds_double()
			if (mtime - self._starttime) - self._last_runtime_update >= 60:
				self._dbusservice['/Runtime'] = int(mtime - self._starttime)
				self._update_accumulated_time()
			elif self._last_runtime_update == 0:
				self._dbusservice['/Runtime'] = int(mtime - self._starttime)


		if self._evaluate_manual_start():
			startbycondition = 'manual'
			start = True

		# Conditions will only be evaluated if the autostart functionality is enabled
		if self._settings['autostart'] == 1:

			if self._evaluate_testrun_condition():
				startbycondition = 'testrun'
				start = True

			# Evaluate value conditions
			for condition in conditions:
				start = self._evaluate_condition(self._condition_stack[condition], values[condition]) or start
				startbycondition = condition if start and startbycondition is None else startbycondition
				# Connection lost is set to true if the number of retries of one or more enabled conditions
				# >= RETRIES_ON_ERROR
				if self._condition_stack[condition]['enabled']:
					connection_lost = self._condition_stack[condition]['retries'] >= self.RETRIES_ON_ERROR

			if self._condition_stack['stoponac1']['reached'] and startbycondition not in ['manual', 'testrun']:
				start = False
				if self._dbusservice['/State'] == States.RUNNING and activecondition not in ['manual', 'testrun']:
					self.log_info('AC input 1 available, stopping')

			# If none condition is reached check if connection is lost and start/keep running the generator
			# depending on '/OnLossCommunication' setting
			if not start and connection_lost:
				# Start always
				if self._settings['onlosscommunication'] == 1:
					start = True
					startbycondition = 'lossofcommunication'
				# Keep running if generator already started
				if self._dbusservice['/State'] == States.RUNNING and self._settings['onlosscommunication'] == 2:
					start = True
					startbycondition = 'lossofcommunication'

		if not start and self._errorstate:
			self._stop_generator()

		if self._errorstate:
			return

		if start:
			self._start_generator(startbycondition)
		elif (self._dbusservice['/Runtime'] >= self._settings['minimumruntime'] * 60
			  or activecondition == 'manual'):
			self._stop_generator()

	def _detect_generator_at_acinput(self):
		state = self._dbusservice['/State']

		if state == States.STOPPED:
			self._reset_acpower_inverter_input()
			return

		if self._settings['nogeneratoratacinalarm'] == 0:
			self._reset_acpower_inverter_input()
			return

		vebus_service = self._vebusservice if self._vebusservice else ''
		activein_state = self._dbusmonitor.get_value(
			vebus_service, '/Ac/ActiveIn/Connected')

		# Path not supported, skip evaluation
		if activein_state == None:
			return

		# Sources 0 = Not available, 1 = Grid, 2 = Generator, 3 = Shore
		generator_acsource = self._dbusmonitor.get_value(
			SYSTEM_SERVICE, '/Ac/ActiveIn/Source') == 2
		# Not connected = 0, connected = 1
		activein_connected = activein_state == 1

		if generator_acsource and activein_connected:
			if self._acpower_inverter_input['unabletostart']:
				self.log_info('Generator detected at inverter AC input, alarm removed')
			self._reset_acpower_inverter_input()
		elif self._acpower_inverter_input['timeout'] < self.RETRIES_ON_ERROR:
			self._acpower_inverter_input['timeout'] += 1
		elif not self._acpower_inverter_input['unabletostart']:
			self._acpower_inverter_input['unabletostart'] = True
			self._dbusservice['/Alarms/NoGeneratorAtAcIn'] = 2
			self.log_info('Generator not detected at inverter AC input, triggering alarm')

	def _reset_acpower_inverter_input(self, clear_error=True):
		if self._acpower_inverter_input['timeout'] != 0:
			self._acpower_inverter_input['timeout'] = 0

		if self._acpower_inverter_input['unabletostart'] != 0:
			self._acpower_inverter_input['unabletostart'] = 0

		self._dbusservice['/Alarms/NoGeneratorAtAcIn'] = 0

	def _reset_condition(self, condition):
		condition['reached'] = False
		if condition['timed']:
			condition['start_timer'] = 0
			condition['stop_timer'] = 0

	def _check_condition(self, condition, value):
		name = condition['name']

		if self._settings[name + 'enabled'] == 0:
			if condition['enabled']:
				condition['enabled'] = False
				self.log_info('Disabling (%s) condition' % name)
				condition['retries'] = 0
				condition['valid'] = True
				self._reset_condition(condition)
			return False

		elif not condition['enabled']:
			condition['enabled'] = True
			self.log_info('Enabling (%s) condition' % name)

		if (condition['monitoring'] == 'battery') and (self._settings['batterymeasurement'] == 'nobattery'):
			# If no battery monitor is selected reset the condition
			self._reset_condition(condition)
			return False

		if value is None and condition['valid']:
			if condition['retries'] >= self.RETRIES_ON_ERROR:
				logging.info('Error getting (%s) value, skipping evaluation till get a valid value' % name)
				self._reset_condition(condition)
				self._comunnication_lost = True
				condition['valid'] = False
			else:
				condition['retries'] += 1
				if condition['retries'] == 1 or (condition['retries'] % 10) == 0:
					self.log_info('Error getting (%s) value, retrying(#%i)' % (name, condition['retries']))
			return False

		elif value is not None and not condition['valid']:
			self.log_info('Success getting (%s) value, resuming evaluation' % name)
			condition['valid'] = True
			condition['retries'] = 0

		# Reset retries if value is valid
		if value is not None and condition['retries'] > 0:
			self.log_info('Success getting (%s) value, resuming evaluation' % name)
			condition['retries'] = 0

		return condition['valid']

	def _evaluate_condition(self, condition, value):
		name = condition['name']
		setting = ('qh_' if self._dbusservice['/QuietHours'] == 1 else '') + name
		startvalue = self._settings[setting + 'start'] if not condition['boolean'] else 1
		stopvalue = self._settings[setting + 'stop'] if not condition['boolean'] else 0

		# Check if the condition has to be evaluated
		if not self._check_condition(condition, value):
			# If generator is started by this condition and value is invalid
			# wait till RETRIES_ON_ERROR to skip the condition
			if condition['reached'] and condition['retries'] <= self.RETRIES_ON_ERROR:
				if condition['retries'] > 0:
					return True

			return False

		# As this is a generic evaluation method, we need to know how to compare the values
		# first check if start value should be greater than stop value and then compare
		start_is_greater = startvalue > stopvalue

		# When the condition is already reached only the stop value can set it to False
		start = condition['reached'] or (value >= startvalue if start_is_greater else value <= startvalue)
		stop = value <= stopvalue if start_is_greater else value >= stopvalue

		# Timed conditions must start/stop after the condition has been reached for a minimum
		# time.
		if condition['timed']:
			if not condition['reached'] and start:
				condition['start_timer'] += time.time() if condition['start_timer'] == 0 else 0
				start = time.time() - condition['start_timer'] >= self._settings[name + 'starttimer']
				condition['stop_timer'] *= int(not start)
				self._timer_runnning = True
			else:
				condition['start_timer'] = 0

			if condition['reached'] and stop:
				condition['stop_timer'] += time.time() if condition['stop_timer'] == 0 else 0
				stop = time.time() - condition['stop_timer'] >= self._settings[name + 'stoptimer']
				condition['stop_timer'] *= int(not stop)
				self._timer_runnning = True
			else:
				condition['stop_timer'] = 0

		condition['reached'] = start and not stop
		return condition['reached']

	def _evaluate_manual_start(self):
		if self._dbusservice['/ManualStart'] == 0:
			if self._dbusservice['/RunningByCondition'] == 'manual':
				self._dbusservice['/ManualStartTimer'] = 0
			return False

		start = True
		# If /ManualStartTimer has a value greater than zero will use it to set a stop timer.
		# If no timer is set, the generator will not stop until the user stops it manually.
		# Once started by manual start, each evaluation the timer is decreased
		if self._dbusservice['/ManualStartTimer'] != 0:
			self._manualstarttimer += time.time() if self._manualstarttimer == 0 else 0
			self._dbusservice['/ManualStartTimer'] -= int(time.time()) - int(self._manualstarttimer)
			self._manualstarttimer = time.time()
			start = self._dbusservice['/ManualStartTimer'] > 0
			self._dbusservice['/ManualStart'] = int(start)
			# Reset if timer is finished
			self._manualstarttimer *= int(start)
			self._dbusservice['/ManualStartTimer'] *= int(start)

		return start

	def _evaluate_testrun_condition(self):
		if self._settings['testrunenabled'] == 0:
			self._dbusservice['/SkipTestRun'] = None
			self._dbusservice['/NextTestRun'] = None
			return False

		today = datetime.date.today()
		yesterday = today - datetime.timedelta(days=1) # Should deal well with DST
		now = time.time()
		runtillbatteryfull = self._settings['testruntillbatteryfull'] == 1
		soc = self._get_updated_values()['soc']
		batteryisfull = runtillbatteryfull and soc == 100
		duration = 60 if runtillbatteryfull else self._settings['testrunruntime']

		try:
			startdate = datetime.date.fromtimestamp(self._settings['testrunstartdate'])
			_starttime = time.mktime(yesterday.timetuple()) + self._settings['testrunstarttimer']

			# today might in fact still be yesterday, if this test run started
			# before midnight and finishes after. If `now` still falls in
			# yesterday's window, then by the temporal anthropic principle,
			# which I just made up but loosely states that time must have
			# these properties for observers to exist, it must be yesterday
			# because we are here to observe it.
			if _starttime <= now <= _starttime + duration:
				today = yesterday
				starttime = _starttime
			else:
				starttime = time.mktime(today.timetuple()) + self._settings['testrunstarttimer']
		except ValueError:
			logging.debug('Invalid dates, skipping testrun')
			return False

		# If start date is in the future set as NextTestRun and stop evaluating
		if startdate > today:
			self._dbusservice['/NextTestRun'] = time.mktime(startdate.timetuple())
			return False

		start = False
		# If the accumulated runtime during the tes trun interval is greater than '/TestRunIntervalRuntime'
		# the tes trun must be skipped
		needed = (self._settings['testrunskipruntime'] > self._dbusservice['/TestRunIntervalRuntime']
					  or self._settings['testrunskipruntime'] == 0)
		self._dbusservice['/SkipTestRun'] = int(not needed)

		interval = self._settings['testruninterval']
		stoptime = starttime + duration
		elapseddays = (today - startdate).days
		mod = elapseddays % interval

		start = not bool(mod) and starttime <= now <= stoptime

		if runtillbatteryfull:
			if soc is not None:
				self._testrun_soc_retries = 0
				start = (start or self._dbusservice['/RunningByCondition'] == 'testrun') and not batteryisfull
			elif self._dbusservice['/RunningByCondition'] == 'testrun':
				if self._testrun_soc_retries < self.RETRIES_ON_ERROR:
					self._testrun_soc_retries += 1
					start = True
					if (self._testrun_soc_retries % 10) == 0:
						self.log_info('Test run failed to get SOC value, retrying(#%i)' % self._testrun_soc_retries)
				else:
					self.log_info('Failed to get SOC after %i retries, terminating test run condition' % self._testrun_soc_retries)
					start = False
			else:
				start = False

		if not bool(mod) and (now <= stoptime):
			self._dbusservice['/NextTestRun'] = starttime
		else:
			self._dbusservice['/NextTestRun'] = (time.mktime((today + datetime.timedelta(days=interval - mod)).timetuple()) +
												 self._settings['testrunstarttimer'])
		return start and needed

	def _check_quiet_hours(self):
		active = False
		if self._settings['quiethoursenabled'] == 1:
			# Seconds after today 00:00
			timeinseconds = time.time() - time.mktime(datetime.date.today().timetuple())
			quiethoursstart = self._settings['quiethoursstarttime']
			quiethoursend = self._settings['quiethoursendtime']

			# Check if the current time is between the start time and end time
			if quiethoursstart < quiethoursend:
				active = quiethoursstart <= timeinseconds and timeinseconds < quiethoursend
			else:  # End time is lower than start time, example Start: 21:00, end: 08:00
				active = not (quiethoursend < timeinseconds and timeinseconds < quiethoursstart)

		if self._dbusservice['/QuietHours'] == 0 and active:
			self.log_info('Entering to quiet mode')

		elif self._dbusservice['/QuietHours'] == 1 and not active:
			self.log_info('Leaving quiet mode')

		self._dbusservice['/QuietHours'] = int(active)

		return active

	def _update_accumulated_time(self):
		seconds = self._dbusservice['/Runtime']
		accumulated = seconds - self._last_runtime_update

		self._settings['accumulatedtotal'] = int(self._settings['accumulatedtotal']) + accumulated
		# Using calendar to get timestamp in UTC, not local time
		today_date = str(calendar.timegm(datetime.date.today().timetuple()))

		# If something goes wrong getting the json string create a new one
		try:
			accumulated_days = json.loads(self._settings['accumulateddaily'])
		except ValueError:
			accumulated_days = {today_date: 0}

		if (today_date in accumulated_days):
			accumulated_days[today_date] += accumulated
		else:
			accumulated_days[today_date] = accumulated

		self._last_runtime_update = seconds

		# Keep the historical with a maximum of HISTORY_DAYS
		while len(accumulated_days) > HISTORY_DAYS:
			accumulated_days.pop(min(accumulated_days.keys()), None)

		# Upadate settings
		self._settings['accumulateddaily'] = json.dumps(accumulated_days, sort_keys=True)
		self._dbusservice['/TodayRuntime'] = self._interval_runtime(0)
		self._dbusservice['/TestRunIntervalRuntime'] = self._interval_runtime(self._settings['testruninterval'])

	def _interval_runtime(self, days):
		summ = 0
		try:
			daily_record = json.loads(self._settings['accumulateddaily'])
		except ValueError:
			return 0

		for i in range(days + 1):
			previous_day = calendar.timegm((datetime.date.today() - datetime.timedelta(days=i)).timetuple())
			if str(previous_day) in daily_record.keys():
				summ += daily_record[str(previous_day)] if str(previous_day) in daily_record.keys() else 0

		return summ

	def _get_battery(self):
		battery = {}
		if self._settings['batterymeasurement'] == 'default':
			battery['service'] = SYSTEM_SERVICE
			battery['prefix'] = BATTERY_PREFIX
		else:
			battery['service'] = self._battery_service if self._battery_service else ''
			battery['prefix'] = self._battery_prefix if self._battery_prefix else ''

		return battery

	def _get_updated_values(self):
		battery = self._get_battery()
		vebus_service = self._vebusservice if self._vebusservice else ''
		loadOnAcOut = []
		totalConsumption = []
		inverterHighTemp = []
		inverterOverload = []

		values = {
			'batteryvoltage': self._dbusmonitor.get_value(battery['service'], battery['prefix'] + '/Voltage'),
			'batterycurrent': self._dbusmonitor.get_value(battery['service'], battery['prefix'] + '/Current'),
			# Soc from the device doesn't have the '/Dc/0' prefix like the current and voltage do, but it does
			# have the same prefix on systemcalc
			'soc': self._dbusmonitor.get_value(battery['service'], (battery['prefix'] if battery['prefix'] == BATTERY_PREFIX else '') + '/Soc'),
			'inverterhightemp': self._dbusmonitor.get_value(vebus_service, '/Alarms/HighTemperature'),
			'inverteroverload': self._dbusmonitor.get_value(vebus_service, '/Alarms/Overload')
		}

		for phase in ['L1', 'L2', 'L3']:
			# Get the values directly from the inverter, systemcalc doesn't provide raw inverted power
			loadOnAcOut.append(self._dbusmonitor.get_value(vebus_service, ('/Ac/Out/%s/P' % phase)))

			# Calculate total consumption, '/Ac/Consumption/%s/Power' is deprecated
			c_i = self._dbusmonitor.get_value(SYSTEM_SERVICE, ('/Ac/ConsumptionOnInput/%s/Power' % phase))
			c_o = self._dbusmonitor.get_value(SYSTEM_SERVICE, ('/Ac/ConsumptionOnOutput/%s/Power' % phase))
			totalConsumption.append(sum(filter(None, (c_i, c_o))))

			# Inverter alarms must be fetched directly from the inverter service
			inverterHighTemp.append(self._dbusmonitor.get_value(vebus_service, ('/Alarms/%s/HighTemperature' % phase)))
			inverterOverload.append(self._dbusmonitor.get_value(vebus_service, ('/Alarms/%s/Overload' % phase)))

		# Toltal consumption
		if self._settings['acloadmeasuerment'] == 0:
			values['acload'] = sum(filter(None, totalConsumption))

		# Load on inverter AC out
		if self._settings['acloadmeasuerment'] == 1:
			values['acload'] = sum(filter(None, loadOnAcOut))

		# Highest phase load
		if self._settings['acloadmeasuerment'] == 2:
			values['acload'] = safe_max(loadOnAcOut)

		# AC input 1
		activein = self._dbusmonitor.get_value(vebus_service, '/Ac/ActiveIn/ActiveInput')
		# Active input is connected
		connected = self._dbusmonitor.get_value(vebus_service, '/Ac/ActiveIn/Connected')
		if None not in (activein, connected):
			values['stoponac1'] = activein == 0 and connected == 1
		else:
			values['stoponac1'] = None

		# Invalidate if vebus is not available
		if loadOnAcOut[0] == None:
			values['acload'] = None

		if values['batterycurrent']:
			values['batterycurrent'] *= -1

		# When multi is connected to CAN-bus, alarms are published to
		# /Alarms/Overload... but when connected to vebus alarms are
		# splitted in three phases and published to /Alarms/LX/Overload...
		if values['inverteroverload'] == None:
			values['inverteroverload'] = safe_max(inverterOverload)

		if values['inverterhightemp'] == None:
			values['inverterhightemp'] = safe_max(inverterHighTemp)

		return values

	def _determineservices(self):
		# batterymeasurement is either 'default' or 'com_victronenergy_battery_288/Dc/0'.
		# In case it is set to default, we use the AutoSelected battery
		# measurement, given by SystemCalc.
		batterymeasurement = None
		newbatteryservice = None
		batteryprefix = ''
		selectedbattery = self._settings['batterymeasurement']
		vebusservice = None

		if selectedbattery == 'default':
			batterymeasurement = 'default'
		elif len(selectedbattery.split('/', 1)) == 2:  # Only very basic sanity checking..
			batterymeasurement = self._settings['batterymeasurement']
		elif selectedbattery == 'nobattery':
			batterymeasurement = None
		else:
			# Exception: unexpected value for batterymeasurement
			pass

		if batterymeasurement and batterymeasurement != 'default':
			batteryprefix = '/' + batterymeasurement.split('/', 1)[1]

		# Get the current battery servicename
		if self._battery_service:
			oldservice = self._battery_service
		else:
			oldservice = None

		if batterymeasurement != 'default':
			battery_instance = int(batterymeasurement.split('_', 3)[3].split('/')[0])
			service_type = None

			if 'vebus' in batterymeasurement:
				service_type = 'vebus'
			elif 'battery' in batterymeasurement:
				service_type = 'battery'

			newbatteryservice = self._get_servicename_by_instance(battery_instance, service_type)
		elif batterymeasurement == 'default':
			newbatteryservice = 'default'

		if newbatteryservice and newbatteryservice != oldservice:
			if selectedbattery == 'default':
				self.log_info('Getting battery values from systemcalc.')
			if selectedbattery == 'nobattery':
				self.log_info('Battery monitoring disabled! Stop evaluating related conditions')
				self._battery_service = None
				self._battery_prefix = None
			self.log_info('Battery service we need (%s) found! Using it for generator start/stop' % batterymeasurement)
			self._battery_service = newbatteryservice
			self._battery_prefix = batteryprefix
		elif not newbatteryservice and newbatteryservice != oldservice:
			self.log_info('Error getting battery service!')
			self._battery_service = newbatteryservice
			self._battery_prefix = batteryprefix

		# Get the default VE.Bus service
		vebusservice = self._dbusmonitor.get_value('com.victronenergy.system', '/VebusService')
		if vebusservice:
			if self._vebusservice != vebusservice:
				self._vebusservice = vebusservice
				self.log_info('Vebus service (%s) found! Using it for generator start/stop' % vebusservice)
		else:
			if self._vebusservice is not None:
				self.log_info('Vebus service (%s) dissapeared! Stop evaluating related conditions' % self._vebusservice)
			else:
				self.log_info('Error getting Vebus service!')
			self._vebusservice = None

	def _get_servicename_by_instance(self, instance, service_type=None):
		sv = None
		services = self._dbusmonitor.get_service_list()

		for service in services:
			if service_type and service_type not in service:
				continue

			if services[service] == instance:
				sv = service
				break

		return sv

	def _get_monotonic_seconds(self):
		return monotonic_time.monotonic_time().to_seconds_double()

	def _start_generator(self, condition):
		state = self._dbusservice['/State']
		remote_state = self._get_remote_switch_state()

		# This function will start the generator in the case generator not
		# already running. When differs, the RunningByCondition is updated
		if state == States.STOPPED or remote_state != state:
			self._dbusservice['/State'] = States.RUNNING
			self._update_remote_switch()
			self._starttime = monotonic_time.monotonic_time().to_seconds_double()
			self.log_info('Starting generator by %s condition' % condition)
		elif self._dbusservice['/RunningByCondition'] != condition:
			self.log_info('Generator previously running by %s condition is now running by %s condition'
						% (self._dbusservice['/RunningByCondition'], condition))

		self._dbusservice['/RunningByCondition'] = condition
		self._dbusservice['/RunningByConditionCode'] = RunningConditions.lookup(condition)

	def _stop_generator(self):
		state = self._dbusservice['/State']
		remote_state = self._get_remote_switch_state()

		if state == 1 or remote_state != state:
			self._dbusservice['/State'] = States.STOPPED
			self._update_remote_switch()
			self.log_info('Stopping generator that was running by %s condition' %
						str(self._dbusservice['/RunningByCondition']))
			self._dbusservice['/RunningByCondition'] = ''
			self._dbusservice['/RunningByConditionCode'] = RunningConditions.Stopped
			self._update_accumulated_time()
			self._starttime = 0
			self._dbusservice['/Runtime'] = 0
			self._dbusservice['/ManualStartTimer'] = 0
			self._manualstarttimer = 0
			self._last_runtime_update = 0

	def _update_remote_switch(self):
		self._set_remote_switch_state(dbus.Int32(self._dbusservice['/State'], variant_level=1))

	def _get_remote_switch_state(self):
		raise Exception('This function should be overridden')

	def _set_remote_switch_state(self, value):
		raise Exception('This function should be overridden')

	# Check the remote status, for example errors
	def _check_remote_status(self):
		raise Exception('This function should be overridden')

	def _remote_setup(self):
		raise Exception('This function should be overridden')

	def _create_dbus_monitor(self, *args, **kwargs):
		raise Exception('This function should be overridden')

	def _create_settings(self, *args, **kwargs):
		raise Exception('This function should be overridden')

	def _create_dbus_service(self):
		return create_dbus_service(self._instance)

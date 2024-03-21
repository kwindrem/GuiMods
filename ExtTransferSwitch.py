#!/usr/bin/env python

# This program integrates an external transfer switch ahead of the single AC input
# of a MultiPlus or Quattro inverter/charger.
#
# A new type of digital input is defined to provide select grid or generator input profiles
#
# When the external transfer switch changes between grid and generator the data for that input must be switched between
#  grid and generator settings
#
# These two sets of settings are stored in dbus Settings.
# When the transfer switch digital input changes, this program switches
#   the Multiplus settings between these two stored values
# When the user changes the settings, the grid or generator-specific Settings are updated
#
# In order to function, one of the digital inputs must be set to External AC Transfer Switch
# This input should be connected to a contact closure on the external transfer switch to indicate
#	which of it's sources is switched to its output
#
# For Quattro, the /Settings/TransferSwitch/TransferSwitchOnAc2 tells this program where the transfer switch is connected:
#	0 if connected to AC 1 In
#	1 if connected to AC 2 In

import platform
import argparse
import logging
import sys
import subprocess
import os
import time
import dbus

dbusSettingsPath = "com.victronenergy.settings"
dbusSystemPath = "com.victronenergy.system"



# accommodate both Python 2 and 3
# if the Python 3 GLib import fails, import the Python 2 gobject
try:
	from gi.repository import GLib # for Python 3
except ImportError:
	import gobject as GLib # for Python 2

# add the path to our own packages for import
# use an established Victron service to maintain compatiblity
sys.path.insert(1, os.path.join('/opt/victronenergy/dbus-systemcalc-py', 'ext', 'velib_python'))
from vedbus import VeDbusService
from ve_utils import wrap_dbus_value
from settingsdevice import SettingsDevice

class Monitor:

	def getVeBusObjects (self):
		vebusService = ""

		# invalidate all local parameters if transfer switch is not active
		if not self.transferSwitchActive:
			# release generator override if it's still active
			try:
				if self.remoteGeneratorSelectedItem != None:
					self.remoteGeneratorSelectedItem.SetValue (wrap_dbus_value (0))
			except:
				logging.error ("could not release /Ac/Control/RemoteGeneratorSelected")
				pass
			self.remoteGeneratorSelectedItem = None
			self.remoteGeneratorSelectedLocalValue = -1
			self.dbusOk = False
			self.numberOfAcInputs = 0
			self.stopWhenAcAvailableObj = None
			self.stopWhenAcAvailableFpObj = None
			self.acInputTypeObj = None
			self.veBusService = ""
			self.transferSwitchLocation = 0
			return

		try:
			obj = self.theBus.get_object (dbusSystemPath, '/VebusService')
			vebusService = obj.GetText ()
		except:
			if self.dbusOk:
				logging.info ("Multi/Quattro disappeared - /VebusService invalid")
			self.veBusService = ""
			self.dbusOk = False
			self.numberOfAcInputs = 0
			self.acInputTypeObj = None

		if vebusService == "---":
			if self.veBusService != "":
				logging.info ("Multi/Quattro disappeared")
			self.veBusService = ""
			self.dbusOk = False
			self.numberOfAcInputs = 0
		elif self.veBusService == "" or vebusService != self.veBusService:
			self.veBusService = vebusService
			try:
				self.numberOfAcInputs = self.theBus.get_object (vebusService, "/Ac/NumberOfAcInputs").GetValue ()
			except:
				self.numberOfAcInputs = 0
			try:
				self.remoteGeneratorSelectedItem = self.theBus.get_object (vebusService,
					"/Ac/Control/RemoteGeneratorSelected")
			except:
				self.remoteGeneratorSelectedItem = None
				self.remoteGeneratorSelectedLocalValue = -1

			if self.numberOfAcInputs == 0:
				self.dbusOk = False
			elif self.numberOfAcInputs == 2:
				logging.info ("discovered Quattro at " + vebusService)
			elif self.numberOfAcInputs == 1:
				logging.info ("discovered Multi at " + vebusService)			

			try:
				self.currentLimitObj = self.theBus.get_object (vebusService, "/Ac/ActiveIn/CurrentLimit")
				self.currentLimitIsAdjustableObj = self.theBus.get_object (vebusService, "/Ac/ActiveIn/CurrentLimitIsAdjustable")
			except:
				logging.error ("current limit dbus setup failed - changes can't be made")
				self.dbusOk = False

		# check to see where the transfer switch is connected
		if self.numberOfAcInputs == 0:
			transferSwitchLocation = 0
		elif self.numberOfAcInputs == 1:
			transferSwitchLocation = 1
		elif self.DbusSettings['transferSwitchOnAc2'] == 1:
			transferSwitchLocation = 2
		else:
			transferSwitchLocation = 1

		# if changed, trigger refresh of object pointers
		if transferSwitchLocation != self.transferSwitchLocation:
			if transferSwitchLocation != 0:
				logging.info ("Transfer switch is on AC %d in" % transferSwitchLocation)
			self.transferSwitchLocation = transferSwitchLocation
			self.stopWhenAcAvailableObj = None
			self.stopWhenAcAvailableFpObj = None
			try:
				if self.transferSwitchLocation == 2:
					self.acInputTypeObj = self.theBus.get_object (dbusSettingsPath, "/Settings/SystemSetup/AcInput2")
				else:
					self.acInputTypeObj = self.theBus.get_object (dbusSettingsPath, "/Settings/SystemSetup/AcInput1")
				self.dbusOk = True
			except:
				self.dbusOk = False
				logging.error ("AC input dbus setup failed - changes can't be made")

			# set up objects for stop when AC available
			#	there's one for "Generator" and one for "FischerPanda"
			#	ignore errors if these aren't present
			try:
				if self.transferSwitchLocation == 2:
					self.stopWhenAcAvailableObj = self.theBus.get_object (dbusSettingsPath, "/Settings/Generator0/StopWhenAc2Available")
				else:
					self.stopWhenAcAvailableObj = self.theBus.get_object (dbusSettingsPath, "/Settings/Generator0/StopWhenAc1Available")
			except:
				self.stopWhenAcAvailableObj = None
			# first try new settings
			try:
				if self.transferSwitchLocation == 2:
					self.stopWhenAcAvailableFpObj = self.theBus.get_object (dbusSettingsPath, "/Settings/Generator1/StopWhenAc2Available")
				else:
					self.stopWhenAcAvailableFpObj = self.theBus.get_object (dbusSettingsPath, "/Settings/Generator1/StopWhenAc1Available")
			# next try old settings
			except:
				try:
					if self.transferSwitchLocation == 2:
						self.stopWhenAcAvailableFpObj = self.theBus.get_object (dbusSettingsPath, "/Settings/FischerPanda0/StopWhenAc2Available")
					else:
						self.stopWhenAcAvailableFpObj = self.theBus.get_object (dbusSettingsPath, "/Settings/FischerPanda0/StopWhenAc1Available")
				except:
					self.stopWhenAcAvailableFpObj = None


	def updateTransferSwitchState (self):
		inputInvalid = False
		try:
			if self.transferSwitchActive:
				state = self.transferSwitchStateObj.GetValue ()
				if state == 12:		# 12 is the on generator value
					self.onGenerator = True
				elif state == 13:	# 13 is the on grid value
					self.onGenerator = False
				# other value indicates the selected digital input is assigned to a different function
				else:
					inputInvalid = True

			# digital input not active
			# search for a new one only every 10 seconds to avoid unnecessary processing
			elif self.tsInputSearchDelay >= 10:
				newInputService = ""
				for service in self.theBus.list_names():
					# found a digital input service, now check the for valid state value
					if service.startswith ("com.victronenergy.digitalinput"):
						self.transferSwitchStateObj = self.theBus.get_object (service, '/State')
						state = self.transferSwitchStateObj.GetValue()
						# found it!
						if state == 12 or state == 13:
							newInputService = service
							break
 
				# found new service - set up to use it's values
				if newInputService != "":
					logging.info ("discovered transfer switch digital input service at %s", newInputService)
					self.transferSwitchActive = True
				elif self.transferSwitchActive:
					logging.info ("Transfer switch digital input service NOT found")
					self.transferSwitchActive = False


		# any exception indicates the selected digital input is no longer active
		except:
			inputInvalid = True

		if inputInvalid:
			if self.transferSwitchActive:
				logging.info ("Transfer switch digital input no longer valid")
			self.transferSwitchActive = False

		if self.transferSwitchActive:
			self.tsInputSearchDelay = 0
		else:
			self.onGenerator = False
			# if serch delay timer is active, increment it now
			if self.tsInputSearchDelay < 10:
				self.tsInputSearchDelay += 1
			else:
				self.tsInputSearchDelay = 0


	def transferToGrid (self):
		if self.dbusOk:
			logging.info ("switching to grid settings")
			# save current values for restore when switching back to generator
			try:
				self.DbusSettings['generatorCurrentLimit'] = self.currentLimitObj.GetValue ()
			except:
				logging.error ("dbus error generator AC input current limit not saved switching to grid")

			try:
				self.acInputTypeObj.SetValue (self.DbusSettings['gridInputType'])
			except:
				logging.error ("dbus error AC input type not changed to grid")
			try:
				if self.currentLimitIsAdjustableObj.GetValue () == 1:
					self.currentLimitObj.SetValue (wrap_dbus_value (self.DbusSettings['gridCurrentLimit']))
				else:
					logging.warning ("Input current limit not adjustable - not changed")
			except:
				logging.error ("dbus error AC input current limit not changed switching to grid")

			try:
				if self.stopWhenAcAvailableObj != None:
					self.stopWhenAcAvailableObj.SetValue (self.DbusSettings['stopWhenAcAvaiable'])
				if self.stopWhenAcAvailableFpObj != None:
					self.stopWhenAcAvailableFpObj.SetValue (self.DbusSettings['stopWhenAcAvaiableFp'])
			except:
				logging.error ("stopWhenAcAvailable update not changed when switching to grid")

	def transferToGenerator (self):
		if self.dbusOk:
			logging.info ("switching to generator settings")
			# save current values for restore when switching back to grid
			try:
				inputType = self.acInputTypeObj.GetValue ()
				# grid input type can only be either 1 (grid) or 3 (shore)
				#	patch this up to prevent issues later
				if inputType == 2:
					logging.warning ("grid input can not be generator - setting to grid")
					inputType = 1
				self.DbusSettings['gridInputType'] = inputType
			except:
				logging.error ("dbus error AC input type not saved when switching to generator")
			try:
				self.DbusSettings['gridCurrentLimit'] = self.currentLimitObj.GetValue ()
			except:
				logging.error ("dbus error AC input current limit not saved when switching to generator")
			try:
				if self.stopWhenAcAvailableObj != None:
					self.DbusSettings['stopWhenAcAvaiable'] = self.stopWhenAcAvailableObj.GetValue ()
				else:
					self.DbusSettings['stopWhenAcAvaiable'] = 0
				if self.stopWhenAcAvailableFpObj != None:
					self.DbusSettings['stopWhenAcAvaiableFp'] = self.stopWhenAcAvailableFpObj.GetValue ()
				else:
					self.DbusSettings['stopWhenAcAvaiableFp'] = 0
			except:
				logging.error ("dbus error stop when AC available settings not saved when switching to generator")

			try:
				self.acInputTypeObj.SetValue (2)
			except:
				logging.error ("dbus error AC input type not changed when switching to generator")
			try:
				if self.currentLimitIsAdjustableObj.GetValue () == 1:
					self.currentLimitObj.SetValue (wrap_dbus_value (self.DbusSettings['generatorCurrentLimit']))
				else:
					logging.warning ("Input current limit not adjustable - not changed")
			except:
				logging.error ("dbus error AC input current limit not changed when switching to generator")

			try:
				if self.stopWhenAcAvailableObj != None:
					self.stopWhenAcAvailableObj.SetValue (0)
				if self.stopWhenAcAvailableFpObj != None:
					self.stopWhenAcAvailableFpObj.SetValue (0)
			except:
				logging.error ("stopWhenAcAvailable update not changed switching to generator")


	def background (self):

		##startTime = time.time()
		self.updateTransferSwitchState ()
		self.getVeBusObjects ()

		# skip processing if any dbus paramters were not initialized properly
		if self.dbusOk and self.transferSwitchActive:

			# process transfer switch state change
			if self.lastOnGenerator != None and self.onGenerator != self.lastOnGenerator:
				if self.onGenerator:
					self.transferToGenerator ()
				else:
					self.transferToGrid ()
			self.lastOnGenerator = self.onGenerator
		elif self.onGenerator:
			self.transferToGrid ()

		# update main VE.Bus RemoteGeneratorSelected which is used to enable grid charging
		#	if renewable energy is turned on
		if not self.dbusOk or not self.onGenerator:
			newRemoteGeneratorSelectedLocalValue = 0
		else:
			newRemoteGeneratorSelectedLocalValue = 1
		if self.remoteGeneratorSelectedItem == None:
			self.remoteGeneratorSelectedLocalValue = -1
		elif newRemoteGeneratorSelectedLocalValue != self.remoteGeneratorSelectedLocalValue:
			try:
				self.remoteGeneratorSelectedItem.SetValue (wrap_dbus_value (newRemoteGeneratorSelectedLocalValue))
			except:
				logging.error ("could not set /Ac/Control/RemoteGeneratorSelected")
				pass

			self.remoteGeneratorSelectedLocalValue = newRemoteGeneratorSelectedLocalValue

		##stopTime = time.time()
		##print ("#### background time %0.3f" % (stopTime - startTime))
		return True


	def __init__(self):

		self.theBus = dbus.SystemBus()
		self.onGenerator = False
		self.veBusService = ""
		self.lastVeBusService = ""
		self.acInputTypeObj = None
		self.numberOfAcInputs = 0
		self.currentLimitObj = None
		self.currentLimitIsAdjustableObj = None
		self.stopWhenAcAvailableObj = None
		self.stopWhenAcAvailableFpObj = None
		self.remoteGeneratorSelectedItem = None
		self.remoteGeneratorSelectedLocalValue = -1

		self.transferSwitchStateObj = None
		self.extTransferDigInputName = "External AC Input transfer switch"	# must match name set in dbus_digitalInputs.py !!!!!

		self.lastOnGenerator = None
		self.transferSwitchActive = False
		self.dbusOk = False
		self.transferSwitchLocation = 0
		self.tsInputSearchDelay = 99 # allow serch to occur immediately

		# create / attach local settings
		settingsList = {
			'gridCurrentLimit': [ '/Settings/TransferSwitch/GridCurrentLimit', 0.0, 0.0, 0.0 ],
			'generatorCurrentLimit': [ '/Settings/TransferSwitch/GeneratorCurrentLimit', 0.0, 0.0, 0.0 ],
			'gridInputType': [ '/Settings/TransferSwitch/GridType', 0, 0, 0 ],
			'stopWhenAcAvaiable': [ '/Settings/TransferSwitch/StopWhenAcAvailable', 0, 0, 0 ],
			'stopWhenAcAvaiableFp': [ '/Settings/TransferSwitch/StopWhenAcAvailableFp', 0, 0, 0 ],
			'transferSwitchOnAc2': [ '/Settings/TransferSwitch/TransferSwitchOnAc2', 0, 0, 0 ],
						}
		self.DbusSettings = SettingsDevice(bus=self.theBus, supportedSettings=settingsList,
								timeout = 10, eventCallback=None )

		# grid input type should be either 1 (grid) or 3 (shore)
		#	patch this up to prevent issues later
		if self.DbusSettings['gridInputType'] == 2:
			logging.warning ("grid input type was generator - resetting to grid")
			self.DbusSettings['gridInputType'] = 1

		GLib.timeout_add (1000, self.background)
		return None

def main():

	from dbus.mainloop.glib import DBusGMainLoop

	# set logging level to include info level entries
	logging.basicConfig(level=logging.INFO)

	# Have a mainloop, so we can send/receive asynchronous calls to and from dbus
	DBusGMainLoop(set_as_default=True)

	installedVersion = "(no version installed)"
	versionFile = "/etc/venus/installedVersion-GuiMods"
	if os.path.exists (versionFile):
		try:
			proc = subprocess.Popen (["cat", versionFile], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		except:
			pass
		else:
			proc.wait()
			# convert from binary to string
			stdout, stderr = proc.communicate ()
			stdout = stdout.decode ().strip ()
			stderr = stderr.decode ().strip ()
			returnCode = proc.returncode
			if proc.returncode == 0:
				installedVersion = stdout

	logging.info (">>>>>>>>>>>>>>>> ExtTransferSwitch starting " + installedVersion + " <<<<<<<<<<<<<<<<")

	Monitor ()

	mainloop = GLib.MainLoop()
	mainloop.run()

main()

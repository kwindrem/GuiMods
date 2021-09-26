import QtQuick 1.1
import com.victron.velib 1.0

VeQItemSortTableModel {
	property alias all: childValues

	filterRole: VeQItemTableModel.ValueRole
	sortColumn: childValues.sortValueColumn
	dynamicSortFilter: true

	model: VeQItemChildModel {
		id: childValues

		// Select all fluid types of all available tank services...
		childId: "FluidType"
		model: VeQItemSortTableModel {
			filterFlags: VeQItemSortTableModel.FilterOffline
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.tank\."
			model: AvailableServices
		}

		// And sort them by type, description
		sortDelegate: VeQItemSortDelegate {
			property variant service: DBusServices.get(buddy.id)
			sortValue: (item.value !== undefined ? item.value.toString() : "") + (service ? service.description : "")
		}
	}
}

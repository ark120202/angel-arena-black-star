"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables

function OnPlayertableChange(tableName, changesObject, deletionsObject) {
	for (var key in changesObject) {
		var objData = changesObject[key]
		var InviteBox = $.CreatePanel('Panel', $("#Invites"), "invitebox_" + key)
		InviteBox.AddClass("InviteBox")
		for (var field in objData.fields) {
			var fieldValue = objData.fields[field]
			AddFields(fieldValue, InviteBox, key + "_field" + field)
		}
	}
	for (var key in deletionsObject) {
		$("#invitebox_" + key).DeleteAsync(0)
	}
}

function AddFields(field, panel, panelIndex) {
	if (field.field == "Text") {
		var InviteBoxField = $.CreatePanel('Label', panel, "invitebox_" + panelIndex)
		InviteBoxField.text = $.Localize(field.fieldData.text)
		if (field.class != undefined) {
			InviteBoxField.AddClass(field.class)
		} else {
			InviteBoxField.AddClass("FieldTextNormal")
		}
	}
	if (field.field == "HeroImage") {
		var InviteBoxField = $.CreatePanel('DOTAHeroImage', panel, "invitebox_" + panelIndex)
		if (field.fieldData.heroname != undefined) {
			InviteBoxField.heroname = field.fieldData.heroname
		}
		if (field.fieldData.heroimagestyle != undefined) {
			InviteBoxField.heroimagestyle = field.fieldData.heroimagestyle
		}
		if (field.class != undefined) {
			InviteBoxField.AddClass(field.class)
		}
	}
	if (field.field == "Button") {
		var InviteBoxField = $.CreatePanel('Button', panel, "invitebox_" + panelIndex)
		if (field.class != undefined) {
			InviteBoxField.AddClass(field.class)
		} else {
			InviteBoxField.AddClass("FieldButtonNormal")
		}
		var _OnButtonClickEvent = (function(_panel) {
			return function() {
				OnButtonClickEvent(_panel)
			}
		})(InviteBoxField)
		if (field.onactivate != undefined) {
			InviteBoxField.SetPanelEvent('onactivate', _OnButtonClickEvent)
		}
		for (var fieldKey in field.fieldData) {
			var fieldKeyValue = field.fieldData[fieldKey]
			AddFields(fieldKeyValue, InviteBoxField, panelIndex + "_subfield_" + fieldKey)
		}
	}
	if (field.field == "PanelCollection") {
		var InviteBoxField = $.CreatePanel('Panel', panel, "invitebox_" + panelIndex)
		if (field.class != undefined) {
			InviteBoxField.AddClass(field.class)
		} else {
			InviteBoxField.AddClass("FieldPanelCollectionNormal")
		}
		for (var fieldKey in field.fieldData) {
			var fieldKeyValue = field.fieldData[fieldKey]
			AddFields(fieldKeyValue, InviteBoxField, panelIndex + "_subfield" + fieldKey)
		}
	}
}

function OnButtonClickEvent(panel) {
	GameEvents.SendCustomGameEventToServer("playermessages_response", {
		panelIndex: panel.id,
	});
}

(function() {
	PlayerTables.SubscribeNetTableListener("ply_msgs_" + Game.GetLocalPlayerID(), OnPlayertableChange)
})()
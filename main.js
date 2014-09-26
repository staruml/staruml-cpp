define(function (require, exports, module) {
	"use strict";

	var AppInit             = staruml.getModule("utils/AppInit"),
		Repository          = staruml.getModule("engine/Repository"),
		Engine              = staruml.getModule("engine/Engine"),
		Commands            = staruml.getModule("command/Commands"),
		CommandManager      = staruml.getModule("command/CommandManager"),
		MenuManager         = staruml.getModule("menu/MenuManager"),
		Dialogs             = staruml.getModule("dialogs/Dialogs"),
		ElementPickerDialog = staruml.getModule("dialogs/ElementPickerDialog"),
		FileSystem          = staruml.getModule("filesystem/FileSystem"),
		FileSystemError     = staruml.getModule("filesystem/FileSystemError"),
		ExtensionUtils      = staruml.getModule("utils/ExtensionUtils"),
		UML                 = staruml.getModule("uml/UML");
		
	var CodeGenUtils        = require("CodeGenUtils"),
		CppPreferences		= require("CppPreferences"),
		CppCodeGenerator	= require("CppCodeGenerator");
	

	/**
	 * Command IDs
	 */
	var CMD_CPP            = 'cpp',
		CMD_CPP_GENERATE   = 'cpp.generate',
		CMD_CPP_REVERSE    = 'cpp.reverse',
		CMD_CPP_CONFIGURE  = 'cpp.configure';

	function _handleGenerate(base, path, options) {
		var result = new $.Deferred();

		// If options is not passed, get from preference
		options = options || CppPreferences.getGenOptions();

		// If base is not assigned, popup ElementPicker
		if (!base) {
			ElementPickerDialog.showDialog("Select a base model to generate codes", null, type.UMLPackage)
				.done(function (buttonId, selected) {
					if (buttonId === Dialogs.DIALOG_BTN_OK && selected) {
						base = selected;

						// If path is not assigned, popup Open Dialog to select a folder
						if (!path) {
							FileSystem.showOpenDialog(false, true, "Select a folder where generated codes to be located", null, null, function (err, files) {
								if (!err) {
									if (files.length > 0) {
										path = files[0];
										CppCodeGenerator.generate(base, path, options).then(result.resolve, result.reject);
									} else {
										result.reject(FileSystem.USER_CANCELED);
									}
								} else {
									result.reject(err);
								}
							});
						} else {
							CppCodeGenerator.generate(base, path, options).then(result.resolve, result.reject);
						}
					} else {
						result.reject();
					}
				});
		} else {
			// If path is not assigned, popup Open Dialog to select a folder
			if (!path) {
				FileSystem.showOpenDialog(false, true, "Select a folder where generated codes to be located", null, null, function (err, files) {
					if (!err) {
						if (files.length > 0) {
							path = files[0];
							CppCodeGenerator.generate(base, path, options).then(result.resolve, result.reject);
						} else {
							result.reject(FileSystem.USER_CANCELED);
						}
					} else {
						result.reject(err);
					}
				});
			} else {
				CppCodeGenerator.generate(base, path, options).then(result.resolve, result.reject);
			}
		}
		return result.promise();
	}

	function _handleConfigure() {
		CommandManager.execute(Commands.FILE_PREFERENCES, CppPreferences.getId());
	}

	CommandManager.register("Cpp",             CMD_CPP,           function(){console.log("Cpp");});
	CommandManager.register("Generate Code...", CMD_CPP_GENERATE,  _handleGenerate);
	CommandManager.register("Reverse Code...",  CMD_CPP_REVERSE,   function(){console.log("Reverse code...");});
	CommandManager.register("Configure...",     CMD_CPP_CONFIGURE, _handleConfigure);

	var menu, menuItem;
	menu = MenuManager.getMenu(Commands.TOOLS);
	menuItem = menu.addMenuItem(CMD_CPP);
	menuItem.addMenuItem(CMD_CPP_GENERATE);
	menuItem.addMenuItem(CMD_CPP_REVERSE);
	menuItem.addMenuDivider();
	menuItem.addMenuItem(CMD_CPP_CONFIGURE);
});
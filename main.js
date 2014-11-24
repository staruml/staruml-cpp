/*
 * Copyright (c) 2014 MKLab. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */
 
/*jslint vars: true, plusplus: true, devel: true, nomen: true, indent: 4, maxerr: 50, regexp: true */

define(function (require, exports, module) {
	"use strict";

	var AppInit             = staruml.getModule("utils/AppInit"),
		Repository          = staruml.getModule("core/Repository"),
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

	CommandManager.register("C++",             CMD_CPP,           CommandManager.doNothing);
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
    
    // for debug 
    
    var getCurrentTime = function () {
        var currentdate = new Date(); 
        var datetime = "Last Sync: " + currentdate.getDate() + "/"
                + (currentdate.getMonth()+1)  + "/" 
                + currentdate.getFullYear() + " @ "  
                + currentdate.getHours() + ":"  
                + currentdate.getMinutes() + ":" 
                + currentdate.getSeconds();
        return datetime;
    }    
    console.log("================================================");
    console.log("Cpp Code Generator Plugin.");
    console.log("Version time - " + CppCodeGenerator.getVersion() );
    console.log(getCurrentTime());
    console.log("================================================");
});
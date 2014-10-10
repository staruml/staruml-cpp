/*
 * Copyright (c) 2013-2014 Minkyu Lee. All rights reserved.
 *
 * NOTICE:  All information contained herein is, and remains the
 * property of Minkyu Lee. The intellectual and technical concepts
 * contained herein are proprietary to Minkyu Lee and may be covered
 * by Republic of Korea and Foreign Patents, patents in process,
 * and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Minkyu Lee (niklaus.lee@gmail.com).
 *
 */

/*jslint vars: true, plusplus: true, devel: true, nomen: true, indent: 4, maxerr: 50, regexp: true */
/*global define, $, _, window, appshell, staruml */

define(function (require, exports, module) {
	"use strict";

	var AppInit           = staruml.getModule("utils/AppInit"),
		Core              = staruml.getModule("core/Core"),
		PreferenceManager = staruml.getModule("preference/PreferenceManager");

	var preferenceId = "Cpp";
	
	var CppPreferences = {
		"Cpp.gen": {
			text: "Cpp Code Generation",
			type: "Section"
		},
		"Cpp.gen.useTab": {
			text: "Use Tab",
			description: "Use Tab for indentation instead of spaces.",
			type: "Check",
			default: false
		},
		"Cpp.gen.indentSpaces": {
			text: "Indent Spaces",
			description: "Number of spaces for indentation.",
			type: "Number",
			default: 4
		},
		"Cpp.gen.includeHeader": {
			text: "Include default header",
			description: "Include default header.",
			type: "Check",
			default: true
		},
		"Cpp.gen.useVector": {
			text: "Use vector instead of *",
			description: "Use vector<> instead of pointer.",
			type: "Check",
			default: true
		},
		"Cpp.gen.genCpp": {
			text: "Generate *.cpp file",
			description: "Generate cpp file",
			type: "Check",
			default: true
		}
	};
	
	function getId() {
		return preferenceId;
	}

	function getGenOptions() {
		return {
			useTab          	: PreferenceManager.get("Cpp.gen.useTab"),
			indentSpaces    	: PreferenceManager.get("Cpp.gen.indentSpaces"),
			useVector			: PreferenceManager.get("Cpp.gen.useVector"),
			includeHeader 		: PreferenceManager.get("Cpp.gen.includeHeader"),
            genCpp              : PreferenceManager.get("Cpp.gen.genCpp")
		};
	}
	/*

		
		
	*/

	AppInit.htmlReady(function () {
		PreferenceManager.register(preferenceId, "Cpp", CppPreferences);
	});

	exports.getId         = getId;
	exports.getGenOptions = getGenOptions;
});
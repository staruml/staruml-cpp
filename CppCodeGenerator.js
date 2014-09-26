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
/*global define, $, _, window, staruml, type, document, java7 */

define(function (require, exports, module) {
	"use strict";

	var Repository = staruml.getModule("engine/Repository"),
		Engine     = staruml.getModule("engine/Engine"),
		FileSystem = staruml.getModule("filesystem/FileSystem"),
		FileUtils  = staruml.getModule("file/FileUtils"),
		Async      = staruml.getModule("utils/Async"),
		UML        = staruml.getModule("uml/UML");

	var CodeGenUtils = require("CodeGenUtils");

	var copyrightHeader = "// Test header @ toori67 " ;
	/**
	 * Cpp code generator
	 * @constructor
	 * 
	 * @param {type.UMLPackage} baseModel
	 * @param {string} basePath generated files and directories to be placed
	 * 
	 */
	function CppCodeGenerator(baseModel, basePath) {
	
		/** @member {type.Model} */
		this.baseModel = baseModel;
		
		/** @member {string} */
		this.basePath = basePath;	
	}

	/**
	 * Return Indent String based on options
	 * @param {Object} options
	 * @return {string}
	 */
	CppCodeGenerator.prototype.getIndentString = function (options) {
		if (options.useTab) {
			return '\t';
		}else {
			
			var i, len, indent = [];
			for (i = 0, len = options.indentSpaces; i < len; i++) {
				indent.push(" ");
			}
			return indent.join("");
		}
	};

	CppCodeGenerator.prototype.generate = function (elem, path, options) {
		var result = new $.Deferred(),
		self = this,
		fullPath,
		directory,
		codeWriter,
		file;
        
		// Package -> as namespace or not
		if(elem instanceof type.UMLPackage){
			fullPath = path + "/" + elem.name;
			directory = FileSystem.getDirectoryForPath(fullPath);
            
			directory.create(function (err, stat) {
				if (!err) {
					Async.doSequentially(
						elem.ownedElements,
						function (child) {
							return self.generate(child, fullPath, options);
						},
						false
					).then(result.resolve, result.reject);
				} else {
				    result.reject(err);
				}
			});
		} else if (elem instanceof type.UMLClass) {
			result.resolve();
		} else if (elem instanceof type.UMLInterface) {
			fullPath = path + "/" + elem.name + ".h";
			codeWriter = new CodeGenUtils.CodeWriter(this.getIndentString(options));
			this.writeHeaders(codeWriter, elem, options);
			this.writeEnd(codeWriter, elem, options);
			file = FileSystem.getFileForPath(fullPath);
			FileUtils.writeText(file, codeWriter.getData(), true).then(result.resolve, result.reject);
		} else {
			result.resolve();
		}
		return result.promise();
	};

	CppCodeGenerator.prototype.writeHeaders = function (codeWriter, elem, options) {
        codeWriter.writeLine(copyrightHeader);
		var headerString = "_" +elem.name.toUpperCase() + "_H";
		codeWriter.writeLine("#ifndef " + headerString);
		codeWriter.writeLine("#define " + headerString);

	}

	CppCodeGenerator.prototype.writeEnd = function (codeWriter, elem, options){
		var headerString = "_" +elem.name.toUpperCase() + "_H";
		codeWriter.writeLine("#endif //"+headerString);
	}


	function generate(baseModel, basePath, options){
		var result = new $.Deferred();
		var cppCodeGenerator = new CppCodeGenerator(baseModel, basePath);
		return cppCodeGenerator.generate(baseModel, basePath, options);
	}
	exports.generate = generate;
});
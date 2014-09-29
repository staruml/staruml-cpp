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
    
    var _CPP_CODE_GEN_H = "h";
    var _CPP_CODE_GEN_CPP = "cpp";
    
	var Repository = staruml.getModule("engine/Repository"),
		Engine     = staruml.getModule("engine/Engine"),
		FileSystem = staruml.getModule("filesystem/FileSystem"),
		FileUtils  = staruml.getModule("file/FileUtils"),
		Async      = staruml.getModule("utils/Async"),
		UML        = staruml.getModule("uml/UML");

	var CodeGenUtils = require("CodeGenUtils");

	var copyrightHeader = "/* Test header @ toori67 \n * This is Test\n * also test\n * also test again\n */" ;
    
    var versionString = "v0.0.1";
    
    // TODO - using map to add headers for relationships. 
    // TODO - need to check dependencies ( what elem parse first )
    var _headerMap;
    
    
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
        var getFilePath = function(extenstions) {
            var abs_path = path + "/" + elem.name + "." ;
            if(extenstions === _CPP_CODE_GEN_H) 
                abs_path += _CPP_CODE_GEN_H;
            else 
                abs_path += _CPP_CODE_GEN_CPP; 
            return abs_path;
        };
        
		var result = new $.Deferred(),
		self = this,
		fullPath,
		directory,
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
                    if(err === "AlreadyExists"){
                        Async.doSequentially(
                            elem.ownedElements,
                            function (child) {
                                return self.generate(child, fullPath, options);
                            },
                            false
					   ).then(result.resolve, result.reject);
                    }
				    result.reject(err);
				}
			});
		
        
        } else if (elem instanceof type.UMLClass) {
            
            // generate class header elem_name.h 
            var writeClassHeaderBody = function(codeWriter, elem, options) { console.log("test funct");};
			file = FileSystem.getFileForPath(getFilePath(_CPP_CODE_GEN_H));
            var skeleton_code = this.writeHeaderSkeletonCode(elem, options, writeClassHeaderBody);
			FileUtils.writeText(file, skeleton_code, true).then(result.resolve, result.reject);
            
            // generate class cpp elem_name.cpp
            
		} else if (elem instanceof type.UMLInterface) {
            // generate interface header ONLY elem_name.h 
            var writeInterfaceHeaderBody = function(codeWriter, elem, options) { console.log("writeInterfaceHeaderBody funct");};
			file = FileSystem.getFileForPath(getFilePath(_CPP_CODE_GEN_H));
            var skeleton_code = this.writeHeaderSkeletonCode(elem, options, writeInterfaceHeaderBody);
			FileUtils.writeText(file, skeleton_code, true).then(result.resolve, result.reject);
            
		} else if (elem instanceof type.UMLEnumeration) {
            
            // generate enumeration header ONLY elem_name.h 
            var writeEnumerationHeader = function(codeWriter, elem, options) { 
                var _literal_str = "";
                for(var i=0; i<elem.literals.length; i++){
                    _literal_str += elem.literals[i].name + (i < elem.literals.length - 1 ? ", " : " ")
                }
                // remove trailing <,&nbsp> 
                codeWriter.writeLine("enum " + elem.name + " { "  + _literal_str + "};");
            };
            
			file = FileSystem.getFileForPath(getFilePath(_CPP_CODE_GEN_H));
            var skeleton_code = this.writeHeaderSkeletonCode(elem, options, writeEnumerationHeader);
			FileUtils.writeText(file, skeleton_code, true).then(result.resolve, result.reject);
            
        }else {
			result.resolve();
		}
		return result.promise();
	};

    /**
     * Write *.h file. Implement functor to each uml type.
     * Returns text 
     * 
     * @param {Object} elem
     * @param {Object} options
     * @param {Object} functor
     * @return {Object} string
     */
    CppCodeGenerator.prototype.writeHeaderSkeletonCode = function (elem, options, funct) {
        var headerString = "_" +elem.name.toUpperCase() + "_H";
        var codeWriter = new CodeGenUtils.CodeWriter(this.getIndentString(options));
		
        codeWriter.writeLine(copyrightHeader);
        codeWriter.writeLine();
		codeWriter.writeLine("#ifndef (" + headerString + ")");
		codeWriter.writeLine("#define " + headerString);
        codeWriter.writeLine();
        funct(codeWriter, elem, options);
        codeWriter.writeLine();
		codeWriter.writeLine("#endif //"+headerString);
        return codeWriter.getData();
    }
    
	CppCodeGenerator.prototype.getVisibility = function (elem) {
		switch (elem.visibility) {
		case UML.VK_PUBLIC:
			return "public";
		case UML.VK_PROTECTED:
			return "protected";
		case UML.VK_PRIVATE:
			return "private";
		}
		return null;
	};
    
    CppCodeGenerator.prototype.getModifiers = function (elem) {
		var modifiers = [];
		var visibility = this.getVisibility(elem);
		if (visibility) {
			modifiers.push(visibility);
		}
        if(visibility) {
            modifiers.push(visibility);
        }
        if(elem.isStatic === true) {
            modifiers.push("static");
        }
        if(elem.isReadOnly === true) {
            modifiers.push("const");
        }
        if(elem.isAbstract === true) {
            modifiers.push("virtual");
        }
		if (elem.isFinalSpecification === true || elem.isLeaf === true) {
			modifiers.push("final");
		}
		return modifiers;
	};
                                                       
	function generate(baseModel, basePath, options){
		var result = new $.Deferred();
		var cppCodeGenerator = new CppCodeGenerator(baseModel, basePath);
		return cppCodeGenerator.generate(baseModel, basePath, options);
	}
	
    function getVersion() {return versionString; };
    
    exports.generate = generate;
    exports.getVersion = getVersion;
});
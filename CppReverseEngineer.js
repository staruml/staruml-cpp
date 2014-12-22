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

/*jslint vars: true, plusplus: true, devel: true, nomen: true, indent: 4, maxerr: 50, regexp: true, continue:true */
/*global define, $, _, window, app, type, document, cpp, parser */
define(function (require, exports, module) {
    "use strict"; 
    
    var Core            = app.getModule("core/Core"),
        Repository      = app.getModule("core/Repository"),
        ProjectManager  = app.getModule("engine/ProjectManager"),
        CommandManager  = app.getModule("command/CommandManager"),
        UML             = app.getModule("uml/UML"),
        FileSystem      = app.getModule("filesystem/FileSystem"),
        FileSystemError = app.getModule("filesystem/FileSystemError"),
        FileUtils       = app.getModule("file/FileUtils"),
        Async           = app.getModule("utils/Async");

    require("grammar/cpp");
    
    // C++ Primitive Types
//    var cppPrimitiveTypes = [
//        "sbyte",
//        "byte",
//        "short",
//        "ushort",
//        "int",
//        "uint",
//        "long",
//        "ulong",
//        "char",
//        "float",
//        "double",
//        "decimal",
//        "bool",
//        "object",
//        "string",
//        "void"
//    ];
      
    /**
     * C# Code Analyzer
     * @constructor
     */
    function CppCodeAnalyzer() {

        /** @member {type.UMLModel} */
        this._root = new type.UMLModel();
        this._root.name = "CppReverse";

        /** @member {Array.<File>} */
        this._files = [];

        /** @member {Object} */
        this._currentCompilationUnit = null;

        /**
         * @member {{classifier:type.UMLClassifier, node: Object, kind:string}}
         */
        this._extendPendings = [];

        /**
         * @member {{classifier:type.UMLClassifier, node: Object}}
         */
        this._implementPendings = [];

        /**
         * @member {{classifier:type.UMLClassifier, association: type.UMLAssociation, node: Object}}
         */
        this._associationPendings = [];

        /**
         * @member {{operation:type.UMLOperation, node: Object}}
         */
        this._throwPendings = [];

        /**
         * @member {{namespace:type.UMLModelElement, feature:type.UMLStructuralFeature, node: Object}}
         */
        this._typedFeaturePendings = [];
        
        this._usingList = [];
    }
 
    /**
     * Add File to Reverse Engineer
     * @param {File} file
     */
    CppCodeAnalyzer.prototype.addFile = function (file) {
        this._files.push(file);
    };

    /**
     * Analyze all files.
     * @param {Object} options
     * @return {$.Promise}
     */
    CppCodeAnalyzer.prototype.analyze = function (options) {
        var self = this,
            promise;

        // Perform 1st Phase
        promise = this.performFirstPhase(options);

//        // Perform 2nd Phase
//        promise.always(function () {
//            self.performSecondPhase(options);
//        });
//
//        // Load To Project
//        promise.always(function () {
//            var writer = new Core.Writer();
//            console.log(self._root);
//            writer.writeObj("data", self._root);
//            var json = writer.current.data;
//            ProjectManager.importFromJson(ProjectManager.getProject(), json);
//        });
//
//        // Generate Diagrams
//        promise.always(function () {
//            self.generateDiagrams(options);
//            console.log("[C#] done.");
//        });

        return promise;
    }; 
      
    
    /**
     * Perform First Phase
     *   - Create Packages, Classes, Interfaces, Enums, AnnotationTypes.
     *
     * @param {Object} options
     * @return {$.Promise}
     */
    CppCodeAnalyzer.prototype.performFirstPhase = function (options) {
        var self = this;
        return Async.doSequentially(this._files, function (file) {
            var result = new $.Deferred();
            file.read({}, function (err, data, stat) {
                if (!err) {
                    try {
                        var ast = parser.parse(data);
                        
                        var results = [];
                        for (var property in ast) {
                            var value = ast[property];
                            if (value) {
                                results.push(property.toString() + ': ' + value);
                            }
                        }
                        console.log( JSON.stringify(ast) );  
                        
//                        self._currentCompilationUnit = ast;
//                        self._currentCompilationUnit.file = file;
//                        self.translateCompilationUnit(options, self._root, ast); 
                        
                        result.resolve();
                        console.log('test');
                    } catch (ex) {
                        console.error("[C++] Failed to parse - " + file._name + "  : " + ex);
                        result.reject(ex);
                    }
                } else {
                    result.reject(err);
                }
            });
            return result.promise();
        }, false);
    };

     
     /**
     * Add File to Reverse Engineer
     * @param {File} file
     */
    CppCodeAnalyzer.prototype.addFile = function (file) {
        this._files.push(file);
    }; 
    
    
    /**
     * Analyze all C# files in basePath
     * @param {string} basePath
     * @param {Object} options
     * @return {$.Promise}
     */
    function analyze(basePath, options) {
         
        
        var result = new $.Deferred(),
            cppAnalyzer = new CppCodeAnalyzer();

        function visitEntry(entry) {
            if (entry._isFile === true) {
                var ext = FileUtils.getFileExtension(entry._path);
                if (ext && ((ext.toLowerCase() === "cpp") || (ext.toLowerCase() === "h")))
                {
                    cppAnalyzer.addFile(entry);
                }
            }
            return true;
        }

        // Traverse all file entries
        var dir = FileSystem.getDirectoryForPath(basePath);
        dir.visit(visitEntry, {}, function (err) {
            if (!err) {
                cppAnalyzer.analyze(options).then(result.resolve, result.reject);
            } else {
                result.reject(err);
            }
        });

        return result.promise();
    }

    exports.analyze = analyze;

});
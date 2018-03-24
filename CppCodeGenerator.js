/*
 * Copyright (c) 2014 MKLab. All rights reserved.
 * Copyright (c) 2014 Sebastian Schleemilch.
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
/*global define, $, _, window, app, type, document, cpp */

define(function (require, exports, module) {
    "use strict";

    var _CPP_CODE_GEN_H     = "h";
    var _CPP_CODE_GEN_CPP   = "cpp";

    var _CPP_PUBLIC_MOD     = "public";
    var _CPP_PROTECTED_MOD  = "protected";
    var _CPP_PRIVATE_MOD    = "private";

    var Repository          = app.getModule("core/Repository"),
        ProjectManager      = app.getModule("engine/ProjectManager"),
        Engine              = app.getModule("engine/Engine"),
        FileSystem          = app.getModule("filesystem/FileSystem"),
        FileUtils           = app.getModule("file/FileUtils"),
        Async               = app.getModule("utils/Async"),
        UML                 = app.getModule("uml/UML");

    var CodeGenUtils        = require("CodeGenUtils");

    var copyrightHeader     = "/* Test header @ toori67 \n * This is Test\n * also test\n * also test again\n */";
    var versionString       = "v0.0.1";


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

        var doc = "";
        if (ProjectManager.getProject().name && ProjectManager.getProject().name.length > 0) {
            doc += "\nProject " + ProjectManager.getProject().name;
        }
        if (ProjectManager.getProject().author && ProjectManager.getProject().author.length > 0) {
            doc += "\n@author " + ProjectManager.getProject().author;
        }
        if (ProjectManager.getProject().version && ProjectManager.getProject().version.length > 0) {
            doc += "\n@version " + ProjectManager.getProject().version;
        }
        copyrightHeader = this.getDocuments(doc);
    }

    /**
     * Object for each modified operation
     * @constructor
     */
    function OperationBody() {
        /** @member {string} Operation._id */
        this.Id = "";
        /** @member {string} Operation._content */
        this.Content = "";
    }

    /**
     * Return Indent String based on options
     * @param {Object} options
     * @return {string}
     */
    CppCodeGenerator.prototype.getIndentString = function (options) {
        if (options.useTab) {
            return '\t';
        } else {

            var i, len, indent = [];
            for (i = 0, len = options.indentSpaces; i < len; i++) {
                indent.push(" ");
            }
            return indent.join("");
        }
    };


    CppCodeGenerator.prototype.generate = function (elem, path, options) {
        this.genOptions = options;
        this.opImplSaved = []; // Custom operations by Developper
        this.haveSR = false; // Signal and/or Reception found in the class elem

        var getFilePath = function (extenstions) {
            var abs_path = path + "/" + elem.name + ".";
            if (extenstions === _CPP_CODE_GEN_H) {
                abs_path += _CPP_CODE_GEN_H;
            } else {
                abs_path += _CPP_CODE_GEN_CPP;
            }
            return abs_path;
        };

        var writeSignal = function (codeWriter, elem, cppCodeGen) {
            var i;
            var modifierList = cppCodeGen.getModifiers(elem);
            var modifierStr = "";
            var identifier = "";

            for (i = 0; i < modifierList.length; i++) {
                modifierStr += modifierList[i] + " ";
            }

            var params = [];
            for (i = 0; i < elem.attributes.length; i++) {
                var att = elem.attributes[i];
                params.push(cppCodeGen.getVariableDeclaration(att, true));
            }
            // doc
            var docs = cppCodeGen.getDocuments(elem.documentation);

            if (cppCodeGen.genOptions.useQt) {
                identifier = "Q_SIGNAL ";
            }

            codeWriter.writeLine(docs + identifier + modifierStr + "void " + elem.name + "(" + params.join(", ") + ");");
        };

        var writeEnumeration = function (codeWriter, elem, cppCodeGen) {
            var i;
            var modifierList = cppCodeGen.getModifiers(elem);
            var modifierStr = "";
            for (i = 0; i < modifierList.length; i++) {
                modifierStr += modifierList[i] + " ";
            }
            // doc
            var docs = cppCodeGen.getDocuments(elem.documentation);

            codeWriter.writeLine(docs + modifierStr + "enum " + elem.name + " {\n\t" + _.pluck(elem.literals, 'name').join(",\n\t") + "\n};");
        };

        var writeClassHeader = function (codeWriter, elem, cppCodeGen) {
            var i;
            var write = function (items) {
                var i;
                for (i = 0; i < items.length; i++) {
                    var item = items[i];
                    if (item instanceof type.UMLAttribute || item instanceof type.UMLAssociationEnd) { // if write member variable
                        codeWriter.writeLine(cppCodeGen.getMemberVariable(item));
                    } else if (item instanceof type.UMLOperation) { // if write method
                        codeWriter.writeLine(cppCodeGen.getMethod(item, false));
                    } else if (item instanceof type.UMLReception) {
                        codeWriter.writeLine(cppCodeGen.getSlot(item, false));
                    } else if (item instanceof type.UMLClass) {
                        writeClassHeader(codeWriter, item, cppCodeGen);
                    } else if (item instanceof type.UMLEnumeration) {
                        writeEnumeration(codeWriter, item, cppCodeGen);
                    } else if (item instanceof type.UMLSignal) {
                        writeSignal(codeWriter, item, cppCodeGen);
                    }
                }
            };
            var writeInheritance = function (elem) {
                var genList = cppCodeGen.getSuperClasses(elem);
                var i;
                var term = [];

                for (i = 0; i < genList.length; i++) {
                    var generalization = genList[i];
                    // public AAA, private BBB
                    term.push(generalization.visibility + " " + generalization.target.name);
                }

                if (cppCodeGen.haveSR && cppCodeGen.genOptions.useQt) {
                    term.push("public QObject");
                }

                if (!term.length) {
                    return "";
                }

                return  ": " + term.join(", ");
            };

            // member variable
            var memberAttr = elem.attributes.slice(0);
            var associations = Repository.getRelationshipsOf(elem, function (rel) {
                return (rel instanceof type.UMLAssociation);
            });
            for (i = 0; i < associations.length; i++) {
                var asso = associations[i];
                if (asso.end1.reference === elem && asso.end2.navigable === true && asso.end2.name.length !== 0) {
                    memberAttr.push(asso.end2);
                } else if (asso.end2.reference === elem && asso.end1.navigable === true && asso.end1.name.length !== 0) {
                    memberAttr.push(asso.end1);
                }
            }

            // method
            var methodList = elem.operations.slice(0);
            var innerElement = [];
            for (i = 0; i < elem.ownedElements.length; i++) {
                var element = elem.ownedElements[i];
                if (element instanceof type.UMLClass || element instanceof type.UMLEnumeration || element instanceof type.UMLSignal) {
                    innerElement.push(element);
                }
            }

            var receptionList = elem.receptions.slice(0);

            var allMembers = memberAttr.concat(methodList).concat(receptionList).concat(innerElement);

            var classfiedAttributes = cppCodeGen.classifyVisibility(allMembers);


            var finalModifier = "";
            if (elem.isFinalSpecialization === true || elem.isLeaf === true) {
                finalModifier = " final ";
            }

            // doc
            var docs = cppCodeGen.getDocuments(elem.documentation);
            if (docs.length > 0) {
                codeWriter.writeLine(docs);
            }

            var templatePart = cppCodeGen.getTemplateParameter(elem);
            if (templatePart.length > 0) {
                codeWriter.writeLine(templatePart);
            }

            codeWriter.writeLine("class " + elem.name + finalModifier + writeInheritance(elem) + "\n{");
            if (cppCodeGen.haveSR && cppCodeGen.genOptions.useQt) {
                codeWriter.indent();
                codeWriter.writeLine("Q_OBJECT");
                codeWriter.outdent();
            }
            if (classfiedAttributes._public.length > 0) {
                codeWriter.writeLine("public: ");
                codeWriter.indent();
                write(classfiedAttributes._public);
                codeWriter.outdent();
            }
            if (classfiedAttributes._protected.length > 0) {
                codeWriter.writeLine("protected: ");
                codeWriter.indent();
                write(classfiedAttributes._protected);
                codeWriter.outdent();
            }
            if (classfiedAttributes._private.length > 0) {
                codeWriter.writeLine("private: ");
                codeWriter.indent();
                write(classfiedAttributes._private);
                codeWriter.outdent();
            }

            codeWriter.writeLine("};");
        };

        var writeClassBody = function (codeWriter, elem, cppCodeGen) {
            var i = 0;
            var item;
            var writeClassMethod = function (elemList) {

                for (i = 0; i < elemList._public.length; i++) {
                    item = elemList._public[i];
                    if (item instanceof type.UMLOperation) { // if write method
                        codeWriter.writeLine(cppCodeGen.getMethod(item, true));
                    } else if (item instanceof type.UMLReception) {
                        codeWriter.writeLine(cppCodeGen.getSlot(item, true));
                    } else if (item instanceof type.UMLClass) {
                        writeClassBody(codeWriter, item, cppCodeGen);
                    }
                }

                for (i = 0; i < elemList._protected.length; i++) {
                    item = elemList._protected[i];
                    if (item instanceof type.UMLOperation) { // if write method
                        codeWriter.writeLine(cppCodeGen.getMethod(item, true));
                    } else if (item instanceof type.UMLReception) {
                        codeWriter.writeLine(cppCodeGen.getSlot(item, true));
                    } else if (item instanceof type.UMLClass) {
                        writeClassBody(codeWriter, item, cppCodeGen);
                    }
                }

                for (i = 0; i < elemList._private.length; i++) {
                    item = elemList._private[i];
                    if (item instanceof type.UMLOperation) { // if write method
                        codeWriter.writeLine(cppCodeGen.getMethod(item, true));
                    } else if (item instanceof type.UMLReception) {
                        codeWriter.writeLine(cppCodeGen.getSlot(item, true));
                    } else if (item instanceof type.UMLClass) {
                        writeClassBody(codeWriter, item, cppCodeGen);
                    }
                }
            };

            var docs = elem.name + " implementation\n\n";
            if (_.isString(elem.documentation)) {
                docs += elem.documentation;
            }
            codeWriter.writeLine(cppCodeGen.getDocuments(docs));

            // parsing class
            var methodList = cppCodeGen.classifyVisibility(elem.operations.slice(0));
            writeClassMethod(methodList);

            var receptionList = cppCodeGen.classifyVisibility(elem.receptions.slice(0));
            writeClassMethod(receptionList);

            // parsing nested class
            var innerClass = [];
            for (i = 0; i < elem.ownedElements.length; i++) {
                var element = elem.ownedElements[i];
                if (element instanceof type.UMLClass) {
                    innerClass.push(element);
                }
            }
            if (innerClass.length > 0) {
                innerClass = cppCodeGen.classifyVisibility(innerClass);
                writeClassMethod(innerClass);
            }

        };

        var result = new $.Deferred(),
            self = this,
            fullPath,
            directory,
            file;

        // Package -> as namespace or not
        if (elem instanceof type.UMLPackage ||
            elem instanceof type.UMLComponent) {
            fullPath = path + "/" + elem.name;
            directory = FileSystem.getDirectoryForPath(fullPath);
            directory.create(function (err, stat) {
                if (!err || err === "AlreadyExists") {
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
            self.haveSR = SRState(elem);

            // generate class header elem_name.h
            file = FileSystem.getFileForPath(getFilePath(_CPP_CODE_GEN_H));
            FileUtils.writeText(file, self.writeHeaderSkeletonCode(elem, options, writeClassHeader), true).then(result.resolve, result.reject);

            // generate class cpp elem_name.cpp
            if (options.genCpp) {
                file = FileSystem.getFileForPath(getFilePath(_CPP_CODE_GEN_CPP));
                var first = true; // for the sequence identifiation

                Async.doSequentially([file, file], function (_file) {
                    var _result = new $.Deferred();

                    if (first) { // save all modification of operation's body
                        _file.read({}, function (err, data, stat) {
                            if (!err) {
                                self.opImplSaved = self.getAllCustomOpImpl(data);
                                _result.resolve();
                            } else {
                                _result.reject(err);
                            }
                        });

                        first = false; // switch to the second sequence
                    } else /*second*/ { // rewrite all with the saved modification
                        FileUtils.writeText(_file, self.writeBodySkeletonCode(elem, options, writeClassBody), true).then(_result.resolve, _result.reject);
                    }

                    return _result.promise();
                }, false)
                .then(result.resolve, result.reject);
            }

        } else if (elem instanceof type.UMLInterface) {
            /**
             * interface will convert to class which only contains virtual method and member variable.
             */
            // generate interface header ONLY elem_name.h
            file = FileSystem.getFileForPath(getFilePath(_CPP_CODE_GEN_H));
            FileUtils.writeText(file, self.writeHeaderSkeletonCode(elem, options, writeClassHeader), true).then(result.resolve, result.reject);

        } else if (elem instanceof type.UMLEnumeration) {
            // generate enumeration header ONLY elem_name.h

            file = FileSystem.getFileForPath(getFilePath(_CPP_CODE_GEN_H));
            FileUtils.writeText(file, self.writeHeaderSkeletonCode(elem, options, writeEnumeration), true).then(result.resolve, result.reject);
        
        } else if (elem instanceof type.UMLSignal) {
            // generate signal header ONLY elem_name.h

            file = FileSystem.getFileForPath(getFilePath(_CPP_CODE_GEN_H));
            FileUtils.writeText(file, self.writeHeaderSkeletonCode(elem, options, writeSignal, true)).then(result.resolve, result.reject);
        
        } else {
            result.resolve();
        }
        return result.promise();
    };

    /**
     * find if the elem have Signal and/or Reception
     * @param {Object} elem 
     * @return {Boolean}
     */
    function SRState(elem) {
        if (elem.receptions.length > 0) {
            return true;
        }
        for (var i = 0; i < elem.ownedElements.length; i++) {
            var element = elem.ownedElements[i];
            if (element instanceof type.UMLSignal) {
                return true;
            }
        }

        return false;
    }

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
        var namespaces = this.getNamespaces(elem).join("_");
        if (namespaces.length > 0) { namespaces += "_"; }
        var headerString = "_" + namespaces.toUpperCase() + elem.name.toUpperCase() + "_H";
        var codeWriter = new CodeGenUtils.CodeWriter(this.getIndentString(options));
        var includePart = this.getIncludePart(elem);
        codeWriter.writeLine(copyrightHeader);
        codeWriter.writeLine();
        codeWriter.writeLine("#ifndef " + headerString);
        codeWriter.writeLine("#define " + headerString);
        codeWriter.writeLine();

        if (includePart.length > 0) {
            codeWriter.writeLine(includePart);
        }
      
        this.writeHeaderNamespaces(codeWriter, elem, funct);

        codeWriter.writeLine();
        codeWriter.writeLine("#endif //" + headerString);
        return codeWriter.getData();
    };

    /**
     * Save all operation's body already implemented by the Developper
     * 
     * @param {string} data : the cpp file content
     * @return {Array.<Object>}
     */
    CppCodeGenerator.prototype.getAllCustomOpImpl = function (data) {
        var operationBodies = [];

        if (!data.length) {
            return operationBodies;
        }
        // transform this data to row array
        var rowContents = data.split("\n");
        var cell = [];
        var i;

        for (i = 0; i < rowContents.length; i++) {
            // continue if no information
            if (rowContents[i].length === 0) {
                continue;
            }
            cell = rowContents[i].split(" ");
            // catch the begin index
            if (cell.length !== 3 || cell[0] !== "//override") {
                continue;
            }
            // continue if the contents is overridable
            if (cell[1] === "true") {
                continue;
            }
            var operationBody = new OperationBody();

            operationBody.Id = cell[2];
            cell = rowContents[++i].split(" ");

            while ((cell[0] !== "//end") && (i < rowContents.length)) {
                // for Content integrity
                operationBody.Content += (!operationBody.Content.length ? "" : "\n") + rowContents[i];
                cell = rowContents[++i].split(" ");
            }
            operationBodies.push(operationBody);
        }

        return operationBodies;
    };

    /**
     * Write *.cpp file. Implement functor to each uml type.
     * Returns text
     *
     * @param {Object} elem
     * @param {Object} options
     * @param {Object} functor
     * @return {Object} string
     */
    CppCodeGenerator.prototype.writeBodySkeletonCode = function (elem, options, funct) {
        var codeWriter = new CodeGenUtils.CodeWriter(this.getIndentString(options));

        codeWriter.writeLine(copyrightHeader);
        codeWriter.writeLine();
        codeWriter.writeLine("#include \"" + elem.name + ".h\"");
        codeWriter.writeLine();

        funct(codeWriter, elem, this);
        return codeWriter.getData();
    };

    /**
     * get list of namespace element
     *
     * @param {Object} elem
     * @return {Array <String>}
     */
    CppCodeGenerator.prototype.getNamespaces = function (elem) {
        var namespaces = [];
        var greatNamespaces = [];
        var i;

        var parentElem = elem._parent;
        while (parentElem) {
            if (parentElem instanceof type.UMLPackage &&
               !(parentElem instanceof type.UMLModel) &&
               !(parentElem instanceof type.UMLProfile)) {
                namespaces.push(parentElem.name);
            }
            parentElem = parentElem._parent;
        }

        for (i = 0; i < namespaces.length; i++) {
            greatNamespaces.push(namespaces[(namespaces.length - 1) - i]);
        }

        return greatNamespaces;
    };

    /**
     * get all parents of the elem (package only)
     * @param {Object} elem 
     * @return {String}
     */
    CppCodeGenerator.prototype.getNamespacesSpecifierStr = function (elem) {
        var namespaces = this.getNamespaces(elem);
        var namespacesString = "";
        if (namespaces.length > 0) {
            namespacesString += namespaces.join("::") + "::";
        }
        return namespacesString;
    };
    
    /**
     * get all parents of the elem (package and class)
     * @param {Object} elem 
     * @return {String}
     */
    CppCodeGenerator.prototype.getContainersSpecifierStr = function (elem) {
        var t_elem = elem;
        var specifiers = [];
        var invSpecifiers = [];

        while (t_elem._parent instanceof type.UMLClass) {
            invSpecifiers.push(t_elem._parent.name);
            t_elem = t_elem._parent;
        }

        for (var i = 0; i < invSpecifiers.length; i++) {
            specifiers.push(invSpecifiers[(invSpecifiers.length - 1) - i]);
        }

        return this.getNamespacesSpecifierStr(t_elem) + specifiers.join("::");

    };

    CppCodeGenerator.prototype.writeHeaderNamespaces = function (codeWriter, elem, funct) {
        var namespaces = this.getNamespaces(elem);

        if (namespaces.length > 0) {
            var i;
            for (i = 0; i < namespaces.length; i++) {
                codeWriter.writeLine("namespace " + namespaces[i] + " {");
            }
            codeWriter.writeLine();

            funct(codeWriter, elem, this);

            codeWriter.writeLine();
            for (i = 0; i < namespaces.length; i++) {
                codeWriter.writeLine("} // end of namespace " + namespaces[(namespaces.length - 1) - i]);
            }
        } else {
            funct(codeWriter, elem, this);
        }
        
        return codeWriter.getData();
    };

    /**
     * Parsing template parameter
     *
     * @param {Object} elem
     * @return {Object} string
     */
    CppCodeGenerator.prototype.getTemplateParameter = function (elem) {
        var i;
        var returnTemplateString = "";
        if (elem.templateParameters.length <= 0) {
            return returnTemplateString;
        }
        var term = [];
        returnTemplateString = "template <";

        for (i = 0; i < elem.templateParameters.length; i++) {
            var template = elem.templateParameters[i];
            var templateStr = template.parameterType + " ";
            templateStr += template.name;
            if (template.defaultValue.length !== 0) {
                templateStr += " = " + template.defaultValue;
            }
            term.push(templateStr);
        }
        returnTemplateString += term.join(", ");
        returnTemplateString += ">";
        return returnTemplateString;
    };

    CppCodeGenerator.prototype.getTemplateParameterNames = function (elem) {
        var i;
        var returnTemplateString = "";
        if (elem.templateParameters.length <= 0) {
            return returnTemplateString;
        }
        var term = [];
        returnTemplateString = "<";

        for (i = 0; i < elem.templateParameters.length; i++) {
            var template = elem.templateParameters[i];
            var templateStr = template.name;
            term.push(templateStr);
        }
        returnTemplateString += term.join(", ");
        returnTemplateString += ">";
        return returnTemplateString;
    };

    CppCodeGenerator.prototype.trackingHeader = function (elem, target) {
        var header = "";
        var elementString = "";
        var targetString = "";
        var i;

        while (elem._parent._parent !== null) {
            elementString = (elementString.length !== 0) ? elem.name + "/" + elementString : elem.name;
            elem = elem._parent;
        }
        while (target._parent._parent !== null) {
            targetString = (targetString.length !== 0) ? target.name + "/" + targetString : target.name;
            target = target._parent;
        }

        var idx;
        for (i = 0; i < (elementString.length < targetString.length) ? elementString.length : targetString.length; i++) {

            if (elementString[i] === targetString[i]) {
                if (elementString[i] === '/' && targetString[i] === '/') {
                    idx = i + 1;
                }
            } else {
                break;
            }
        }
        // remove common path
        elementString = elementString.substring(idx, elementString.length);
        targetString = targetString.substring(idx, targetString.length);

        for (i = 0; i < elementString.split('/').length - 1; i++) {
            header += "../";
        }
        header += targetString;

        return header;
    };

    CppCodeGenerator.prototype.getAssociatedMemberType = function (elem) {
        if (Repository.getRelationshipsOf(elem).length > 0) {
            var i;
            var associatedMemberType = [];

            var associations = Repository.getRelationshipsOf(elem, function (rel) {
                return (rel instanceof type.UMLAssociation);
            });

            for (i = 0; i < associations.length; i++) {
                var asso = associations[i];
                var target;
                if (asso.end1.reference === elem && asso.end2.navigable === true && asso.end2.name.length !== 0) {
                    target = asso.end2.reference;
                } else if (asso.end2.reference === elem && asso.end1.navigable === true && asso.end1.name.length !== 0) {
                    target = asso.end1.reference;
                } else {
                    continue;
                }
                if (target === elem) {
                    continue;
                }
                associatedMemberType.push(target);
            }
            return associatedMemberType;
        }
    };

    /**
     * Parsing include header
     *
     * @param {Object} elem
     * @return {Object} string
     */
    CppCodeGenerator.prototype.getIncludePart = function (elem) {
        var i;
        var headerString = "";
        var memberString = "";
        var dependenciesString = "";

        if (this.haveSR && this.genOptions.useQt) {
            headerString += "#include <QObject>\n";
        }

        if (Repository.getRelationshipsOf(elem).length <= 0) {
            return "";
        }
        var realizations = Repository.getRelationshipsOf(elem, function (rel) {
            return (rel instanceof type.UMLInterfaceRealization || rel instanceof type.UMLGeneralization);
        });

        // for comparaison
        var associationComp = [];

        // check for interface or class
        for (i = 0; i < realizations.length; i++) {
            var realize = realizations[i];
            if (realize.target === elem) {
                continue;
            }
            headerString += "#include \"" + this.trackingHeader(elem, realize.target) + ".h\"\n";
            associationComp.push(realize.target);
        }

        // check for association member variable
        var associatedMemberType = this.getAssociatedMemberType(elem);

        if (associatedMemberType.length > 0) {
            for (i = 0; i < associatedMemberType.length; i++) {
                var target = associatedMemberType[i];
                if (associationComp.contains(target)) {
                    continue;
                }
                memberString += "#include \"" + this.trackingHeader(elem, target) + ".h\"\n";
                associationComp.push(target);
            }
        }

        // check for dependencies class
        var dependencies = elem.getDependencies();

        if (dependencies.length > 0) {
            for (i = 0; i < dependencies.length; i++) {
                var target = dependencies[i];
                if (associationComp.contains(target) ||
                    !(target instanceof type.UMLClassifier)) {
                    continue;
                }
                dependenciesString += "#include \"" + this.trackingHeader(elem, target) + ".h\"\n";
                associationComp.push(target);
            }
        }

        return headerString + memberString + dependenciesString;
    };

    /**
     * Classfy method and attribute by accessor.(public, private, protected)
     *
     * @param {Object} items
     * @return {Object} list
     */
    CppCodeGenerator.prototype.classifyVisibility = function (items) {
        var public_list = [];
        var protected_list = [];
        var private_list = [];
        var i;
        for (i = 0; i < items.length; i++) {

            var item = items[i];
            var visib = this.getVisibility(item);

            if ("public" === visib) {
                public_list.push(item);
            } else if ("private" === visib) {
                private_list.push(item);
            } else {
                // if modifier not setted, consider it as protected
                protected_list.push(item);
            }
        }
        return {
            _public: public_list,
            _protected: protected_list,
            _private: private_list
        };
    };

    /**
     * generate variables from attributes[i]
     *
     * @param {Object} elem
     * @return {Object} string
     */
    CppCodeGenerator.prototype.getMemberVariable = function (elem) {
        if (elem.name.length > 0) {
            var terms = this.getVariableDeclaration(elem, false);
            // doc
            var docs = this.getDocuments(elem.documentation);

            return (docs + terms + ";");
        }
    };

    /**
     * generate methods from operations[i]
     *
     * @param {Object} elem
     * @param {boolean} isCppBody
     * @return {Object} string
     */
    CppCodeGenerator.prototype.getMethod = function (elem, isCppBody) {
        if (elem.name.length > 0) {
            var docs = "@brief " + elem.documentation;
            var i;
            var methodStr = "";

            var returnTypeParam = _.filter(elem.parameters, function (params) {
                return params.direction === "return";
            });
            var inputParams = _.filter(elem.parameters, function (params) {
                return (params.direction === "in" || params.direction === "inout" || params.direction === "out");
            });
            var inputParamStrings = [];
            for (i = 0; i < inputParams.length; i++) {
                var inputParam = inputParams[i];
                inputParamStrings.push(this.getVariableDeclaration(inputParam, isCppBody));
                docs += "\n@param " + inputParam.name + (inputParam.documentation.length ? " :    " + inputParam.documentation : "");
            }

            var validReturnParam = returnTypeParam[0];
            var returnType = ((returnTypeParam.length > 0) ? this.getType(validReturnParam) : "void");
            // var _returnTypeMultiplicity = validReturnParam.multiplicity;

            // // multiplicity
            // if (_returnTypeMultiplicity) {
            //     returnType += "bla";
            //     if (_.contains(["0..*", "1..*", "*"], _returnTypeMultiplicity.trim())) {
            //         if (this.genOptions.useVector) {
            //             returnType = "vector<" + returnType + ">";
            //         } else {
            //             returnType += "*";
            //         }
            //     } else if (_returnTypeMultiplicity !== "1" && _returnTypeMultiplicity !== "0..1") {
            //         if (_returnTypeMultiplicity.match(/^\d+$/)) { // number
            //             returnType += "[" + _returnTypeMultiplicity + "]";
            //         } else {
            //             returnType += "[]";
            //         }
            //     }
            // }

            methodStr += returnType + " ";

            if (isCppBody) {
                var templateSpecifier = "";
                var templateParameter = this.getTemplateParameter(elem);
                var parentTemplateParameter = this.getTemplateParameter(elem._parent);

                if (templateParameter.length > 0) {
                    templateSpecifier = this.getTemplateParameterNames(elem);
                    methodStr = templateParameter + "\n" + methodStr;
                } else if (parentTemplateParameter.length > 0) {
                    templateSpecifier = this.getTemplateParameterNames(elem._parent);
                    methodStr = parentTemplateParameter + "\n" + methodStr;
                }

                var indentLine = this.getIndentString(this.genOptions);
                var specifier = this.getContainersSpecifierStr(elem) + templateSpecifier + "::";

                methodStr += specifier;
                methodStr += elem.name;
                methodStr += "(" + inputParamStrings.join(", ") + ")" + "\n{";

                var _override = true;
                var _contents = "";
                // get the content of an identified operation
                if (this.opImplSaved.length > 0) {
                    for (var i = 0; i < this.opImplSaved.length; i++) {
                        if (elem._id === this.opImplSaved[i].Id) {
                            _override = false;
                            _contents = this.opImplSaved[i].Content;
                            break;
                        }
                    }
                }
                // write an operation identifier
                methodStr += "\n//override " + (_override ? "true " : "false ") + elem._id + "\n";

                if (_override === false) {
                    methodStr += _contents;
                } else {
                    if (returnTypeParam.length > 0) {
                        var retParam_Name = validReturnParam.name;
                        if (retParam_Name.length > 0) {
                            methodStr += indentLine + this.getVariableDeclaration(validReturnParam, isCppBody) + ";\n";
                            methodStr += "\n" + indentLine + "return " + retParam_Name + ";";
                        } else {
                            if (returnType === "boolean" || returnType === "bool") {
                                methodStr += indentLine + "return false;";
                            } else if (returnType === "int" || returnType === "long" || returnType === "short" || returnType === "byte") {
                                methodStr += indentLine + "return 0;";
                            } else if (returnType === "double" || returnType === "float") {
                                methodStr += indentLine + "return 0.0;";
                            } else if (returnType === "char") {
                                methodStr += indentLine + "return '0';";
                            } else if (returnType === "string" || returnType === "String") {
                                methodStr += indentLine + 'return "";';
                            } else if (returnType === "void") {
                                methodStr += indentLine + "return;";
                            } else {
                                methodStr += indentLine + "return null;";
                            }
                        }
                        docs += "\n@return " + returnType + (validReturnParam.documentation.length ? " :    " + validReturnParam.documentation : "");
                    }
                }
                
                methodStr += "\n//end";
                methodStr += "\n}";

            } else {

                methodStr += elem.name;
                methodStr += "(" + inputParamStrings.join(", ") + ")";

                // make pure virtual all operation of an UMLInterface
                if (elem._parent instanceof type.UMLInterface) {
                    methodStr = "virtual " + methodStr;
                    methodStr += " = 0";
                    // set the elem and his parent in model to abstract (if not setted)
                    elem._parent.isAbstract = true;
                    elem.isAbstract = true;
                } else {
                    if (elem.isStatic) {
                        methodStr = "static " + methodStr;
                    } else if (elem.isAbstract) {
                        methodStr = "virtual " + methodStr;
                        methodStr += " = 0";
                        // set the parent elem in model to abstract (if not setted)
                        elem._parent.isAbstract = true;
                    } else if (elem.isLeaf) {
                        methodStr += " final";
                    }
                }
                methodStr += ";";
            }

            return "\n" + this.getDocuments(docs) + methodStr;
        }
    };

    /**
     * generate slot from reception[i]
     *
     * @param {Object} elem
     * @param {boolean} isCppBody
     * @return {Object} string
     */
    CppCodeGenerator.prototype.getSlot = function (elem, isCppBody) {
        if (elem.name.length > 0) {
            var docs = "@brief " + elem.documentation;
            var i;
            var methodStr = "";
            var paramStr = "";

            if (elem.isStatic === true) {
                methodStr += "static ";
            }

            if (elem.signal !== null && elem.signal instanceof type.UMLSignal) {
                var elemSignal = elem.signal;
                var params = [];
                for (i = 0; i < elemSignal.attributes.length; i++) {
                    var att = elemSignal.attributes[i];
                    params.push(this.getVariableDeclaration(att, true));
                }
                paramStr += params.join(", ");
                
                var specifier = this.getContainersSpecifierStr(elemSignal);
                if (specifier.length > 0) {
                    specifier += "::";
                }
                docs += "\nFrom signal: " + specifier + elemSignal.name;
            }

            if (isCppBody) {
                var templateSpecifier = "";
                var templateParameter = this.getTemplateParameter(elem);
                var parentTemplateParameter = this.getTemplateParameter(elem._parent);

                if (templateParameter.length > 0) {
                    templateSpecifier = this.getTemplateParameterNames(elem);
                    methodStr = templateParameter + "\n" + methodStr;
                } else if (parentTemplateParameter.length > 0) {
                    templateSpecifier = this.getTemplateParameterNames(elem._parent);
                    methodStr = parentTemplateParameter + "\n" + methodStr;
                }

                var indentLine = this.getIndentString(this.genOptions);
                var specifier = this.getContainersSpecifierStr(elem) + templateSpecifier + "::";

                methodStr += "void " + specifier + elem.name + "(" + paramStr + ")";
                methodStr += "\n{";

                var _override = true;
                var _contents = "";
                // get the content of an identified operation
                if (this.opImplSaved.length > 0) {
                    for (var i = 0; i < this.opImplSaved.length; i++) {
                        if (elem._id === this.opImplSaved[i].Id) {
                            _override = false;
                            _contents = this.opImplSaved[i].Content;
                            break;
                        }
                    }
                }
                // write an operation identifier
                methodStr += "\n//override " + (_override ? "true " : "false ") + elem._id + "\n";

                if (_override === false) {
                    methodStr += _contents;
                }
                
                methodStr += "\n//end";
                methodStr += "\n}";
            } else {
                var identifier = "";
                if (this.genOptions.useQt) {
                    identifier = "Q_SLOT ";
                }

                methodStr += identifier + "void " + elem.name + "(" + paramStr + ");";
            }

            return "\n" + this.getDocuments(docs) + methodStr;
        }
    };

    /**
     * generate doc string from doc element
     *
     * @param {Object} text
     * @return {Object} string
     */
    CppCodeGenerator.prototype.getDocuments = function (text) {
        var docs = "";
        if (_.isString(text) && text.length !== 0) {
            var lines = text.trim().split("\n");
            docs += "/**\n";
            var i;
            for (i = 0; i < lines.length; i++) {
                docs += " * " + lines[i] + "\n";
            }
            docs += " */\n";
        }
        return docs;
    };

    /**
     * parsing visibility from element
     *
     * @param {Object} elem
     * @return {Object} string
     */
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

    /**
     * parsing modifiers from element
     *
     * @param {Object} elem
     * @return {Object} list
     */
    CppCodeGenerator.prototype.getModifiers = function (elem) {
        var modifiers = [];

        if (elem.isStatic === true) {
            modifiers.push("static");
        }
        if (elem.isReadOnly === true) {
            modifiers.push("const");
        }
        if (elem.isAbstract === true) {
            modifiers.push("virtual");
        }
        return modifiers;
    };

    /**
     * parsing type from element
     *
     * @param {Object} elem
     * @return {Object} string
     */
    CppCodeGenerator.prototype.getType = function (elem) {
        var _type = "void";

        if (elem instanceof type.UMLAssociationEnd) { // member variable from association
            if (elem.reference instanceof type.UMLModelElement && elem.reference.name.length > 0) {
                _type = this.getNamespacesSpecifierStr(elem.reference) + elem.reference.name;

                var associations = Repository.getRelationshipsOf(elem.reference, function (rel) {
                    return (rel instanceof type.UMLAssociation);
                });

                var oppositeElem;
                var i;

                for (i = 0; i < associations.length; i++) {
                    var asso = associations[i];

                    if (asso.end1 === elem) {
                        oppositeElem = asso.end2;
                        break;
                    } else if (asso.end2 === elem) {
                        oppositeElem = asso.end1;
                        break;
                    }
                }

                if (oppositeElem.aggregation !== UML.AK_COMPOSITE) {
                    _type += "*";
                }
            }
        } else { // member variable inside class
            if (elem.type instanceof type.UMLModelElement && elem.type.name.length > 0) {
                _type = this.getNamespacesSpecifierStr(elem.type) + elem.type.name;
            } else if (_.isString(elem.type) && elem.type.length > 0) {
                _type = elem.type;
            }

            if (elem.aggregation === UML.AK_SHARED) {
                _type += "*";
            }
        }

        return _type;
    };

    /**
     * generate variable/parameter declaration
     *
     * @param {Object} elem
     * @param {boolean} isCppBody
     * @return {Object} string
     */
    CppCodeGenerator.prototype.getVariableDeclaration = function (elem, isCppBody) {
        var vDeclaration = [];

        // modifiers
        var vModifiers = this.getModifiers(elem);
        if (vModifiers.length > 0) {
            vDeclaration.push(vModifiers.join(" "));
        }

        // type
        var vType = this.getType(elem);

        // name
        var vName = elem.name;

        // multiplicity
        if (elem.multiplicity) {
            if (_.contains(["0..*", "1..*", "*"], elem.multiplicity.trim())) {
                if (this.genOptions.useVector) {
                    vType = "vector<" + vType + ">";
                } else {
                    vType += "*";
                }
            } else if (elem.multiplicity !== "1" && elem.multiplicity !== "0..1") {
                if (elem.multiplicity.match(/^\d+$/)) { // number
                    vName += "[" + elem.multiplicity + "]";
                } else {
                    vName += "[]";
                }
            }
        }

        // modify the type if elem is an UMLParameter and direction is "inout" or "out"
        if (elem instanceof type.UMLParameter) {
            switch (elem.direction) {
                case UML.DK_INOUT:
                    vName = "&" + vName;
                    break;
                case UML.DK_OUT:
                    vName = "*" + vName;
                    break;
            }
        }    

        // vType or vName can be modified by the multiplicity computation
        vDeclaration.push(vType);
        vDeclaration.push(vName);

        // if parameter with direction other than "return", Default value is not generated in body of the class
        if (!isCppBody || (elem instanceof type.UMLParameter && elem.direction === UML.DK_RETURN)) {
            // initial value
            if (elem.defaultValue && elem.defaultValue.length > 0) {
                vDeclaration.push("= " + elem.defaultValue);
            }
        }

        return vDeclaration.join(" ");
    };

    /**
     * get all super class / interface from element
     *
     * @param {Object} elem
     * @return {Object} list
     */
    CppCodeGenerator.prototype.getSuperClasses = function (elem) {
        var generalizations = Repository.getRelationshipsOf(elem, function (rel) {
            return ((rel instanceof type.UMLGeneralization || rel instanceof type.UMLInterfaceRealization) && rel.source === elem);
        });
        return generalizations;
    };



    function generate(baseModel, basePath, options) {
        var result = new $.Deferred();
        var cppCodeGenerator = new CppCodeGenerator(baseModel, basePath);
        return cppCodeGenerator.generate(baseModel, basePath, options);
    }

    function getVersion() { return versionString; }

    exports.generate = generate;
    exports.getVersion = getVersion;
});

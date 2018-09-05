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

const fs = require('fs')
const path = require('path')
const parser = require('./grammar/cpp')

// C++ Primitive Types
var cppPrimitiveTypes = [
  'sbyte',
  'short',
  'ushort',
  'uint',
  'long',
  'ulong',
  'char',
  'float',
  'double',
  'decimal',
  'bool',
  'void',
  'auto',
  'int',
  'short int',
  'long int',
  'long long',
  'long double',
  'signed int',
  'signed char',
  'signed long',
  'signed short',
  'signed short int',
  'signed long int',
  'signed long long',
  'signed',
  'unsigned',
  'unsigned int',
  'unsigned char',
  'unsigned long',
  'unsigned short',
  'unsigned short int',
  'unsigned long int',
  'unsigned long long'
]

/**
 * C++ Code Analyzer
 */
class CppCodeAnalyzer {
  /**
   * @constructor
   */
  constructor () {
    /** @member {type.UMLModel} */
    this._root = new type.UMLModel()
    this._root.name = 'CppReverse'

    /** @member {Array.<File>} */
    this._files = []

    /** @member {Object} */
    this._currentCompilationUnit = null

    /**
     * @member {{classifier:type.UMLClassifier, node: Object, kind:string}}
     */
    this._extendPendings = []

    /**
     * @member {{classifier:type.UMLClassifier, node: Object}}
     */
    this._implementPendings = []

    /**
     * @member {{classifier:type.UMLClassifier, association: type.UMLAssociation, node: Object}}
     */
    this._associationPendings = []

    /**
     * @member {{operation:type.UMLOperation, node: Object}}
     */
    this._throwPendings = []

    /**
     * @member {{namespace:type.UMLModelElement, feature:type.UMLStructuralFeature, node: Object}}
     */
    this._typedFeaturePendings = []

    this._usingList = []
  }

  /**
   * Add File to Reverse Engineer
   * @param {File} file
   */
  addFile (file) {
    this._files.push(file)
  }

  /**
   * Analyze all files.
   * @param {Object} options
   * @return {$.Promise}
   */
  analyze (options) {
    // Perform 1st Phase
    this.performFirstPhase(options)

    // Perform 2nd Phase
    this.performSecondPhase(options)

    // Load To Project
    var writer = new app.repository.Writer()
    writer.writeObj('data', this._root)
    var json = writer.current.data
    app.project.importFromJson(app.project.getProject(), json)

    // Generate Diagrams
    this.generateDiagrams(options)
    console.log('[C++] done.')
  }

  /**
   * Generate Diagrams (Type Hierarchy, Package Structure, Package Overview)
   * @param {Object} options
   */
  generateDiagrams (options) {
    var baseModel = app.repository.get(this._root._id)
    if (options.packageStructure) {
      app.commands.execute('diagram-generator:package-structure', baseModel, true)
    }
    if (options.typeHierarchy) {
      app.commands.execute('diagram-generator:type-hierarchy', baseModel, true)
    }
    if (options.packageOverview) {
      baseModel.traverse(elem => {
        if (elem instanceof type.UMLPackage) {
          app.commands.execute('diagram-generator:overview', elem, true)
        }
      })
    }
  }

  /**
   * Find Type.
   *
   * @param {type.Model} namespace
   * @param {string|Object} type Type name string or type node.
   * @param {Object} compilationUnitNode To search type with import statements.
   * @return {type.Model} element correspond to the type.
   */
  _findType (namespace, type_, compilationUnitNode) {
    var typeName, pathName
    var _type = null

    typeName = type_

    if (typeof typeName !== 'string') {
      typeName = type_.name
    }

    pathName = [ typeName ]

    // 1. Lookdown from context
    if (pathName.length > 1) {
      _type = namespace.lookdown(pathName)
    } else {
      _type = namespace.findByName(typeName)
    }

    // 2. Lookup from context
    if (!_type) {
      _type = namespace.lookup(typeName, null, this._root)
    }

    // 3. Find from imported namespaces
    var i, len
    if (!_type) {
      for (i = 0, len = this._usingList.length; i < len; i++) {
        var _import = this._usingList[i]
        // Find in import exact matches (e.g. import java.lang.String)
        _type = this._root.lookdown(_import.name)
      }
    }

    // 4. Lookdown from Root
    if (!_type) {
      if (pathName.length > 1) {
        _type = this._root.lookdown(pathName)
      } else {
        _type = this._root.findByName(typeName)
      }
    }

    return _type
  }

  /**
   * Return the class of a given pathNames. If not exists, create the class.
   * @param {type.Model} namespace
   * @param {Array.<string>} pathNames
   * @return {type.Model} Class element corresponding to the pathNames
   */
  _ensureClass (namespace, pathNames) {
    if (pathNames.length > 0) {
      var _className = pathNames.pop()
      var _package = this._ensurePackage(namespace, pathNames)
      var _class = _package.findByName(_className)

      if (!_class) {
        _class = new type.UMLClass()
        _class._parent = _package
        _class.name = _className
        _class.visibility = type.UMLModelElement.VK_PUBLIC
        _package.ownedElements.push(_class)
      }

      return _class
    }
    return null
  }

  /**
   * Test a given type is a generic collection or not
   * @param {Object} typeNode
   * @return {string} Collection item type name
   */
  _isGenericCollection (typeNode, compilationUnitNode) {
    return null
  }

  /**
   * Perform Second Phase
   *   - Create Generalizations
   *   - Create InterfaceRealizations
   *   - Create Fields or Associations
   *   - Resolve Type References
   *
   * @param {Object} options
   */
  performSecondPhase (options) {
    var i, len, j, len2, _typeName, _type, _itemTypeName, _itemType, _pathName

    // Create Generalizations
    //     if super type not found, create a Class correspond to the super type.
    for (i = 0, len = this._extendPendings.length; i < len; i++) {
      var _extend = this._extendPendings[i]
      _typeName = _extend.node
      _type = this._findType(_extend.classifier, _typeName, _extend.compilationUnitNode)

      if (!_type) {
        //                _pathName = this._toPathName(_typeName);
        _pathName = [ _typeName ]
        //                if (_extend.kind === "interface") {
        //                    _type = this._ensureInterface(this._root, _pathName);
        //                } else {
        _type = this._ensureClass(this._root, _pathName)
        //                }
      }

      var generalization = new type.UMLGeneralization()
      generalization._parent = _extend.classifier
      generalization.source = _extend.classifier
      generalization.target = _type
      _extend.classifier.ownedElements.push(generalization)
    }

    // Create Associations
    for (i = 0, len = this._associationPendings.length; i < len; i++) {
      var _asso = this._associationPendings[i]
      _typeName = _asso.node
      _type = this._findType(_asso.classifier, _typeName, _asso.node.compilationUnitNode)
      _itemTypeName = this._isGenericCollection(_asso.node.type, _asso.node.compilationUnitNode)
      if (_itemTypeName) {
        _itemType = this._findType(_asso.classifier, _itemTypeName, _asso.node.compilationUnitNode)
      } else {
        _itemType = null
      }

      // if type found, add as Association
      if (_type || _itemType) {
        for (j = 0, len2 = _asso.node.name.length; j < len2; j++) {
          var variableNode = _asso.node.name[j]

          // Create Association
          var association = new type.UMLAssociation()
          association._parent = _asso.classifier
          _asso.classifier.ownedElements.push(association)

          // Set End1
          association.end1.reference = _asso.classifier
          association.end1.name = ''
          association.end1.visibility = type.UMLModelElement.VK_PACKAGE
          association.end1.navigable = false

          // Set End2
          if (_itemType) {
            association.end2.reference = _itemType
            association.end2.multiplicity = '*'
            this._addTag(association.end2, type.Tag.TK_STRING, 'collection', _asso.node.type.qualifiedName.name)
          } else {
            association.end2.reference = _type
          }
          association.end2.name = variableNode.name
          association.end2.visibility = this._getVisibility(_asso.node.modifiers)
          association.end2.navigable = true

          // Final Modifier
          if (_asso.node.modifiers && _asso.node.modifiers.includes('final')) {
            association.end2.isReadOnly = true
          }

          // Static Modifier
          if (_asso.node.modifiers && _asso.node.modifiers.includes('static')) {
            this._addTag(association.end2, type.Tag.TK_BOOLEAN, 'static', true)
          }

          // Volatile Modifier
          if (_asso.node.modifiers && _asso.node.modifiers.includes('volatile')) {
            this._addTag(association.end2, type.Tag.TK_BOOLEAN, 'volatile', true)
          }

          // Transient Modifier
          if (_asso.node.modifiers && _asso.node.modifiers.includes('transient')) {
            this._addTag(association.end2, type.Tag.TK_BOOLEAN, 'transient', true)
          }
        }
        // if type not found, add as Attribute
      } else {
        this.translateFieldAsAttribute(options, _asso.classifier, _asso.node)
      }
    }

    // Resolve Type References
    for (i = 0, len = this._typedFeaturePendings.length; i < len; i++) {
      var _typedFeature = this._typedFeaturePendings[i]
      _typeName = _typedFeature.node.type

      // Find type and assign
      _type = this._findType(_typedFeature.namespace, _typedFeature.node, _typedFeature.node.compilationUnitNode)

      // if type is exists
      if (_type) {
        _typedFeature.feature.type = _type
        // if type is not exists
      } else {
        // if type is generic collection type (e.g. java.util.List<String>)
        _itemTypeName = this._isGenericCollection(_typedFeature.node.type, _typedFeature.node.compilationUnitNode)
        if (_itemTypeName) {
          _typeName = _itemTypeName
          _typedFeature.feature.multiplicity = '*'
          this._addTag(_typedFeature.feature, type.Tag.TK_STRING, 'collection', _typedFeature.node.type)
        }

        // if type is primitive type
        if (cppPrimitiveTypes.includes(_typeName)) {
          _typedFeature.feature.type = _typeName
          // otherwise
        } else {
          _pathName = [_typeName]
          var _newClass = this._ensureClass(this._root, _pathName)
          _typedFeature.feature.type = _newClass
        }
      }

      // Translate type's arrayDimension to multiplicity
      if (_typedFeature.node.type && _typedFeature.node.type.length > 0) {
        var _dim = []
        for (j = 0, len2 = _typedFeature.node.type.length; j < len2; j++) {
          if (_typedFeature.node.type[j] === '[') {
            _dim.push('*')
          }
        }
        _typedFeature.feature.multiplicity = _dim.join(',')
      }
    }
  }

  /**
   * Translate C++ CompilationUnit Node.
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Object} compilationUnitNode
   */
  translateCompilationUnit (options, namespace, compilationUnitNode) {
    var _namespace = namespace
    this.translateTypes(options, _namespace, compilationUnitNode['member'])
  }

  /**
   * Translate Type Nodes
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Array.<Object>} typeNodeArray
   */
  translateTypes (options, namespace, typeNodeArray) {
    var _namespace = namespace
    var i, len
    if (typeNodeArray.length > 0) {
      for (i = 0, len = typeNodeArray.length; i < len; i++) {
        var typeNode = typeNodeArray[i]
        switch (typeNode.node) {
        case 'namespace':
          var _package = this.translatePackage(options, _namespace, typeNode)
          if (_package !== null) {
            _namespace = _package
          }
          // Translate Types
          this.translateTypes(options, _namespace, typeNode.body)
          break
        case 'class':
        case 'struct':
          this.translateClass(options, namespace, typeNode)
          break
        case 'enum':
          this.translateEnum(options, namespace, typeNode)
          break
        case 'using':
          this._usingList.push(typeNode)
          break
        }
      }
    }
  }

  /**
   * Translate C++ Enum Node.
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Object} enumNode
   */
  translateEnum (options, namespace, enumNode) {
    var _enum

    // Create Enumeration
    _enum = new type.UMLEnumeration()
    _enum._parent = namespace
    _enum.name = enumNode.name
    _enum.visibility = this._getVisibility(enumNode.modifiers)

    // CppDoc
    //        if (enumNode.comment) {
    //            _enum.documentation = enumNode.comment;
    //        }
    namespace.ownedElements.push(_enum)

    // Translate Type Parameters
    //        this.translateTypeParameters(options, _enum, enumNode.typeParameters);
    if (enumNode.body !== '{') {
      // Translate Members
      this.translateMembers(options, _enum, enumNode.body)
    }
  }

  /**
   * Translate C++ Class Node.
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Object} compilationUnitNode
   */
  translateClass (options, namespace, classNode) {
    var i, len, _class

    // Create Class
    _class = new type.UMLClass()
    _class._parent = namespace
    _class.name = classNode.name

    // Access Modifiers
    _class.visibility = this._getVisibility(classNode.modifiers)

    // Abstract Class
    if (classNode.modifiers && classNode.modifiers.includes('abstract')) {
      _class.isAbstract = true
    }

    // Final Class

    // CppDoc
    //        if (classNode.comment) {
    //            _class.documentation = classNode.comment;
    //        }

    namespace.ownedElements.push(_class)

    // Register Extends for 2nd Phase Translation
    if (classNode['base']) {
      for (i = 0, len = classNode['base'].length; i < len; i++) {
        var _extendPending = {
          classifier: _class,
          node: classNode['base'][i],
          kind: 'class',
          compilationUnitNode: this._currentCompilationUnit
        }
        this._extendPendings.push(_extendPending)
      }
    }

    // Translate Type Parameters
    //        this.translateTypeParameters(options, _class, classNode.typeParameters);

    if (classNode.body && (classNode.body !== '{')) {
      // Translate Types
      this.translateTypes(options, _class, classNode.body)
      // Translate Members
      this.translateMembers(options, _class, classNode.body)
    }
  }

  /**
   * Translate Members Nodes
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Array.<Object>} memberNodeArray
   */
  translateMembers (options, namespace, memberNodeArray) {
    var i, len
    if (memberNodeArray.length > 0) {
      for (i = 0, len = memberNodeArray.length; i < len; i++) {
        var memberNode = memberNodeArray[i]
        var visibility = this._getVisibility(memberNode.modifiers)

        // Generate public members only if publicOnly == true
        if (options.publicOnly && visibility !== type.UMLModelElement.VK_PUBLIC) {
          continue
        }

        memberNode.compilationUnitNode = this._currentCompilationUnit

        switch (memberNode.node) {
        case 'field':
        case 'property':
          if (options.association) {
            this.translateFieldAsAssociation(options, namespace, memberNode)
          } else {
            this.translateFieldAsAttribute(options, namespace, memberNode)
          }
          break
        case 'constructor':
          this.translateMethod(options, namespace, memberNode, true)
          break
        case 'method':
          this.translateMethod(options, namespace, memberNode)
          break
        case 'constant':
          //                    this.translateEnumConstant(options, namespace, memberNode);
          break
        }
      }
    }
  }

  /**
   * Translate Method
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Object} methodNode
   * @param {boolean} isConstructor
   */
  translateMethod (options, namespace, methodNode, isConstructor) {
    var i, len
    var _operation = new type.UMLOperation()
    _operation._parent = namespace
    _operation.name = methodNode.name

    if (!isConstructor) {
      _operation.name = methodNode.name
    }

    namespace.operations.push(_operation)

    // Modifiers
    _operation.visibility = this._getVisibility(methodNode.modifiers)
    if (methodNode.modifiers && methodNode.modifiers.includes('static')) {
      _operation.isStatic = true
    }
    if (methodNode.modifiers && methodNode.modifiers.includes('abstract')) {
      _operation.isAbstract = true
    }

    // Constructor
    if (isConstructor) {
      _operation.stereotype = 'constructor'
    }

    // Formal Parameters
    if (methodNode.parameter && methodNode.parameter.length > 0) {
      for (i = 0, len = methodNode.parameter.length; i < len; i++) {
        var parameterNode = methodNode.parameter[i]
        parameterNode.compilationUnitNode = methodNode.compilationUnitNode
        this.translateParameter(options, _operation, parameterNode)
      }
    }

    // Return Type
    if (methodNode.type) {
      var _returnParam = new type.UMLParameter()
      _returnParam._parent = _operation
      _returnParam.name = ''
      _returnParam.direction = type.UMLParameter.DK_RETURN
      // Add to _typedFeaturePendings
      this._typedFeaturePendings.push({
        namespace: namespace,
        feature: _returnParam,
        node: methodNode
      })
      _operation.parameters.push(_returnParam)
    }

    // Throws
    //        if (methodNode.throws) {
    //            for (i = 0, len = methodNode.throws.length; i < len; i++) {
    //                var _throwNode = methodNode.throws[i];
    //                var _throwPending = {
    //                    operation: _operation,
    //                    node: _throwNode,
    //                    compilationUnitNode: methodNode.compilationUnitNode
    //                };
    //                this._throwPendings.push(_throwPending);
    //            }
    //        }

    // CppDoc
    //        if (methodNode.comment) {
    //            _operation.documentation = methodNode.comment;
    //        }

    // "default" for Annotation Type Element
    //        if (methodNode.defaultValue) {
    //            this._addTag(_operation, type.Tag.TK_STRING, "default", methodNode.defaultValue);
    //        }

    // Translate Type Parameters
    //        this.translateTypeParameters(options, _operation, methodNode.typeParameters);
  }

  /**
   * Translate Method Parameters
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Object} parameterNode
   */
  translateParameter (options, namespace, parameterNode) {
    var _parameter = new type.UMLParameter()
    _parameter._parent = namespace
    _parameter.name = parameterNode.name
    namespace.parameters.push(_parameter)

    // Add to _typedFeaturePendings
    this._typedFeaturePendings.push({
      namespace: namespace._parent,
      feature: _parameter,
      node: parameterNode
    })
  }

  /**
   * Translate C++ Field Node as UMLAttribute.
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Object} fieldNode
   */
  translateFieldAsAttribute (options, namespace, fieldNode) {
    var i, len
    if (fieldNode.name && fieldNode.name.length > 0) {
      for (i = 0, len = fieldNode.name.length; i < len; i++) {
        var variableNode = fieldNode.name[i]

        // Create Attribute
        var _attribute = new type.UMLAttribute()
        _attribute._parent = namespace
        _attribute.name = variableNode.name

        // Access Modifiers
        _attribute.visibility = this._getVisibility(fieldNode.modifiers)
        if (variableNode.initialize) {
          _attribute.defaultValue = variableNode.initialize
        }

        // Static Modifier
        if (fieldNode.modifiers && fieldNode.modifiers.includes('static')) {
          _attribute.isStatic = true
        }

        // Final Modifier

        // Volatile Modifier
        if (fieldNode.modifiers && fieldNode.modifiers.includes('volatile')) {
          this._addTag(_attribute, type.Tag.TK_BOOLEAN, 'volatile', true)
        }

        // CppDoc
        //                if (fieldNode.comment) {
        //                    _attribute.documentation = fieldNode.comment;
        //                }

        namespace.attributes.push(_attribute)

        // Add to _typedFeaturePendings
        var _typedFeature = {
          namespace: namespace,
          feature: _attribute,
          node: fieldNode
        }
        this._typedFeaturePendings.push(_typedFeature)
      }
    }
  }

  /**
   * Add a Tag
   * @param {type.Model} elem
   * @param {string} kind Kind of Tag
   * @param {string} name
   * @param {?} value Value of Tag
   */
  _addTag (elem, kind, name, value) {
    var tag = new type.Tag()
    tag._parent = elem
    tag.name = name
    tag.kind = kind
    switch (kind) {
    case type.Tag.TK_STRING:
      tag.value = value
      break
    case type.Tag.TK_BOOLEAN:
      tag.checked = value
      break
    case type.Tag.TK_NUMBER:
      tag.number = value
      break
    case type.Tag.TK_REFERENCE:
      tag.reference = value
      break
    case type.Tag.TK_HIDDEN:
      tag.value = value
      break
    }
    elem.tags.push(tag)
  }

  /**
   * Translate C++ Field Node as UMLAssociation.
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Object} fieldNode
   */
  translateFieldAsAssociation (options, namespace, fieldNode) {
    if (fieldNode.name && fieldNode.name.length > 0) {
      // Add to _associationPendings
      var _associationPending = {
        classifier: namespace,
        node: fieldNode
      }
      this._associationPendings.push(_associationPending)
    }
  }

  /**
   * Return visiblity from modifiers
   *
   * @param {Array.<string>} modifiers
   * @return {string} Visibility constants for UML Elements
   */
  _getVisibility (modifiers) {
    modifiers = modifiers || []
    if (modifiers.includes('public')) {
      return type.UMLModelElement.VK_PUBLIC
    } else if (modifiers.includes('protected')) {
      return type.UMLModelElement.VK_PROTECTED
    } else if (modifiers.includes('private')) {
      return type.UMLModelElement.VK_PRIVATE
    }
    return type.UMLModelElement.VK_PACKAGE
  }

  /**
   * Translate C++ Package Node.
   * @param {Object} options
   * @param {type.Model} namespace
   * @param {Object} compilationUnitNode
   */
  translatePackage (options, namespace, packageNode) {
    if (packageNode && packageNode.name) {
      var packageName = packageNode.name
      return this._ensurePackage(namespace, packageName)
    }
    return null
  }

  /**
   * Return the package of a given packageName. If not exists, create the package.
   * @param {type.Model} namespace
   * @param {Array.<string>} packageName
   * @return {type.Model} Package element corresponding to the packageName
   */
  _ensurePackage (namespace, packageName) {
    if (packageName.length > 0) {
      var name = packageName
      if (name && name.length > 0) {
        var elem = namespace.findByName(name)
        if (elem !== null) {
          // Package exists
          return elem
        } else {
          // Package not exists, then create one.
          var _package = new type.UMLPackage()
          namespace.ownedElements.push(_package)
          _package._parent = namespace
          _package.name = name
          return _package
        }
      }
    } else {
      return namespace
    }
  }

  /**
   * Perform First Phase
   *   - Create Packages, Classes, Interfaces, Enums, AnnotationTypes.
   *
   * @param {Object} options
   * @return {$.Promise}
   */
  performFirstPhase (options) {
    this._files.forEach(file => {
      var data = fs.readFileSync(file, 'utf8')
      try {
        var ast = parser.parse(data)
        var results = []
        for (var property in ast) {
          var value = ast[property]
          if (value) {
            results.push(property.toString() + ': ' + value)
          }
        }
        this._currentCompilationUnit = ast
        this._currentCompilationUnit.file = file
        this.translateCompilationUnit(options, this._root, ast)
      } catch (ex) {
        console.error('[C++] Failed to parse - ' + file)
        console.error(ex)
      }
    })
  }
}

/**
 * Analyze all C++ files in basePath
 * @param {string} basePath
 * @param {Object} options
 */
function analyze (basePath, options) {
  var cppAnalyzer = new CppCodeAnalyzer()

  function visit (base) {
    var stat = fs.lstatSync(base)
    if (stat.isFile()) {
      var ext = path.extname(base).toLowerCase()
      if (ext === '.cpp' || ext === '.h') {
        cppAnalyzer.addFile(base)
      }
    } else if (stat.isDirectory()) {
      var files = fs.readdirSync(base)
      if (files && files.length > 0) {
        files.forEach(entry => {
          var fullPath = path.join(base, entry)
          visit(fullPath)
        })
      }
    }
  }

  // Traverse all file entries
  visit(basePath)

  // Perform reverse engineering
  cppAnalyzer.analyze(options)
}

exports.analyze = analyze

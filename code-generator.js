
const _CPP_CODE_GEN_H = 'h'
const _CPP_CODE_GEN_CPP = 'cpp'

const path = require('path')
const fs = require('fs')
const codegen = require('./codegen-utils')

var copyrightHeader = '/* Test header @ toori67 \n * This is Test\n * also test\n * also test again\n */'
var versionString = 'v0.0.1'

const _CPP_DEFAULT_TYPE = [
  'void',
  'bool',
  'char',
  'short',
  'int',
  'long',
  'float',
  'double',
  'sbyte',
  'decimal',
  'auto',

  'uchar',
  'ushort',
  'uint',
  'ulong',
  'ufloat',
  'udouble',

  'short int',
  'long int',
  'long long',
  'long double',

  'signed int',
  'signed char',
  'signed long',
  'signed float',
  'signed short',
  'signed short int',
  'signed long int',
  'signed long long',
  'signed',

  'unsigned',
  'unsigned int',
  'unsigned char',
  'unsigned long',
  'unsigned float',
  'unsigned double',
  'unsigned short',
  'unsigned short int',
  'unsigned long int',
  'unsigned long long',

  // Qt typedef
  'qint8',
  'qint16',
  'qint32',
  'qint64',
  'qintptr',
  'qlonglong',

  'quint8',
  'quint16',
  'quint32',
  'quint64',
  'quintptr',
  'qulonglong',

  'qreal',
  'qptrdiff'
]

/**
 * Change first character to upper case
 * 
 * @param {string} name
 */
function firstUpperCase (name) {
  if (name.length > 0) {
    return name[0].toUpperCase() + name.substr(1, name.length - 1)
  }
  return ''
}

/**
 * verif if elem is a great package
 * @param {Object} elem 
 * @return {boolean}
 */
function isGreatUMLPackage(elem) {
  return (elem instanceof type.UMLPackage && !(elem instanceof type.UMLModel) && !(elem instanceof type.UMLProfile))
}

/**
 * get all super class / interface from element
 *
 * @param {Object} elem
 * @return {Object} list
 */
function getSuperClasses (elem) {
  var generalizations = app.repository.getRelationshipsOf(elem, function (rel) {
    return ((rel instanceof type.UMLGeneralization || rel instanceof type.UMLInterfaceRealization) && rel.source === elem)
  })

  return generalizations
}

/**
 * verif if elem (or one of inherited classes) has a Signal or Reception
 * @param {UMLClassifier} elem 
 */
function hasAsyncMethod(elem) {
  if (!(elem instanceof type.UMLClassifier)) {
    return false
  }
  // only on Qt framework
  if (elem instanceof type.UMLPrimitiveType && elem.name == 'QObject') {
    return true
  }
  if (elem.receptions.length) {
    return true
  }

  var i

  for (i = 0; i < elem.ownedElements.length; i++) {
    var element = elem.ownedElements[i]
    if (element instanceof type.UMLSignal) {
      return true
    }
  }

  var superClasses = getSuperClasses(elem)
  for (i = 0; i < superClasses.length; i++) {
    if (hasAsyncMethod(superClasses[i].target)) {
      return true
    }
  }

  return false
}

/**
 * Check if attr has accessors method
 * @param {Object} attr 
 * @return {Integer} 0: noAccessor | 1: getter | 2: setter | 3: all
 */
function accessorMethodIndex(attr) {
  var hasGetter = false
  var hasSetter = false

  if (attr instanceof type.UMLParameter) {
    return 0
  }

  const parent = attr instanceof type.UMLAssociationEnd ? getOppositeElem(attr).reference : attr._parent
  const attrType = attr instanceof type.UMLAssociationEnd ? attr.reference : attr.type
  
  for (var i = 0; i < parent.operations.length; i++) {
    const currentOp = parent.operations[i]

    if (currentOp.name === ('set' + firstUpperCase(attr.name)) ||
        currentOp.name === attr.name) {
      
      if (currentOp.parameters.length === 1 && currentOp.parameters[0].type === attrType) {
        if (currentOp.parameters[0].direction === type.UMLParameter.DK_RETURN) {
          hasGetter = true
        } else {
          hasSetter = true
        }
      }
    }

    if (hasGetter && hasSetter) {
      return 3
    }
  }

  return hasGetter ? 1 : hasSetter ? 2 : 0
}


/**
 * return an elem if it is instance of association end
 * @param {associationEnd} elem
 * @return {associationEnd}
 */
function getOppositeElem(elem) {  
  var associations = app.repository.getRelationshipsOf(elem.reference, function (rel) {
    return (rel instanceof type.UMLAssociation)
  })

  for (var i = 0; i < associations.length; i++) {
    var asso = associations[i]

    if (asso.end1 === elem) {
      return asso.end2
    } else if (asso.end2 === elem) {
      return asso.end1
    }
  }

  return null
}

/**
 * check the relation of source with target
 * @param {Object} source reference of an elem
 * @param {Object} target reference of an elem
 * @return {Boolean}
 */
function hasAssociation(source, target) {  
  var associations = app.repository.getRelationshipsOf(source, function (rel) {
    return (rel instanceof type.UMLAssociation)
  })

  for (var i = 0; i < associations.length; i++) {
    var asso = associations[i]

    if ((asso.end1.reference === source && asso.end2.reference === target) ||
        (asso.end2.reference === source && asso.end1.reference === target)) {
      return true
    }
  }

  return false
}

/**
 * Check if elem is a pointer attribute
 * @param {Attribute} elem 
 * @param {Object} cppCodeGen just to get the options.useVector
 * @param {Boolean} ignoreMultiplicity usefull for getType operation
 * @return {Boolean}
 */
function likePointer (elem, cppCodeGen, ignoreMultiplicity = false) {
  // stereotype 'pointer'
  if ((elem.stereotype instanceof type.UMLModelElement ? elem.stereotype.name : elem.stereotype) === 'pointer') {
    return true
  }

  // multiplicity '0..1' or array (with no vector as type)
  if (!ignoreMultiplicity) {
    if (['0..*', '1..*', '*'].includes(elem.multiplicity.trim())) {
      if (!cppCodeGen.genOptions.useVector) {
        return true
      }
    } else if (elem.multiplicity === '0..1') {
      return true
    }
  }

  // opposite elem aggregation 'none' and 'shared'
  if (elem instanceof type.UMLAssociationEnd) {
    return getOppositeElem(elem).aggregation !== type.UMLAttribute.AK_COMPOSITE
  }

  // direction 'inout' || static array return value
  else if (elem instanceof type.UMLParameter) {
    return elem.direction === type.UMLParameter.DK_INOUT ||
          (!ignoreMultiplicity && elem.multiplicity !== '1' && elem.multiplicity.match(/^\d+$/) && elem.direction === type.UMLParameter.DK_RETURN)
  }

  // elem aggregation 'shared'
  return elem.aggregation === type.UMLAttribute.AK_SHARED
}

/**
 * Useful to improve the code
 * @param {UMLClass} elem
 * @param {Array<Attribute>} memberAttrs
 * @param {Object} cppCodeGen
 */
function generateNecessaryOperations (elem, memberAttrs, cppCodeGen) {

  // only UMLClass can be continued
  if (!(elem instanceof type.UMLClass)) {
    return
  }

  /**
   * Check the custom constructor of the elem
   * @param {Object} elem 
   */
  var parentHaveCustomConstructor = (elem) => {
    var parents = getSuperClasses(elem)

    for (var i = 0; i < parents.length; i++) {
      const currentParent = parents[i].target

      // find custom constructor
      for (var j = 0; j < currentParent.operations.length; j++) {
        const currentOp = currentParent.operations[j]
    
        // for public visibility
        if (currentOp.visibility === type.UMLModelElement.VK_PRIVATE) {
          continue
        }
    
        if (currentOp.name === currentParent.name && // this is the constructor
            currentOp.parameters.length > 0 && // not the default constructor
            currentOp.parameters[0].type !== currentParent) { // not the copy constructor
          return true // then, this is a custom constructor
        }
      }
    }

    return false
  }

  var i
  var _constructor, _destructor
  var _operator, _param
  
  var hasDefaultConstructor = false, hasCopyConstructor = false
  var hasDestructor = false

  var hasEqualOp = false, hasDiffOp = false
  var hasAssignOp = false
  
  // parse member attributes
  var hasDynamicAttr = false
  var needConstructor = false

  for (i = 0; i < memberAttrs.length; i++) {
    currentAttr = memberAttrs[i]
    // find dynamic attribute
    if (likePointer(currentAttr, cppCodeGen)) {
      hasDynamicAttr = true
    }
    // readOnly attribute must be setted in the constructor
    if (currentAttr.isReadOnly) {
      needConstructor = true
    }
  }

  if (!needConstructor) {
    needConstructor = parentHaveCustomConstructor(elem)
  }
  
  // check existence of operation to generate
  for (i = 0; i < elem.operations.length; i++) {
    const currentOp = elem.operations[i]
    const paramNb = currentOp.parameters.length

    if (currentOp.name === elem.name) {
      // for default constructor
      if (!paramNb) {
        hasDefaultConstructor = true
      }
      
      else if (paramNb > 0) {
        const firstParam = currentOp.parameters[0]
        // for copy constructor
        if (paramNb === 1 &&
            firstParam.type === elem &&
            firstParam.direction === type.UMLParameter.DK_OUT) {
          hasCopyConstructor = true
        }
        // ignore default constructor if one constructor is defined with default value on first param
        else if (firstParam.defaultValue.length > 0) {
          needConstructor = false
        }
      }
    }

    // for assignment operator
    else if (currentOp.name === 'operator=' &&
            currentOp.parameters.length >= 1 && currentOp.parameters[0].type === elem) {
      hasAssignOp = true
    }

    // for destructor
    else if (currentOp.name === ('~' + elem.name) && !currentOp.parameters.length) {
      hasDestructor = true
    }

    // for comparison operators
    else if (currentOp.name === 'operator==') {
			hasEqualOp = true
		} else if (currentOp.name === 'operator!=') {
			hasDiffOp = true
		}
  }

  // generating ...
	var builder = app.repository.getOperationBuilder()
	builder.begin('generate additional method')

	if (!hasDefaultConstructor && needConstructor) {
		_constructor = new type.UMLOperation()
		_constructor.name = elem.name
		_constructor.visibility = type.UMLModelElement.VK_PUBLIC
		_constructor._parent = elem

		builder.insert(_constructor)
    builder.fieldInsert(elem, 'operations', _constructor)
    
    hasDefaultConstructor = true
    needConstructor = false
	}
  
  if (memberAttrs.length) {
	
    if (hasDynamicAttr) {
      // don't generate copy constructor and assign operator in QObject child class
      if (!((cppCodeGen.genOptions.useQt && cppCodeGen.haveSR) || elem.isAbstract)) {
        if (!hasCopyConstructor) {
          _constructor = new type.UMLOperation()
          _constructor.name = elem.name
          _constructor.visibility = type.UMLModelElement.VK_PUBLIC
          _constructor._parent = elem
          
          _param = new type.UMLParameter()
          _param.name = 'other'
          _param.direction = type.UMLParameter.DK_OUT
          _param.type = elem
          _param.isReadOnly = true
          _param._parent = _constructor
          _constructor.parameters.push(_param)
      
          builder.insert(_constructor)
          builder.fieldInsert(elem, 'operations', _constructor)

          hasCopyConstructor = true
        }
          
        if (!hasAssignOp) {
          _operator = new type.UMLOperation()
          _operator.name = 'operator='
          _operator.visibility = type.UMLModelElement.VK_PUBLIC
          _operator._parent = elem

          // return
          _param = new type.UMLParameter()
          _param.visibility = type.UMLModelElement.VK_PUBLIC
          _param.type = elem
          _param.direction = type.UMLParameter.DK_RETURN
          _param.stereotype = 'reference'
          _param._parent = _operator
          _operator.parameters.push(_param)

          // other
          _param = new type.UMLParameter()
          _param.name = 'other'
          _param.visibility = type.UMLModelElement.VK_PUBLIC
          _param.type = elem
          _param.isReadOnly = true
          _param.direction = type.UMLParameter.DK_OUT
          _param._parent = _operator
          _operator.parameters.push(_param)

          builder.insert(_operator)
          builder.fieldInsert(elem, 'operations', _operator)

          hasAssignOp = true
        }
      }

      if (!hasDestructor) {
        _destructor = new type.UMLOperation()
        _destructor.name = '~' + elem.name
        _destructor.visibility = type.UMLModelElement.VK_PUBLIC
        _destructor._parent = elem

        builder.insert(_destructor)
        builder.fieldInsert(elem, 'operations', _destructor)

        hasDestructor = true
      }
    }

    if (!elem.isAbstract) {

      if (!hasEqualOp) {
        _operator = new type.UMLOperation()
        _operator.name = 'operator=='
        _operator.visibility = type.UMLModelElement.VK_PUBLIC
        _operator.stereotype = 'readOnly'
        _operator._parent = elem

        // return
        _param = new type.UMLParameter()
        _param.visibility = type.UMLModelElement.VK_PUBLIC
        _param.type = 'bool'
        _param.direction = type.UMLParameter.DK_RETURN
        _param._parent = _operator
        _operator.parameters.push(_param)

        // other
        _param = new type.UMLParameter()
        _param.name = 'other'
        _param.visibility = type.UMLModelElement.VK_PUBLIC
        _param.type = elem
        _param.isReadOnly = true
        _param.direction = type.UMLParameter.DK_OUT
        _param._parent = _operator
        _operator.parameters.push(_param)

        builder.insert(_operator)
        builder.fieldInsert(elem, 'operations', _operator)

        hasEqualOp = true
      }

      if (!hasDiffOp) {
        _operator = new type.UMLOperation()
        _operator.name = 'operator!='
        _operator.visibility = type.UMLModelElement.VK_PUBLIC
        _operator.stereotype = 'readOnly'
        _operator._parent = elem

        // return
        _param = new type.UMLParameter()
        _param.visibility = type.UMLModelElement.VK_PUBLIC
        _param.type = 'bool'
        _param.direction = type.UMLParameter.DK_RETURN
        _param._parent = _operator
        _operator.parameters.push(_param)

        // other
        _param = new type.UMLParameter()
        _param.name = 'other'
        _param.visibility = type.UMLModelElement.VK_PUBLIC
        _param.type = elem
        _param.isReadOnly = true
        _param.direction = type.UMLParameter.DK_OUT
        _param._parent = _operator
        _operator.parameters.push(_param)

        builder.insert(_operator)
        builder.fieldInsert(elem, 'operations', _operator)

        hasDiffOp = true
      }
    }
  }

	builder.end()
	var cmd = builder.getOperation()
	app.repository.doOperation(cmd)
}

/**
 * Object to store any content refer to a key
 */
class KeyContent {
  /**
   * @constructor
   */
  constructor() {
    /** @member {string} Operation._id */
    this.Key = ''
    /** @member {string} Operation._content */
    this.Content = ''
  }
}

/**
* Cpp Code Generator
*/
class CppCodeGenerator {
  /**
   * @constructor
   *
   * @param {type.UMLPackage} baseModel
   * @param {string} logPath StarUML log file path
   *
   */
  constructor (baseModel, logPath) {
    /** @member {type.Model} */
    this.baseModel = baseModel

    /** @member {String} */
    this.logPath = logPath

    /** @member {Array.<KeyContent>} */
    this.FilePathLogs = []
    

    if (this.getFilePathLogs(logPath)) {
      fs.unlinkSync(logPath)
    }
  
    var doc = ''
    // if (app.project.getProject().name && app.project.getProject().name.length > 0) {
    //   doc += '\nProject ' + app.project.getProject().name
    // }
    // if (app.project.getProject().company && app.project.getProject().company.length > 0) {
    //   doc += '\nCompany ' + app.project.getProject().company
    // }
    if (app.project.getProject().author && app.project.getProject().author.length > 0) {
      doc += '\n@author ' + app.project.getProject().author
    }
    if (app.project.getProject().version && app.project.getProject().version.length > 0) {
      doc += '\n@version ' + app.project.getProject().version
    }
    
    copyrightHeader = this.getDocuments(doc)
  }

  /**
   * Get an array of path on the last generation
   * 
   * @param {String} logPath 
   * @return {Boolean} status
   */
  getFilePathLogs (logPath) {
    var data
    try {
      fs.accessSync(logPath, fs.constants.F_OK | fs.constants.R_OK)
      data = fs.readFileSync(logPath, 'utf8')
    } catch (err) {
      app.toast.error('Project file config : ' + err)
      data = ''
    }

    if (!data.length) {
      return false
    }

    // transform this data to row array
    var rows = data.split('\n')
    var cell = []

    for (var i = 0; i < rows.length; i++) {
      // continue if no information
      if (rows[i].length === 0) {
        continue
      }
      cell = rows[i].split(' => ')
      // catch the begin index
      if (cell.length !== 2) {
        continue
      }
      var filePath = new KeyContent()

      filePath.Key = cell[0]
      filePath.Content = cell[1]
      
      this.FilePathLogs.push(filePath)
    }

    return true
  }

  /**
   * Get the elem file path
   * 
   * @param {type.UMLModelElement} elem 
   * @return {String} file path within extension
   */
  getElemFilePath (elem) {
    if (this.FilePathLogs.length > 0) {
      for (var i = 0; i < this.FilePathLogs.length; i++) {
        var keyContent = this.FilePathLogs[i]

        if (keyContent.Key === elem._id) {
          return keyContent.Content
        }
      }
    }

    return null
  }

  /**
  * Return Indent String based on options
  * @param {Object} options
  * @return {string}
  */
  getIndentString (options) {
    if (options.useTab) {
      return '\t'
    } else {
      var i, len
      var indent = []
      for (i = 0, len = options.indentSpaces; i < len; i++) {
        indent.push(' ')
      }
      return indent.join('')
    }
  }

  generate (elem, basePath, options) {
    this.elemToGenerate = elem
    this.genOptions = options
    this.haveSR = false // Signal and/or Reception found in the class elem
    this.opImplSaved = [] // Custom operations by Developper
    this.needComment = true // Explanation of saving Operation body

    this.toDeclared = []
    this.toIncluded = []
    this.notRecType = []

    var getFilePath = (extenstions) => {
      var absPath = basePath + '/' + elem.name + '.'
      if (extenstions === _CPP_CODE_GEN_H) {
        absPath += _CPP_CODE_GEN_H
      } else {
        absPath += _CPP_CODE_GEN_CPP
      }
      return absPath
    }

    var writeSignal = (codeWriter, elem, cppCodeGen) => {
      var identifier = ''
      var signalName = elem.name

      if (cppCodeGen.genOptions.useQt) {
        identifier = 'Q_SIGNAL '
      } else { // using function pointer
        signalName = '(*' + signalName + ')'
      }

      var i
      var modifierList = cppCodeGen.getModifiers(elem)
      var modifierStr = ''

      for (i = 0; i < modifierList.length; i++) {
        modifierStr += modifierList[i] + ' '
      }

      var params = []
      for (i = 0; i < elem.attributes.length; i++) {
        var att = elem.attributes[i]
        params.push(cppCodeGen.getVariableDeclaration(att, true))
      }
      // doc
      var docs = cppCodeGen.getDocuments(elem.documentation)

      codeWriter.writeLine(docs + identifier + modifierStr + 'void ' + signalName + '(' + params.join(', ') + ');')
    }

    var writeEnumeration = (codeWriter, elem, cppCodeGen) => {
      var i
      var modifierList = cppCodeGen.getModifiers(elem)
      var idL = cppCodeGen.getIndentString(cppCodeGen.genOptions)
      var modifierStr = ''
      for (i = 0; i < modifierList.length; i++) {
        modifierStr += modifierList[i] + ' '
      }
      // doc
      var docs = cppCodeGen.getDocuments(elem.documentation)

      codeWriter.writeLine(docs + modifierStr + 'enum ' + elem.name + ' {\n' +
        idL  + elem.literals.map(lit => lit.name + (lit.documentation.length ? ' /*!< ' + lit.documentation + ' */' : '')).join(',\n' + idL) +
        '\n};')
      
      if (cppCodeGen.genOptions.useQt) {
        if (elem._parent instanceof type.UMLClass || elem._parent instanceof type.UMLInterface) {
          codeWriter.writeLine('Q_ENUM(' + elem.name + ')')
        } else {
          codeWriter.writeLine('Q_DECLARE_METATYPE(' + cppCodeGen.getContainersSpecifierStr(elem) + elem.name + ')')
        }
      }
    }

    var writeClassHeader = (codeWriter, elem, cppCodeGen) => {
      var i
      var write = (items) => {
        var i
        for (i = 0; i < items.length; i++) {
          var item = items[i]
          if (item instanceof type.UMLAttribute || item instanceof type.UMLAssociationEnd) { // if write member variable
            codeWriter.writeLine(cppCodeGen.getMemberVariable(item))
          } else if (item instanceof type.UMLOperation) { // if write method
            codeWriter.writeLine(cppCodeGen.getMethod(item, false))
          } else if (item instanceof type.UMLReception) {
            codeWriter.writeLine(cppCodeGen.getSlot(item, false))
          } else if (item instanceof type.UMLClass) {
            writeClassHeader(codeWriter, item, cppCodeGen)
          } else if (item instanceof type.UMLEnumeration) {
            writeEnumeration(codeWriter, item, cppCodeGen)
          } else if (item instanceof type.UMLSignal) {
            writeSignal(codeWriter, item, cppCodeGen)
          }
        }
      }

      var writeInheritance = (elem) => {
        var genList = getSuperClasses(elem)
        var i
        var term = []

        // arrange item that QtObject subclass be the first item in the list
        if (genList.length > 1) {
          // find the first QtObject subclass item
          var index = -1
          for (var i = 0; i < genList.length; i++) {
            var currentItem = genList[i].target
            if (hasAsyncMethod(currentItem) || (currentItem.name === 'QObject' && currentItem instanceof type.UMLPrimitiveType)) {
              index = i
              break
            }
          }

          if (index > 0) {
            var items = genList.splice(index, 1)
            genList.unshift(items[0])
          }
        }


        for (i = 0; i < genList.length; i++) {
          var generalization = genList[i]
          // public AAA, private BBB
          term.push(generalization.visibility + ' ' + cppCodeGen.getNamespacesSpecifierStr(generalization.target) + generalization.target.name)
          cppCodeGen.parseElemType(generalization.target, false)
        }

        if (!term.length) {
          // force QObject inheritance if Qt is used and have Signal & Reception
          if (cppCodeGen.haveSR && cppCodeGen.genOptions.useQt) {
            return ' : public QObject'
          }
          return ''
        }

        return  ' : ' + term.join(', ')
      }

      var writeProperties = (codeWriter , elem, memberAttr, cppCodeGen) => {
        /**
         * Check if currentOperation is a setter method
         * @param {UMLOperation} currentOperation 
         */
        var isSetterMethod = (currentOperation) => {
          if (currentOperation.parameters.length > 2) {
            return false
          }

          var innerParams = currentOperation.parameters.filter(function (params) {
            return (params.direction === 'in' || params.direction === 'inout' || params.direction === 'out')
          })

          if (innerParams.length !== 1) {
            return false
          }

          return true
        }

        /**
         * Check if elem could be used as property (Use this only with Qt framework)
         * @param {Object} elem 
         */
        var likeProperty = (elem) => {
          if (elem.isStatic) {
            return false;
          }

          const _accessorMethodIndex = accessorMethodIndex(elem)

          // QtObject with type as non pointer is not used as property
          // because it disable assignement operator and copy constructor
          return (!(hasAsyncMethod(elem.reference) && !likePointer(elem, cppCodeGen)) ||
                    (_accessorMethodIndex === 1 || _accessorMethodIndex === 3) /* variable having atleast a getterMethod is considered as property*/)
        }

        var attrs = cppCodeGen.classifyVisibility(memberAttr)
        // generate only a valid property
        var securedAttributes = attrs._protected.concat(attrs._private).filter(function(attr) {
          return likeProperty(attr)
        })

        for (var c = 0; c < securedAttributes.length; c++) {
          var attr = securedAttributes[c]
          var i
          
          // For the moment, ignore an array, but you must fix it with property list (QQmlListProperty)
          if (!['1', '0..1', ''].includes(attr.multiplicity)) { continue }

          // for variable
          var variableStr = cppCodeGen.getType(attr, false) + ' ' + attr.name
          
          // for member
          const memberStr = ' MEMBER m_' + attr.name
          
          // for getter & setter
          var getterStr = '', hasGetter = false
          var setterStr = '', hasSetter = false
          const setterOp = 'set' + firstUpperCase(attr.name)
          for (i = 0; i < elem.operations.length; i++) {
            const op = elem.operations[i]
            // find getter
            if (op.name === attr.name && op.visibility === type.UMLModelElement.VK_PUBLIC && op.parameters.length === 1) {
              getterStr = ' READ ' + op.name
              hasGetter =true
            }
            // find setter
            if (op.name === setterOp && op.visibility === type.UMLModelElement.VK_PUBLIC && isSetterMethod(op)) {
              setterStr = ' WRITE ' + op.name
              hasSetter = true
            }
            // all accessor found
            if (hasGetter && hasSetter) {
              break
            }
          }
          
          // ignore a statement like this "Q_PROPERTY(std::unique_ptr<type> propertyName MEMBER attrName)"
          if (cppCodeGen.genOptions.useSmartPtr && attr.multiplicity === '0..1' && !hasGetter) { continue }

          // for signal
          var signalStr = ''
          const signalRef = attr.name + 'Changed'
          for (i = 0; i < elem.ownedElements.length; i++) {
            const currentElem = elem.ownedElements[i]
            if (currentElem instanceof type.UMLSignal && currentElem.name === signalRef) {
              signalStr = ' NOTIFY ' + signalRef
              break
            }
          }
          
          // writing property
          codeWriter.writeLine('Q_PROPERTY(' + variableStr + (hasGetter ? getterStr : memberStr) + ((!elem.isReadOnly && hasSetter) ? (setterStr + signalStr) : '') + ')')
        }
      }

      // member variable
      var memberAttr = elem.attributes.slice(0)
      var associations = app.repository.getRelationshipsOf(elem, function (rel) {
        return (rel instanceof type.UMLAssociation)
      })
      for (i = 0; i < associations.length; i++) {
        var asso = associations[i]
        if (asso.end1.reference === elem && asso.end2.navigable === true && asso.end2.name.length !== 0) {
          memberAttr.push(asso.end2)
        } else if (asso.end2.reference === elem && asso.end1.navigable === true && asso.end1.name.length !== 0) {
          memberAttr.push(asso.end1)
        }
      }
      // it's time to fill the elem with all necessaries operations
      if (cppCodeGen.genOptions.implementation) {
        generateNecessaryOperations(elem, memberAttr, cppCodeGen)
      }

      // method
      var methodList = elem.operations.slice(0)
      var innerElement = []
      for (i = 0; i < elem.ownedElements.length; i++) {
        var element = elem.ownedElements[i]
        if (element instanceof type.UMLClass || element instanceof type.UMLEnumeration || element instanceof type.UMLSignal) {
          innerElement.push(element)
        }
      }

      var receptionList = elem.receptions.slice(0)
      var allMembers = innerElement.concat(memberAttr).concat(methodList).concat(receptionList)

      var classfiedAttributes = cppCodeGen.classifyVisibility(allMembers)
      var finalModifier = ''
      if (elem.isFinalSpecialization === true || elem.isLeaf === true) {
        finalModifier = ' final '
      }
      // doc
      var docs = cppCodeGen.getDocuments(elem.documentation)
      if (docs.length > 0) {
          codeWriter.writeLine(docs)
      }

      var templatePart = cppCodeGen.getTemplateParameter(elem)
      if (templatePart.length > 0) {
        codeWriter.writeLine(templatePart)
      }

      codeWriter.writeLine('class ' + elem.name + finalModifier + writeInheritance(elem) + '\n{')
      if (cppCodeGen.canHaveProperty(elem)) {
        codeWriter.indent()
        if (cppCodeGen.haveSR) {
          codeWriter.writeLine('Q_OBJECT')
        } else {
          codeWriter.writeLine('Q_GADGET')
        }
        writeProperties(codeWriter, elem, memberAttr, cppCodeGen)

        codeWriter.outdent()
      }
      if (classfiedAttributes._public.length > 0) {
        codeWriter.writeLine('public: ')
        codeWriter.indent()
        write(classfiedAttributes._public)
        codeWriter.outdent()
      }
      if (classfiedAttributes._protected.length > 0) {
        codeWriter.writeLine('protected: ')
        codeWriter.indent()
        write(classfiedAttributes._protected)
        codeWriter.outdent()
      }
      if (classfiedAttributes._private.length > 0) {
        codeWriter.writeLine('private: ')
        codeWriter.indent()
        write(classfiedAttributes._private)
        codeWriter.outdent()
      }

      codeWriter.writeLine('};')
    }

    var writeClassBody = (codeWriter, elem, cppCodeGen) => {
      var i
      var item
      var writeClassMethod = (elemList) => {
        for (i = 0; i < elemList._public.length; i++) {
          item = elemList._public[i]
          if (item instanceof type.UMLOperation) { // if write method
            codeWriter.writeLine(cppCodeGen.getMethod(item, true))
          } else if (item instanceof type.UMLReception) {
            codeWriter.writeLine(cppCodeGen.getSlot(item, true))
          } else if (item instanceof type.UMLClass) {
            writeClassBody(codeWriter, item, cppCodeGen)
          }
        }

        for (i = 0; i < elemList._protected.length; i++) {
          item = elemList._protected[i]
          if (item instanceof type.UMLOperation) { // if write method
            codeWriter.writeLine(cppCodeGen.getMethod(item, true))
          } else if (item instanceof type.UMLReception) {
            codeWriter.writeLine(cppCodeGen.getSlot(item, true))
          } else if (item instanceof type.UMLClass) {
            writeClassBody(codeWriter, item, cppCodeGen)
          }
        }

        for (i = 0; i < elemList._private.length; i++) {
          item = elemList._private[i]
          if (item instanceof type.UMLOperation) { // if write method
            codeWriter.writeLine(cppCodeGen.getMethod(item, true))
          } else if (item instanceof type.UMLReception) {
            codeWriter.writeLine(cppCodeGen.getSlot(item, true))
          } else if (item instanceof type.UMLClass) {
            writeClassBody(codeWriter, item, cppCodeGen)
          }
        }
      }

      codeWriter.writeLine('// ' + elem.name + ' implementation\n\n')

      // parsing class
      var methodList = cppCodeGen.classifyVisibility(elem.operations.slice(0))
      writeClassMethod(methodList)

      var receptionList = cppCodeGen.classifyVisibility(elem.receptions.slice(0))
      writeClassMethod(receptionList)

      // parsing nested class
      var innerClass = []
      for (i = 0; i < elem.ownedElements.length; i++) {
        var element = elem.ownedElements[i]
        if (element instanceof type.UMLClass) {
          innerClass.push(element)
        }
      }
      if (innerClass.length > 0) {
        innerClass = cppCodeGen.classifyVisibility(innerClass)
        writeClassMethod(innerClass)
      }
    }

    var fullPath, file, oldFile

    // Package -> as namespace or not
    if (elem instanceof type.UMLPackage) {
      fullPath = path.join(basePath, elem.name)
      try {
        fs.accessSync(fullPath)
      } catch (error) {
        fs.mkdirSync(fullPath) 
      }
      if (Array.isArray(elem.ownedElements)) {
        elem.ownedElements.forEach(child => {
          return this.generate(child, fullPath, options)
        })
      }
    } else if (elem instanceof type.UMLPrimitiveType) {
      // nothing to generate because the UMLPrimitiveType is taken for an element of the system
    } else {
      // for writing file
      file = getFilePath(_CPP_CODE_GEN_H)
      var data = elem._id + ' => ' + basePath + (this.genOptions.windows ? '\\' : '/') + elem.name + '\n'

      // get the old file (path) of each element
      oldFile = this.getElemFilePath(elem)
      if (oldFile !== null) {
        oldFile += '.' + _CPP_CODE_GEN_H
        try {
          fs.accessSync(oldFile, fs.constants.F_OK | fs.constants.R_OK | fs.constants.W_OK)
          this.opImplSaved = this.getAllCustomOpImpl(fs.readFileSync(oldFile, 'utf8'))
          this.needComment = false
          fs.unlinkSync(oldFile)
        } catch (err) {}
      } else {
        try {
          fs.accessSync(file, fs.constants.F_OK | fs.constants.R_OK | fs.constants.W_OK)
          this.opImplSaved = this.getAllCustomOpImpl(fs.readFileSync(file, 'utf8'))
          this.needComment = false
          fs.unlinkSync(file)
        } catch (err) {}
      }

      if (elem instanceof type.UMLClass) {
        this.haveSR = hasAsyncMethod(elem) // Signal and/or Reception found in the class elem
    
        // generate class header elem_name.h
        fs.writeFileSync(file, this.writeHeaderSkeletonCode(elem, options, writeClassHeader))
        fs.appendFileSync(this.logPath, data, 'utf8')
        
        if (options.genCpp) {
          file = getFilePath(_CPP_CODE_GEN_CPP)

          oldFile = this.getElemFilePath(elem)
          if (oldFile !== null) {
            oldFile += '.' + _CPP_CODE_GEN_CPP
            try {
              fs.accessSync(oldFile, fs.constants.F_OK | fs.constants.R_OK | fs.constants.W_OK)
              this.opImplSaved = this.getAllCustomOpImpl(fs.readFileSync(oldFile, 'utf8'))
              this.needComment = false
              fs.unlinkSync(oldFile)
            } catch (err) {}
          } else {
            try {
              fs.accessSync(file, fs.constants.F_OK | fs.constants.R_OK | fs.constants.W_OK)
              this.opImplSaved = this.getAllCustomOpImpl(fs.readFileSync(file, 'utf8'))
              this.needComment = false
              fs.unlinkSync(file)
            } catch (err) {}
          }
    
          // generate class cpp elem_name.cpp
          fs.writeFileSync(file, this.writeBodySkeletonCode(elem, options, writeClassBody))
        }
      } else if (elem instanceof type.UMLInterface) {
        this.haveSR = hasAsyncMethod(elem) // Signal and/or Reception found in the class elem
        /*
        * interface will convert to class which only contains virtual method and member variable.
        */
        // generate interface header ONLY elem_name.h
        fs.writeFileSync(file, this.writeHeaderSkeletonCode(elem, options, writeClassHeader))
        fs.appendFileSync(this.logPath, data, 'utf8')
      } else if (elem instanceof type.UMLEnumeration) {
        // generate enumeration header ONLY elem_name.h
        fs.writeFileSync(file, this.writeHeaderSkeletonCode(elem, options, writeEnumeration))
        fs.appendFileSync(this.logPath, data, 'utf8')
      // } else if (elem instanceof type.UMLSignal) {
      //   // generate signal header ONLY elem_name.h
      //   fs.writeFileSync(file, this.writeHeaderSkeletonCode(elem, options, writeSignal))
      }
    }
  }

  /**
   * parse the type of used model element (to declare or to include)
   * @param {UML.ModelElement} elemType 
   * @param {boolean} toDeclared 
   */
  parseElemType (type, toDeclared) {
    if (!type.name.length) {
      return
    }

    var elemType = type
    var anchestors = this.getAnchestorsClass(elemType)
    if (anchestors.length) {
        elemType = anchestors[0]
    }

    // if already exist
    if ((toDeclared && this.toDeclared.includes(elemType)) || this.toIncluded.includes(elemType) || elemType === this.elemToGenerate) {
        return
    }

    // remove the elem in toDeclared if the new value is toIncluded
    if (this.toDeclared.includes(elemType) && !toDeclared) {
      var i
        for (i = 0; i < this.toDeclared.length; i++) {
            if (this.toDeclared[i] === elemType) {
                break
            }
        }
        this.toDeclared.splice(i, 1)
    }

    // add the elem
    if (toDeclared) {
        this.toDeclared.push(elemType)
    } else {
        this.toIncluded.push(elemType)
    }
  }

  parseUnrecognizedType (typeExp) {
    if (!typeExp.length) {
      return
    }
    
    // if typeExp equal to an   type1<type2, type3>
    var typeNames = typeExp.split('<')

    var typeName = typeNames[0]
    if (_CPP_DEFAULT_TYPE.includes(typeName) || this.notRecType.includes(typeName)) {
      return
    }
    this.notRecType.push(typeName)
  }

  /**
   * Save all operation's body already implemented by the Developper
   * 
   * @param {string} data : the file content
   * @return {Array.<Object>}
   */
  getAllCustomOpImpl (data) {
    var operationBodies = []

    if (!data.length) {
      return operationBodies
    }
    // transform this data to row array
    var rowContents = data.split('\n')
    var cell = []
    var i

    for (i = 0; i < rowContents.length; i++) {
      // continue if no information
      if (rowContents[i].length === 0) {
        continue
      }
      cell = rowContents[i].split(' ')
      // catch the begin index
      if (cell.length < 2 || cell[0] !== '//<') {
        continue
      }
      var operationBody = new KeyContent()

      operationBody.Key = cell[1]
      
      cell = rowContents[++i].split(' ')

      while (cell[0] !== '//>' && (i < rowContents.length)) {
        // for Content integrity
        operationBody.Content += (!operationBody.Content.length ? '' : '\n') + rowContents[i]
        cell = rowContents[++i].split(' ')
      }
      operationBodies.push(operationBody)
    }

    return operationBodies
  }

  /**
   * Write all developer custom code in the file
   * 
   * @param {UMLModelElement} elem
   * @param {string} defaultContent
   * @return {string} customCode
   */
  writeCustomCode (elem, defaultContent) {
    var customCode = ''
    var _contents = ''
    // get the content of an identified operation
    if (this.opImplSaved.length > 0) {
      for (var i = 0; i < this.opImplSaved.length; i++) {
        if (elem._id === this.opImplSaved[i].Key) {
          _contents = this.opImplSaved[i].Content
          break
        }
      }
    }
    // write an operation identifier
    customCode += '\n//< ' + elem._id + '\n'

    customCode += _contents.length > 0 ? _contents : defaultContent

    customCode += '\n//>'

    return customCode
  }

  /**
   * check if the elem can use Q_PROPERTY
   * @param {UMLClass} elem
   * @return boolean
   */
  canHaveProperty (elem) {
    if (!this.genOptions.useQt) {
      return false
    }

    if (this.haveSR) {
      return true
    }

    var havePublicDefaultConstructor = false
    var havePublicCopyConstructor = false
    var havePublicDestructor = false

    for (var i = 0; i < elem.operations.length; i++) {
      const currentOp = elem.operations[i]

      // for public visibility
      if (currentOp.visibility !== type.UMLModelElement.VK_PUBLIC) {
        continue
      }

      if (currentOp.name === elem.name) {
        // for default constructor
        if (!currentOp.parameters.length) {
          havePublicDefaultConstructor = true
        }
        // for copy constructor
        else if (currentOp.parameters.length === 1) {
          const firstParam = currentOp.parameters[0]
          if (firstParam.type === elem && firstParam.direction === type.UMLParameter.DK_OUT) {
            havePublicCopyConstructor = true
          }
        }
      }

      // for destructor
      if (currentOp.name === ('~' + elem.name) && !currentOp.parameters.length) {
        havePublicDestructor = true
      }

      if (havePublicDefaultConstructor && havePublicCopyConstructor && havePublicDestructor) {
        return true
      }
    }

    return false
  }
  /**
   * Write *.h file. Implement functor to each uml type.
   * Returns text
   *
   * @param {Object} elem
   * @param {Object} options
   * @param {Object} funct
   * @return {string}
   */
  writeHeaderSkeletonCode (elem, options, funct) {
    var getIncludePart = (elem, cppCodeGen) => {
      var i
      var headerString = ''
      var memberString = ''
      var dependenciesString = ''

      // incluce the QObject item if Qt framework is checked
      if (cppCodeGen.genOptions.useQt) {
        // find if QObject is already exist
        var qobjectFound = false
        for (i = 0; i < cppCodeGen.toIncluded.length; i++) {
          if (cppCodeGen.toIncluded[i].name === 'QObject') {
            qobjectFound = true
            break
          }
        }
        for (i = 0; i < cppCodeGen.toDeclared.length; i++) {
          if (cppCodeGen.toDeclared[i].name === 'QObject') {
            cppCodeGen.toDeclared.splice(i)
            break
          }
        }
        if (!qobjectFound) {
          cppCodeGen.parseUnrecognizedType('QObject')
        }
      }

      // for comparaison
      var associationComp = []

      for (i = 0; i < cppCodeGen.notRecType.length; i++) {
        headerString += '#include <' + cppCodeGen.notRecType[i] + '>\n'
      }

      // begin check for association member variable
      for (i = 0; i < cppCodeGen.toIncluded.length; i++) {
        var target = cppCodeGen.toIncluded[i]

        const anchestors = cppCodeGen.getAnchestorsClass(target)
        if (anchestors.length) {
          target = anchestors.reverse()[0]
        }

        if (target === elem || associationComp.includes(target) || anchestors.includes(elem)) {
          continue
        }
        if (target instanceof type.UMLPrimitiveType) {
          // nothing to generate because the UMLPrimitiveType is taken for an element of the system
          headerString += '#include <' + target.name + '>\n'
        } else {
          headerString += '#include "' + cppCodeGen.trackingHeader(elem, target) + '.h"\n'
        }

        associationComp.push(target)
      }

      for (i = 0; i < cppCodeGen.toDeclared.length; i++) {
        var target = cppCodeGen.toDeclared[i]
        const anchestors = cppCodeGen.getAnchestorsClass(target)
        
        if (target === elem || associationComp.includes(target) || anchestors.includes(elem)) {
          continue
        }
        associationComp.push(target)
      }

      memberString += cppCodeGen.writeClassesDeclarations()
      // end check for association member variable

      // check for dependencies class
      var dependencies = elem.getDependencies()

      if (dependencies.length > 0) {
        for (i = 0; i < dependencies.length; i++) {
          var target = dependencies[i]
          
          const anchestors = cppCodeGen.getAnchestorsClass(target)
          if (anchestors.length) {
            target = anchestors.reverse()[0]
          }

          if (associationComp.includes(target) || !(target instanceof type.UMLClassifier) || anchestors.includes(elem)) {
            continue
          }
          if (target instanceof type.UMLPrimitiveType) {
            // nothing to generate because the UMLPrimitiveType is taken for an element of the system
            headerString += '#include <' + target.name + '>\n'
          } else {
            dependenciesString += '#include "' + cppCodeGen.trackingHeader(elem, target) + '.h"\n'
          }
		  
          associationComp.push(target)
        }
      }

      return headerString + dependenciesString + memberString
    }

    var writeHeaderNamespaces = (elem, cppCodeGen, funct) => {
      var codeWriter = new codegen.CodeWriter(cppCodeGen.getIndentString(cppCodeGen.genOptions))
      var namespaces = cppCodeGen.getNamespaces(elem)
  
      if (namespaces.length > 0) {
        namespaces.forEach(function(namespace) {
          codeWriter.writeLine('namespace ' + namespace + ' {')
        })

        codeWriter.writeLine()
        funct(codeWriter, elem, cppCodeGen)
        codeWriter.writeLine()

        namespaces.reverse()
        namespaces.forEach(function(namespace) {
          codeWriter.writeLine('} // end of namespace ' + namespace)
        })
      } else {
        funct(codeWriter, elem, cppCodeGen)
      }
      
      return codeWriter.getData()
    }

    var namespaces = this.getNamespaces(elem).join('_')
    if (namespaces.length > 0) {
      namespaces += '_'
    }
  
    var headerString = namespaces.toUpperCase() + elem.name.toUpperCase() + '_H'
    var codeWriter = new codegen.CodeWriter(this.getIndentString(options))

    codeWriter.writeLine(copyrightHeader)
    codeWriter.writeLine()
    codeWriter.writeLine('#ifndef ' + headerString)
    codeWriter.writeLine('#define ' + headerString)
    codeWriter.writeLine()

    var classDeclaration = writeHeaderNamespaces(elem, this, funct)
    var includePart = getIncludePart(elem, this)

    if (includePart.length > 0) {
        codeWriter.writeLine(includePart)
    }
    
    if (this.needComment) {
      codeWriter.writeLine('// DON\'T REMOVE ALL LINE CONTAINS "//< op._id" AND "//>"')
      codeWriter.writeLine('// THEY HELP YOU TO SAVE ALL CHANGE IN THE CURRENT OPERATION FOR THE NEXT CODE GENERATION')
      codeWriter.writeLine()
    }

    codeWriter.writeLine(this.writeCustomCode(elem, ''))
    codeWriter.writeLine()

    codeWriter.writeLine(classDeclaration)

    codeWriter.writeLine()
    codeWriter.writeLine('#endif // ' + headerString)

    return codeWriter.getData()
  }

  /**
   * Write *.cpp file. Implement functor to each uml type.
   * Returns text
   *
   * @param {Object} elem
   * @param {Object} options
   * @param {Object} functor
   * @return {Object} string
   */
  writeBodySkeletonCode (elem, options, funct) {
    var codeWriter = new codegen.CodeWriter(this.getIndentString(options))
    codeWriter.writeLine(copyrightHeader)
    codeWriter.writeLine()
    codeWriter.writeLine('#include "' + elem.name + '.h"')
    codeWriter.writeLine()

    for (var i = 0; i < this.toDeclared.length; i++) {
      var target = this.toDeclared[i]
      if (target === elem) {
          continue
      }
      if (target instanceof type.UMLPrimitiveType) {
        // nothing to generate because the UMLPrimitiveType is taken for an element of the system
        codeWriter.writeLine('#include <' + target.name + '>')
      } else {
        codeWriter.writeLine('#include "' + this.trackingHeader(elem, target) + '.h"')
      }
    }
    codeWriter.writeLine()

    if (this.needComment) {
        codeWriter.writeLine('// DON\'T REMOVE ALL LINE CONTAINS "//< op._id" AND "//>"')
        codeWriter.writeLine('// THEY HELP YOU TO SAVE ALL CHANGE IN THE CURRENT OPERATION FOR THE NEXT CODE GENERATION')
        codeWriter.writeLine()
    }

    codeWriter.writeLine(this.writeCustomCode(elem, ''))
    codeWriter.writeLine()

    funct(codeWriter, elem, this)
    return codeWriter.getData()
  }

  /**
   * get string list of namespace element
   *
   * @param {Object} elem
   * @return {Array <String>}
   */
  getNamespaces (elem) {
    var namespaces = []
    var parentElem = elem._parent

    while (parentElem) {
      if (isGreatUMLPackage(parentElem)) {
        namespaces.push(parentElem.name)
      }
      parentElem = parentElem._parent
    }

    if (namespaces.length > 1) {
      namespaces.reverse()
    }
  
    return namespaces
  }

  /**
   * get all parents of the elem (package only)
   * @param {Object} elem 
   * @param {Boolean} absolute
   * @return {String}
   */
  getNamespacesSpecifierStr (elem, absolute = false) {
    var namespaces = this.getNamespaces(elem)
    var namespacesStr =  namespaces.join('::')
    
    namespacesStr += (namespacesStr.length && !absolute) ? '::' : ''

    return namespacesStr
  }

  /**
   * get all parents of the elem (class only)
   * @param {Object} elem 
   * @return {type.UMLClass}
   */
  getAnchestorsClass (elem) {
    var t_elem = elem._parent
    var specifiers = []

    while (t_elem) {
      if (t_elem instanceof type.UMLClass || t_elem instanceof type.UMLInterface ||
        t_elem instanceof type.UMLDataType || t_elem instanceof type.UMLPrimitiveType) {
        specifiers.push(t_elem)
      }
      t_elem = t_elem._parent
    }
    specifiers.reverse()

    return specifiers
  }

  /**
   * get all parents of the elem (class only) to string
   * @param {Object} elem 
   * @param {Boolean} absolute
   * @return {String}
   */
  getAnchestorClassSpecifierStr (elem, absolute = false) {
    var getAnchestorsClassStr = (elem, cppCodeGen) => {
      var specifiers = []
      var templateSpecifier = ''

      // var t_elem = elem._parent
      // while (t_elem instanceof type.UMLClass) {
      //   if (cppCodeGen.getTemplateParameter(t_elem).length > 0) {
      //     templateSpecifier = cppCodeGen.getTemplateParameterNames(t_elem)
      //   }
      //   specifiers.push(t_elem.name + templateSpecifier)
      //   t_elem = t_elem._parent
      // }

      var anchestorsClass = cppCodeGen.getAnchestorsClass(elem)

      for (var i = 0; i < anchestorsClass.length; i++) {
        const currentAnchestorClass = anchestorsClass[i]
        if (cppCodeGen.getTemplateParameter(currentAnchestorClass).length > 0) {
          templateSpecifier = cppCodeGen.getTemplateParameterNames(currentAnchestorClass)
        }
        specifiers.push(currentAnchestorClass.name + templateSpecifier)
      }

      // specifiers.reverse()

      return specifiers
    }

    var classStr = ''

    classStr += getAnchestorsClassStr(elem, this).join('::')
    classStr += (classStr.length && !absolute) ? '::' : ''

    return classStr
  }

  /**
   * get all parents of the elem (package and class)
   * @param {Object} elem 
   * @param {Boolean} absolute
   * @return {String}
   */
  getContainersSpecifierStr (elem, absolute = false) {
    var classStr = this.getAnchestorClassSpecifierStr(elem, absolute)
    var namespacesStr = this.getNamespacesSpecifierStr(elem, !(classStr.length || !absolute))

    return namespacesStr + classStr
  }

  /**
   * write and arrange class declarations
   */
  writeClassesDeclarations () {
    var codeWriter = new codegen.CodeWriter(this.getIndentString(this.genOptions))

    var getAnchestors = (elem) => {
      var anchestorList = []
      var parentElem = elem._parent

      while (parentElem) {
        if (isGreatUMLPackage(parentElem)) {
          anchestorList.push(parentElem)
        }
        parentElem = parentElem._parent
      }

      if (anchestorList.length > 1) {
        anchestorList.reverse()
      }
      
      return anchestorList
    }

    var isUseful = (elem, elemTab) => {
      for (var i = 0; i < elemTab.length; i++) {
        var anchestors = getAnchestors(elemTab[i])

        if (!anchestors.length) {
          continue
        }
        
        if (anchestors.includes(elem)) {
          return true
        }
      }

      return false
    }

    var writeDeclaration = (elem, codeWriter, elemTab) => {
      if ((elem instanceof type.UMLClass || elem instanceof type.UMLPrimitiveType || elem instanceof type.UMLInterface) && elemTab.includes(elem)) {
        codeWriter.writeLine('class ' + elem.name + ';')
      } else if ((elem instanceof type.UMLDataType) && elemTab.includes(elem)) {
        codeWriter.writeLine('struct ' + elem.name + ';')
      } else if (isUseful(elem, elemTab)) {
        codeWriter.writeLine('namespace ' + elem.name + ' {')
        var ownElems = elem.ownedElements
        for (var i = 0; i < ownElems.length; i++) {
          writeDeclaration(ownElems[i], codeWriter, elemTab)
        }
        codeWriter.writeLine('} // end of namespace ' + elem.name)
      }
    }

    var elemTab = this.toDeclared
    var originAnchestorList = []
    var noAnchestorList = []

    // get all common anchestor
    for (var i = 0; i < elemTab.length; i++) {
      if (elemTab[i] instanceof type.UMLPrimitiveType || !getAnchestors(elemTab[i]).length) {
        noAnchestorList.push(elemTab[i])
        continue
      }
      var origin = getAnchestors(elemTab[i])[0]
      
      if (originAnchestorList.length && originAnchestorList.includes(origin)) {
          continue
      }
      originAnchestorList.push(origin)
    }

    // for the beauty of code
    if (elemTab.length) {
        codeWriter.writeLine()
    }

    // write each class doesn't have anchestor first
    for (i = 0; i < noAnchestorList.length; i++) {
      writeDeclaration(noAnchestorList[i], codeWriter, elemTab)
    }

    // locate the class in each subAnchestor of each achestor
    for (i = 0; i < originAnchestorList.length; i++) {
      writeDeclaration(originAnchestorList[i], codeWriter, elemTab)
    }

    // for the beauty of code
    if (elemTab.length) {
      codeWriter.writeLine()
    }

    return codeWriter.getData()
  }

  /**
   * Parsing template parameter
   *
   * @param {Object} elem
   * @return {Object} string
   */
  getTemplateParameter (elem) {
    var i
    var returnTemplateString = ''
    if (elem.templateParameters.length <= 0) {
      return returnTemplateString
    }
    var term = []
    returnTemplateString = 'template<'
    for (i = 0; i < elem.templateParameters.length; i++) {
      var template = elem.templateParameters[i]
      var templateStr = template.parameterType + ' '
      templateStr += template.name
      if (template.defaultValue.length !== 0) {
        templateStr += ' = ' + template.defaultValue
      }
      term.push(templateStr)
    }
    returnTemplateString += term.join(', ')
    returnTemplateString += '>'
    return returnTemplateString
  }

  getTemplateParameterNames (elem) {
    var i
    var returnTemplateString = ''
    if (elem.templateParameters.length <= 0) {
      return returnTemplateString
    }
    var term = []
    returnTemplateString = '<'

    for (i = 0; i < elem.templateParameters.length; i++) {
      var template = elem.templateParameters[i]
      var templateStr = template.name
      term.push(templateStr)
    }
    returnTemplateString += term.join(', ')
    returnTemplateString += '>'
    return returnTemplateString
  }

  trackingHeader (elem, target) {
    if (target instanceof type.UMLPrimitiveType) {
      return target.name
    }

    var header = ''
    var elementString = ''
    var targetString = ''
    var i

    while (elem._parent._parent !== null) {
      elementString = (elementString.length !== 0) ? elem.name + '/' + elementString : elem.name
      elem = elem._parent
    }
    while (target._parent._parent !== null) {
      targetString = (targetString.length !== 0) ? target.name + '/' + targetString : target.name
      target = target._parent
    }

    var idx
    for (i = 0; i < (elementString.length < targetString.length) ? elementString.length : targetString.length; i++) {
      if (elementString[i] === targetString[i]) {
        if (elementString[i] === '/' && targetString[i] === '/') {
          idx = i + 1
        }
      } else {
        break
      }
    }

    // remove common path
    elementString = elementString.substring(idx, elementString.length)
    targetString = targetString.substring(idx, targetString.length)
    for (i = 0; i < elementString.split('/').length - 1; i++) {
      header += '../'
    }
    header += targetString
    return header
  }

  /**
   * Classfy method and attribute by accessor.(public, private, protected)
   *
   * @param {Object} items
   * @return {Object} list
   */
  classifyVisibility (items) {
    var publicList = []
    var protectedList = []
    var privateList = []
    var i
    for (i = 0; i < items.length; i++) {
      var item = items[i]
      var visib = this.getVisibility(item)

      if (visib === 'public') {
        publicList.push(item)
      } else if (visib === 'private') {
        privateList.push(item)
      } else {
        // if modifier not setted, consider it as protected
        protectedList.push(item)
      }
    }
    return {
      _public: publicList,
      _protected: protectedList,
      _private: privateList
    }
  }

  /**
   * generate variables from attributes[i]
   *
   * @param {Object} elem
   * @return {Object} string
   */
  getMemberVariable (elem) {
    if (!elem.name.length) {
      return ''
    }
    var terms = this.getVariableDeclaration(elem, false, true)

    return terms + ';' + (elem.documentation.length ? ' /*!< ' + elem.documentation + ' */' : '')
  }

  /**
   * generate methods from operations[i]
   *
   * @param {Object} elem
   * @param {boolean} isCppBody
   * @return {Object} string
   */
  getMethod (elem, isCppBody) {

    var getConstraint = (elem, cppCodeGen) => {
      let codeWriter = new codegen.CodeWriter(cppCodeGen.getIndentString(cppCodeGen.genOptions))

      let specification = elem.specification
      var preconditions = elem.preconditions
      var bodyConditions = elem.bodyConditions
      var postconditions = elem.postconditions
      
      // for specification
      if (specification && specification.length > 0) {
        codeWriter.writeLine('specification :')
        codeWriter.indent()
        codeWriter.writeLine(specification)
        codeWriter.outdent()
      }

      // for preconditions
      if (preconditions && preconditions.length > 0) {

        preconditions.forEach((precondition) => {
          app.toast.info('precondition name = ' + precondition.name)
          specification = precondition.specification

          if (specification && specification.length > 0) {
            codeWriter.writeLine(precondition.name + ' <<precodition>> :')
            codeWriter.indent()
            codeWriter.writeLine(specification)
            codeWriter.outdent()
          }
        })
      }

      // for bodyConditions
      if (bodyConditions && bodyConditions.length > 0) {

        bodyConditions.forEach((bodyCondition) => {
          specification = bodyCondition.specification

          if (specification && specification.length > 0) {
            codeWriter.writeLine(bodyCondition.name + ' <<bodyCodition>> :')
            codeWriter.indent()
            codeWriter.writeLine(specification)
            codeWriter.outdent()
          }
        })
      }

      // for postconditions
      if (postconditions && postconditions.length > 0) {

        postconditions.forEach((postcondition) => {
          specification = postcondition.specification

          if (specification && specification.length > 0) {
            codeWriter.writeLine(postcondition.name + ' <<postcodition>> :')
            codeWriter.indent()
            codeWriter.writeLine(specification)
            codeWriter.outdent()
          }
        })
      }

      return codeWriter.getData()
    }
   
   // don't generate an abstract operation body
    if ((isCppBody && elem.isAbstract) || !elem.name.length) {
      return ''
    }

    var docs = '@brief ' + (elem.documentation.length ? elem.documentation : elem.name)
    var i
    var methodStr = ''
    var returnType = ''
    var returnTypeParam
    var validReturnParam

    var isInLine = false

    // for operation stereotype
    const isFriend = ((elem.stereotype instanceof type.UMLModelElement ? elem.stereotype.name : elem.stereotype) === 'friend')
    const isReadOnly = ((elem.stereotype instanceof type.UMLModelElement ? elem.stereotype.name : elem.stereotype) === 'readOnly')
    // for parameter stereotype
  
    // constructor and destructor verification
    const isConstructor = elem.name === elem._parent.name // for constructor
    const isDestructor = elem.name === ('~' + elem._parent.name) // for destructor

    var inputParams = elem.parameters.filter(function (params) {
      return (params.direction === 'in' || params.direction === 'inout' || params.direction === 'out')
    })
    var inputParamStrings = []
    for (i = 0; i < inputParams.length; i++) {
      var inputParam = inputParams[i]
      inputParamStrings.push(this.getVariableDeclaration(inputParam, isCppBody))
      docs += '\n@param ' + inputParam.name + (inputParam.documentation.length ? ' : ' + inputParam.documentation : '')
    }            

    if (!(isConstructor || isDestructor)) {
      returnTypeParam = elem.parameters.filter(function (params) {
        return params.direction === 'return'
      })
      
      var stereotypeIdentifier = ' '

      if (returnTypeParam.length > 0) {
        validReturnParam = returnTypeParam[0]
        returnType += this.getType(validReturnParam)

        // for parameter stereotype
        if ((validReturnParam.stereotype instanceof type.UMLModelElement ? validReturnParam.stereotype.name : validReturnParam.stereotype) === 'reference') {
          stereotypeIdentifier = ' &'
        }
        
        docs += '\n@return ' + returnType + (validReturnParam.documentation.length ? ' : ' + validReturnParam.documentation : '')
      } else {
        returnType = 'void'
      }
      
      methodStr += returnType + stereotypeIdentifier
    }

    var templateParameter = this.getTemplateParameter(elem)

    if (templateParameter.length > 0) {
      methodStr = templateParameter + '\n' + methodStr
    }

    // if generation of body code is setted
    if (isCppBody) {
      var parentTemplateParameter = this.getTemplateParameter(elem._parent)

      if (parentTemplateParameter.length > 0) {
        methodStr = parentTemplateParameter + '\n' + methodStr
      }
      
      var indentLine = this.getIndentString(this.genOptions)

      if (!isFriend) {
        methodStr += this.getContainersSpecifierStr(elem, false)
      }

      methodStr += elem.name
      methodStr += '(' + inputParamStrings.join(', ') + ')'
  
      if (isReadOnly) {
        methodStr += ' const'
      }

      var defaultContent = '{\n'

      if (!(isConstructor || isDestructor)) {
        if (returnTypeParam.length > 0) {
          var retParam_Name = validReturnParam.name
          if (retParam_Name.length > 0) {
              defaultContent += indentLine + this.getVariableDeclaration(validReturnParam, isCppBody) + ';\n'
              defaultContent += '\n' + indentLine + 'return ' + retParam_Name + ';'
          } else {
            if (returnType === 'boolean' || returnType === 'bool') {
              defaultContent += indentLine + 'return false;'
            } else if (returnType === 'int' || returnType === 'long' || returnType === 'short' || returnType === 'byte' ||
                        returnType === 'unsigned int' || returnType === 'unsigned long' || returnType === 'unsigned short' || returnType === 'unsigned byte') {
              defaultContent += indentLine + 'return 0;'
            } else if (returnType === 'double' || returnType === 'float' ||
                        returnType === 'unsigned double' || returnType === 'unsigned float') {
              defaultContent += indentLine + 'return 0.0;'
            } else if (returnType === 'char') {
              defaultContent += indentLine + 'return \'0\';'
            } else if (returnType === 'string' || returnType === 'String') {
              defaultContent += indentLine + 'return "";'
            } else if (returnType === 'void') {
              defaultContent += indentLine + 'return;'
            } else {
              defaultContent += indentLine + 'return ' + returnType + '();'
            }
          }
        }
      }
      defaultContent += '\n}'

      methodStr += this.writeCustomCode(elem, defaultContent)

      // adding all constraint fo doc format
      methodStr = this.getDocuments(getConstraint(elem, this)) + methodStr
    } else {

      methodStr += elem.name
      methodStr += '(' + inputParamStrings.join(', ') + ')'
      if (isReadOnly) { methodStr += ' const' }

      // make pure virtual all operation of an UMLInterface
      if (elem._parent instanceof type.UMLInterface || elem.isAbstract) {
        // constructor can not define as virtual
        if (!isConstructor) {
          methodStr = 'virtual ' + methodStr
        }

        // make inline the destructor of an interface instead pure virtual
        if (isDestructor || isConstructor) {
          isInLine = true
        } else {
          methodStr += ' = 0'

          // set the elem and his parent in model to abstract (if not setted)
          elem._parent.isAbstract = true
          elem.isAbstract = true
        }
      }
      else if (isFriend) { methodStr = 'friend ' + methodStr }
      else if (elem.isStatic) { methodStr = 'static ' + methodStr }
      else if (elem.isLeaf) { methodStr += ' final' }
      // else if (isConstructor) { methodStr = 'explicit ' + methodStr }
      else { methodStr = 'virtual ' + methodStr }
  
      methodStr += isInLine ? ' {}' : ';'
  
      methodStr = '\n' + this.getDocuments(docs) + methodStr
    }

    return methodStr + '\n'
  }

  /**
   * generate methods from reception[i]
   *
   * @param {Object} elem
   * @param {boolean} isCppBody
   * @return {Object} string
   */
  getSlot (elem, isCppBody) {
    if (!elem.name.length) {
      return ''
    }

    var docs = ''
    var i
    var methodStr = ''
    var paramStr = ''
  
    // constructor and destructor verification
    const isConstructor = elem.name === elem._parent.name // for constructor
    const isDestructor = elem.name === ('~' + elem._parent.name) // for destructor

    if (isConstructor || isDestructor) {
      return ''
    }
    
    if (elem.signal !== null && elem.signal instanceof type.UMLSignal) {
      var elemSignal = elem.signal
      var params = []
      for (i = 0; i < elemSignal.attributes.length; i++) {
          var att = elemSignal.attributes[i]
          params.push(this.getVariableDeclaration(att, true))
      }
      paramStr += params.join(', ')
      
      var specifier = this.getContainersSpecifierStr(elemSignal, false)

      // sync reception name to the signal
      elem.name = 'on' + firstUpperCase(elemSignal.name)
      docs += '\nFrom signal: ' + specifier + elemSignal.name
    }
    docs = '@brief ' + (elem.documentation.length ? elem.documentation : elem.name) + docs

    // if generation of body code is setted
    if (isCppBody) {
      var parentTemplateParameter = this.getTemplateParameter(elem._parent)

      if (parentTemplateParameter.length > 0) {
        methodStr = parentTemplateParameter + '\n' + methodStr
      }
      
      var specifier = this.getContainersSpecifierStr(elem, false)

      methodStr += 'void ' + specifier + elem.name + '(' + paramStr + ')'

      methodStr += this.writeCustomCode(elem, '{\n\n}')

    } else {

      methodStr = 'void ' + elem.name + '(' + paramStr + ')'

      // make pure virtual all operation of an UMLInterface
      if (elem._parent instanceof type.UMLInterface) {
        methodStr = 'virtual ' + methodStr
        methodStr += ' = 0'
        // set the elem and his parent in model to abstract (if not setted)
        elem._parent.isAbstract = true
      } else if (elem.isStatic) {
        methodStr = 'static ' + methodStr
      } else if (elem.isLeaf) {
        methodStr += ' final'
      } else {
        methodStr = 'virtual ' + methodStr
      }
      
      if (this.genOptions.useQt) {
        methodStr = 'Q_SLOT ' + methodStr
      }

      methodStr = '\n' + this.getDocuments(docs) + methodStr
      methodStr += ';'
    }

    return methodStr + '\n'
  }

  /**
   * generate doc string from doc element
   *
   * @param {Object} text
   * @return {Object} string
   */
  getDocuments (text) {
    var docs = ''
    if ((typeof text === 'string') && text.length !== 0) {
      var lines = text.trim().split('\n')
      docs += '/**\n'
      var i
      for (i = 0; i < lines.length; i++) {
        docs += ' * ' + lines[i] + '\n'
      }
      docs += ' */\n'
    }
    return docs
  }

  /**
   * parsing visibility from element
   *
   * @param {Object} elem
   * @return {Object} string
   */
  getVisibility (elem) {
    switch (elem.visibility) {
    case type.UMLModelElement.VK_PUBLIC:
      return 'public'
    case type.UMLModelElement.VK_PROTECTED:
      return 'protected'
    case type.UMLModelElement.VK_PRIVATE:
      return 'private'
    }
    return null
  }

  /**
   * parsing modifiers from element
   *
   * @param {Object} elem
   * @return {Object} list
   */
  getModifiers (elem) {
    var modifiers = []
    if (elem.isStatic === true) {
      modifiers.push('static')
    }
    if (elem.isReadOnly === true) {
      modifiers.push('const')
    }
    if (elem.isAbstract === true) {
      modifiers.push('virtual')
    }
    return modifiers
  }

  /**
   * parsing type from element
   *
   * @param {Object} elem
   * @param {boolean} allowSmartPtr
   * @param {boolean} ignoreQualifier
   * @return {Object} string
   */
  getType (elem, allowSmartPtr = true, ignoreQualifier = false) {
    var _elemType
    var _typeStr = 'void'
    var _likePointer = likePointer(elem, this)
    var _isRecognizedType = true
    var _isAssociationContainer = false
    var _isNotSharedWithAutoPtr = false

    /**
     * Get the string of the correct type (with her container prefix)
     * @param {Object} _elemType 
     * @return {Object} string
     */
    var getCorrectType = (_elemType) => {
      var _typeStr = this.getContainersSpecifierStr(_elemType, false) + _elemType.name
      if (this.getTemplateParameter(_elemType).length > 0) {
        _typeStr += this.getTemplateParameterNames(_elemType)
      }
      return _typeStr
    }

    if (elem instanceof type.UMLAssociationEnd) { // member variable from association
      _elemType = elem.reference
        
      if (_elemType instanceof type.UMLModelElement && _elemType.name.length > 0) {
        if (getOppositeElem(elem).qualifiers.length > 0 && !ignoreQualifier) {
          _isAssociationContainer = true
          // generate only the first qualifier
          const _key = getOppositeElem(elem).qualifiers[0]
          const _containerType = this.genOptions.useQt ? 'QHash<' : 'std::hash<'
          const _keyType = this.getType(_key)
          const _valueType = this.getType(elem, allowSmartPtr, true)

          _typeStr = _containerType + _keyType + ',' + _valueType + '>'

        } else {
          _typeStr = getCorrectType(_elemType)
          _isNotSharedWithAutoPtr = (this.genOptions.useSmartPtr &&
                                      !(elem._parent instanceof type.UMLSignal) /*Signal is used as method here*/ &&
                                      getOppositeElem(elem).aggregation === type.UMLAttribute.AK_COMPOSITE)
        }
      }
    } else if (elem instanceof type.UMLParameter) { // parameter inside method
      _elemType = elem.type

      if (_elemType instanceof type.UMLModelElement && _elemType.name.length > 0) {
        _typeStr = getCorrectType(_elemType)
      } else if ((typeof _elemType === 'string')) {
        if (_elemType.length > 0) {
          _typeStr = _elemType
        }
        _isRecognizedType = false
      }
    } else { // member variable inside class
      _elemType = elem.type

      if (_elemType instanceof type.UMLModelElement && _elemType.name.length > 0) {
        _typeStr = getCorrectType(_elemType)
      } else if ((typeof _elemType === 'string')) {
        if (_elemType.length > 0) {
          _typeStr = _elemType
        }
        _isRecognizedType = false
      }

      _isNotSharedWithAutoPtr = (this.genOptions.useSmartPtr &&
                                  !(elem._parent instanceof type.UMLSignal) /*Signal is used as method here*/ &&
                                  elem.aggregation !== type.UMLAttribute.AK_SHARED)
    }

    if (!_isAssociationContainer) {
      const _likePointer_withoutMultiplicity = likePointer(elem, this, true)

      // first, generate a pointer : if element is pure pointer not by the multiplicity parameter
      if (_likePointer_withoutMultiplicity) {
        _typeStr += '*'
      }
  
      // multiplicity
      if (elem.multiplicity) {

        // [0..1]
        // multiplicity '0..1' is often used as pointer
        if (elem.multiplicity === '0..1') {
          // use a smart pointer if all below statements is true
          if (_isNotSharedWithAutoPtr && allowSmartPtr && !_likePointer_withoutMultiplicity &&
              !(elem instanceof type.UMLParameter)) {

            // using a smart pointer according to the choosed preference
            if (this.genOptions.useQt) {
              if (hasAsyncMethod(elem.reference)) {
                _typeStr = 'QScopedPointer<' + _typeStr + ', QScopedPointerDeleteLater>'
              } else {
                _typeStr = 'QScopedPointer<' + _typeStr + '>'
              }
              this.parseUnrecognizedType('QScopedPointer')
            } else {
              _typeStr = 'std::unique_ptr<' + _typeStr + '>'
              this.parseUnrecognizedType('memory')
            }
            
          }
          // else make a simple pointer
          else {
            _typeStr += '*'
          }
          // if element is pure pointer, the declaration is like below :
          // type** name;
          // else : std::unique_ptr<type> name;
          _likePointer = true

        }
        else {

          const isQtObject = (this.genOptions.useQt && hasAsyncMethod(elem.reference)) /*QtObject class*/
          const isModifiable_QtObject = (isQtObject && (accessorMethodIndex(elem) >= 2))

          // make type as pointer : if (QtObject or Interface) is used with current type is not like pointer
          // because QtObject and Interface does not implement : copy constructor, assignment operator
          if (!_likePointer_withoutMultiplicity &&
              (isQtObject || elem.reference instanceof type.UMLInterface /*Interface*/)) {

            // [1]
            // use a smart pointer if all below statements is true
            if (elem.multiplicity === '1' && !(elem instanceof type.UMLParameter) &&
                _isNotSharedWithAutoPtr && allowSmartPtr) {

              // nothing if elem is a QtObject (but not a modifiable) and not an interface
              if (isModifiable_QtObject || elem.reference instanceof type.UMLInterface){
                // using a smart pointer according to the specified preference
                if (this.genOptions.useQt) {
                  _typeStr = 'QScopedPointer<' + _typeStr + (isQtObject ? ', QScopedPointerDeleteLater' : '') + '>'
                  this.parseUnrecognizedType('QScopedPointer')
                } else {
                  _typeStr = 'std::unique_ptr<' + _typeStr + '>'
                  this.parseUnrecognizedType('memory')
                }
                
                _likePointer = true
              }
            } else {
              _typeStr += '*'
              _likePointer = true
            }
          }

          // [ARRAY] dynamic
          if (['0..*', '1..*', '*'].includes(elem.multiplicity.trim())) {
            // use a vector if it is specified in the preference
            if (this.genOptions.useVector) {
              if (this.genOptions.useQt) {
                _typeStr = 'QVector<' + _typeStr + '>'
                this.parseUnrecognizedType('QVector')
              } else {
                _typeStr = 'std::vector<' + _typeStr + '>'
                this.parseUnrecognizedType('vector')
              }
            }
            // else make a simple pointer instead
            else {
              _typeStr += '*'

              _likePointer = true
            }
          }

          // i don't check here the [ARRAY] static because the declaration is like below :
          // type name[size];
          // the size is setted after the variable name, then check it in variable declaration
        }
      }

      if (_isRecognizedType) {

        // if all below statement is true :
        // create a dependency of elem anchestor class and elem type
        if (!_likePointer && !(elem instanceof type.UMLAssociationEnd) && this.genOptions.implementation) {
          const anchestorClass = this.getAnchestorsClass(elem)

          // we can continue : if _elemType is not the anchestor of the elem
          if (anchestorClass.length && !anchestorClass.includes(_elemType)) {
            var parentClass = anchestorClass[0]
            // ignore this operation if the dependency is already exist
            if (!parentClass.getDependencies().includes(_elemType) && !hasAssociation(parentClass, _elemType)) {

              var builder = app.repository.getOperationBuilder()
              builder.begin('generate dependency')
              
              var dep = new type.UMLDependency()
              dep.source = parentClass
              dep.target = _elemType
              dep._parent = parentClass

              builder.insert(dep)
              builder.fieldInsert(parentClass, 'ownedElements', dep)

              builder.end()
              var cmd = builder.getOperation()
              app.repository.doOperation(cmd)
            }
          }
        }

        this.parseElemType(_elemType, _likePointer)
      } else {
        this.parseUnrecognizedType(_elemType)
      }
    }

    // modifiers
    const _modifiers = this.getModifiers(elem)

    if (_modifiers.length > 0) {
      _typeStr = _modifiers.join(' ') + ' ' + _typeStr
    }

    return _typeStr
  }

  /**
   * generate variable/parameter declaration
   *
   * @param {Object} elem
   * @param {boolean} isCppBody
   * @param {boolean} isMemberVariable
   * @return {Object} string
   */
  getVariableDeclaration (elem, isCppBody, isMemberVariable = false) {
    var _declarationStr = []

    // type
    var _typeStr = this.getType(elem)

    // name
    var _nameStr = elem.name
    if (isMemberVariable && elem.visibility !== type.UMLModelElement.VK_PUBLIC) {
      _nameStr = 'm_' + _nameStr
    }

    if (elem.multiplicity && ['1', '0..1', '0..*', '1..*', '*'].includes(elem.multiplicity) === false) {
      if (elem.multiplicity.match(/^\d+$/)) { // number
        _nameStr += '[' + elem.multiplicity + ']'
      } else {
        _nameStr += '[]'
      }
    }

    // modify the type if elem is an UMLParameter and direction is "out"
    if (elem instanceof type.UMLParameter && elem.direction === type.UMLParameter.DK_OUT) {
      _nameStr = '&' + _nameStr
    }    

    // _typeStr or _nameStr can be modified by the multiplicity computation
    _declarationStr.push(_typeStr)
    _declarationStr.push(_nameStr)

    // if parameter with direction other than "return", Default value is not generated in body of the class
    if (!isCppBody || (elem instanceof type.UMLParameter && elem.direction === type.UMLParameter.DK_RETURN)) {
      // initial value
      if (elem.defaultValue && elem.defaultValue.length > 0) {
        _declarationStr.push('= ' + elem.defaultValue)
      }
    }

    return _declarationStr.join(' ')
  }
}

function generate (baseModel, basePath, logPath, options) {
  if (!logPath || !logPath.length) {
    logPath = basePath + (options.windows ? '\\' : '/') + baseModel.name + '.slf'
    app.toast.info('Generate project config in : ' + logPath)
  }

  var cppCodeGenerator = new CppCodeGenerator(baseModel, logPath)
  cppCodeGenerator.generate(baseModel, basePath, options)
}

function getVersion () { return versionString }

exports.generate = generate
exports.getVersion = getVersion

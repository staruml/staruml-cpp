
const fs = require('fs')
const codeGenerator = require('./code-generator')
const codeAnalyzer = require('./code-analyzer')

var logPath = ''
var path = ''
var lastBase


function getGenOptions () {
  return {
    windows: app.preferences.get('cpp.gen.windows'),
    useTab: app.preferences.get('cpp.gen.useTab'),
    useQt: app.preferences.get('cpp.gen.useQt'),
    indentSpaces: app.preferences.get('cpp.gen.indentSpaces'),
    useVector: app.preferences.get('cpp.gen.useVector'),
    includeHeader: app.preferences.get('cpp.gen.includeHeader'),
    genCpp: app.preferences.get('cpp.gen.genCpp')
  }
}

function getRevOptions () {
  return {
    association: app.preferences.get('cpp.rev.association'),
    publicOnly: app.preferences.get('cpp.rev.publicOnly'),
    typeHierarchy: app.preferences.get('cpp.rev.typeHierarchy'),
    packageOverview: app.preferences.get('cpp.rev.packageOverview'),
    packageStructure: app.preferences.get('cpp.rev.packageStructure')
  }
}

/**
 * Command Handler for C++ Generate
 *
 * @param {Element} base
 * @param {string} path
 * @param {Object} options
 */
function _handleGenerate (base, options) {
  // If options is not passed, get from preference
  options = options || getGenOptions()
  // If base is not assigned, popup ElementPicker
  if (!base) {
    app.elementPickerDialog.showDialog('Select a base model to generate codes', null, type.UMLPackage).then(function ({buttonId, returnValue}) {
      if (buttonId === 'ok') {
        base = returnValue

        if (!lastBase || lastBase !== base) {
          lastBase = base
          logPath = ''
          path = ''
        }
        
        if (!logPath) {
			logPath = app.dialogs.showSaveDialog('Select a StarUML log file', null, null)
		}
        // If path is not assigned, popup Open Dialog to select a folder
        if (!path) {
          var files = app.dialogs.showOpenDialog('Select a folder where generated codes to be located', null, null, { properties: [ 'openDirectory' ] })
          if (files && files.length > 0) {
            path = files[0]
            codeGenerator.generate(base, path, logPath, options)
          }
        } else {
          codeGenerator.generate(base, path, logPath, options)
        }
      }
    })
  } else {
	if (!lastBase || lastBase !== base) {
		lastBase = base
		logPath = ''
		path = ''
	}
	
	if (!logPath) {
		logPath = app.dialogs.showSaveDialog('Select a StarUML log file', null, null)
	}
    // If path is not assigned, popup Open Dialog to select a folder
    if (!path) {
      var files = app.dialogs.showOpenDialog('Select a folder where generated codes to be located', null, null, { properties: [ 'openDirectory' ] })
      if (files && files.length > 0) {
        path = files[0]
        codeGenerator.generate(base, path, logPath, options)
      }
    } else {
      codeGenerator.generate(base, path, logPath, options)
    }
  }
}

/**
 * Command Handler for C++ Reverse
 *
 * @param {string} basePath
 * @param {Object} options
 */
function _handleReverse (basePath, options) {
  // If options is not passed, get from preference
  options = getRevOptions()
  // If basePath is not assigned, popup Open Dialog to select a folder
  if (!basePath) {
    var files = app.dialogs.showOpenDialog('Select Folder', null, null, { properties: [ 'openDirectory' ] })
    if (files && files.length > 0) {
      basePath = files[0]
      codeAnalyzer.analyze(basePath, options)
    }
  }
}

function _handleConfigure () {
  app.commands.execute('application:preferences', 'cpp')
}

function init () {
  app.commands.register('cpp:generate', _handleGenerate)
  app.commands.register('cpp:reverse', _handleReverse)
  app.commands.register('cpp:configure', _handleConfigure)
}

exports.init = init

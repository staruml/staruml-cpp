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

define(function (require, exports, module) {
    "use strict";
    
    /**
     * CodeWriter
     * @constructor
     */
    function CodeWriter(indentString) {
        
        /** @member {Array.<string>} lines */
        this.lines = [];

        /** @member {string} indentString */
        this.indentString = (indentString ? indentString : "    "); // default 4 spaces

        /** @member {Array.<string>} indentations */
        this.indentations = [];
    }

    /**
     * Indent
     */    
    CodeWriter.prototype.indent = function () {
        this.indentations.push(this.indentString);
    };

    /**
     * Outdent
     */    
    CodeWriter.prototype.outdent = function () {
        this.indentations.splice(this.indentations.length-1, 1);
    };

    /**
     * Write a line
     * @param {string} line
     */    
    CodeWriter.prototype.writeLine = function (line) {
        
        if (line) {
            var line_split_by_new = line.split('\n');
            for (var i=0; i<line_split_by_new.length; i++){
                this.lines.push(this.indentations.join("") + line_split_by_new[i]);        
            }
        } else {
            this.lines.push("");
        }        
    };

    /**
     * Return as all string data
     * @return {string}
     */    
    CodeWriter.prototype.getData = function () {
        return this.lines.join("\n");
    };
    
    
    /**
     * CodeHelper
     * @constructor
     */
    function CodeHelper(node, delim) {
        
        /** @member {Objcet} root node for uml */
        this.node = node;
        
        /** @member {String} header path delimeter */
        this.delim = delim;
        
        /** @member {Objcet} map for parsed header. [ node._id ] = "path" */
        this.headerMap = {};
    }
    
    
    exports.CodeWriter = CodeWriter;

});
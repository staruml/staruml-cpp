Cpp Extension for StarUML 2 
============================
This extension for StarUML(http://staruml.io) support to generate Cpp code from UML model.



### UMLPackage
* converted to folder.

### UMLClass

* converted to _Cpp Class_. (as a separate `.h` file)
* `visibility` to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* `isFinalSpecification` and `isLeaf` property to `final` modifier.
* Default constructor is generated.
* All contained types (_UMLClass_, _UMLInterface_, _UMLEnumeration_) are generated as inner type definition.
* TemplateParameter to _Cpp Template_.

### UMLAttribute

* converted to _Cpp Field_.
* `visibility` property to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* `name` property to field identifier.
* `type` property to field type.
* `multiplicity` property to vector type.
* `isStatic` property to `static` modifier.
* `isLeaf` property to `final` modifier.
* `defaultValue` property to initial value.
* Documentation property to JavaDoc comment.

### UMLOperation

* converted to _Cpp Methods_.
* `visibility` to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* `name` property to method identifier.
* `isAbstract` property to `virtual` modifier. (TODO need options to create pure-virtual function or virtual function)
* `isStatic` property to `static` modifier.
* _UMLParameter_ to _Cpp Method Parameters_.
* _UMLParameter_'s name property to parameter identifier.
* _UMLParameter_'s type property to type of parameter.
* _UMLParameter_ with `direction` = `return` to return type of method. When no return parameter, `void` is used.
* _UMLParameter_ with `isReadOnly` = `true` to `const` modifier of parameter.

### UMLInterface

* converted to _Cpp Class_.  (as a separate `.h` file)
* `visibility` property to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* all method will treated as pure virtaul.

### UMLEnumeration

* converted to _Cpp Enum_.  (as a separate `.h` file)
* `visibility` property to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* _UMLEnumerationLiteral_ to literals of enum.

### UMLAssociationEnd

* converted to _Cpp Field_.
* `visibility` property to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* `name` property to field identifier.
* `type` property to field type.
* If `multiplicity` is one of `0..*`, `1..*`, `*`, then collection type (`std::vector<T>` ) is used.
* `defaultValue` property to initial value.

### UMLGeneralization & UMLInterfaceRealization

* converted to _Cpp Inheritance_ (` : `).
* Allowed for _UMLClass_ to _UMLClass_, and _UMLClass_ to _UMLInterface_.


Licensed under the MIT license (see LICENSE file).
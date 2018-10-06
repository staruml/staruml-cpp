Cpp Extension for StarUML 2
============================
This extension for StarUML(http://staruml.io) support to generate Cpp code from UML model.


### Preference choice

* `Qt` keywords with all necessary functionality. [`usefull in signal-reception`]
```c
    #include <QObject>

    namespace ... {
    class ... : public QObject, ...
    {
        Q_OBJECT
    public:

        Q_SIGNAL void signalName(int signalAttValue);

        /* ...
         * From signal : signalName
         */
        virtual Q_SLOT void receptionName(int signalAttValue);
    };
    }
```

* `Smart pointer` ready to use to _simplify the code_. Example below:
```c
    //! NMSPC1::C1 is composed of [0..1] NMSPC2::C2
        // or
    //! NMSPC1::C1 use an interface [1] NMSPC2::C2

    #include <memory>

    namespace NMSPC2 {
    class C2;
    } // end of namespace NMSPC2

    namespace NMSPC1 {
    class C1 {
        std::unique_ptr<C2> varName; // using smart pointer
        C2* varName; // using normal code
    };
    } // end of namespace NMSPC1
```

* `Implementation model` functionality added. [*`work only on Gen..`]

        Parse C1 if need new necessary method,
        then generate all need missing method.

        This add in the Class C1 [in Model and Code] :
            * operator ==, !=, =
            * default and copy constructor
            * destructor



### Behavior [*new]


* `ReUse` of present source code _only if the same tool regenerate it before_. [*`choose your OS before Gen.. code`]

        Why he need to save the configuration of all sources code generated in a file.
        Create the file at the first Gen.. [auto (at the same directory with the model name) if not set]
        and choose this file on the next Gen.. to reUse the last code.
```c
    //! all generated operations in the cpp body code are like this :

    void NMSPC1::C1::setC2(NMSPC2::C2* value)
    //< {ID of NMSPC1::C1::setC2}
    {
        /*begin to write your custom code here*/
        //! all wrotten code between { ... } are reUse in the next Gen..

        NMSPC2::C2* _returnParamName; // default if setted

        return _returnParamName;

        /*end of your custom code*/
    }
    //>
```
* All `normal` and  _`virtual`_ operations is considered as _`virtual`_ to make `polymorphism` possible.
* `Qualifier element` considered as `std::hash<elemType, assoEndType>`.



### UMLPackage
* converted to _folder_ and _Cpp namespace_ in generated file type (_UMLClass_, _UMLInterface_, _UMLEnumeration_).

### UMLClass

* converted to _Cpp Class_. (as a separate `.h` file)
* `visibility` to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* `isFinalSpecialization` and `isLeaf` property to `final` modifier.
* All contained types (_UMLClass_, _UMLInterface_, _UMLEnumeration_) are generated as inner type definition.
* TemplateParameter to `Cpp Template`.

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
* _UMLParameter_'s `defaultValue` only setted to `return` direction in _Cpp file_ and `in`/`out`/`inout` direction in _Header file_.
* _UMLParameter_ with `isReadOnly` = `true` to `const` modifier of parameter.
* Parse body method if all _modification by developper_ in _Cpp file_ (already generated) need to be `Save` or `Reset` (Usefull with all _`"Unified Process"` Methodology_).

### UMLInterface

* converted to _Cpp Class_.  (as a separate `.h` file)
* `visibility` property to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* all method will treated as pure virtaul.

### UMLEnumeration
| Weekdays      |
| ------------- |
| Monday        |
| Tuesday       |
| Saturday      |

converts

```c
/* Test header @ toori67
 * This is Test
 * also test
 * also test again
 */
#ifndef (_WEEKDAYS_H)
#define _WEEKDAYS_H

enum Weekdays {
    Monday,
    Tuesday,
    Saturday
};

#endif //_WEEKDAYS_H
```

* converted to _Cpp Enum_.  (as a separate `.h` file)
* `visibility` property to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* _UMLEnumerationLiteral_ to literals of enum.

### UMLAssociationEnd

* converted to _Cpp Field_.
* `visibility` property to one of modifiers `public`, `protected`, `private`. If visibility is not setted, consider as `protected`.
* `name` property to field identifier.
* `type` property to field type.
* If `multiplicity` is one of `0..*`, `1..*`, `*`, then collection type (`std::vector<T>` or `T*`) is used.
* `defaultValue` property to initial value.

### UMLGeneralization & UMLInterfaceRealization

* converted to _Cpp Inheritance_ (` : `).
* Allowed for _UMLClass_ to _UMLClass_, and _UMLClass_ to _UMLInterface_.



C++ Reverse Engineering
------------------------

1. Click the menu (`Tools > C++ > Reverse Code...`)
2. Select a folder containing C++ source files to be converted to UML model elements.
3. `CppReverse` model will be created in the Project.

Belows are the rules to convert from C++ source code to UML model elements.

### C++ Namespace

* converted to _UMLPackage_.

### C++ Class

* converted to _UMLClass_.
* Class name to `name` property.
* Type parameters to _UMLTemplateParameter_.
* Access modifier `public`, `protected` and  `private` to `visibility` property.
* `abstract` modifier to `isAbstract` property.
* Constructors to _UMLOperation_ with stereotype `<<constructor>>`.
* All contained types (_UMLClass_, _UMLInterface_, _UMLEnumeration_) are generated as inner type definition.


### C++ Field (to UMLAttribute)

* converted to _UMLAttribute_ if __"Use Association"__ is __off__ in Preferences.
* Field type to `type` property.

    * Primitive Types : `type` property has the primitive type name as string.
    * `T[]`(array) or its decendants: `type` property refers to `T` with multiplicity `*`.
    * `T` (User-Defined Types)  : `type` property refers to the `T` type.
    * Otherwise : `type` property has the type name as string.

* Access modifier `public`, `protected` and  `private` to `visibility` property.
* `static` modifier to `isStatic` property.
* Initial value to `defaultValue` property.

### C++ Field (to UMLAssociation)

* converted to (Directed) _UMLAssociation_ if __"Use Association"__ is __on__ in Preferences and there is a UML type element (_UMLClass_, _UMLInterface_, or _UMLEnumeration_) correspond to the field type.
* Field type to `end2.reference` property.

    * `T[]`(array) or its decendants: `reference` property refers to `T` with multiplicity `*`.
    * `T` (User-Defined Types)  : `reference` property refers to the `T` type.
    * Otherwise : converted to _UMLAttribute_, not _UMLAssociation_.

* Access modifier `public`, `protected` and  `private` to `visibility` property.

### C++ Method

* converted to _UMLOperation_.
* Type parameters to _UMLTemplateParameter_.
* Access modifier `public`, `protected` and  `private` to `visibility` property.
* `static` modifier to `isStatic` property.
* `abstract` modifier to `isAbstract` property.


### C++ Enum

* converted to _UMLEnumeration_.
* Enum name to `name` property.
* Type parameters to _UMLTemplateParameter_.
* Access modifier `public`, `protected` and  `private` to `visibility` property.

---

Licensed under the MIT license (see LICENSE file).

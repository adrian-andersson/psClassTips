# Custom Classes and Inheritance

If you use a lot of inheritance in your classes, you may come up against a scenario where you want to validate your object type parameter is effectively inherited from a parent.

This is easy to do for the parent class but it is actually pretty hard to do if you have multiple levels of inheritance.

## What am I talking about

Say you have a parent class with some methods and basic params, and you want to use that class as a strict parameter in another class, you can force the type with the parameter type, you can use the object in the constructor and validate it in the param set.

```PowerShell
class parentClass
{
    #Mandatory Params
    [string]$String

    parentClass([string]$string)
    {
        $this.string = $string
    }
}


class referenceClass
{
    #Mandatory Params
    [parentClass]$parentClass

    parentClass([object]$parentClass)
    {
        $this.parentClass = $parentClass
    }
}

```

This falls over though if we wanted to extend the parent class though

```PowerSHell
class parentClass
{
    [string]$String

    parentClass([string]$string)
    {
        $this.string = $string
    }
}


class childClassOne :: ParentClass
{
    [string]$String
    [bool]$childClass = $true #Extending the parent class

    parentClass([string]$string)
    {
        $this.string = $string
    }
}



class childClassTwo :: ChildClassOne
{
    [string]$String
    [bool]$childClass = $true #Extending the parent class

    parentClass([string]$string)
    {
        $this.string = $string
    }

    [string] getName()
    {
        return 'Extended extended class'
    }
}

```

In the above example, how do we ensure that the referenceClass is using _any_ of the inherited children but still validating ok. My solution was to use a custom Validation class that loops through the inheritance of an object and matches a specified class name

```PowerShell

class validateObjectTypeAttribute : System.Management.Automation.ValidateArgumentsAttribute
{
    <#
        .SYNOPSIS
            A custom object validator
            That checks the object type either matches
            or inherits from the typename provided

        .Example
            From a function PARAM block

            Ensures that the type comes from PSCustomObject
            param(
                [validateObjectType('PSCustomObject')]
                [object[]]$object
            )

        .Example
            From a function PARAM block

            Ensures that the type comes from MyCustomClass or is inherited
            param(
                [validateObjectType('MyCustomClass')]
                [object[]]$object
            )
    #>


    #Place to store the parent object type name
    [string]$baseObjectType

    #Custom constructor to take a string of the parent object type name
    validateObjectTypeAttribute([string]$baseObjectType)
    {
        $this.baseObjectType = $baseObjectType
    }

    [void] Validate($arguments,[System.Management.Automation.EngineIntrinsics]$engineIntrinsics)
    {

        #Throw if we have no arguments
        if([string]::IsNullOrWhiteSpace($arguments))
        {
            throw [System.ArgumentNullException]::new()
        }

        #Cycle through each object
        #Check its the correct basetype
        foreach($object in $arguments)
        {
            if(($object.GetType().IsSubclassOf($this.baseObjectType) -ne $true) -and ($object.getType().name -ne $this.baseObjectType))
            {
                #Not a proper type or not inherrited and should throw
                throw 'Invalid Object type. Expected object Type or inheritence from: {0}' -f $this.baseObjectType
            }
        }

        #Check if this object is a subclass of the baseObject type
        #  This works with Inheritence
        #Alternative, if the type name matches it must be an instance of the type
    }
}


```

Then using that in line with our Reference class we can do the following, and it doesn't matter if what we pass as the object any more so long as it was the parent class or inherited from the parent class originally.

```PowerShell
class referenceClass
{
    #Mandatory Params
    [validateObjectTypeAttribute('parentClass')]
    [object]$referencedObject

    parentClass([object]$referencedObject)
    {
        $this.referencedObject = $referencedObject
    }
}


```
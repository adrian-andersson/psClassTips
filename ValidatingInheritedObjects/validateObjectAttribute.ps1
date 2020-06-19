
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

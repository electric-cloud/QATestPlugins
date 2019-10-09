
// DO NOT EDIT THIS BLOCK === configuration starts ===
procedure 'CreateConfiguration', description: 'Creates a plugin configuration', {

    step 'checkConnectionGeneric',
        command: new File(pluginDir, "dsl/procedures/CreateConfiguration/steps/checkConnectionGeneric.groovy").text,
        errorHandling: 'abortProcedure',
        shell: 'ec-groovy',
        condition: '$[/javascript myJob.checkConnection == "true"]'


    step 'createConfiguration',
        command: new File(pluginDir, "dsl/procedures/CreateConfiguration/steps/createConfiguration.pl").text,
        errorHandling: 'abortProcedure',
        exclusiveMode: 'none',
        postProcessor: 'postp',
        releaseMode: 'none',
        shell: 'ec-perl',
        timeLimitUnits: 'minutes'

    property 'ec_checkConnection', value: ''
// DO NOT EDIT THIS BLOCK === configuration ends, checksum: 5a7ab0ec556cc89190941f496f1191b0 ===
}
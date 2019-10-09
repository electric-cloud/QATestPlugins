// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Get Test Case', description: 'The gettign the Test Case from Test Rail as JSON', {

    step 'Get Test Case', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetTestCase/steps/GetTestCase.groovy").text
        shell = 'ec-groovy -cp "$[/server/settings/pluginsDirectory]/QA-GroovyTestRail-1.0.0.0/agent/deps/lib/flowpdf-groovy-lib-1.0.0-SNAPSHOT.jar"'
        
    }

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail, if exist'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: bf256b813fefc0bb8a460587429f7b3c ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
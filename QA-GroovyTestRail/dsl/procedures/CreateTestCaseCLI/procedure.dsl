// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Create Test Case CLI', description: 'The procedure take a JSON and import it to Test Rail as Test Case via CLI', {

    step 'Create Test Case CLI', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/CreateTestCaseCLI/steps/CreateTestCaseCLI.groovy").text
        shell = 'ec-groovy -cp "$[/server/settings/pluginsDirectory]/QA-GroovyTestRail-1.0.0.0/agent/deps/lib/flowpdf-groovy-lib-1.0.0-SNAPSHOT.jar"'
    }

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail'

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 45d0e7ed0e1143e292b335806c5917f4 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Update Test Case', description: 'The procedure take a JSON and update Case in Test Rail', {

    step 'Update Test Case', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/UpdateTestCase/steps/UpdateTestCase.groovy").text
        shell = 'ec-groovy -cp "$[/server/settings/pluginsDirectory]/QA-GroovyTestRail-1.0.0.0/agent/deps/lib/flowpdf-groovy-lib-1.0.0-SNAPSHOT.jar"'

    }

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail'

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 1acf7e754ec23ebc65c29d5b060fa302 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
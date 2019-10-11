// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Create Test Case', description: 'The procedure take a JSON and import it to Test Rail as Test Case', {

    step 'Create Test Case', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/CreateTestCase/steps/CreateTestCase.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail, if exist'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: b8639d805562722d9c6b233f477887da ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
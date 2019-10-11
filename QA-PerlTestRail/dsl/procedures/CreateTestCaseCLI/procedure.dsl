// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Create Test Case CLI', description: 'The procedure take a JSON and import it to Test Rail as Test Case via CLI', {

    step 'Create Test Case CLI', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/CreateTestCaseCLI/steps/CreateTestCaseCLI.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail'

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: a9376412a9315b5170d2ae239bc1cc50 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
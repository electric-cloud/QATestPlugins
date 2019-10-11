// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Update Test Case CLI', description: 'The procedure take a JSON and update Case in Test Rail via CLI', {

    step 'Update Test Case CLI', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/UpdateTestCaseCLI/steps/UpdateTestCaseCLI.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail'

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 92a9678b23ea0e0be24a051f2a011a64 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
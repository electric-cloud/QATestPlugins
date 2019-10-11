// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Get Test Case CLI', description: 'The getting the Test Case from Test Rail as JSON via CLI', {

    step 'Get Test Case CLI', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetTestCaseCLI/steps/GetTestCaseCLI.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail, if exist'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 5225faa600cd1f173a6b90bb857e6bec ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
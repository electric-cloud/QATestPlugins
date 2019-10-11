// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Get Test Case', description: 'he getting the Test Case from Test Rail as JSON', {

    step 'Get Test Case', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetTestCase/steps/GetTestCase.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail, if exist'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: e5ef5f700fade35af55837d3059ed69c ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
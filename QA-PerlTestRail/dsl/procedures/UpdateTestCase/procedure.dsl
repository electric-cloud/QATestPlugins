// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Update Test Case', description: 'The procedure take a JSON and update Case in Test Rail', {

    step 'Update Test Case', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/UpdateTestCase/steps/UpdateTestCase.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail, if exist'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: a88bba84de6ec0a42fbff720a0553f6a ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
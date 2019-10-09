// This procedure.dsl was generated automatically
// === procedure_autogen starts ===
procedure 'Get Test Case CLI', description: 'The getting the Test Case from Test Rail as JSON via CLI', {

    step 'Get Test Case CLI', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetTestCaseCLI/steps/GetTestCaseCLI.pl").text
        shell = 'ec-perl'

        }

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail, if exist'
// === procedure_autogen ends, checksum: 59cb0a77989d94dce915f5f401b97b0d ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
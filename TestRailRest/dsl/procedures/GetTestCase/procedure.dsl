// This procedure.dsl was generated automatically
// === procedure_autogen starts ===
procedure 'Get Test Case', description: 'The gettign the Test Case from Test Rail as JSON', {

    step 'Get Test Case', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/GetTestCase/steps/GetTestCase.pl").text
        shell = 'ec-perl'

        }

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail, if exist'
// === procedure_autogen ends, checksum: 5fdd0882d1f7886075508b01abf7da6a ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
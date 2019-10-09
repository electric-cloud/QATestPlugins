// This procedure.dsl was generated automatically
// === procedure_autogen starts ===
procedure 'Create Test Case', description: 'The procedure take a JSON and import it to Test Rail as Test Case', {

    step 'Create Test Case', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/CreateTestCase/steps/CreateTestCase.pl").text
        shell = 'ec-perl'

        }

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail'

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'
// === procedure_autogen ends, checksum: 337fdf6b1a0c1e14dc9b5036e55b030e ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
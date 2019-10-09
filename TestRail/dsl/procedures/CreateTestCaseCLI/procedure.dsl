// This procedure.dsl was generated automatically
// === procedure_autogen starts ===
procedure 'Create Test Case CLI', description: 'The procedure take a JSON and import it to Test Rail as Test Case via CLI', {

    step 'Create Test Case CLI', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/CreateTestCaseCLI/steps/CreateTestCaseCLI.pl").text
        shell = 'ec-perl'

        }

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail'

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'
// === procedure_autogen ends, checksum: 9a104f2f6adea9da55dbd541bc0239e5 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
// This procedure.dsl was generated automatically
// === procedure_autogen starts ===
procedure 'Update Test Case CLI', description: 'The procedure take a JSON and update Case in Test Rail via CLI', {

    step 'Update Test Case CLI', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/UpdateTestCaseCLI/steps/UpdateTestCaseCLI.pl").text
        shell = 'ec-perl'

        }

    formalOutputParameter 'caseId',
        description: 'Id of created/updated test case on TestRail'

    formalOutputParameter 'caseJSON',
        description: 'case as JSON'
// === procedure_autogen ends, checksum: d7477e2078b5d61d91483713654476d3 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}
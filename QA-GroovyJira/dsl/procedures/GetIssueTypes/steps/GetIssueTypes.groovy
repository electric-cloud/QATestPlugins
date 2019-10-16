$[/myProject/scripts/preamble.groovy]

QAGroovyJira plugin = new QAGroovyJira()
plugin.runStep('Get Issue Types', 'Get Issue Types', 'getIssueTypes')

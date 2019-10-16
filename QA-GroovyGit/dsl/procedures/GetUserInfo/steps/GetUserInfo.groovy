$[/myProject/scripts/preamble.groovy]

QAGroovyGit plugin = new QAGroovyGit()
plugin.runStep('Get User Info', 'Get User Info', 'getUserInfo')

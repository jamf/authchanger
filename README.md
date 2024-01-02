# NoMAD Projects Archived

Jamf has decided to archive the NoMAD repos on GitHub. Going forward they aren’t going to receive any updates. 

While they are read-only, they aren’t being deleted. That means that anyone who wants to fork and use the code is welcome to do so. Everything remains MIT licensed and open source.

The projects are still here and still open source, they just won’t be maintained by Jamf. Any existing issues or PRs have been closed.

You can see the official announcement on the [Jamf Blog](https://www.jamf.com/blog/jamf-to-archive-nomad-open-source-projects/).

There is still an active user community on the [MacAdmins Slack nomad channel](https://macadmins.slack.com/archives/C1Y2Y14QG).

As always, have fun and read the man pages.

macshome

#  authchanger

Authchanger is a utility to help you manage the authorization database used by macOS to determine how the login process progresses.

This utility is used for both the open source NoMAD Login AD and the commercial Jamf Connect Login applications and is typically included with the standard installation of both.


## Options

* -Version        : prints the version number
* -Help | -h      : prints this help statement
* -Reset          : resets the login screen to the factory settings
* -Okta           : sets up NoMAD Login+Okta
* -OIDC           : sets up Jamf Connect Login for Open ID Connect auth
* -AD             : sets up NoMAD LoginAD
* -Demobilize     : sets up the login mechanisms to demobilize the account taking into account any other AD or OIDC setup you are doing
* -Notify         : adds the DEP Notify addition to the corresponding -AD, -OIDC, -Okta, or -Setup argument
* -Print          : prints the current list of authorization mechanisms
* -Debug          : does a dry run of the changes and prints out what would have happened
* -CustomRule ["mechanisms" | "rules"] <Mechs/Rules seperated by spaces>
                  : allows the printout of any authorizationDB rule as well as setting of that rule to any custom mechanism/s

Note: The -CustomRule parameter will change the class the rule from "rule" to "evaluate-mechanism" if necessary, and vice-versa

### Experimental options for working with Admin authorization:

* -SysPrefs       : enables OIDC authentication for the Network Preference Pane
* -SysPrefsReset  : removes OIDC authentication for the Network Preference Pane

### Experimental options for working with sudo authorization:

* -DefaultJCRight : adds the mechanism to be used with the PAM module from Jamf Connect

### In addition to setting basic setups, you can also specify custom rules to be put in.

* -preLogin       : mechs to be used before the actual UI is shown
* -preAuth        : mechs to be used between the login UI and actual authentication
* -postAuth       : mechs to be used after system authentication

## Usage

* authchanger -reset

  Will ensure that the authdb is reset to factory defaults for the following entries:  
    
       system.login.console  
       system.services.systemconfiguration.network  
       system.preferences.network  

* authchanger -print

  Will display the current authdb settings for the following entries:  
    
       system.login.console  
       system.services.systemconfiguration.network  
       system.preferences.network  

* authchanger -CustomRule authenticate -print

  Will print out the current rule for authenticate in the authorization database

* authchanger -CustomRule authenticate mechanisms CustomMechanism:Something AnotherCustomMechanism:Notify -debug

  Will overwrite the authenticate rule mechanism list with the two defined mechanisms and print out the changes it would have made

* authchanger -CustomRule system.login.screensaver rules authenticate-session-owner-or-admin

  Overwrites the system.login.screensaver rule with the defined one. This will also print out the previously set rule for reference

* authchanger -debug -reset -Okta -Notify -preLogin CustomMechanism:Something AnotherCustomMechanism:Notify

  Will reset the authdb then add NoMAD Login+Okta settings as well as the Okta notify mechanism, followed by adding the two custom
  mechanisms before the login window is shown. The -debug flag will show you the resulting output without actually making the change.


## Pull from Defaults - WIP

authchanger should use UserDefaults to look up settings and apply as appropriate. As a CLI app we'll have to init with suite, which might actually work really well as you'll then be able to override from the CLI as necessary.

Current thinking is "com.jamf.connect.authchanger" and "menu.nomad.authchanger" as the default domains.


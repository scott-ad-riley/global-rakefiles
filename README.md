#Rakefiles

All files are split with a namespace, the initial commit contains a 'mt' (Minitest) namespace and some utility functions for it. That file is documented below (so you can do the same with others if you add them).

N.B. If you want to use arguments with rake tasks whilst using the oh-my-zsh terminal - you need to create an alias for the rake task. See here: https://github.com/robbyrussell/oh-my-zsh/issues/433. In short, it means adding a new line with: `alias rake='noglob rake` to your .zshrc file.

##namespace: mt

###setup

* Creates a spec folder, and then creates the required spec files inside of that folder, based off of the models (or files currently sitting in the project root)
* Optionally takes a number of arguments that will be used to create your models
  * Passed in like rake mt:setup[bear,fish,river]

###delete_tests

* Deletes your specs/ folder (just runs rm -rf specs/ inside the task)

###run

* Will loop over each .rb file in your specs folder and run them.

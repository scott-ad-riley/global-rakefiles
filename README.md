#Rakefiles

All files are split with a namespace, the initial commit contains just 'mt' (Minitest) and it's some utility functions for it. That file is documented below (and as will others as they are added).

##namespace: mt

###setup

* Creates a spec folder, and then creates the required spec files inside of that folder, based off of the models (or files currently sitting in the project root)

###delete_tests

* Deletes your specs/ folder (just runs rm -rf specs/ under inside the task)

###run

* Will loop over each .rb file in your specs folder and run them.
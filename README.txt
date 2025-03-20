MultiEditR version 1.1.0

Hello! Welcome to MultiEditR! We hope that our program can be of use for your edit detection and quantification needs. Please note that this is a beta version of the application, and as such aspects of it are still under development.

However, if you are noticing any errors when using the application please feel free to reach out Mitch at klues009@umn.edu for troubleshooting and input on the application.

To run this program online visit this webpage:
https://moriaritylab.shinyapps.io/multieditr

To run this program locally please do the following:

1) Download and install R 4.3 (https://www.r-project.org/)
2) Install renv (install.packages("renv"))
3) Use renv::restore() with the included renv.lock file to install depedencies
4) Determine the directory of the MultiEditR app on your computer. It will look something like this:

/Users/kluesner/Desktop/Research/EditR/multiEditR/program/working_branch/app

4) Copy, paste, and run the following line of code in your R command line, using the specific directory of the MultiEditR app on your computer:

shiny::runApp(“/Users/kluesner/Downloads/MultiEditR-master”)

5) The application should launch and be used interactively

Upon submission of the MultiEditR manuscript to a journal, the web application will be live at https://moriaritylab.shinyapps.io/MultiEditR
